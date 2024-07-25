
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <span class="pkg">aka</span> <img src="man/figures/logo.svg" align="right" alt="" width="120" />

<code>aka::alias()</code> allows creating aliases for other R names or
arbitrarily complex R expressions. Accessing the alias acts as-if the
aliased expression were invoked instead, and continuously reflects the
current value of that expression: updates to the original expression
will be reflected in the alias; and updates to the alias will
automatically be reflected in the original expression.

## Installation

<span class="pkg">aka</span> is on CRAN; install it via:

``` r
install.packages('aka')
```

You can also install the development version of
<span class="pkg">aka</span> from GitHub:

``` r
pak::pak('klmr/aka')
```

## Example

The simplest case aliases another name:

``` r
library(aka)
```

``` r
x = 'hello'
alias(ax = x)
ax
```

    ## [1] "hello"

``` r
x = 'world'
ax
```

    ## [1] "world"

``` r
ax = 'goodbye'
x
```

    ## [1] "goodbye"

As we can see, updates to the original names are reflected in the alias,
and updates to the alias are reflected in the original name.

As an alternative syntax, we can use an “assignment-like” form:

``` r
ax %=&% x
```

This form is strictly equivalent to `alias(ax = x)`.

Furthermore, aliases can be created for complex expressions:

``` r
mercedes %=&% mtcars[grep('^Merc ', rownames(mtcars)), ]
mercedes
```

|             |  mpg | cyl |  disp |  hp | drat |   wt | qsec |  vs |  am | gear | carb |
|:------------|-----:|----:|------:|----:|-----:|-----:|-----:|----:|----:|-----:|-----:|
| Merc 240D   | 24.4 |   4 | 146.7 |  62 | 3.69 | 3.19 | 20.0 |   1 |   0 |    4 |    2 |
| Merc 230    | 22.8 |   4 | 140.8 |  95 | 3.92 | 3.15 | 22.9 |   1 |   0 |    4 |    2 |
| Merc 280    | 19.2 |   6 | 167.6 | 123 | 3.92 | 3.44 | 18.3 |   1 |   0 |    4 |    4 |
| Merc 280C   | 17.8 |   6 | 167.6 | 123 | 3.92 | 3.44 | 18.9 |   1 |   0 |    4 |    4 |
| Merc 450SE  | 16.4 |   8 | 275.8 | 180 | 3.07 | 4.07 | 17.4 |   0 |   0 |    3 |    3 |
| Merc 450SL  | 17.3 |   8 | 275.8 | 180 | 3.07 | 3.73 | 17.6 |   0 |   0 |    3 |    3 |
| Merc 450SLC | 15.2 |   8 | 275.8 | 180 | 3.07 | 3.78 | 18.0 |   0 |   0 |    3 |    3 |

… and we can even update parts of an aliased expression to modify parts
of the original, underlying objects:

``` r
# Set all Mercedes engine types to V-shaped
mercedes$vs = 0

mtcars[8 : 14, 'vs', drop = FALSE]
```

|             |  vs |
|:------------|----:|
| Merc 240D   |   0 |
| Merc 230    |   0 |
| Merc 280    |   0 |
| Merc 280C   |   0 |
| Merc 450SE  |   0 |
| Merc 450SL  |   0 |
| Merc 450SLC |   0 |

However, be careful when assigning to an alias of an object in a parent
environment:

``` r
e = attach(new.env())
e$y = 'hello'

alias(ay = y)
```

This will seem to work:

``` r
ay
```

    ## [1] "hello"

… because `y` is found in the attached *parent environment* after it was
not found in the current scope; however, the following will create a
*new* variable `y` in the current scope, and leave `e$y` untouched:

``` r
ay = 'world'
e$y
```

    ## [1] "hello"

``` r
y
```

    ## [1] "world"

To prevent this: pass `env_expr` when defining the alias:

``` r
alias(ay = y, expr_env = e)
```

## Why?!

<span class="pkg">aka</span> implements an approach to [reactive
programming](https://en.wikipedia.org/wiki/Reactive_programming) that is
complementary to [Shiny’s reactive programming
API](https://mastering-shiny.org/basic-reactivity.html). Superficially,
the mechanism resembles [references in
C++](https://en.wikipedia.org/wiki/Reference_(C%2B%2B)). However, under
the hood they are fundamentally different. In particular,
<span class="pkg">aka</span> aliases are currently implemented as
[active
bindings](https://stat.ethz.ch/R-manual/R-devel/library/base/html/bindenv.html),
whereas C++ references are direct aliases that are either replaced with
the actual value by the compiler or converted to pointers.

This package purely provides syntactic sugar for active bindings, it
does not add any *functionality* over manually calling
`makeActiveBinding()` (the aliases created by
<span class="pkg">aka</span> *are* active bindings). It is also
superficially similar to the
<span class="pkg">[pointr](https://cran.r-project.org/package=pointr)</span>
package. Unlike the latter, the API of <span class="pkg">aka</span> uses
proper R expressions instead of being [stringly
typed](https://wiki.c2.com/?StringlyTyped), and its usage and
implementation are conceptually more straightforward and idiomatic. To
allow programming on the language, <span class="pkg">aka</span> supports
`bquote()`’s macro interpolation syntax rather than requiring string
manipulation. It also allows explicitly controlling the evaluating and
defining environments of the alias.

Truth be told, for now I have not yet identified a compelling use-case
for this package; it mainly exists to explore the concepts, and to
provide a playground. Another purpose is to act as a tutorial for the
implementation of a simple but powerful non-standard evaluation API. If
you’ve found an interesting use-case, please reach out: I am genuinely
curious!
