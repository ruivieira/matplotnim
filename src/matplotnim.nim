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

proc save*(figure: Figure, dest: string) =
  var script = newSeq[string]()
  script.add "import matplotlib"
  script.add "matplotlib.use('Agg')"
  script.add "from matplotlib import rc"
  script.add "import matplotlib.pyplot as plt"
  script.add "from matplotlib.lines import Line2D"
  # script.add "rc('font', **{'family': '#{@font.family}', 'serif': '#{@font.styles.to_s}'})"
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
  Figure(python: "/usr/local/bin/python3", script: newSeq[string](), latex: false)

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
  x*: seq[A]
  y*: seq[B]
method render[A,B](this: ScatterPlot[A,B]): string =
  let xs = makeList(this.x)
  let ys = makeList(this.y)
  var options: seq[string] = @[]
  if this.colour!="":
    options.add fmt"color='{this.colour}'"
  if len(options)>0:
    let optstr = options.join(",")
    return fmt"plt.scatter({xs},{ys},{optstr})"
  else:
    return fmt"plt.scatter({xs},{ys})"

proc newScatterPlot*[A,B](x: seq[A], y: seq[B]): ScatterPlot[A, B] =
  ScatterPlot[A, B](colour: "",  x: x, y: y)
    
