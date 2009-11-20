# scons [--prefix=/usr/local] [--libdir=$PREFIX/lib] [--include_soname] install

"""
Copyright (c) 2009 Barry Schwartz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

import os

AddOption('--prefix',
          dest='prefix',
          type='string',
          nargs=1,
          action='store',
          metavar='DIR',
          help='installation prefix')
AddOption('--libdir',
          dest='libdir',
          type='string',
          nargs=1,
          action='store',
          metavar='DIR',
          help='installation library directory')
AddOption('--include_soname',
          nargs=0,
          help='include an soname in the shared library')

env = Environment()

env['PREFIX'] = ('/usr/local' if GetOption('prefix') == None else GetOption('prefix'))
env['LIBDIR'] = ('$PREFIX/lib' if GetOption('libdir') == None else GetOption('libdir'))
env['SONAME_FLAGS'] = ('' if GetOption('include_soname') == None else ' -Wl,-soname=libglyph_name.so.1.2 ')

cflags = os.getenv('CFLAGS')
if cflags:
    env['CFLAGS'] = Split(cflags)

env['M4FLAGS'] = Split('-DGLYPHLIST=glyphlist.txt')

usr_lib = '$LIBDIR'
usr_include = '$PREFIX/include'

env.M4('agl_lookup.c.m4')
static_lib = env.StaticLibrary('glyph_name', ['glyph_name.c', 'agl_lookup.c'])
shared_lib = env.SharedLibrary('glyph_name', ['glyph_name.c', 'agl_lookup.c'],
                               LINKFLAGS = env['LINKFLAGS'] + env['SONAME_FLAGS'])

env.Install(usr_lib, [static_lib, shared_lib])
env.Install(usr_include, 'glyph_name.h')
env.Alias('install', [usr_lib, usr_include])


# local variables:
# mode: python
# python-indent: 4
# end:
