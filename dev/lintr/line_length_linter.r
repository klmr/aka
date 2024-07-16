line_length_linter = function (length = 120L) {
  general_msg = paste('Lines should not be more than', length, 'characters.')

  lintr::Linter(\(source_expression) {
    if (! lintr::is_lint_level(source_expression, 'file')) {
      return(list())
    }

    # Note that this will handle “comment-looking” lines in multi-line strings incorrectly. But that’s fine.
    comment_lines = grep('^\\s*#', source_expression$file_lines)
    line_lengths = nchar(source_expression$file_lines)
    long_lines = setdiff(which(line_lengths > length), comment_lines)

    Map(
      \(long_line, line_length) {
        lintr::Lint(
          filename = source_expression$filename,
          line_number = long_line,
          column_number = length + 1L,
          type = 'style',
          message = paste(general_msg, 'This line is', line_length, 'characters.'),
          line = source_expression$file_lines[long_line],
          ranges = list(c(1L, line_length))
        )
      },
      long_lines,
      line_lengths[long_lines]
    )
  })
}
