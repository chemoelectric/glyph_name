#ifndef _GLYPH_NAME_H
#define _GLYPH_NAME_H 1

void look_up_glyph_name_in_the_agl(const char *glyph_name,
                                   unsigned int *unicode1,
                                   unsigned int *unicode2);

unsigned int *glyph_name_to_unicode(const char *name);
char *unicode_string_to_hex(const unsigned int *unicode_string);
char *glyph_name_to_hex(const char *glyph_name);


#endif /* glyph_name.h */
