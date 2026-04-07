%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern FILE* yyin;
void yyerror(const char* s);

int line_num = 1;

typedef enum {
    VAL_INTEGER,
    VAL_FLOAT,
    VAL_STRING,
    VAL_BOOLEAN,
    VAL_FUNCTION,
    VAL_EXCEPTION,
    VAL_NULL,
    VAL_ARRAY
} ValueType;

struct ASTNode;
typedef struct Value Value;

struct Value {
    ValueType type;
    int is_const;
    union {
        int ival;
        double fval;
        char* sval;
        int bval;
        struct {
            struct ASTNode* func_def;
            char* name;
        } func;
        struct {
            Value* elements;
            int length;
            int capacity;
        } array;
    } data;
};

typedef struct {
    int has_return;
    int has_exception;
    int has_break;
    int has_continue;
    Value value;
} ReturnValue;

typedef struct {
    char* name;
    Value value;
} Symbol;

typedef struct SymbolTable {
    Symbol* symbols;
    int count;
    int capacity;
    struct SymbolTable* parent;
} SymbolTable;

SymbolTable* global_symbols;
SymbolTable* current_symbols;

typedef enum {
    NODE_INTEGER,
    NODE_FLOAT,
    NODE_STRING,
    NODE_BOOLEAN,
    NODE_IDENTIFIER,
    NODE_BINARY_OP,
    NODE_UNARY_OP,
    NODE_ASSIGNMENT,
    NODE_DECLARATION,
    NODE_IF,
    NODE_WHILE,
    NODE_FOR,
    NODE_FOR_EACH,
    NODE_PRINT,
    NODE_SCAN,
    NODE_BLOCK,
    NODE_FUNCTION_DEF,
    NODE_FUNCTION_CALL,
    NODE_RETURN,
    NODE_BREAK,
    NODE_CONTINUE,
    NODE_TRY_CATCH,
    NODE_THROW,
    NODE_ARRAY_LITERAL,
    NODE_ARRAY_ACCESS,
    NODE_SLICE
} NodeType;

typedef struct ElifNode {
    struct ASTNode* condition;
    struct ASTNode* block;
    struct ElifNode* next;
} ElifNode;

typedef struct ASTNode {
    NodeType type;
    union {
        int ival;
        double fval;
        char* sval;
        int bval;
        struct {
            struct ASTNode* left;
            struct ASTNode* right;
            int op;
        } binary_op;
        struct {
            struct ASTNode* operand;
            int op;
        } unary_op;
        struct {
            struct ASTNode* target;
            struct ASTNode* value;
        } assignment;
        struct {
            char* name;
            struct ASTNode* initial_value;
            int is_const;
        } declaration;
        struct {
            struct ASTNode* condition;
            struct ASTNode* if_branch;
            ElifNode* elifs;
            struct ASTNode* else_branch;
        } if_stmt;
        struct {
            struct ASTNode* condition;
            struct ASTNode* body;
        } while_loop;
        struct {
            struct ASTNode* init;
            struct ASTNode* condition;
            struct ASTNode* update;
            struct ASTNode* body;
        } for_loop;
        struct {
            char* var_name;
            struct ASTNode* iterable;
            struct ASTNode* body;
        } for_each_loop;
        struct {
            struct ASTNode* expr;
        } print_stmt;
        struct {
            char* name;
        } scan_stmt;
        struct {
            struct ASTNode** statements;
            int count;
            int capacity;
        } block;
        struct {
            char* name;
            char** parameters;
            int param_count;
            struct ASTNode* body;
        } func_def;
        struct {
            char* name;
            struct ASTNode** arguments;
            int arg_count;
        } func_call;
        struct {
            struct ASTNode* expr;
        } return_stmt;
        struct {
            struct ASTNode* try_block;
            struct ASTNode* catch_block;
            char* exception_var;
            struct ASTNode* finally_block;
        } try_catch;
        struct {
            struct ASTNode* expr;
        } throw_stmt;
        struct {
            struct ASTNode** elements;
            int count;
            int capacity;
        } array_literal;
        struct {
            struct ASTNode* array;
            struct ASTNode* index;
        } array_access;
        struct {
            struct ASTNode* value;
            struct ASTNode* start;
            struct ASTNode* end;
            struct ASTNode* step;
        } slice;
    } data;
} ASTNode;

ASTNode* create_integer_node(int value);
ASTNode* create_float_node(double value);
ASTNode* create_string_node(char* value);
ASTNode* create_boolean_node(int value);
ASTNode* create_identifier_node(char* name);
ASTNode* create_binary_op_node(ASTNode* left, int op, ASTNode* right);
ASTNode* create_unary_op_node(int op, ASTNode* operand);
ASTNode* create_assignment_node(ASTNode* target, ASTNode* value);
ASTNode* create_declaration_node(char* name, ASTNode* initial_value, int is_const);
ASTNode* create_if_node(ASTNode* condition, ASTNode* if_branch, ElifNode* elifs, ASTNode* else_branch);
ASTNode* create_while_node(ASTNode* condition, ASTNode* body);
ASTNode* create_for_node(ASTNode* init, ASTNode* condition, ASTNode* update, ASTNode* body);
ASTNode* create_for_each_node(char* var_name, ASTNode* iterable, ASTNode* body);
ASTNode* create_print_node(ASTNode* expr);
ASTNode* create_scan_node(char* name);
ASTNode* create_block_node();
ASTNode* create_function_def_node(char* name, char** parameters, int param_count, ASTNode* body);
ASTNode* create_function_call_node(char* name);
ASTNode* create_return_node(ASTNode* expr);
ASTNode* create_break_node();
ASTNode* create_continue_node();
ASTNode* create_try_catch_node(ASTNode* try_block, ASTNode* catch_block, char* exception_var, ASTNode* finally_block);
ASTNode* create_throw_node(ASTNode* expr);
ASTNode* create_array_literal_node();
ASTNode* create_array_access_node(ASTNode* array, ASTNode* index);
ASTNode* create_slice_node(ASTNode* value, ASTNode* start, ASTNode* end, ASTNode* step);

void add_statement_to_block(ASTNode* block, ASTNode* statement);
void add_parameter_to_function(ASTNode* func_def, char* param);
void add_argument_to_function_call(ASTNode* func_call, ASTNode* arg);
void add_element_to_array_literal(ASTNode* array_node, ASTNode* element);

SymbolTable* create_symbol_table();
void free_symbol_table(SymbolTable* table);
int find_symbol_in_table(SymbolTable* table, char* name);
int find_symbol(char* name);
void declare_variable(char* name, Value value, int is_const);
void set_variable(char* name, Value value);
Value get_variable(char* name);
void push_scope();
void pop_scope();

Value evaluate_expression(ASTNode* expr);
ReturnValue interpret(ASTNode* node);
ReturnValue interpret_block(ASTNode* block, int new_scope);
ReturnValue call_function(ASTNode* func_def, ASTNode** arguments, int arg_count);
void print_value(Value val);
char* value_to_string(Value val);
int value_to_boolean(Value val);
Value copy_value(Value val);
Value make_exception(const char* msg);
int set_array_nested(Value* arr, int* idxs, int count, Value val);
int collect_indices(ASTNode* node, int* idxs, int max, char** root_name, Value* err);

ASTNode* program_root = NULL;
int call_depth = 0;
const int MAX_CALL_DEPTH = 200;
%}

%union {
    int ival;
    double fval;
    char* sval;
    int bval;
    struct ASTNode* node;
    struct ElifNode* elifs;
    struct {
        char** items;
        int count;
    } str_list;
    struct {
        struct ASTNode** items;
        int count;
    } node_list;
}

%start program

%token VAR CONST FN IF ELIF ELSE WHILE FOR IN BREAK CONTINUE RETURN PRINT SCAN TRY CATCH FINALLY THROW
%token AND_OP OR_OP NOT_OP
%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token INCREMENT DECREMENT PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token ASSIGN EQUAL NOT_EQUAL LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SEMICOLON COMMA COLON

%token <ival> INTEGER
%token <fval> FLOAT
%token <sval> STRING
%token <sval> CHAR
%token <sval> IDENTIFIER
%token <bval> BOOLEAN

%type <node> program statement_list statement block
%type <node> declaration assignment expression or_expr and_expr not_expr comparison arithmetic term factor
%type <node> if_statement while_statement for_statement print_statement scan_statement
%type <node> function_definition function_call return_statement break_statement continue_statement try_statement throw_statement
%type <node> array_literal primary postfix
%type <str_list> param_list
%type <node_list> arg_list array_elements
%type <elifs> elif_list

%left OR_OP
%left AND_OP
%left EQUAL NOT_EQUAL LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right NOT_OP
%right UMINUS
%nonassoc IFX
%nonassoc ELSE

%%

program : statement_list { program_root = $1; }
        ;

statement_list
    : statement_list statement { add_statement_to_block($1, $2); $$ = $1; }
    | statement { $$ = create_block_node(); add_statement_to_block($$, $1); }
    ;

statement
    : declaration SEMICOLON { $$ = $1; }
    | assignment SEMICOLON { $$ = $1; }
    | if_statement { $$ = $1; }
    | while_statement { $$ = $1; }
    | for_statement { $$ = $1; }
    | function_definition { $$ = $1; }
    | function_call SEMICOLON { $$ = $1; }
    | return_statement SEMICOLON { $$ = $1; }
    | break_statement SEMICOLON { $$ = $1; }
    | continue_statement SEMICOLON { $$ = $1; }
    | print_statement SEMICOLON { $$ = $1; }
    | scan_statement SEMICOLON { $$ = $1; }
    | try_statement { $$ = $1; }
    | throw_statement SEMICOLON { $$ = $1; }
    | block { $$ = $1; }
    ;

block
    : LBRACE statement_list RBRACE { $$ = $2; }
    ;

declaration
    : VAR IDENTIFIER ASSIGN expression { $$ = create_declaration_node($2, $4, 0); }
    | CONST IDENTIFIER ASSIGN expression { $$ = create_declaration_node($2, $4, 1); }
    ;

assignment
    : postfix ASSIGN expression { $$ = create_assignment_node($1, $3); }
    | postfix PLUS_ASSIGN expression { $$ = create_assignment_node($1, create_binary_op_node($1, PLUS, $3)); }
    | postfix MINUS_ASSIGN expression { $$ = create_assignment_node($1, create_binary_op_node($1, MINUS, $3)); }
    | postfix MULT_ASSIGN expression { $$ = create_assignment_node($1, create_binary_op_node($1, MULTIPLY, $3)); }
    | postfix DIV_ASSIGN expression { $$ = create_assignment_node($1, create_binary_op_node($1, DIVIDE, $3)); }
    | postfix MOD_ASSIGN expression { $$ = create_assignment_node($1, create_binary_op_node($1, MODULO, $3)); }
    | postfix INCREMENT { $$ = create_assignment_node($1, create_binary_op_node($1, PLUS, create_integer_node(1))); }
    | postfix DECREMENT { $$ = create_assignment_node($1, create_binary_op_node($1, MINUS, create_integer_node(1))); }
    ;

if_statement
    : IF expression block elif_list ELSE block { $$ = create_if_node($2, $3, $4, $6); }
    | IF expression block elif_list %prec IFX { $$ = create_if_node($2, $3, $4, NULL); }
    | IF expression block ELSE block { $$ = create_if_node($2, $3, NULL, $5); }
    | IF expression block %prec IFX { $$ = create_if_node($2, $3, NULL, NULL); }
    ;

elif_list
    : elif_list ELIF expression block {
        ElifNode* tail = $1;
        while (tail->next) tail = tail->next;
        ElifNode* n = (ElifNode*)malloc(sizeof(ElifNode));
        n->condition = $3;
        n->block = $4;
        n->next = NULL;
        tail->next = n;
        $$ = $1;
      }
    | ELIF expression block {
        ElifNode* n = (ElifNode*)malloc(sizeof(ElifNode));
        n->condition = $2;
        n->block = $3;
        n->next = NULL;
        $$ = n;
      }
    ;

while_statement
    : WHILE expression block { $$ = create_while_node($2, $3); }
    ;

for_statement
    : FOR LPAREN assignment SEMICOLON expression SEMICOLON assignment RPAREN block
      { $$ = create_for_node($3, $5, $7, $9); }
    | FOR IDENTIFIER IN expression block
      { $$ = create_for_each_node($2, $4, $5); }
    ;

print_statement
    : PRINT LPAREN expression RPAREN { $$ = create_print_node($3); }
    ;

scan_statement
    : SCAN LPAREN IDENTIFIER RPAREN { $$ = create_scan_node($3); }
    ;

function_definition
    : FN IDENTIFIER LPAREN RPAREN block { $$ = create_function_def_node($2, NULL, 0, $5); }
    | FN IDENTIFIER LPAREN param_list RPAREN block {
        ASTNode* fn = create_function_def_node($2, NULL, 0, $6);
        for (int i = 0; i < $4.count; i++) {
            add_parameter_to_function(fn, $4.items[i]);
        }
        $$ = fn;
      }
    ;

param_list
    : IDENTIFIER {
        $$.items = (char**)malloc(sizeof(char*));
        $$.items[0] = $1;
        $$.count = 1;
      }
    | param_list COMMA IDENTIFIER {
        $$.items = (char**)realloc($1.items, sizeof(char*) * ($1.count + 1));
        $$.items[$1.count] = $3;
        $$.count = $1.count + 1;
      }
    ;

function_call
    : IDENTIFIER LPAREN RPAREN { $$ = create_function_call_node($1); }
    | IDENTIFIER LPAREN arg_list RPAREN {
        ASTNode* call = create_function_call_node($1);
        for (int i = 0; i < $3.count; i++) {
            add_argument_to_function_call(call, $3.items[i]);
        }
        $$ = call;
      }
    ;

arg_list
    : expression {
        $$.items = (ASTNode**)malloc(sizeof(ASTNode*));
        $$.items[0] = $1;
        $$.count = 1;
      }
    | arg_list COMMA expression {
        $$.items = (ASTNode**)realloc($1.items, sizeof(ASTNode*) * ($1.count + 1));
        $$.items[$1.count] = $3;
        $$.count = $1.count + 1;
      }
    ;

return_statement
    : RETURN expression { $$ = create_return_node($2); }
    ;

break_statement
    : BREAK { $$ = create_break_node(); }
    ;

