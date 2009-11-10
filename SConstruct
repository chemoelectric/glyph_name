# scons [--prefix=/usr/local] [--libdir=$PREFIX/lib] install

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

env = Environment()

env['PREFIX'] = ('/usr/local' if GetOption('prefix') == None else GetOption('prefix'))
env['LIBDIR'] = ('$PREFIX/lib' if GetOption('libdir') == None else GetOption('libdir'))
env['CFLAGS'] = Split('-pipe -g -O2')
env['M4FLAGS'] = Split('-DGLYPHLIST=glyphlist.txt')

usr_lib = '$LIBDIR'
usr_include = '$PREFIX/include'

env.M4('agl_lookup.c.m4')
static_lib = env.StaticLibrary('glyph_name', ['glyph_name.c', 'agl_lookup.c'])
shared_lib = env.SharedLibrary('glyph_name', ['glyph_name.c', 'agl_lookup.c'])

env.Install(usr_lib, [static_lib, shared_lib])
env.Install(usr_include, 'glyph_name.h')
env.Alias('install', [usr_lib, usr_include])


# local variables:
# mode: python
# python-indent: 4
# end:
