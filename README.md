# TZON

## Overview
TZON is a small educational programming language designed for learning compiler construction.  
It supports dynamic typing, functions, arrays, control flow, exceptions, basic I/O, and for-each iteration.

## Group Members
- İbrahim Utku ADANUR
- Oğuzhan ÇELİK
- Ali ALTIN
- Melih ATALAY

## Grammar in BNF Form
The formal grammar is provided in `BNF.txt`. It explains:
- Program and block structure
- Statements and expressions
- Function definitions and calls
- Arrays, indexing, and slicing
- Control flow (`if`, `while`, `for`, `for-each`)
- Exception handling (`try/catch/finally`, `throw`)

## Syntax

### Dynamic Typing
```tzon
var age = 23;
var pi = 3.14;
var isActive = true;
var message = "hello";
var initial = 't';

age = 24;
```

### Constants
```tzon
const MAX_SIZE = 100;
const APP_NAME = "TZON";
```

### Operators
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Comparison: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Logical: `&&`, `||`, `!`
- Assignment: `=`
- Compound assignment: `+=`, `-=`, `*=`, `/=`, `%=`
- Increment / decrement: `++`, `--`

### Control Structures

#### If-Elif-Else
```tzon
if x > 10 {
    print("x is greater than 10");   # output: x is greater than 10
} elif x == 10 {
    print("x is exactly 10");        # output: x is exactly 10
} else {
    print("x is less than 10");      # output: x is less than 10
}
```

#### While Loop
```tzon
var i = 0;
while i < 3 {
    print(i);    # output (line by line): 0, 1, 2
    i++;
}
```

#### Classic For Loop
```tzon
var i = 0;
for (i = 0; i < 5; i = i + 1) {
    print(i);    # output (line by line): 0, 1, 2, 3, 4
}
```

#### For-Each Loop
```tzon
var nums = [1, 2, 3];
for item in nums {
    print(item);   # output (line by line): 1, 2, 3
}

for ch in "abc" {
    print(ch);     # output (line by line): a, b, c
}
```

#### Break / Continue
```tzon
var i = 0;
while i < 10 {
    i++;
    if i == 3 {
        continue;
    }
    if i == 8 {
        break;
    }
    print(i);   # output (line by line): 1, 2, 4, 5, 6, 7
}
```

### Functions
```tzon
fn add(x, y) {
    return x + y;
}

fn giveOne() {
    return 1;
}

var result = add(5, 3);
```

### Arrays
```tzon
var empty = [];
var numbers = [1, 2, 3, 4, 5];
var mixed = [1, "hello", true, 'x'];

var first = numbers[0];
numbers[2] = 10;
```

### Slicing
```tzon
var nums = [0, 2, 4, 6, 8];
print(nums[1:]);      # [2, 4, 6, 8]
print(nums[:3]);      # [0, 2, 4]
print(nums[::-1]);    # [8, 6, 4, 2, 0]

var s = "abcdef";
print(s[1:5:2]);      # output: bd
```

### Exception Handling
```tzon
try {
    throw "something went wrong";
} catch (e) {
    print("caught: " + e);   # output: caught: something went wrong
} finally {
    print("cleanup");         # output: cleanup
}
```

### Input / Output
```tzon
var fileName = "";
print("enter file name");
scan(fileName);
print("you entered: " + fileName);   # output example: you entered: notes.txt
```

### Built-in Functions
```tzon
var seq = range(0, 10, 2);  # [0, 2, 4, 6, 8]
print(len(seq));            # output: 5
print(len("hello"));        # output: 5
```

## What's New in This Version
1. Dynamic typing and simplified variable handling
2. Arrays with indexing and nested access
3. Array/string slicing support
4. Exceptions with `try/catch/finally` and `throw`
5. Compound assignments and increment/decrement
6. `for-each` loop support (`for item in iterable { ... }`)
7. Boolean coercion for flexible condition checks

## Design Decisions
- Keep syntax small and readable for education
- Use dynamic typing to reduce boilerplate
- Keep block-based structure with `{}`
- Support both classic loops and for-each loops
- Add practical runtime features (arrays, slicing, exceptions)

## Running TZON Programs
1. Write code in a `.tzon` file.
2. Build and run:

```bash
make
./myprog example.tzon
```

## Submission Contents
This repository contains:
- `myprog.l` (lexer)
- `myprog.y` (parser + interpreter)
- `BNF.txt` (grammar)
- `README.md` (report)
- Example programs under `example-programs/`

## Example Programs
- `example.tzon`
- `example-programs/arrays.tzon`
- `example-programs/exceptions.tzon`
- `example-programs/functions.tzon`
- `example-programs/loops.tzon`
- `example-programs/io.tzon`
- `example-programs/uncaught.tzon`
- `example-programs/new_features.tzon`
