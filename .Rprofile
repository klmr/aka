try(rprofile::load())

options(
  lintr.linter_file = file.path(getwd(), 'dev', 'lintr', 'config')
)

local({
  .pkgdir = getwd()

  build = function () {
    .write_license_file()
    .rcmd('build', .pkgdir)
  }

  check = function (as_cran = TRUE) {
    unlink(.bundle_path(), force = TRUE)
    .rcmd('check', if (as_cran) '--as-cran', .bundle())
  }

  readme = function () {
    devtools::document()
    devtools::build_readme()
  }

  reload = function (export_all = FALSE) {
    devtools::load_all(.pkgdir, export_all = export_all)
  }

  site = function () {
    readme()
    pkgdown::build_site()
  }

  .bundle = function () {
    bundle = .bundle_path()
    if (! file.exists(bundle)) build()
    bundle
  }

  .bundle_path = function () {
    desc = .desc()
    file.path(.pkgdir, paste0(desc$Package, '_', desc$Version, '.tar.gz'))
  }

  .desc = function () {
    d = as.list(read.dcf(file.path(.pkgdir, 'DESCRIPTION'))[1L, ])
    d$Authors = eval(parse(text = d$`Authors@R`))
    d
  }

  .r = function (...) {
    rbin = file.path(R.home('bin'), 'R')
    system2(rbin, shQuote(c(...)))
  }

  .rcmd = function (...) {
    .r('CMD', ...)
  }

  .write_license_file = function () {
    authors = toString(format(.desc()$Authors, c('given', 'family')))
    license_text = sprintf('YEAR: 2024\nCOPYRIGHT HOLDER: %s', authors)
    writeLines(license_text, file.path(.pkgdir, 'LICENSE'))
  }

  attach(mget(ls()), name = 'rprofile-utils')
})
