import "../src/matplotnim"

let figure = newFigure()
figure.add newLinePlot[int,float](@[1, 2, 3, 4], @[5.5, 7.6, 11.1, 6.5])
figure.save("docs/lineplot_default.png")