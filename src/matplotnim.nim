import strutils
import sequtils
import strformat
import tempfile
import os

func numberToStr[T](data: seq[T]): seq[string] = data.map(proc(k:T):string = $k)

func makeList[T](data: seq[T]): string = 
  let str = numberToStr(data).join(",")
  return fmt"[{str}]"

type Plot = ref object of RootObj
method render(this: Plot): string {.base.} = ""

type 
  Figure = ref object of RootObj
    python*: string
    script*: seq[string]
    latex*: bool
    plots*: seq[seq[Plot]]
    font*: tuple[family: string, style: string]
    dpi*: int
    size*: tuple[w: float, h: float]
    grid*: tuple[rows: int, cols: int]
    index: int

proc save*(figure: Figure, dest: string) =
  var script = newSeq[string]()
  script.add "import matplotlib"
  script.add "matplotlib.use('Agg')"
  script.add "from matplotlib import rc"
  script.add "import matplotlib.pyplot as plt"
  script.add "from matplotlib.lines import Line2D"
  if figure.font.family!="":
    script.add "rc('font', **{'family': '" & figure.font.family & "', 'serif': '" & figure.font.style & "'})"
  let latex_str = if figure.latex: "True" else: "False"
  script.add fmt"rc('text', usetex={latex_str})"
  script.add "matplotlib.rcParams['text.latex.unicode']=True"
  if figure.size.w > 0.0:
    script.add &"fig = plt.figure(figsize=({figure.size.w},{figure.size.h}))"
  else:
    script.add "fig = plt.figure()"
  for i in 0..<len(figure.plots):
    echo &"i = {i}"
    echo &"plt.subplot({figure.grid.rows}, {figure.grid.cols}, {i+1})"
    script.add &"plt.subplot({figure.grid.rows}, {figure.grid.cols}, {i+1})"
    let plots = figure.plots[i]
    echo &"#plots = {len(plots)}"
    for j in 0..<len(plots):
      echo &"j = {j}"
      script.add plots[j].render
  if figure.dpi > 0:
    script.add fmt"plt.savefig('{dest}', format='png', transparent=False, dpi={figure.dpi})"
  else:
    script.add fmt"plt.savefig('{dest}', format='png', transparent=False)"
  let script_str = script.join("\n")
  # get the temporary file
  var (file, name) = mkstemp(suffix = ".py")
  echo name
  writeFile(name, script_str)
  echo name
  discard execShellCmd fmt"/usr/local/bin/python3 {name}"
  
proc newFigure*(): Figure =
  Figure(python: "/usr/local/bin/python3", 
         script: newSeq[string](), 
         latex: false,
         font: ("", ""),
         dpi: 0,
         size: (0.0, 0.0),
         grid: (1, 1),
         index: 0,
         plots: @[])

proc add*(figure: Figure, plot: Plot) =
  if len(figure.plots)==0:
    figure.plots.add @[]
  echo &"Add plot to {figure.index}"
  figure.plots[figure.index].add plot

proc subplot*(figure: Figure) =
  figure.plots.add @[]
  figure.index += 1
  
# Line plots
type LinePlot[A, B] = ref object of Plot
  linestyle*: string
  colour*: string
  x*: seq[A]
  y*: seq[B]
method render[A,B](this: LinePlot[A,B]): string =
  let xs = makeList(this.x)
  let ys = makeList(this.y)
  var options: seq[string] = @[]
  if this.linestyle!="":
    options.add fmt"linestyle='{this.linestyle}'"
  if this.colour!="":
    options.add fmt"color='{this.colour}'"
  if len(options)>0:
    let optstr = options.join(",")
    return fmt"plt.plot({xs},{ys},{optstr})"
  else:
    return fmt"plt.plot({xs},{ys})"

proc newLinePlot*[A,B](x: seq[A], y: seq[B]): LinePlot[A, B] =
  LinePlot[A, B](linestyle: "", colour: "",  x: x, y: y)

# Scatter plots
type ScatterPlot[A,B] = ref object of Plot
  colour*: string
  marker*: string
  x*: seq[A]
  y*: seq[B]
method render[A,B](this: ScatterPlot[A,B]): string =
  let xs = makeList(this.x)
  let ys = makeList(this.y)
  var options: seq[string] = @[]
  if this.colour!="":
    options.add fmt"color='{this.colour}'"
  if this.marker!="":
    options.add fmt"marker='{this.marker}'"
  if len(options)>0:
    let optstr = options.join(",")
    return fmt"plt.scatter({xs},{ys},{optstr})"
  else:
    return fmt"plt.scatter({xs},{ys})"

proc newScatterPlot*[A,B](x: seq[A], y: seq[B]): ScatterPlot[A, B] =
  ScatterPlot[A, B](colour: "",  x: x, y: y)

# Histogram
type Histogram[A] = ref object of Plot
  x*:seq[A]
  bins*: int
method render[A](this: Histogram[A]): string =
  let xs = makeList(this.x)  
  var options: seq[string] = @[]
  if this.bins>0:
    options.add fmt"bins={this.bins}"
  if len(options)>0:
    let optstr = options.join(",")
    return fmt"plt.hist({xs},{optstr})"
  else:
    return fmt"plt.hist({xs})"

