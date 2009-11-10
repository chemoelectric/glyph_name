#!/usr/bin/env python

from distutils.core import setup, Extension

glyph_name_module = Extension('_glyph_name',
                              sources = ['glyph_name_wrap.c'],
                              library_dirs = ['/home/trashman/lib64'],
                              libraries = ['glyph_name'],
                              )

setup (name = 'example',
       version = '1.0',
       description = 'Glyph name processing using the Adobe Glyph List',
       ext_modules = [glyph_name_module],
       py_modules = ['glyph_name'],
       )
