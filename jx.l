%{

#include "y.tab.h"

#include <stdio.h>

#include <stdlib.h>

%}



%option noyywrap



%%


","            { return COMMA; }          // Recognize commas

\n+            { return NEWLINE; }         // Recognize one or more newlines

\"([^\"]*)\"   { yylval.str = strdup(yytext + 1); yytext[yyleng - 1] = '\0'; return STRING; } // Quoted str
ings

[a-zA-Z0-9. ]+  { yylval.str = strdup(yytext); return STRING; } // Unquoted strings (words)

[ \t]+         { /* Ignore whitespace */ }  // Ignore spaces and tabs

.              { /* Ignore unrecognized characters */ }



%%
