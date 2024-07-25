# Choosing the Right Technique

## Dot Repeat

```plainetxt
* Hey, I just met you
* and this is crazy
* but here’s my number
* So call me maybe
```

## Substitution

```
stdio.h
fcntl.h
unistd.h
stdlib.h
```

### Desired Result:

```
#include "stdio.h"
#include "fcntl.h"
#include "unistd.h"
#include "stdlib.h"
```

```vim
:s/.*/#include "&"/
```

## Macros

```bash
x = 1  # Initialize x
y = 2  # Initialize y
z = x + y  # Sum x and y
print(z)  # Print the result
```

### Desired Result:

```bash
# NOTE: Initialize x
x = 1
# NOTE: Initialize y
y = 2
# NOTE: Sum x and y
z = x + y
# NOTE: Print the result
print(z)
```

