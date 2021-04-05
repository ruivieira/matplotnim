[![CI](https://github.com/ruivieira/matplotnim/actions/workflows/test.yml/badge.svg)](https://github.com/ruivieira/matplotnim/actions/workflows/test.yml) [![builds.sr.ht status](https://builds.sr.ht/~ruivieira/matplotnim/commits/.build.yml.svg)](https://builds.sr.ht/~ruivieira/matplotnim/commits/.build.yml?)

# matplotnim

A Nim wrapper for matplotlib.

## 🔮 v0.2.0 and the Future

Most of `v0.1.0` is now deprecated and redundant with the creation of
the great [`nimpy`](https://github.com/yglukhov/nimpy).
With `nimpy` (almost) all of the constructs of `matplotlib` can now
be called directly.

Nevertheless, I will keep this package for two reasons:

1. Hopefully it will serve as a learning resource, with examples, on how to call
   `matplotlib` using `nimpy`
2. Some complex plots can be very verbose (not Nim's fault, by the way) and this
   will be a package aiming at providing premade templates for such plots.

## Features

- Line plots
- Scatter plots
- Histograms (and KDE denisty plots)
- Line segments
- Axis (horizontal and vertical) lines
- Font customisation
- Annotations
- Custom size and DPI
- Sub-plots
- Horizontal and vertical limits
- Custom markers

## Examples

Examples can be found [here](docs/README.md).

## Contributing

- Fork it (https://github.com/ruivieira/matplotnim)
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create a new Pull Request

## mailing lists

- Announcements: [https://lists.sr.ht/~ruivieira/nim-announce](https://lists.sr.ht/~ruivieira/nim-announce)
- Discussion: [https://lists.sr.ht/~ruivieira/nim-discuss](https://lists.sr.ht/~ruivieira/nim-discuss)
- Development: [https://lists.sr.ht/~ruivieira/nim-devel](https://lists.sr.ht/~ruivieira/nim-devel)

Please prefix the subject with `[matplotnim]`.
