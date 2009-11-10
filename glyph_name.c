/*-----------------------------------------------------------------------*/
#include "glyph_name.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* Conversion of glyph names to Unicode strings, using the method
 * documented in the Adobe Glyph Naming convention,
 * http://www.adobe.com/devnet/opentype/archives/glyph.html.
 *
 * The special rules for Zapf Dingbats are not implemented here.
 */

/*-----------------------------------------------------------------------*/

static int
string_is_hex(const char *s)
{
    const char *hex_digits = "0123456789ABCDEF";
    int i;

    i = 0;
    while (s[i] != '\0' && strchr(hex_digits, s[i]) != NULL)
        i++;
    return (s[i] == '\0');
}


static unsigned int *
match_uni(const char *name)
{
    unsigned int *unicode_string;
    size_t name_length;

    unicode_string = NULL;

    name_length = strlen(name);
    if (7 <= name_length &&
        (name_length - 3) % 4 == 0 &&
        strncmp("uni", name, 3) == 0 &&
        string_is_hex(name + 3)) {

        const size_t word_count = (name_length - 3) / 4;

        unicode_string = malloc((word_count + 1) * sizeof (*unicode_string));
        if (unicode_string != NULL) {
            size_t i;
            char substring[5];

            unicode_string[0] = word_count;
            i = 0;
            while (unicode_string != NULL && i < word_count) {
                unsigned int u;

                memcpy(substring, name + 3 + (4 * i), 4);
                substring[4] = '\0';
                u = (unsigned int) strtoul(substring, NULL, 16);
                if ((0x0000 <= u && u <= 0xD7FF) || (0xE000 <= u && u <= 0xFFFF)) {
                    unicode_string[i + 1] = u;
                } else {
                    free(unicode_string);
                    unicode_string = NULL;
                }
                i++;
            }
        }
    }
    return unicode_string;
}


static unsigned int *
match_u(const char *name)
{
    unsigned int *unicode_string;
    size_t name_length;

    unicode_string = NULL;

    name_length = strlen(name);
    if (5 <= name_length && name_length <= 7 &&
        name[0] == 'u' &&
        string_is_hex(name + 1)) {

        long int value;

        value = strtol(name + 1, NULL, 16);
        if ((0x0000 <= value && value <= 0xD7FF) ||
            (0xE000 <= value && value <= 0xFFFF)) {
            unicode_string = malloc(2 * sizeof (*unicode_string));
            if (unicode_string != NULL) {
                unicode_string[0] = 1;
                unicode_string[1] = value;
            }
        } else if (0x10000 <= value && value <= 0x10FFFF) {
            unicode_string = malloc(3 * sizeof (*unicode_string));
            if (unicode_string != NULL) {
                long int n;
                long int right_10_bits;
                long int left_10_bits;

                /* Encode as a UTF-16BE surrogate pair. */
                
                n = value - 0x10000;
                right_10_bits = (n & 0x3FF);
                left_10_bits = ((n >> 10) & 0x3FF);
                unicode_string[0] = 2;
                unicode_string[1] = left_10_bits + 0xD800;
                unicode_string[2] = right_10_bits + 0xDC00;
            }
        }
    }
    return unicode_string;
}


static unsigned int *
match_agl(const char *name)
{
    unsigned int *unicode_string;
    unsigned int unicode1;
    unsigned int unicode2;

    unicode_string = NULL;
    look_up_glyph_name_in_the_agl(name, &unicode1, &unicode2);
    if (unicode2 != 0) {
        unicode_string = malloc(3 * sizeof (*unicode_string));
        unicode_string[0] = 2;
        unicode_string[1] = unicode1;
        unicode_string[2] = unicode2;
    } else if (unicode1 != 0) {
        unicode_string = malloc(2 * sizeof (*unicode_string));
        unicode_string[0] = 1;
        unicode_string[1] = unicode1;
    }
    return unicode_string;
}


static char *
dotless_copy(const char *s)
{
    size_t i;
    char *copy;

    i = 0;
    while (s[i] != '\0' && s[i] != '.')
        i++;
    copy = malloc((i + 1) * sizeof (char));
    if (copy != NULL) {
        strncpy(copy, s, i);
        copy[i] = '\0';
    }
    return copy;
}


static unsigned int *
append_to_unicode_string(unsigned int *unicode_string,
                         unsigned int *appendix)
{
    size_t new_length;
    unsigned int *new_string;

    if (unicode_string == NULL) {
        new_string = appendix;
    } else {
        new_length = unicode_string[0] + appendix[0];
        new_string = realloc(unicode_string, (new_length + 1) * sizeof (*unicode_string));
        if (new_string == NULL) {
            free(unicode_string);
        } else {
            memcpy(new_string + unicode_string[0] + 1, appendix + 1, appendix[0] * sizeof (*unicode_string));
            new_string[0] = new_length;
        }
        free(appendix);
    }
    return new_string;
}


unsigned int *
glyph_name_to_unicode(const char *name)
{
    unsigned int *unicode_string;

    unicode_string = NULL;

    if (name != NULL) {
        char *dotless_name;
        char *p;
        char *q;

        dotless_name = dotless_copy(name);
        if (dotless_name != NULL) {
            p = dotless_name;
            while (p[0] != '\0') {
                q = strchr(p, '_');
                if (q != NULL) {
                    unsigned int *uni;

                    *q = '\0';
                    uni = glyph_name_to_unicode(p);
                    if (uni != NULL)
                        unicode_string = append_to_unicode_string(unicode_string, uni);
                    p = q + 1;
                } else {
                    unsigned int *uni;

                    uni = match_agl(p);
                    if (uni == NULL)
                        uni = match_uni(p);
                    if (uni == NULL)
                        uni = match_u(p);
                    if (uni != NULL)
                        unicode_string = append_to_unicode_string(unicode_string, uni);
                    p = "";
                }
            }
            free(dotless_name);
        }
    }
    return unicode_string;
}


char *
unicode_string_to_hex(const unsigned int *unicode_string)
{
    char *hex_string;

    if (unicode_string != NULL) {
        hex_string = malloc((4 * unicode_string[0] + 1) * sizeof (char));
        if (hex_string != NULL) {
            size_t i;

            for (i = 0;  i < unicode_string[0];  i++)
                snprintf(hex_string + 4 * i, 5, "%.4X", unicode_string[i + 1]);
        }
    } else {
        hex_string = strdup("");
    }
    return hex_string;
}


char *
glyph_name_to_hex(const char *glyph_name)
{
    unsigned int *unicode_string;
    char *hex_string;

    unicode_string = glyph_name_to_unicode(glyph_name);
    hex_string = unicode_string_to_hex(unicode_string);
    free(unicode_string);
    return hex_string;
}

/*-----------------------------------------------------------------------*/

#if 0

int
main(int argc, char **argv)
{
    const char *names[] = {
        ".notdef",
        "uni0000",
        "uni1234_u10000",
        "u10FFFD_uni1234_u10000",
        "uniABCD_uniABCD.sc",
        "uniABCDABCD.sc",
        "uniABCDAABCD.sc",
        "f_f_uni9999",
        "omicron",
        "dalettserehebrew_uniABCD.001",
        "uniABCD_dalettserehebrew.001",
        "f_f_l",
        NULL
    };

    int i;

    for (i = 0;  names[i] != NULL;  i++)
        printf("%s |%s|\n", names[i], glyph_name_to_hex(names[i]));

    return 0;
}

#endif

/*-----------------------------------------------------------------------*/