continue_statement
    : CONTINUE { $$ = create_continue_node(); }
    ;

try_statement
    : TRY block CATCH LPAREN IDENTIFIER RPAREN block FINALLY block
      { $$ = create_try_catch_node($2, $7, $5, $9); }
    | TRY block CATCH LPAREN IDENTIFIER RPAREN block
      { $$ = create_try_catch_node($2, $7, $5, NULL); }
    ;

throw_statement
    : THROW expression { $$ = create_throw_node($2); }
    ;

expression
    : or_expr { $$ = $1; }
    ;

or_expr
    : and_expr { $$ = $1; }
    | or_expr OR_OP and_expr { $$ = create_binary_op_node($1, OR_OP, $3); }
    ;

and_expr
    : not_expr { $$ = $1; }
    | and_expr AND_OP not_expr { $$ = create_binary_op_node($1, AND_OP, $3); }
    ;

not_expr
    : comparison { $$ = $1; }
    | NOT_OP not_expr { $$ = create_unary_op_node(NOT_OP, $2); }
    ;

comparison
    : arithmetic { $$ = $1; }
    | comparison EQUAL arithmetic { $$ = create_binary_op_node($1, EQUAL, $3); }
    | comparison NOT_EQUAL arithmetic { $$ = create_binary_op_node($1, NOT_EQUAL, $3); }
    | comparison LESS_THAN arithmetic { $$ = create_binary_op_node($1, LESS_THAN, $3); }
    | comparison LESS_EQUAL arithmetic { $$ = create_binary_op_node($1, LESS_EQUAL, $3); }
    | comparison GREATER_THAN arithmetic { $$ = create_binary_op_node($1, GREATER_THAN, $3); }
    | comparison GREATER_EQUAL arithmetic { $$ = create_binary_op_node($1, GREATER_EQUAL, $3); }
    ;

arithmetic
    : term { $$ = $1; }
    | arithmetic PLUS term { $$ = create_binary_op_node($1, PLUS, $3); }
    | arithmetic MINUS term { $$ = create_binary_op_node($1, MINUS, $3); }
    ;

term
    : factor { $$ = $1; }
    | term MULTIPLY factor { $$ = create_binary_op_node($1, MULTIPLY, $3); }
    | term DIVIDE factor { $$ = create_binary_op_node($1, DIVIDE, $3); }
    | term MODULO factor { $$ = create_binary_op_node($1, MODULO, $3); }
    ;

factor
    : postfix { $$ = $1; }
    | MINUS factor %prec UMINUS { $$ = create_unary_op_node(UMINUS, $2); }
    ;

primary
    : IDENTIFIER { $$ = create_identifier_node($1); }
    | INTEGER { $$ = create_integer_node($1); }
    | FLOAT { $$ = create_float_node($1); }
    | STRING { $$ = create_string_node($1); }
    | CHAR { $$ = create_string_node($1); }
    | BOOLEAN { $$ = create_boolean_node($1); }
    | LPAREN expression RPAREN { $$ = $2; }
    | function_call { $$ = $1; }
    | array_literal { $$ = $1; }
    ;

postfix
    : primary { $$ = $1; }
    | postfix LBRACKET expression RBRACKET { $$ = create_array_access_node($1, $3); }
    | postfix LBRACKET COLON RBRACKET { $$ = create_slice_node($1, NULL, NULL, NULL); }
    | postfix LBRACKET expression COLON RBRACKET { $$ = create_slice_node($1, $3, NULL, NULL); }
    | postfix LBRACKET COLON expression RBRACKET { $$ = create_slice_node($1, NULL, $4, NULL); }
    | postfix LBRACKET expression COLON expression RBRACKET { $$ = create_slice_node($1, $3, $5, NULL); }
    | postfix LBRACKET COLON COLON expression RBRACKET { $$ = create_slice_node($1, NULL, NULL, $5); }
    | postfix LBRACKET expression COLON COLON expression RBRACKET { $$ = create_slice_node($1, $3, NULL, $6); }
    | postfix LBRACKET COLON expression COLON expression RBRACKET { $$ = create_slice_node($1, NULL, $4, $6); }
    | postfix LBRACKET expression COLON expression COLON expression RBRACKET { $$ = create_slice_node($1, $3, $5, $7); }
    ;

array_literal
    : LBRACKET RBRACKET { $$ = create_array_literal_node(); }
    | LBRACKET array_elements RBRACKET {
        ASTNode* arr = create_array_literal_node();
        for (int i = 0; i < $2.count; i++) {
            add_element_to_array_literal(arr, $2.items[i]);
        }
        $$ = arr;
      }
    ;

array_elements
    : expression {
        $$.items = (ASTNode**)malloc(sizeof(ASTNode*));
        $$.items[0] = $1;
        $$.count = 1;
      }
    | array_elements COMMA expression {
        $$.items = (ASTNode**)realloc($1.items, sizeof(ASTNode*) * ($1.count + 1));
        $$.items[$1.count] = $3;
        $$.count = $1.count + 1;
      }
    ;

/* array access is handled via postfix */

%%

ASTNode* create_integer_node(int value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_INTEGER;
    node->data.ival = value;
    return node;
}

ASTNode* create_float_node(double value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_FLOAT;
    node->data.fval = value;
    return node;
}

ASTNode* create_string_node(char* value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_STRING;
    node->data.sval = value;
    return node;
}

ASTNode* create_boolean_node(int value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_BOOLEAN;
    node->data.bval = value;
    return node;
}

ASTNode* create_identifier_node(char* name) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_IDENTIFIER;
    node->data.sval = name;
    return node;
}

ASTNode* create_binary_op_node(ASTNode* left, int op, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_BINARY_OP;
    node->data.binary_op.left = left;
    node->data.binary_op.op = op;
    node->data.binary_op.right = right;
    return node;
}

ASTNode* create_unary_op_node(int op, ASTNode* operand) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_UNARY_OP;
    node->data.unary_op.op = op;
    node->data.unary_op.operand = operand;
    return node;
}

ASTNode* create_assignment_node(ASTNode* target, ASTNode* value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_ASSIGNMENT;
    node->data.assignment.target = target;
    node->data.assignment.value = value;
    return node;
}

ASTNode* create_declaration_node(char* name, ASTNode* initial_value, int is_const) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_DECLARATION;
    node->data.declaration.name = name;
    node->data.declaration.initial_value = initial_value;
    node->data.declaration.is_const = is_const;
    return node;
}

ASTNode* create_if_node(ASTNode* condition, ASTNode* if_branch, ElifNode* elifs, ASTNode* else_branch) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_IF;
    node->data.if_stmt.condition = condition;
    node->data.if_stmt.if_branch = if_branch;
    node->data.if_stmt.elifs = elifs;
    node->data.if_stmt.else_branch = else_branch;
    return node;
}

ASTNode* create_while_node(ASTNode* condition, ASTNode* body) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_WHILE;
    node->data.while_loop.condition = condition;
    node->data.while_loop.body = body;
    return node;
}

ASTNode* create_for_node(ASTNode* init, ASTNode* condition, ASTNode* update, ASTNode* body) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_FOR;
    node->data.for_loop.init = init;
    node->data.for_loop.condition = condition;
    node->data.for_loop.update = update;
    node->data.for_loop.body = body;
    return node;
}

