dnl  "m4 [--synclines] -DGLYPHLIST=path/to/glyphlist.txt agl_lookup.c.m4 > agl_lookup.c"
`#include <stdlib.h>'
`#include <string.h>'
`#include "glyph_name.h"'

`#define MAX_GLYPH_NAME_LENGTH' esyscmd(`python ./make_trie.py length < 'GLYPHLIST)
/* The following table contains the data of the Adobe Glyph List,
   in the form of a trie. */
const unsigned char agl_lookup[] = {
esyscmd(`python ./make_trie.py < 'GLYPHLIST),
/* The following terminal null character makes it possible treat this
table as a C string. */
0
};

static void
unpack_integer(const unsigned char *s,
               unsigned long int *value,
               size_t *i)
{
    if (s[*i] <= 0x7F) {
        *value = s[*i] - 1;
        (*i)++;
    } else {
        unsigned long int val;
        size_t j;

        j = *i + 1;
        unpack_integer(s, &val, &j);
        *value = ((s[*i] - 1) % 0x7F) + (0x7F * val);
        *i = j;
    }
}


static int
compare_strings(const unsigned char *word,
                const unsigned char *trie,
                size_t i,
                size_t count)
{
    size_t j;

    j = 0;
    while (j < count && word[j] == (trie[i + j] & 0x7F))
        j++;
    return j == count;
}


static void
look_for_match(int *is_match,
               const unsigned char **word,
               const unsigned char *trie,
               size_t *i)
{
    size_t j;

    *is_match = 0;
    j = 0;
    while ((trie[*i + j] & 0x80) == 0)
        j++;
    if (compare_strings(*word, trie, *i, j + 1)) {
        *word += j + 1;
        *i += j + 1;
        *is_match = 1;
    }
}


static void
skip_packed_integer(const unsigned char *s,
                    size_t *i)
{
    while ((s[*i] & 0x80) != 0)
        (*i)++;
    (*i)++;
}


static unsigned long int
search_packed_trie(const unsigned char *word,
                   const unsigned char *trie,
                   const size_t index)
{
    /* It is assumed that the characters in |word| all are between 0
     * and 0x7F. */

    unsigned long int value;
    size_t i;
    int is_match;

    i = index;
    unpack_integer(trie, &value, &i);

    if (word[0] == '\0') {
        return value;
    } else {
        while ((trie[i] & 0x7F) < word[0]) {
            while ((trie[i] & 0x80) == 0)
                i++;
            i++;
            unpack_integer(trie, &value, &i);
            if (value == 0)
                return 0;
            i += value;
        }
        look_for_match(&is_match, &word, trie, &i);
        if (is_match) {
            skip_packed_integer(trie, &i);
            return search_packed_trie(word, trie, i);
        }
    }
    return 0;
}


static int
are_all_7bit_characters(const unsigned char *s)
{
    size_t i;

    i = 0;
    while (s[i] != '\0' && (s[i] & 0x80) == 0)
        i++;
    return (s[i] == '\0');
}


void
look_up_glyph_name_in_the_agl(const char *glyph_name,
                              unsigned int *unicode1,
                              unsigned int *unicode2)
{
    unsigned char word[MAX_GLYPH_NAME_LENGTH + 1];

    *unicode1 = 0;
    *unicode2 = 0;
    if (strlen(glyph_name) <= MAX_GLYPH_NAME_LENGTH) {
        strcpy((char *) word, glyph_name);
        if (are_all_7bit_characters(word)) {
            unsigned long int u;

            u = search_packed_trie(word, agl_lookup, 0);
            *unicode1 = (unsigned int) (u & 0xFFFF);
            *unicode2 = (unsigned int) ((u >> 16) & 0xFFFF);
        }
    }
}

/*-----------------------------------------------------------------------*/

#if 0

int
main(int argc, char **argv)
{
    unsigned int u1;
    unsigned int u2;

    printf("Table size: %d\n", sizeof(agl_lookup) - 1);

    look_up_glyph_name_in_the_agl("A", &u1, &u2);
    printf("%.4X %.4X\n", u1, u2);
    look_up_glyph_name_in_the_agl("omicron", &u1, &u2);
    printf("%.4X %.4X\n", u1, u2);
    look_up_glyph_name_in_the_agl("uni0000", &u1, &u2);
    printf("%.4X %.4X\n", u1, u2);
    look_up_glyph_name_in_the_agl("dalettserehebrew", &u1, &u2);
    printf("%.4X %.4X\n", u1, u2);

    return 0;
}

#endif

/*-----------------------------------------------------------------------*/
dnl
dnl local variables:
dnl mode: c
dnl end:
