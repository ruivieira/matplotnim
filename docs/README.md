# examples

## plot types

### line, scatter with defaults

```nim
let figure = newFigure()
figure.add newLinePlot[int,float](@[1, 2, 3, 4], @[5.5, 7.6, 11.1, 6.5])
```

![plot](lineplot_default.png)

### line, scatter with options

```nim
let figure2 = newFigure()
let lp = newLinePlot[int,float](x, y)
lp.linestyle = "--"
lp.colour = "red"
figure2.add lp
let sp = newScatterPlot[int,float](x, y)
sp.colour = "green"
figure2.add sp
```

![plot](scatterplot_default.png)

Custom markers:

```nim
sp.marker = "*"
figure2.save("docs/marker.png")
```

![plot](marker.png)
