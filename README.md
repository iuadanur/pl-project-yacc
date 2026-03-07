# TZON

## Overview
TZON is a simple educational programming language. It supports static types, functions, control flow, and basic I/O. The syntax is intentionally small and readable.

## Group Members
- İbrahim Utku ADANUR
- Oğuzhan ÇELİK
- Ali ALTIN
- Melih ATALAY

## Grammar in BNF Form
The formal grammar is defined in BNF.txt. It describes:
- Program structure
- Declarations and assignments
- Expressions and operators
- Control flow
- Function definitions and calls
- I/O statements

## Syntax

### Data Types
- `int`: Integer values
- `float`: Floating point numbers
- `bool`: Boolean values (`true` or `false`)
- `string`: Text enclosed in double quotes
- `char`: Single character enclosed in single quotes

### Variable Declaration and Assignment
```tzon
var int age = 23;
var float pi = 3.14;
var bool isActive = true;
var string message = "hello";
var char initial = 't';

age = 24;
```

### Constants
```tzon
const int MAX_SIZE = 100;
const string NAME = "TZON";
```

### Operators
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Comparison: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Logical: `&&`, `||`, `!`
- Assignment: `=`

### Control Structures

#### If-Elif-Else
```tzon
if x > 10 {
    print("x is greater than 10");
} elif x == 10 {
    print("x is exactly 10");
} else {
    print("x is less than 10");
}
```

#### While
```tzon
while age < 18 {
    print("not old enough");
    age = age + 1;
}
```

### Functions
```tzon
fn add(int x, int y) : int {
    return x + y;
}

var int result = add(5, 3);
```

### Comments
```tzon
# this is a comment
var string name = "john"; # inline comment
```

### Input/Output
```tzon
print("hello world");
scan(fileName);
```

## Design Decisions
1. **Simplicity**: A small, readable syntax for beginners.
2. **Static Typing**: Explicit type annotations for clarity.
3. **Block Scoping**: Braces for block structure.
4. **Readable Logic**: `&&`, `||`, and `!` for boolean logic.

## Running TZON Programs
1. Write your code in a file with the `.tzon` extension.
2. Build and run:

```bash
make
./myprog example.tzon
```

## Example Program
See `example.tzon` for a complete demonstration of the language.