proc newHistogram*[A](x: seq[A]): Histogram[A] =
  Histogram[A](bins: 0,  x: x)

type Density[A] = ref object of Plot
  x*:seq[A]
  steps*: int
method render[A](this: Density[A]): string =
  let xs = makeList(this.x)

  var s: seq[string] = @[]
  s.add("from scipy import stats")
  s.add("import numpy as np")
  s.add(fmt"_data = {xs}")
  let x_max = foldr(this.x, max(a, b))
  let x_min = foldr(this.x, min(a, b))
  
  let steps = abs(x_max - x_min) / float(this.steps)
  s.add("_density = stats.kde.gaussian_kde(_data)")
  echo fmt"x_max = {x_max}, x_min = {x_min}, steps = {steps}"
  s.add(fmt"_x = np.arange({x_min}, {x_max}, {steps})")

  s.add("plt.plot(_x, _density(_x))")

  return s.join("\n")

proc newDensity*[A](x: seq[A]): Density[A] =
  Density[A](steps: 100,  x: x)
  

# Line segments
type Line[A,B] = ref object of Plot
  p0*: tuple[x: A, y: B]
  p1*: tuple[x: A, y: B]
  linestyle*: string
  colour*: string
method render[A,B](this: Line[A,B]): string {.locks: 0.} =
  var options: seq[string] = @[]
  if this.linestyle!="":
    options.add fmt"linestyle='{this.linestyle}'"
  if this.colour!="":
    options.add fmt"color='{this.colour}'"
  if len(options)>0:
    let optstr = options.join(",")
    return fmt"ax = plt.gca(){'\n'}ax.add_line(Line2D([{this.p0.x},{this.p1.x}],[{this.p0.y},{this.p1.y}], {optstr}))"
  else:
    return fmt"ax = plt.gca(){'\n'}ax.add_line(Line2D([{this.p0.x},{this.p1.x}],[{this.p0.y},{this.p1.y}]))"

proc newLine*[A,B](ps: tuple[x: A, y: B], pe: tuple[x: A, y: B]): Line[A, B] =
  Line[A,B](p0: ps, p1: pe, linestyle: "", colour: "")

# Title
type Title = ref object of Plot
  title*: string
method render(this: Title): string = fmt"plt.title(r'{this.title}')"

proc newTitle*(title: string): Title = Title(title: title)

# Horizontal line
type HorizontalLine[A] = ref object of Plot
  y*: A
  linestyle*: string
  colour*: string
method render[A](this: HorizontalLine[A]): string {.locks: 0.} =
  var options: seq[string] = @[]
  if this.linestyle!="":
    options.add fmt"linestyle='{this.linestyle}'"
  if this.colour!="":
    options.add fmt"color='{this.colour}'"
  if len(options)>0:
    let optstr = options.join(",")
    return fmt"plt.axhline(y={this.y}, {optstr})"
  else:
    return fmt"plt.axhline(y={this.y})"

proc newHorizontalLine*[A](y: A): HorizontalLine[A] =
  HorizontalLine[A](y: y, linestyle: "", colour: "")

# Vertical line
type VerticalLine[A] = ref object of Plot
  x*: A
  linestyle*: string
  colour*: string
method render[A](this: VerticalLine[A]): string =
  var options: seq[string] = @[]
  if this.linestyle!="":
    options.add fmt"linestyle='{this.linestyle}'"
  if this.colour!="":
    options.add fmt"color='{this.colour}'"
  if len(options)>0:
    let optstr = options.join(",")
    return fmt"plt.axvline(x={this.x}, {optstr})"
  else:
    return fmt"plt.axvline(x={this.x})"

proc newVerticalLine*[A](x: A): VerticalLine[A] =
  VerticalLine[A](x: x, linestyle: "", colour: "")

# Annotations
type Annotation[A,B] = ref object of Plot
  x*: A
  y*: B
  text*: string
  colour*: string
method render[A,B](this: Annotation[A,B]): string =
  var options: seq[string] = @[]
  if this.colour!="":
    options.add fmt"color='{this.colour}'"
  if len(options)>0:
    let optstr = options.join(",")
    return &"ax=plt.gca()\nax.annotate('{this.text}', xy=({this.x}, {this.y}), {optstr})"
  else:
    return &"ax=plt.gca()\nax.annotate('{this.text}', xy=({this.x}, {this.y}))"

proc newAnnotation*[A,B](x: A, y: B, text: string): Annotation[A,B] =
  Annotation[A,B](x: x, y: y, text: text, colour: "")

# Limits
type XLimit[A] = ref object of Plot
  min: A
  max: A
method render[A](this: XLimit[A]): string =
  return &"ax=plt.gca()\nax.set_xlim([{this.min},{this.max}])"

proc newXLimit*[A](min: A, max: A): XLimit[A] = 
  XLimit[A](min: min, max: max)

type YLimit[A] = ref object of Plot
  min: A
  max: A
method render[A](this: YLimit[A]): string =
  return &"ax=plt.gca()\nax.set_ylim([{this.min},{this.max}])"

proc newYLimit*[A](min: A, max: A): YLimit[A] = 
  YLimit[A](min: min, max: max)