hook_data_table = function () {
  setHook(
    packageEvent('data.table', 'attach'),
    \(pkgname, pkgpath) {
      # ‘data.table’ attaches its own version of `:=` that does nothing useful, so we can override it without causing issues. We do this by moving the attached exports in front of those from data.table in the `search()` path, after first ensuring that no other attached environment overwrites `:=`.

      data_table_env = as.environment(paste0('package:', pkgname))
      self_env = as.environment(paste0('package:', .packageName))

      next_walrus = get(':=', envir = parent.env(data_table_env))
      if (! identical(next_walrus, self_env$`:=`)) {
        return()
      }

      detach(environmentName(self_env), character.only = TRUE)
      getExportedValue('base', 'attach')(self_env, name = environmentName(self_env), warn.conflicts = FALSE)
    }
  )
}
