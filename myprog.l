%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

extern int line_num;
%}

/* Regular Definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT}|_)*
INT         {DIGIT}+
FLOAT       ({DIGIT}+\.{DIGIT}*)|({DIGIT}*\.{DIGIT}+)
STRING      \"[^\"]*\"
CHAR        \'[^\'\n]\'
WHITESPACE  [ \t]+
NEWLINE     \n|\r|\r\n

%%

{WHITESPACE}    { /* ignore whitespace */ }

{NEWLINE}       { line_num++; }

"#".*{NEWLINE}  { line_num++; /* skip comments */ }

"var"           { return VAR; }
"const"         { return CONST; }
"fn"            { return FN; }
"if"            { return IF; }
"elif"          { return ELIF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"in"            { return IN; }
"break"         { return BREAK; }
"continue"      { return CONTINUE; }
"return"        { return RETURN; }
"print"         { return PRINT; }
"scan"          { return SCAN; }
"try"           { return TRY; }
"catch"         { return CATCH; }
"finally"       { return FINALLY; }
"throw"         { return THROW; }

"true"          { yylval.bval = 1; return BOOLEAN; }
"false"         { yylval.bval = 0; return BOOLEAN; }

"++"            { return INCREMENT; }
"--"            { return DECREMENT; }
"+="            { return PLUS_ASSIGN; }
"-="            { return MINUS_ASSIGN; }
"*="            { return MULT_ASSIGN; }
"/="            { return DIV_ASSIGN; }
"%="            { return MOD_ASSIGN; }

"&&"            { return AND_OP; }
"||"            { return OR_OP; }
"!"             { return NOT_OP; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
"%"             { return MODULO; }
"="             { return ASSIGN; }
"=="            { return EQUAL; }
"!="            { return NOT_EQUAL; }
"<"             { return LESS_THAN; }
"<="            { return LESS_EQUAL; }
">"             { return GREATER_THAN; }
">="            { return GREATER_EQUAL; }

"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"["             { return LBRACKET; }
"]"             { return RBRACKET; }
";"             { return SEMICOLON; }
":"             { return COLON; }
","             { return COMMA; }

{ID}            { yylval.sval = strdup(yytext); return IDENTIFIER; }
{FLOAT}         { yylval.fval = atof(yytext); return FLOAT; }
{INT}           { yylval.ival = atoi(yytext); return INTEGER; }
{STRING}        {
                  yytext[strlen(yytext)-1] = '\0';
                  yylval.sval = strdup(yytext + 1);
                  return STRING;
                }
{CHAR}          {
                  char buf[2];
                  buf[0] = yytext[1];
                  buf[1] = '\0';
                  yylval.sval = strdup(buf);
                  return CHAR;
                }

.               { fprintf(stderr, "Error: Unrecognized character %s at line %d\n", yytext, line_num); }

%%

int yywrap() {
    return 1;
}
