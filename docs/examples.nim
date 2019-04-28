import "../src/matplotnim"

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