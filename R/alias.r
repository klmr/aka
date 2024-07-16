#' Create an alias for an expression
#'
#' `alias(name = expr`) creates an alias for `expr` named `name`. Subsequently, `name` can (mostly) be used interchangeably with `expr`.
#' @usage \special{alias(name = expr, expr_env = parent.frame(), alias_env = parent.frame())}
#' @param name the alias name
#' @param expr an arbitrary R expression to be aliased by `name`; can contain interpolated expressions; see *Details*
#' @param expr_env the environment in which to evaluate the expression
#' @param alias_env the environment in which to create the alias
#' @return `alias()` is called for its side-effect and does not return a value.
#' @details
#' After executing `alias(name = expr)`, `name` can be used to refer to the value of `expr`. This is especially useful when `expr` is a complex expression that is used multiple times in the code. Unlike with regular assignment, `expr` will be reevaluated every time `name` is evaluated. This means that the value of `name` always stays up to date, similar to a [“reactive” expression][shiny::reactive]. On the flip side, it also means that accessing `name` can be very slow if evaluating `expr` is time-consuming.
#'
#' `expr` can contain interpolated expressions using the [bquote()] syntax (including splicing). These will be substituted at the time of defining the alias. See *Examples*.
#'
#' The parameters `expr_env` and `alias_env` are used to control the environments in which the expression is evaluated and the alias is created, respectively. Note that specifying the correct `expr_env` is particularly important when *assigning* to an alias: an expression can be evaluated inside a parent environment without having to specify `expr_env`; however, during assignment this would cause the assignee object to be copied into the calling environment. See *Examples* for a concrete example of this.
#' @examples
#' x = 'hello'
#' alias(ax = x)
#' ax    # prints 'hello'
#'
#' x = 'world'
#' ax    # prints 'world'
#'
#' ax = 'goodbye'
#' x     # prints 'goodbye'
#'
#' # Aliases can be created for complex expressions:
#' alias(mercedes = mtcars[grepl('^Merc ', rownames(mtcars)), ])
#' mercedes
#'
#' mercedes$vs = 0  # set all Mercedes engine types to V-shaped
#' mtcars
#'
#' # Aliases can contain interpolated expressions:
#' n = 1
#' m = 2
#' alias(s = .(n) + m)
#' s  # prints 3
#'
#' n = 10
#' m = 10
#' s  # prints 11
#'
#' alias_expr('s')  # prints `1 + m`
#'
#' # Be careful when assigning to an alias to an object in a parent environment:
#'
#' e = attach(new.env())
#' e$y = 'hello'
#'
#' alias(ay = y)
#'
#' # Works: `y` is found in the parent environment
#' ay  # prints 'hello'
#'
#' # But the following creates a *new variable* `y` in the current environment:
#' ay = 'world'
#' e$y   # prints 'hello', still!
#' y     # prints 'world'
#'
#' # To prevent this, use `expr_env`:
#' # alias(ay = y, expr_env = e)
#' \dontshow{
#' detach()
#' }
#' @export
alias = function (..., expr_env = parent.frame(), alias_env = parent.frame()) {
  args = match.call(expand.dots = FALSE)$...

  stopifnot(
    `alias() expects a single argument` = length(args) == 1L,
    `alias() expects an argument of the form 'name = expression'` = ! is.null(names(args))
  )

  expr = do.call(bquote, list(args[[1L]], where = expr_env, splice = TRUE))

  f = function (value) {
    if (missing(value)) {
      eval(expr, expr_env)
    } else {
      assign_expr = substitute(base::`<-`(expr, value), list(expr = expr, value = value))
      eval(assign_expr, expr_env)
    }
  }
  makeActiveBinding(names(args), f, alias_env)
}

#' @description `name %&=% expr` is the same as `alias(name = expr)`.
#' @export
#' @rdname alias
`%=&%` = function (name, expr) {
  name = as.character(substitute(name))
  caller = parent.frame()
  expr = substitute(expr)
  do.call(
    alias,
    stats::setNames(list(expr, caller, caller), c(name, 'expr_env', 'alias_env')),
  )
}

#' Query alias internals
#'
#' `alias_expr(alias)` returns the expression that was used to define an alias.
#' @param alias the name of an alias, as a string
#' @param envir the environment in which to look up the alias name (default: calling environment)
#' @return `alias_expr(alias)` returns an unevaluated R expression (a name or a call).
#' @export
#' @name getters
alias_expr = function (alias, envir = parent.frame()) {
  alias_internal_env(alias, envir)$expr
}

#' @description `alias_env(alias)` returns the environment in which the aliased expression is evaluated.
#' @return `alias_env(alias)` returns an environment.
#' @export
#' @rdname getters
alias_env = function (alias, envir = parent.frame()) {
  alias_internal_env(alias, envir)$expr_env
}

alias_internal_env = function (alias, envir) {
  environment(activeBindingFunction(alias, envir))
}
