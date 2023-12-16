#!/usr/bin/env python-3.10-ibdsel

from matplotlib.axes import Axes


_old_axes_init = Axes.__init__


def _new_axes_init(self, *a, **kw):
    _old_axes_init(self, *a, **kw)
    # https://matplotlib.org/stable/gallery/misc/zorder_demo.html
    # 3 => leave text and legends vectorized
    self.set_rasterization_zorder(3)


def rasterize_plots():
    Axes.__init__ = _new_axes_init


def vectorize_plots():
    Axes.__init__ = _old_axes_init
