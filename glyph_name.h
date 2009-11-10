/*

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

*/

#ifndef _GLYPH_NAME_H
#define _GLYPH_NAME_H 1

void look_up_glyph_name_in_the_agl(const char *glyph_name,
                                   unsigned int *unicode1,
                                   unsigned int *unicode2);

unsigned int *glyph_name_to_unicode(const char *name);
char *unicode_string_to_hex(const unsigned int *unicode_string);
char *glyph_name_to_hex(const char *glyph_name);


#endif /* glyph_name.h */