# TZON

## Overview
TZON is a small educational language with dynamic typing. It supports functions, arrays, exceptions, control flow, and basic I/O.

## Group Members
- İbrahim Utku ADANUR
- Oğuzhan ÇELİK
- Ali ALTIN
- Melih ATALAY

## Grammar in BNF Form
The formal grammar is in BNF.txt. It defines:
- Program structure
- Declarations and assignments
- Expressions and operators
- Control flow (if/elif/else, while, for)
- Functions and calls
- Arrays and indexing
- Exception handling (try/catch/finally, throw)

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
const NAME = "TZON";
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

#### For
```tzon
for (i = 0; i < 5; i = i + 1) {
    print(i);
}
```

### Functions
```tzon
fn add(x, y) {
    return x + y;
}

var result = add(5, 3);
```

### Arrays
```tzon
var numbers = [1, 2, 3];
var first = numbers[0];
nums[1] = 99;
```

### Exceptions
```tzon
try {
    throw "error";
} catch (e) {
    print("caught: " + e);
} finally {
    print("cleanup");
}
```

### Input/Output
```tzon
print("hello world");
scan(fileName);
```

## Design Decisions
1. **Dynamic typing** for a smaller language and simpler syntax.
2. **Arrays** and **exceptions** add power and align with Step2 requirements.
3. **For loop** adds extra control flow beyond the minimum.
4. `scan` reads a full line from stdin as a string.

## Running TZON Programs
1. Write your code in a `.tzon` file.
2. Build and run:

```bash
make
./myprog example.tzon
```

## Example Program
See `example.tzon` for a complete demonstration of the language.

## Additional Examples
You can also test features individually in `example-programs/`:
- `arrays.tzon`
- `exceptions.tzon`
- `functions.tzon`
- `loops.tzon`
- `io.tzon`
- `uncaught.tzon`
