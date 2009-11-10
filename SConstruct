# scons [--prefix=/usr/local] [--libdir=$PREFIX/lib] [--include_soname] install

"""
  Copyright (c) 2009, Barry Schwartz

  Permission to use, copy, modify, and/or distribute this software for
  any purpose with or without fee is hereby granted, provided that the
  above copyright notice and this permission notice appear in all
  copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
  WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
  AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
  DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
  OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
  TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
  PERFORMANCE OF THIS SOFTWARE.
"""

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
env['SONAME_FLAGS'] = ('' if GetOption('include_soname') == None else ' -Wl,-soname=libglyph_name.so.1.1.0 ')
env['CFLAGS'] = Split('-pipe -g -O2')
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
