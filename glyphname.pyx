# -*- coding: utf-8 -*-
#--------------------------------------------------------------------------
# Copyright (c) 2009 Barry Schwartz
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

#--------------------------------------------------------------------------

from python_unicode cimport Py_UNICODE, PyUnicode_FromUnicode

cdef extern from 'glyph_name.h':
    void look_up_glyph_name_in_the_agl(char *glyph_name,
                                       unsigned int *unicode1,
                                       unsigned int *unicode2)

cdef extern from 'string.h':
    size_t strlen(char *s)
    char *strchr(char *s, int c)
    int strncmp(char *s1, char *s2, size_t n)
    char *strcpy(char *dest, char *src)
    void *memcpy(void *dest, void *src, size_t n)

cdef extern from 'stdlib.h':
    unsigned long int strtoul(char *nptr, char **endptr, int base)
    long int strtol(char *nptr, char **endptr, int base)

cdef bint string_is_hex(char *s):
    cdef int i
    i = 0
    while s[i] != 0 and strchr(b'0123456789ABCDEF', s[i]) != NULL:
        i += 1
    return s[i] == 0

cdef match_uni(char *name):
    cdef size_t name_length = strlen(name)
    cdef size_t word_count
    cdef size_t i
    cdef char substring[5]
    cdef Py_UNICODE u

    unicode_string = None

    if (7 <= name_length and
        (name_length - 3) % 4 == 0 and
        strncmp(b'uni', name, 3) == 0 and
        string_is_hex(name + 3)):

        word_count = (name_length - 3) // 4;
        unicode_string = ''
        i = 0
        while unicode_string != None and i < word_count:
            memcpy(substring, name + 3 + (4 * i), 4)
            substring[4] = 0
            u = <Py_UNICODE> strtoul(substring, NULL, 16)
            if (0x0000 <= u and u <= 0xD7FF) or (0xE000 <= u and u <= 0xFFFF):
                unicode_string += PyUnicode_FromUnicode(&u, 1)
            else:
                unicode_string = None
            i += 1

    return unicode_string

cdef match_u(char *name):
    cdef size_t name_length = strlen(name)
    cdef long int value
    cdef Py_UNICODE u

    unicode_string = None

    if (5 <= name_length and name_length <= 7 and
        name[0] == 'u' and string_is_hex(name + 1)):

        value = strtol(name + 1, NULL, 16)
        if ((0x0000 <= value and value <= 0xD7FF) or
            (0xE000 <= value and value <= 0xFFFF) or
            (0x10000 <= value and value <= 0x10FFFF)):

            u = <Py_UNICODE> value
            unicode_string = PyUnicode_FromUnicode(&u, 1)

    return unicode_string

cdef match_agl(char *name):
    cdef unsigned int unicode1
    cdef unsigned int unicode2
    cdef Py_UNICODE u[2]

    unicode_string = None

    look_up_glyph_name_in_the_agl(name, &unicode1, &unicode2);
    if unicode2 != 0:
        u[0] = <Py_UNICODE> unicode1
        u[1] = <Py_UNICODE> unicode2
        unicode_string = PyUnicode_FromUnicode(u, 2)
    elif unicode1 != 0:
        u[0] = <Py_UNICODE> unicode1
        unicode_string = PyUnicode_FromUnicode(u, 1)

    return unicode_string

cdef char *dotless_copy(char *s):
    cdef size_t i = 0
    while s[i] != 0 and s[i] != b'.':
        i += 1
    copy = b''.ljust(i)
    memcpy(<char *> copy, s, i)
    return copy

cpdef glyph_name_to_unicode(char *name):
    cdef char *p
    cdef char *q

    unicode_string = ''

    if name != NULL:
        dotless_name = dotless_copy(name)
        p = <char *> dotless_name
        while p[0] != 0:
            q = strchr(p, b'_')
            if q != NULL:
                q[0] = 0
            uni = match_agl(p)
            if not uni:
                uni = match_uni(p)
            if not uni:
                uni = match_u(p)
            if uni:
                unicode_string += uni
            if q != NULL:
                p = q + 1
            else:
                p = <char *> b''

    return unicode_string

#--------------------------------------------------------------------------

# names = [
#     b".notdef",
#     b"uni0000",
#     b"uni1234_u10000",
#     b"u10FFFD_uni1234_u10000",
#     b"uniABCD_uniABCD.sc",
#     b"uniABCDABCD.sc",
#     b"uniABCDAABCD.sc",
#     b"f_f_uni9999",
#     b"omicron",
#     b"dalettserehebrew_uniABCD.001",
#     b"uniABCD_dalettserehebrew.001",
#     b"f_f_l",
#     ]
# 
# for n in names:
#     print(n, repr(glyph_name_to_unicode(n)))

#--------------------------------------------------------------------------