ASTNode* create_for_each_node(char* var_name, ASTNode* iterable, ASTNode* body) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_FOR_EACH;
    node->data.for_each_loop.var_name = var_name;
    node->data.for_each_loop.iterable = iterable;
    node->data.for_each_loop.body = body;
    return node;
}

ASTNode* create_print_node(ASTNode* expr) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_PRINT;
    node->data.print_stmt.expr = expr;
    return node;
}

ASTNode* create_scan_node(char* name) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_SCAN;
    node->data.scan_stmt.name = name;
    return node;
}

ASTNode* create_block_node() {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_BLOCK;
    node->data.block.count = 0;
    node->data.block.capacity = 8;
    node->data.block.statements = (ASTNode**)malloc(sizeof(ASTNode*) * node->data.block.capacity);
    return node;
}

ASTNode* create_function_def_node(char* name, char** parameters, int param_count, ASTNode* body) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_FUNCTION_DEF;
    node->data.func_def.name = name;
    node->data.func_def.parameters = parameters;
    node->data.func_def.param_count = param_count;
    node->data.func_def.body = body;
    return node;
}

ASTNode* create_function_call_node(char* name) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_FUNCTION_CALL;
    node->data.func_call.name = name;
    node->data.func_call.arg_count = 0;
    node->data.func_call.arguments = NULL;
    return node;
}

ASTNode* create_return_node(ASTNode* expr) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_RETURN;
    node->data.return_stmt.expr = expr;
    return node;
}

ASTNode* create_break_node() {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_BREAK;
    return node;
}

ASTNode* create_continue_node() {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_CONTINUE;
    return node;
}

ASTNode* create_try_catch_node(ASTNode* try_block, ASTNode* catch_block, char* exception_var, ASTNode* finally_block) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_TRY_CATCH;
    node->data.try_catch.try_block = try_block;
    node->data.try_catch.catch_block = catch_block;
    node->data.try_catch.exception_var = exception_var;
    node->data.try_catch.finally_block = finally_block;
    return node;
}

ASTNode* create_throw_node(ASTNode* expr) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_THROW;
    node->data.throw_stmt.expr = expr;
    return node;
}

ASTNode* create_array_literal_node() {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_ARRAY_LITERAL;
    node->data.array_literal.count = 0;
    node->data.array_literal.capacity = 4;
    node->data.array_literal.elements = (ASTNode**)malloc(sizeof(ASTNode*) * node->data.array_literal.capacity);
    return node;
}

ASTNode* create_array_access_node(ASTNode* array, ASTNode* index) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_ARRAY_ACCESS;
    node->data.array_access.array = array;
    node->data.array_access.index = index;
    return node;
}

ASTNode* create_slice_node(ASTNode* value, ASTNode* start, ASTNode* end, ASTNode* step) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_SLICE;
    node->data.slice.value = value;
    node->data.slice.start = start;
    node->data.slice.end = end;
    node->data.slice.step = step;
    return node;
}

void add_statement_to_block(ASTNode* block, ASTNode* statement) {
    if (!block || block->type != NODE_BLOCK) return;
    if (block->data.block.count >= block->data.block.capacity) {
        block->data.block.capacity *= 2;
        block->data.block.statements = (ASTNode**)realloc(block->data.block.statements, sizeof(ASTNode*) * block->data.block.capacity);
    }
    block->data.block.statements[block->data.block.count++] = statement;
}

void add_parameter_to_function(ASTNode* func_def, char* param) {
    if (!func_def || func_def->type != NODE_FUNCTION_DEF) return;
    int n = func_def->data.func_def.param_count;
    func_def->data.func_def.parameters = (char**)realloc(func_def->data.func_def.parameters, sizeof(char*) * (n + 1));
    func_def->data.func_def.parameters[n] = param;
    func_def->data.func_def.param_count = n + 1;
}

void add_argument_to_function_call(ASTNode* func_call, ASTNode* arg) {
    if (!func_call || func_call->type != NODE_FUNCTION_CALL) return;
    int n = func_call->data.func_call.arg_count;
    func_call->data.func_call.arguments = (ASTNode**)realloc(func_call->data.func_call.arguments, sizeof(ASTNode*) * (n + 1));
    func_call->data.func_call.arguments[n] = arg;
    func_call->data.func_call.arg_count = n + 1;
}

void add_element_to_array_literal(ASTNode* array_node, ASTNode* element) {
    if (!array_node || array_node->type != NODE_ARRAY_LITERAL) return;
    if (array_node->data.array_literal.count >= array_node->data.array_literal.capacity) {
        array_node->data.array_literal.capacity *= 2;
        array_node->data.array_literal.elements = (ASTNode**)realloc(array_node->data.array_literal.elements, sizeof(ASTNode*) * array_node->data.array_literal.capacity);
    }
    array_node->data.array_literal.elements[array_node->data.array_literal.count++] = element;
}

SymbolTable* create_symbol_table() {
    SymbolTable* table = (SymbolTable*)malloc(sizeof(SymbolTable));
    table->symbols = NULL;
    table->count = 0;
    table->capacity = 0;
    table->parent = NULL;
    return table;
}

int find_symbol_in_table(SymbolTable* table, char* name) {
    if (!table) return -1;
    for (int i = 0; i < table->count; i++) {
        if (strcmp(table->symbols[i].name, name) == 0) return i;
    }
    return -1;
}

int find_symbol(char* name) {
    SymbolTable* t = current_symbols;
    while (t) {
        int idx = find_symbol_in_table(t, name);
        if (idx >= 0) return idx;
        t = t->parent;
    }
    return -1;
}

void declare_variable(char* name, Value value, int is_const) {
    int idx = find_symbol_in_table(current_symbols, name);
    if (idx >= 0) {
        current_symbols->symbols[idx].value = value;
        current_symbols->symbols[idx].value.is_const = is_const;
        return;
    }
    if (current_symbols->count >= current_symbols->capacity) {
        current_symbols->capacity = current_symbols->capacity == 0 ? 8 : current_symbols->capacity * 2;
        current_symbols->symbols = (Symbol*)realloc(current_symbols->symbols, sizeof(Symbol) * current_symbols->capacity);
    }
    current_symbols->symbols[current_symbols->count].name = name;
    current_symbols->symbols[current_symbols->count].value = value;
    current_symbols->symbols[current_symbols->count].value.is_const = is_const;
    current_symbols->count++;
}

void set_variable(char* name, Value value) {
    SymbolTable* t = current_symbols;
    while (t) {
        int idx = find_symbol_in_table(t, name);
        if (idx >= 0) {
            if (t->symbols[idx].value.is_const) {
                fprintf(stderr, "Error: cannot assign to const %s\n", name);
                return;
            }
            value.is_const = 0;
            t->symbols[idx].value = value;
            return;
        }
        t = t->parent;
    }
    fprintf(stderr, "Error: undefined variable %s\n", name);
}

Value get_variable(char* name) {
    SymbolTable* t = current_symbols;
    while (t) {
        int idx = find_symbol_in_table(t, name);
        if (idx >= 0) return t->symbols[idx].value;
        t = t->parent;
    }
    fprintf(stderr, "Error: undefined variable %s\n", name);
    return make_exception("undefined variable");
}

