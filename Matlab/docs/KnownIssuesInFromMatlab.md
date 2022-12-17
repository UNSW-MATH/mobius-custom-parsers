# Known Issues in FromMatlab

## Applying a known funcion to a sum

### Issue
Parsing `"sin(x+y)"` will result in `sin(x)+sin(y)`.

### Cause
The FromMatlab commands return `map[evalhf](sin,(x +~ y))`, if `x` and `y` were defined the `x +~ y` would result in a single object, and this would work. Since `x` and `y` often represent unspecified variables, this fails.

### Workaround
This behaviour only affects known functions. To work around this we replace `sin` with `MAPLE_sin` to make sure this doesn't match a known function.

## Missing brackets with plus/minus signs

### Issue
The Maple langauge does not allow for expressions like `x +- y` or `x/-y`, but MATLAB does.

### Workaround

To allows the string is repeatly search and the following substitutions are made until the string is stable.

| Expression    | Substituion  |
| ------------- |--------------|
| `--` or `++`  | `+`          |
| `+-` or `-+`  | `-`          |
| `*+`          | `*`          |
| `*-`          | `*(-1)*`     |
| `/+`          | `/`          |
| `/-`          | `/(-1)/`     |
