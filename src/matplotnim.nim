import strutils
import sequtils
import strformat
import tempfile
import os

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

type LinePlot[A, B] = ref object of Plot
  linestyle*: string
  x*: seq[A]
  y*: seq[B]
method render[A,B](this: LinePlot[A,B]): string =
  let xs = this.x.map(proc(k:A):string = $k).join(",")
  let ys = this.y.map(proc(k:B):string = $k).join(",")
  return fmt"plt.plot([{xs}],[{ys}])"

proc newLinePlot*[A,B](x: seq[A], y: seq[B]): LinePlot[A, B] =
  LinePlot[A, B](linestyle: "-", x: x, y: y)