void push_scope() {
    SymbolTable* t = create_symbol_table();
    t->parent = current_symbols;
    current_symbols = t;
}

void pop_scope() {
    SymbolTable* t = current_symbols;
    if (!t) return;
    current_symbols = t->parent;
    free(t->symbols);
    free(t);
}

Value make_exception(const char* msg) {
    Value v;
    v.is_const = 0;
    v.type = VAL_EXCEPTION;
    v.data.sval = strdup(msg);
    return v;
}

Value copy_value(Value val) {
    Value out = val;
    if (val.type == VAL_STRING) {
        out.data.sval = strdup(val.data.sval);
    } else if (val.type == VAL_ARRAY) {
        out.data.array.elements = (Value*)malloc(sizeof(Value) * val.data.array.length);
        out.data.array.length = val.data.array.length;
        out.data.array.capacity = val.data.array.length;
        for (int i = 0; i < val.data.array.length; i++) {
            out.data.array.elements[i] = copy_value(val.data.array.elements[i]);
        }
    }
    return out;
}

int value_to_boolean(Value val) {
    switch (val.type) {
        case VAL_EXCEPTION: return 0;
        case VAL_NULL: return 0;
        case VAL_BOOLEAN: return val.data.bval != 0;
        case VAL_INTEGER: return val.data.ival != 0;
        case VAL_FLOAT: return val.data.fval != 0.0;
        case VAL_STRING: return val.data.sval && val.data.sval[0] != '\0';
        case VAL_ARRAY: return val.data.array.length > 0;
        default: return 0;
    }
}

char* value_to_string(Value val) {
    char buf[256];
    if (val.type == VAL_INTEGER) {
        snprintf(buf, sizeof(buf), "%d", val.data.ival);
        return strdup(buf);
    }
    if (val.type == VAL_FLOAT) {
        snprintf(buf, sizeof(buf), "%g", val.data.fval);
        return strdup(buf);
    }
    if (val.type == VAL_BOOLEAN) {
        return strdup(val.data.bval ? "true" : "false");
    }
    if (val.type == VAL_STRING) {
        return strdup(val.data.sval ? val.data.sval : "");
    }
    if (val.type == VAL_EXCEPTION) {
        return strdup(val.data.sval ? val.data.sval : "exception");
    }
    if (val.type == VAL_NULL) {
        return strdup("null");
    }
    if (val.type == VAL_ARRAY) {
        char* out = strdup("[");
        for (int i = 0; i < val.data.array.length; i++) {
            Value elem = val.data.array.elements[i];
            char* s = NULL;
            if (elem.type == VAL_STRING) {
                const char* es = elem.data.sval ? elem.data.sval : "";
                size_t len = strlen(es);
                s = (char*)malloc(len + 3);
                if (len == 1) {
                    sprintf(s, "'%s'", es);
                } else {
                    sprintf(s, "\"%s\"", es);
                }
            } else {
                s = value_to_string(elem);
            }
            char* next = (char*)malloc(strlen(out) + strlen(s) + 4);
            sprintf(next, "%s%s%s", out, s, (i == val.data.array.length - 1) ? "" : ", ");
            free(out);
            free(s);
            out = next;
        }
        char* final = (char*)malloc(strlen(out) + 2);
        sprintf(final, "%s]", out);
        free(out);
        return final;
    }
    if (val.type == VAL_FUNCTION) {
        return strdup("<function>");
    }
    return strdup("<unknown>");
}

void print_value(Value val) {
    char* s = value_to_string(val);
    printf("%s\n", s);
    fflush(stdout);
    free(s);
}

