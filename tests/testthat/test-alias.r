test_that('alias to name can be created', {
  x = 'hello'
  alias(ax = x)

  expect_equal(ax, 'hello')
})

test_that('alias to name correctly tracks updates', {
  x = 'hello'
  alias(ax = x)
  x = 'world'

  expect_equal(ax, 'world')
})

test_that('alias to name can be updated', {
  x = 'hello'
  alias(ax = x)
  ax = 'goodbye'

  expect_equal(x, 'goodbye')
})

test_that('alias to complex expression can be created', {
  x = data.frame(a = 1 : 2, b = c('a', 'b'))
  i = 1L
  alias(ax = x[i, ])

  expect_equal(ax[[2L]], x[1L, 2L])
})

test_that('alias to complex expression correctly tracks updates', {
  x = data.frame(a = 1 : 2, b = c('a', 'b'))
  i = 1L
  alias(ax = x[i, ])

  i = 2L

  expect_equal(ax[[2L]], x[2L, 2L])

  x[i, 1L] = 5L

  expect_equal(ax[[1L]], x[2L, 1L])

  x = data.frame(a = 3 : 4, b = c('c', 'd'))

  expect_equal(ax[[2L]], x[2L, 2L])
})

test_that('alias to complex expression can be updated', {
  x = data.frame(a = 1 : 2, b = c('a', 'b'))
  i = 1L
  alias(ax = x[i, ])

  ax[1L] = 3L

  expect_equal(x[1L, 1L], 3L)

  i = 2L
  ax[1L] = 4L

  expect_equal(x[2L, 1L], 4L)

  ax = data.frame(a = 5L, b = 'c')

  expect_equal(x, data.frame(a = c(3L, 5L), b = c('a', 'c')))
})

test_that('an alias can be created in a different environment', {
  e1 = new.env()
  e2 = new.env()

  alias(ax = x, expr_env = e1, alias_env = e2)

  e1$x = 'hello'

  expect_equal(e2$ax, 'hello')

  e1$x = 'world'

  expect_equal(e2$ax, 'world')

  e2$ax = 'goodbye'

  expect_equal(e1$x, 'goodbye')
})

test_that('alias assignment works with `value` inside expression', {
  # This test ensures that the `substitute` expression with the name `value` in the assignment does the right thing.
  alias(a = x[value])

  x = c(4, 5)
  value = 2L

  expect_equal(a, 5)

  a = 42

  expect_equal(x, c(4, 42))
  expect_equal(value, 2L)
})

test_that('alias() expects exactly one named argument in `...`', {
  expect_error(alias(1), 'alias() expects an argument of the form', fixed = TRUE)
  expect_error(alias(1, 2), 'alias() expects a single argument', fixed = TRUE)
  expect_error(alias(x = 1, 2), 'alias() expects a single argument', fixed = TRUE)
  expect_error(alias(1, y = 2), 'alias() expects a single argument', fixed = TRUE)
})

test_that('alias expression can contain quoted macro', {
  x = 1L
  alias(ax = .(x))

  expect_equal(ax, 1L)

  x = 2L

  expect_equal(ax, 1L)

  alias(ax = .(x) + y)
  y = 3L

  expect_equal(ax, 5L)

  x = 3L
  y = 10L

  expect_equal(ax, 12L)
})

test_that('alias expressions can have arguments spliced in', {
  x = y = z = 1L
  alias(s = sum(..(c(x, quote(y), z))))

  expect_equal(s, 3L)

  x = y = z = 2L

  expect_equal(s, 4L)
  expect_identical(alias_expr('s'), quote(sum(1L, y, 1L)))
})

test_that('the alias operator := can create aliases', {
  x = y = z = 1L
  s := sum(..(c(x, quote(y), z)))

  expect_equal(s, 3L)
  expect_identical(alias_expr('s'), quote(sum(1L, y, 1L)))
})

test_that('alias operator has the correct operator precedence', {
  x = y = 1L
  s := x + y

  expect_equal(s, 2L)
  expect_identical(alias_expr('s'), quote(x + y))
})
