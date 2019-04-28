import "../src/matplotnim"
import "../../nim-science/science/Distributions"
import sequtils
import math
import strformat

let x = @[1, 2, 3, 4]
let y = @[5.5, 7.6, 11.1, 6.5]

let figure = newFigure()
figure.add newLinePlot[int,float](x, y)
figure.save("docs/lineplot_default.png")

let figure2 = newFigure()
let lp = newLinePlot[int,float](x, y)
lp.linestyle = "--"
lp.colour = "red"
figure2.add lp
let sp = newScatterPlot[int,float](x, y)
sp.colour = "green"
figure2.add sp
figure2.save("docs/scatterplot_default.png")

sp.marker = "*"
figure2.save("docs/marker.png")

let samples = rnorm(1000, 0.0, 2.0)
let figure3  =newFigure()
let hist = newHistogram[float] samples
figure3.add hist
figure3.save "docs/hist_default.png"

hist.bins = 200
figure3.save "docs/hist_bins.png"

let figure4 = newFigure()
let x4 = toSeq(0..100)
let y4 = x4.map(proc(k:int):float = float(k).pow(2.0))
let lp4 = newLinePlot(x4, y4)
figure4.add lp4
let line = newLine((2, 4.0),(70, 70.0.pow(2.0)))
figure4.add line
figure4.save("docs/line_segment.png")

lp4.colour = "black"
line.colour = "red"
line.linestyle = "--"
figure4.save("docs/line_segment_colour.png")

let figure5 = newFigure()
let x5 = toSeq(0..1000)
let y5 = x5.map(func(k:int):float = sin(float(k) / 50.0))
figure5.font = ("monospace", "Courier New")
let lp5 = newLinePlot(x5, y5)
lp5.colour = "red"
figure5.add lp5
figure5.add newTitle("A plot with a title (in Courier New).")
figure5.save("docs/plot_title.png")

let figure6 = newFigure()
let x6 = toSeq(0..1000)
let y6 = x5.map(func(k:int):float = sin(float(k) / 50.0))
let lp6 = newLinePlot(x5, y5)
lp6.colour = "red"
figure6.add lp6
let hl6 = newHorizontalLine(0)
hl6.linestyle = "--"
hl6.colour = "black"
figure6.add hl6
for i in 0..6:
    let vl6 = newVerticalLine(PI * float(i) * 50.0)
    vl6.linestyle = "-."
    vl6.colour = "blue"
    figure6.add vl6
figure6.save("docs/plot_hv_lines.png")

### annotations
let figure7 = newFigure()
figure7.latex = true
let x7 = @[1, 2, 3, 4]
let y7 = @[5.5, 7.6, 11.1, 6.5]
let lp7 = newScatterPlot(x7, y7)
figure7.add lp7
for i in 0..2:
    let ann7 = newAnnotation(float(x7[i]) + 0.1, y7[i] + 0.1, &"$p_{i}$")
    figure7.add ann7
figure7.save("docs/annotation.png")

# dpi
figure6.size = (20.0, 2.0)
figure6.dpi = 180
figure6.save("docs/custom_size.png")

# multiple plots
let figure8 = newFigure()
figure8.grid = (rows: 1, cols: 2)
figure8.size = (8.0, 4.0)
figure8.add newLinePlot[int,float](x, y)
figure8.subplot
figure8.add lp6
figure8.add hl6
for i in 0..6:
    let vl6 = newVerticalLine(PI * float(i) * 50.0)
    vl6.linestyle = "-."
    vl6.colour = "blue"
    figure8.add vl6
figure8.save("docs/side_by_side.png")