Value evaluate_expression(ASTNode* expr) {
    Value v;
    memset(&v, 0, sizeof(Value));

    switch (expr->type) {
        case NODE_INTEGER:
            v.type = VAL_INTEGER;
            v.data.ival = expr->data.ival;
            return v;
        case NODE_FLOAT:
            v.type = VAL_FLOAT;
            v.data.fval = expr->data.fval;
            return v;
        case NODE_STRING:
            v.type = VAL_STRING;
            v.data.sval = strdup(expr->data.sval);
            return v;
        case NODE_BOOLEAN:
            v.type = VAL_BOOLEAN;
            v.data.bval = expr->data.bval;
            return v;
        case NODE_IDENTIFIER:
            return copy_value(get_variable(expr->data.sval));
        case NODE_ARRAY_LITERAL: {
            v.type = VAL_ARRAY;
            v.data.array.length = expr->data.array_literal.count;
            v.data.array.capacity = expr->data.array_literal.count;
            v.data.array.elements = (Value*)malloc(sizeof(Value) * v.data.array.length);
            for (int i = 0; i < v.data.array.length; i++) {
                v.data.array.elements[i] = evaluate_expression(expr->data.array_literal.elements[i]);
            }
            return v;
        }
        case NODE_ARRAY_ACCESS: {
            Value arr = evaluate_expression(expr->data.array_access.array);
            Value idx = evaluate_expression(expr->data.array_access.index);
            if (arr.type == VAL_EXCEPTION) return arr;
            if (idx.type == VAL_EXCEPTION) return idx;
            if (arr.type != VAL_ARRAY || idx.type != VAL_INTEGER) {
                return make_exception("invalid array access");
            }
            if (idx.data.ival < 0 || idx.data.ival >= arr.data.array.length) {
                return make_exception("array index out of bounds");
            }
            return copy_value(arr.data.array.elements[idx.data.ival]);
        }
        case NODE_SLICE: {
            Value src = evaluate_expression(expr->data.slice.value);
            if (src.type == VAL_EXCEPTION) return src;
            if (src.type != VAL_ARRAY && src.type != VAL_STRING) {
                return make_exception("slice target must be array or string");
            }

            int length = (src.type == VAL_ARRAY) ? src.data.array.length : (int)strlen(src.data.sval ? src.data.sval : "");
            int step = 1;
            int start_default = expr->data.slice.start == NULL;
            int end_default = expr->data.slice.end == NULL;
            int start = 0;
            int end = length;

            if (expr->data.slice.step) {
                Value sv = evaluate_expression(expr->data.slice.step);
                if (sv.type == VAL_EXCEPTION) return sv;
                if (sv.type != VAL_INTEGER) return make_exception("slice step must be integer");
                step = sv.data.ival;
                if (step == 0) return make_exception("slice step cannot be zero");
            }

            if (step < 0) {
                start = length - 1;
                end = -1;
            }

            if (expr->data.slice.start) {
                Value st = evaluate_expression(expr->data.slice.start);
                if (st.type == VAL_EXCEPTION) return st;
                if (st.type != VAL_INTEGER) return make_exception("slice start must be integer");
                start = st.data.ival;
            }

            if (expr->data.slice.end) {
                Value ev = evaluate_expression(expr->data.slice.end);
                if (ev.type == VAL_EXCEPTION) return ev;
                if (ev.type != VAL_INTEGER) return make_exception("slice end must be integer");
                end = ev.data.ival;
            }

            if (!start_default && start < 0) start += length;
            if (!end_default && end < 0) end += length;

            if (step > 0) {
                if (start < 0) start = 0;
                if (start > length) start = length;
                if (end < 0) end = 0;
                if (end > length) end = length;
            } else {
                if (start < -1) start = -1;
                if (start >= length) start = length - 1;
                if (end < -1) end = -1;
                if (end >= length) end = length - 1;
            }

            if (src.type == VAL_STRING) {
                const char* s = src.data.sval ? src.data.sval : "";
                int capacity = length + 1;
                char* out = (char*)malloc(capacity);
                int w = 0;
                if (step > 0) {
                    for (int i = start; i < end; i += step) out[w++] = s[i];
                } else {
                    for (int i = start; i > end; i += step) out[w++] = s[i];
                }
                out[w] = '\0';
                v.type = VAL_STRING;
                v.data.sval = out;
                return v;
            }

            v.type = VAL_ARRAY;
            v.data.array.length = 0;
            v.data.array.capacity = 8;
            v.data.array.elements = (Value*)malloc(sizeof(Value) * v.data.array.capacity);
            if (step > 0) {
                for (int i = start; i < end; i += step) {
                    if (v.data.array.length >= v.data.array.capacity) {
                        v.data.array.capacity *= 2;
                        v.data.array.elements = (Value*)realloc(v.data.array.elements, sizeof(Value) * v.data.array.capacity);
                    }
                    v.data.array.elements[v.data.array.length++] = copy_value(src.data.array.elements[i]);
                }
            } else {
                for (int i = start; i > end; i += step) {
                    if (v.data.array.length >= v.data.array.capacity) {
                        v.data.array.capacity *= 2;
                        v.data.array.elements = (Value*)realloc(v.data.array.elements, sizeof(Value) * v.data.array.capacity);
                    }
                    v.data.array.elements[v.data.array.length++] = copy_value(src.data.array.elements[i]);
                }
            }
            return v;
        }
        case NODE_UNARY_OP: {
            Value rhs = evaluate_expression(expr->data.unary_op.operand);
            if (rhs.type == VAL_EXCEPTION) return rhs;
            if (expr->data.unary_op.op == NOT_OP) {
                v.type = VAL_BOOLEAN;
                v.data.bval = !value_to_boolean(rhs);
                return v;
            }
            if (expr->data.unary_op.op == UMINUS) {
                if (rhs.type == VAL_INTEGER) {
                    v.type = VAL_INTEGER; v.data.ival = -rhs.data.ival; return v;
                }
                if (rhs.type == VAL_FLOAT) {
                    v.type = VAL_FLOAT; v.data.fval = -rhs.data.fval; return v;
                }
            }
            return make_exception("invalid unary op");
        }
        case NODE_BINARY_OP: {
            Value left = evaluate_expression(expr->data.binary_op.left);
            Value right = evaluate_expression(expr->data.binary_op.right);
            int op = expr->data.binary_op.op;

            if (op == PLUS) {
                if (left.type == VAL_STRING || right.type == VAL_STRING ||
                    left.type == VAL_EXCEPTION || right.type == VAL_EXCEPTION) {
                    char* l = value_to_string(left);
                    char* r = value_to_string(right);
                    char* out = (char*)malloc(strlen(l) + strlen(r) + 1);
                    sprintf(out, "%s%s", l, r);
                    free(l); free(r);
                    v.type = VAL_STRING;
                    v.data.sval = out;
                    return v;
                }
            }
            if (left.type == VAL_EXCEPTION) return left;
            if (right.type == VAL_EXCEPTION) return right;

            if (left.type == VAL_INTEGER && right.type == VAL_INTEGER) {
                v.type = VAL_INTEGER;
                if (op == PLUS) v.data.ival = left.data.ival + right.data.ival;
                else if (op == MINUS) v.data.ival = left.data.ival - right.data.ival;
                else if (op == MULTIPLY) v.data.ival = left.data.ival * right.data.ival;
                else if (op == DIVIDE) {
                    if (right.data.ival == 0) return make_exception("division by zero");
                    v.data.ival = left.data.ival / right.data.ival;
                } else if (op == MODULO) {
                    if (right.data.ival == 0) return make_exception("modulo by zero");
                    v.data.ival = left.data.ival % right.data.ival;
                }
                else if (op == EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = left.data.ival == right.data.ival; }
                else if (op == NOT_EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = left.data.ival != right.data.ival; }
                else if (op == LESS_THAN) { v.type = VAL_BOOLEAN; v.data.bval = left.data.ival < right.data.ival; }
                else if (op == LESS_EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = left.data.ival <= right.data.ival; }
                else if (op == GREATER_THAN) { v.type = VAL_BOOLEAN; v.data.bval = left.data.ival > right.data.ival; }
                else if (op == GREATER_EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = left.data.ival >= right.data.ival; }
                else if (op == AND_OP) { v.type = VAL_BOOLEAN; v.data.bval = value_to_boolean(left) && value_to_boolean(right); }
                else if (op == OR_OP) { v.type = VAL_BOOLEAN; v.data.bval = value_to_boolean(left) || value_to_boolean(right); }
                return v;
            }

            if ((left.type == VAL_INTEGER || left.type == VAL_FLOAT) &&
                (right.type == VAL_INTEGER || right.type == VAL_FLOAT)) {
                double l = (left.type == VAL_FLOAT) ? left.data.fval : left.data.ival;
                double r = (right.type == VAL_FLOAT) ? right.data.fval : right.data.ival;
                v.type = VAL_FLOAT;
                if (op == PLUS) v.data.fval = l + r;
                else if (op == MINUS) v.data.fval = l - r;
                else if (op == MULTIPLY) v.data.fval = l * r;
                else if (op == DIVIDE) {
                    if (r == 0.0) return make_exception("division by zero");
                    v.data.fval = l / r;
                }
                else if (op == EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = l == r; }
                else if (op == NOT_EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = l != r; }
                else if (op == LESS_THAN) { v.type = VAL_BOOLEAN; v.data.bval = l < r; }
                else if (op == LESS_EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = l <= r; }
                else if (op == GREATER_THAN) { v.type = VAL_BOOLEAN; v.data.bval = l > r; }
                else if (op == GREATER_EQUAL) { v.type = VAL_BOOLEAN; v.data.bval = l >= r; }
                else if (op == AND_OP) { v.type = VAL_BOOLEAN; v.data.bval = value_to_boolean(left) && value_to_boolean(right); }
                else if (op == OR_OP) { v.type = VAL_BOOLEAN; v.data.bval = value_to_boolean(left) || value_to_boolean(right); }
                return v;
            }

            if (op == EQUAL || op == NOT_EQUAL) {
                int eq = 0;
                if (left.type == VAL_STRING && right.type == VAL_STRING) {
                    eq = strcmp(left.data.sval, right.data.sval) == 0;
                }
                v.type = VAL_BOOLEAN;
                v.data.bval = (op == EQUAL) ? eq : !eq;
                return v;
            }

            return make_exception("invalid binary op");
        }
        case NODE_FUNCTION_CALL: {
            if (strcmp(expr->data.func_call.name, "len") == 0) {
                if (expr->data.func_call.arg_count != 1) return make_exception("len expects 1 argument");
                Value arg = evaluate_expression(expr->data.func_call.arguments[0]);
                if (arg.type == VAL_EXCEPTION) return arg;
                if (arg.type != VAL_ARRAY && arg.type != VAL_STRING) return make_exception("len expects array or string");
                v.type = VAL_INTEGER;
                v.data.ival = (arg.type == VAL_ARRAY) ? arg.data.array.length : (int)strlen(arg.data.sval ? arg.data.sval : "");
                return v;
            }
            if (strcmp(expr->data.func_call.name, "range") == 0) {
                if (expr->data.func_call.arg_count != 2 && expr->data.func_call.arg_count != 3) {
                    return make_exception("range expects 2 or 3 arguments");
                }
                Value s = evaluate_expression(expr->data.func_call.arguments[0]);
                Value e = evaluate_expression(expr->data.func_call.arguments[1]);
                if (s.type == VAL_EXCEPTION) return s;
                if (e.type == VAL_EXCEPTION) return e;
                if (s.type != VAL_INTEGER || e.type != VAL_INTEGER) return make_exception("range arguments must be integer");
                int step = 1;
                if (expr->data.func_call.arg_count == 3) {
                    Value st = evaluate_expression(expr->data.func_call.arguments[2]);
                    if (st.type == VAL_EXCEPTION) return st;
                    if (st.type != VAL_INTEGER) return make_exception("range step must be integer");
                    step = st.data.ival;
                }
                if (step == 0) return make_exception("range step cannot be zero");
                v.type = VAL_ARRAY;
                v.data.array.length = 0;
                v.data.array.capacity = 8;
                v.data.array.elements = (Value*)malloc(sizeof(Value) * v.data.array.capacity);
                if (step > 0) {
                    for (int i = s.data.ival; i < e.data.ival; i += step) {
                        if (v.data.array.length >= v.data.array.capacity) {
                            v.data.array.capacity *= 2;
                            v.data.array.elements = (Value*)realloc(v.data.array.elements, sizeof(Value) * v.data.array.capacity);
                        }
                        Value iv; iv.type = VAL_INTEGER; iv.data.ival = i;
                        v.data.array.elements[v.data.array.length++] = iv;
                    }
                } else {
                    for (int i = s.data.ival; i > e.data.ival; i += step) {
                        if (v.data.array.length >= v.data.array.capacity) {
                            v.data.array.capacity *= 2;
                            v.data.array.elements = (Value*)realloc(v.data.array.elements, sizeof(Value) * v.data.array.capacity);
                        }
                        Value iv; iv.type = VAL_INTEGER; iv.data.ival = i;
                        v.data.array.elements[v.data.array.length++] = iv;
                    }
                }
                return v;
            }
            Value fn = get_variable(expr->data.func_call.name);
            if (fn.type != VAL_FUNCTION) {
                return make_exception("not a function");
            }
            ReturnValue r = call_function(fn.data.func.func_def, expr->data.func_call.arguments, expr->data.func_call.arg_count);
            if (r.has_exception) return r.value;
            if (r.has_return) return r.value;
            if (r.has_break || r.has_continue) return make_exception("break/continue outside loop");
            v.type = VAL_NULL;
            return v;
        }
        default:
            return make_exception("invalid expression");
    }
}

