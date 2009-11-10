#!/usr/bin/python

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

import sys
from string import split, strip

#--------------------------------------------------------------------------

def read_glyph_list(f = sys.stdin):
    glyph_list = []
    for s in f:
        s = strip(s)
        if s[0] != '#':
            (key, value) = split(s, ';')
            glyph_list.append((key, value))
    return glyph_list


def find_longest_glyph_name(f = sys.stdin):
    count = 0
    for s in f:
        s = strip(s)
        if s[0] != '#':
            (key, _) = split(s, ';')
            count = max(count, len(key))
    return count

#--------------------------------------------------------------------------

def add_to_trie(key, value, trie):
    if trie == None:
        trie = [None, {}]
    if len(key) != 0:
        if key[0] not in trie[1]:
            trie[1][key[0]] = [None, {}]
            trie = add_to_trie(key, value, trie)
        elif len(key) == 1:
            trie[1][key][0] = value
        else:
            add_to_trie(key[1:], value, trie[1][key[0]])
    return trie

def join_two_keys(key, trie):
    k = trie[key][1].keys()[0]
    trie[key + k] = trie[key][1][k]
    del trie[key]
    return key + k

def join_keys(trie):
    """
    Space optimization by joining some keys into strings.
    """
    key_list = trie[1].keys()
    for key in key_list:
        while trie[1][key][0] == None and len(trie[1][key][1]) == 1:
            key = join_two_keys(key, trie[1])
        join_keys(trie[1][key])

def make_trie(pairs):
    trie = None
    for (key, value) in pairs:
        trie = add_to_trie(key, value, trie)
    join_keys(trie)             # This is optional.
    return trie

def search_trie(key, trie):
    if key == '':
        if trie[0] != None:
            return trie[0]
        else:
            raise KeyError
    else:
        key_list = trie[1].keys()
        for k in key_list:
            # len(k) always is 1 if you don't use join_keys().
            if key[:len(k)] == k:
                return search_trie(key[len(k):], trie[1][k])
    raise KeyError

def test_trie():
    glyph_list = read_glyph_list()
    trie = make_trie(glyph_list)
    for (glyph_name, code_point) in glyph_list:
        if search_trie(glyph_name, trie) != code_point:
            print "WOOPS!"
    print "Done"

#--------------------------------------------------------------------------

def pack_integer(n):
    """
    Packs an integer into a string that contains no null characters
    and has the high bit set in all but the last character.
    """
    if n < 0x7F:
        return chr(n + 1)
    else:
        return chr((n % 0x7F) + 0x80) + pack_integer(n / 0x7F)

def unpack_integer(s, i = 0):
    if ord(s[i]) <= 0x7F:
        n = ord(s[i]) - 1
        i = i + 1
    else:
        the_rest = unpack_integer(s, i + 1)
        n = ((ord(s[i]) - 1) % 0x7F) + (0x7F * the_rest[0])
        i = the_rest[1]

    return (n, i)

def skip_packed_integer(s, i):
    while ord(s[i]) & 0x80 != 0:
        i = i + 1
    return i + 1

#--------------------------------------------------------------------------

def mark_end_of_string(s):
    return s[:-1] + chr(ord(s[-1]) | 0x80)

def convert_value(v):
    v = split(v)
    val = int(v[0], 16)
    if len(v) == 2:
        val = val + (int(v[1], 16) << 16)
    return val

def pack_trie(trie):
    """
    Packs the trie into a string 46816 bytes long.
    """

    value = trie[0]
    subtries = trie[1]

    if value == None:
        s = pack_integer(0)
    else:
        s = pack_integer(convert_value(value))

    k = sorted(subtries.keys())
    for i in range(0, len(k)):
        s = s + mark_end_of_string(k[i])
        sub = pack_trie(subtries[k[i]])
        if i == len(k) - 1:
            s = s + pack_integer(0)
        else:
            s = s + pack_integer(len(sub))
        s = s + sub

    return s

def look_for_match(word, trie, i):
    j = 0
    while ord(trie[i + j]) & 0x80 == 0:
        j = j + 1
    key = trie[i:i + j] + chr(ord(trie[i + j]) & 0x7F)
    if key == word[0:j + 1]:
        return (True, word[j + 1:], i + j + 1)
    else:
        return (False, word, i)    

def search_packed_trie(word, trie, i = 0):
    # It is assumed that the characters in |word| all are between 0
    # and 0x7F.

    (value, i) = unpack_integer(trie, i)

    if word == '':
        return value
    else:
        while ord(trie[i]) & 0x7F < ord(word[0]):
            while ord(trie[i]) & 0x80 == 0:
                i = i + 1
            (jump, i) = unpack_integer(trie, i + 1)
            if jump == 0:
                return 0
            i = i + jump
        (is_match, word, i) = look_for_match(word, trie, i)
        if is_match:
            i = skip_packed_integer(trie, i)
            return search_packed_trie(word, trie, i)
        else:
            return 0

def test_packed_trie():
    glyph_list = read_glyph_list()
    trie = pack_trie(make_trie(glyph_list))
    for (glyph_name, code_point) in glyph_list:
        if search_packed_trie(glyph_name, trie) != convert_value(code_point):
            print "WOOPS!"
    print "Done"

#--------------------------------------------------------------------------

def write_c_initializer(data, f = sys.stdout, per_line = 20):
    for i in range(0, len(data)):
        if (i + 1) % per_line == 0:
            f.write('\n')
        f.write(str(ord(data[i])))
        if i != len(data) - 1:
            f.write(',')

#--------------------------------------------------------------------------

if __name__ == '__main__':

#    test_trie()
#    test_packed_trie()

    if 2 <= len(sys.argv) and sys.argv[1] == 'length':
        print find_longest_glyph_name()
    else:
        glyph_list = read_glyph_list()
        pt = pack_trie(make_trie(glyph_list))
        write_c_initializer(pt)

#--------------------------------------------------------------------------
