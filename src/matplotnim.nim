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
    plots*: seq[Plot]
    font*: tuple[family: string, style: string]

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
  for p in figure.plots:
    script.add p.render
  script.add fmt"plt.savefig('{dest}', format='png', transparent=False)"
  let script_str = script.join("\n")
  # get the temporary file
  var (file, name) = mkstemp(suffix = ".py")
  writeFile(name, script_str)
  echo name
  discard execShellCmd fmt"/usr/local/bin/python3 {name}"


  
proc newFigure*(): Figure =
  Figure(python: "/usr/local/bin/python3", 
         script: newSeq[string](), 
         latex: false,
         font: ("", ""))

proc add*(figure: Figure, plot: Plot) =
  figure.plots.add plot

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

# Line segments
type Line[A,B] = ref object of Plot
  p0*: tuple[x: A, y: B]
  p1*: tuple[x: A, y: B]
  linestyle*: string
  colour*: string
method render[A,B](this: Line[A,B]): string =
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
method render[A](this: HorizontalLine[A]): string =
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