ReturnValue interpret(ASTNode* node) {
    ReturnValue rv; rv.has_return = 0; rv.has_exception = 0; rv.has_break = 0; rv.has_continue = 0;
    Value v; memset(&v, 0, sizeof(Value));

    switch (node->type) {
        case NODE_BLOCK:
            return interpret_block(node, 1);
        case NODE_DECLARATION: {
            v = evaluate_expression(node->data.declaration.initial_value);
            if (v.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = v; return rv; }
            declare_variable(node->data.declaration.name, v, node->data.declaration.is_const);
            return rv;
        }
        case NODE_ASSIGNMENT: {
            ASTNode* target = node->data.assignment.target;
            Value val = evaluate_expression(node->data.assignment.value);
            if (val.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = val; return rv; }
            if (target->type == NODE_IDENTIFIER) {
                set_variable(target->data.sval, val);
                return rv;
            }
            if (target->type == NODE_ARRAY_ACCESS) {
                int idxs[16];
                char* root = NULL;
                Value err; err.type = VAL_INTEGER; err.data.ival = 0;
                int count = collect_indices(target, idxs, 16, &root, &err);
                if (count < 0) { rv.has_exception = 1; rv.value = err; return rv; }
                Value base = get_variable(root);
                if (base.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = base; return rv; }
                if (base.type != VAL_ARRAY) { rv.has_exception = 1; rv.value = make_exception("invalid array assignment"); return rv; }
                if (!set_array_nested(&base, idxs, count, val)) {
                    rv.has_exception = 1; rv.value = make_exception("array index out of bounds"); return rv;
                }
                set_variable(root, base);
                return rv;
            }
            return rv;
        }
        case NODE_IF: {
            Value cond = evaluate_expression(node->data.if_stmt.condition);
            if (cond.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = cond; return rv; }
            if (value_to_boolean(cond)) {
                return interpret(node->data.if_stmt.if_branch);
            }
            ElifNode* e = node->data.if_stmt.elifs;
            while (e) {
                Value c = evaluate_expression(e->condition);
                if (c.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = c; return rv; }
                if (value_to_boolean(c)) {
                    return interpret(e->block);
                }
                e = e->next;
            }
            if (node->data.if_stmt.else_branch) {
                return interpret(node->data.if_stmt.else_branch);
            }
            return rv;
        }
        case NODE_WHILE: {
            while (1) {
                Value cond = evaluate_expression(node->data.while_loop.condition);
                if (cond.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = cond; return rv; }
                if (!value_to_boolean(cond)) break;
                ReturnValue inner = interpret(node->data.while_loop.body);
                if (inner.has_exception || inner.has_return) return inner;
                if (inner.has_break) break;
                if (inner.has_continue) continue;
            }
            return rv;
        }
        case NODE_FOR: {
            ReturnValue init = interpret(node->data.for_loop.init);
            if (init.has_exception || init.has_return || init.has_break || init.has_continue) return init;
            while (1) {
                Value cond = evaluate_expression(node->data.for_loop.condition);
                if (cond.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = cond; return rv; }
                if (!value_to_boolean(cond)) break;
                ReturnValue inner = interpret(node->data.for_loop.body);
                if (inner.has_exception || inner.has_return) return inner;
                if (inner.has_break) break;
                if (inner.has_continue) {
                    ReturnValue upd_on_continue = interpret(node->data.for_loop.update);
                    if (upd_on_continue.has_exception || upd_on_continue.has_return || upd_on_continue.has_break || upd_on_continue.has_continue) {
                        return upd_on_continue;
                    }
                    continue;
                }
                ReturnValue upd = interpret(node->data.for_loop.update);
                if (upd.has_exception || upd.has_return || upd.has_break || upd.has_continue) return upd;
            }
            return rv;
        }
        case NODE_FOR_EACH: {
            Value iterable = evaluate_expression(node->data.for_each_loop.iterable);
            if (iterable.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = iterable; return rv; }

            push_scope();
            Value loop_init;
            memset(&loop_init, 0, sizeof(Value));
            loop_init.type = VAL_NULL;
            loop_init.is_const = 0;
            declare_variable(node->data.for_each_loop.var_name, loop_init, 0);

            if (iterable.type == VAL_ARRAY) {
                for (int i = 0; i < iterable.data.array.length; i++) {
                    set_variable(node->data.for_each_loop.var_name, copy_value(iterable.data.array.elements[i]));
                    ReturnValue inner = interpret(node->data.for_each_loop.body);
                    if (inner.has_exception || inner.has_return) { pop_scope(); return inner; }
                    if (inner.has_break) break;
                    if (inner.has_continue) continue;
                }
            } else if (iterable.type == VAL_STRING) {
                const char* s = iterable.data.sval ? iterable.data.sval : "";
                for (int i = 0; s[i] != '\0'; i++) {
                    char buf[2];
                    buf[0] = s[i];
                    buf[1] = '\0';
                    Value ch;
                    ch.type = VAL_STRING;
                    ch.data.sval = strdup(buf);
                    ch.is_const = 0;
                    set_variable(node->data.for_each_loop.var_name, ch);
                    ReturnValue inner = interpret(node->data.for_each_loop.body);
                    if (inner.has_exception || inner.has_return) { pop_scope(); return inner; }
                    if (inner.has_break) break;
                    if (inner.has_continue) continue;
                }
            } else {
                pop_scope();
                rv.has_exception = 1;
                rv.value = make_exception("for-each expects array or string");
                return rv;
            }

            pop_scope();
            return rv;
        }
        case NODE_PRINT: {
            v = evaluate_expression(node->data.print_stmt.expr);
            if (v.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.value = v; return rv; }
            print_value(v);
            return rv;
        }
        case NODE_SCAN: {
            char buffer[1024];
            if (!fgets(buffer, sizeof(buffer), stdin)) buffer[0] = '\0';
            size_t len = strlen(buffer);
            if (len && buffer[len - 1] == '\n') buffer[len - 1] = '\0';
            Value sv; sv.type = VAL_STRING; sv.data.sval = strdup(buffer);
            set_variable(node->data.scan_stmt.name, sv);
            return rv;
        }
        case NODE_FUNCTION_DEF: {
            Value fv; fv.type = VAL_FUNCTION; fv.data.func.func_def = node; fv.data.func.name = node->data.func_def.name;
            declare_variable(node->data.func_def.name, fv, 1);
            return rv;
        }
        case NODE_FUNCTION_CALL: {
            Value eval = evaluate_expression(node);
            if (eval.type == VAL_EXCEPTION) {
                rv.has_exception = 1; rv.value = eval; return rv;
            }
            return rv;
        }
        case NODE_RETURN: {
            rv.has_return = 1;
            rv.value = evaluate_expression(node->data.return_stmt.expr);
            if (rv.value.type == VAL_EXCEPTION) { rv.has_exception = 1; rv.has_return = 0; }
            return rv;
        }
        case NODE_BREAK: {
            rv.has_break = 1;
            return rv;
        }
        case NODE_CONTINUE: {
            rv.has_continue = 1;
            return rv;
        }
        case NODE_TRY_CATCH: {
            ReturnValue tr = interpret(node->data.try_catch.try_block);
            if (tr.has_exception) {
                push_scope();
                declare_variable(node->data.try_catch.exception_var, tr.value, 0);
                ReturnValue cr = interpret(node->data.try_catch.catch_block);
                pop_scope();
                tr = cr;
            }
            if (node->data.try_catch.finally_block) {
                ReturnValue fr = interpret(node->data.try_catch.finally_block);
                if (fr.has_exception || fr.has_return || fr.has_break || fr.has_continue) return fr;
            }
            return tr;
        }
        case NODE_THROW: {
            rv.has_exception = 1;
            rv.value = evaluate_expression(node->data.throw_stmt.expr);
            return rv;
        }
        default:
            return rv;
    }
}

