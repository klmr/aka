pkg = local({
  install_status_line = utils::tail(readLines(file.path(dirname(getwd()), '00install.out')), 1L)
  sub('.*DONE \\((.*)\\)$', '\\1', install_status_line)
})

testthat::test_check(pkg)
