%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line_num = 1;
%}

/* Regular Definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT}|_)*
INT         {DIGIT}+
FLOAT       {DIGIT}+\.{DIGIT}+
STRING      \"[^\"]*\"
CHAR        \'[^\'\\n]\'
WHITESPACE  [ \t]+
NEWLINE     \n|\r|\r\n

%%

{WHITESPACE}    { /* ignore whitespace */ }

{NEWLINE}       { line_num++; }

"#".*{NEWLINE}  { line_num++; printf("COMMENT "); }

"var"           { printf("VAR_KEYWORD "); }
"const"         { printf("CONST_KEYWORD "); }
"fn"            { printf("FN_KEYWORD "); }
"if"            { printf("IF_KEYWORD "); }
"elif"          { printf("ELIF_KEYWORD "); }
"else"          { printf("ELSE_KEYWORD "); }
"while"         { printf("WHILE_KEYWORD "); }
"return"        { printf("RETURN_KEYWORD "); }
"print"         { printf("PRINT_KEYWORD "); }
"scan"          { printf("SCAN_KEYWORD "); }

"int"           { printf("TYPE_INT "); }
"float"         { printf("TYPE_FLOAT "); }
"bool"          { printf("TYPE_BOOL "); }
"string"        { printf("TYPE_STRING "); }
"char"          { printf("TYPE_CHAR "); }

"true"          { printf("BOOLEAN_TRUE "); }
"false"         { printf("BOOLEAN_FALSE "); }

"+"             { printf("PLUS "); }
"-"             { printf("MINUS "); }
"*"             { printf("MULTIPLY "); }
"/"             { printf("DIVIDE "); }
"%"             { printf("MODULO "); }
"="             { printf("ASSIGN "); }
"=="            { printf("EQUAL "); }
"!="            { printf("NOT_EQUAL "); }
"<"             { printf("LESS_THAN "); }
"<="            { printf("LESS_EQUAL "); }
">"             { printf("GREATER_THAN "); }
">="            { printf("GREATER_EQUAL "); }
"&&"            { printf("AND_OP "); }
"||"            { printf("OR_OP "); }
"!"             { printf("NOT_OP "); }

"("             { printf("L_PAREN "); }
")"             { printf("R_PAREN "); }
"{"             { printf("L_BRACE "); }
"}"             { printf("R_BRACE "); }
"["             { printf("L_BRACKET "); }
"]"             { printf("R_BRACKET "); }
";"             { printf("SEMICOLON "); }
":"             { printf("COLON "); }
","             { printf("COMMA "); }

{ID}            { printf("IDENTIFIER(%s) ", yytext); }
{INT}           { printf("INTEGER(%s) ", yytext); }
{FLOAT}         { printf("FLOAT(%s) ", yytext); }
{STRING}        { printf("STRING(%s) ", yytext); }
{CHAR}          { printf("CHAR(%s) ", yytext); }

.               { printf("ERROR: Unrecognized character %s at line %d ", yytext, line_num); }

%%

int yywrap() {
    return 1;
}

int main(int argc, char** argv) {
    if (argc == 2) {
        FILE* input_file = fopen(argv[1], "r");
        if (!input_file) {
            printf("error opening file: %s\n", argv[1]);
            return 1;
        }
        yyin = input_file;
        yylex();
        fclose(input_file);
        return 0;
    }

    if (argc == 1) {
        yylex();
        return 0;
    }

    printf("usage: %s <input_file> or via stdin\n", argv[0]);
    return 1;
}