ReturnValue interpret_block(ASTNode* block, int new_scope) {
    ReturnValue rv; rv.has_return = 0; rv.has_exception = 0; rv.has_break = 0; rv.has_continue = 0;
    if (new_scope) push_scope();
    for (int i = 0; i < block->data.block.count; i++) {
        ReturnValue r = interpret(block->data.block.statements[i]);
        if (r.has_exception || r.has_return || r.has_break || r.has_continue) {
            if (new_scope) pop_scope();
            return r;
        }
    }
    if (new_scope) pop_scope();
    return rv;
}

ReturnValue call_function(ASTNode* func_def, ASTNode** arguments, int arg_count) {
    ReturnValue rv; rv.has_return = 0; rv.has_exception = 0; rv.has_break = 0; rv.has_continue = 0;
    call_depth++;
    if (call_depth > MAX_CALL_DEPTH) {
        call_depth--;
        rv.has_exception = 1;
        rv.value = make_exception("stack overflow");
        return rv;
    }
    push_scope();
    for (int i = 0; i < func_def->data.func_def.param_count; i++) {
        Value val; val.type = VAL_INTEGER; val.data.ival = 0;
        if (i < arg_count) {
            val = evaluate_expression(arguments[i]);
        }
        declare_variable(func_def->data.func_def.parameters[i], val, 0);
    }
    ReturnValue r = interpret(func_def->data.func_def.body);
    pop_scope();
    call_depth--;
    if (r.has_break || r.has_continue) {
        r.has_break = 0;
        r.has_continue = 0;
        r.has_exception = 1;
        r.value = make_exception("break/continue outside loop");
    }
    return r;
}

int collect_indices(ASTNode* node, int* idxs, int max, char** root_name, Value* err) {
    if (node->type == NODE_ARRAY_ACCESS) {
        if (max <= 0) return -1;
        int inner = collect_indices(node->data.array_access.array, idxs, max - 1, root_name, err);
        if (inner < 0) return -1;
        Value idxv = evaluate_expression(node->data.array_access.index);
        if (idxv.type == VAL_EXCEPTION) { *err = idxv; return -1; }
        if (idxv.type != VAL_INTEGER) { *err = make_exception("array index must be integer"); return -1; }
        idxs[inner] = idxv.data.ival;
        return inner + 1;
    }
    if (node->type == NODE_IDENTIFIER) {
        *root_name = node->data.sval;
        return 0;
    }
    *err = make_exception("invalid array assignment target");
    return -1;
}

int set_array_nested(Value* arr, int* idxs, int count, Value val) {
    if (count <= 0) return 0;
    if (arr->type != VAL_ARRAY) return 0;
    int i = idxs[0];
    if (i < 0 || i >= arr->data.array.length) return 0;
    if (count == 1) {
        arr->data.array.elements[i] = val;
        return 1;
    }
    Value* child = &arr->data.array.elements[i];
    return set_array_nested(child, idxs + 1, count - 1, val);
}

int main(int argc, char** argv) {
    global_symbols = create_symbol_table();
    current_symbols = global_symbols;

    if (argc == 2) {
        FILE* input_file = fopen(argv[1], "r");
        if (!input_file) {
            printf("error opening file: %s\n", argv[1]);
            return 1;
        }
        yyin = input_file;
    }

    yyparse();

    if (program_root) {
        ReturnValue r = interpret(program_root);
        if (r.has_break || r.has_continue) {
            Value e = make_exception("break/continue outside loop");
            fflush(stdout);
            char* s = value_to_string(e);
            printf("Unhandled exception: %s\n", s);
            free(s);
        } else if (r.has_exception) {
            fflush(stdout);
            char* s = value_to_string(r.value);
            printf("Unhandled exception: %s\n", s);
            free(s);
        }
    }
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "%s at line %d\n", s, line_num);
}
