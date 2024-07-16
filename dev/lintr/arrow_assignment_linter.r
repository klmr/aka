arrow_assignment_linter = function () {
  xpath = '//LEFT_ASSIGN | //RIGHT_ASSIGN'
  lint_message_fmt = 'Use =, not %s, for assignment.'

  lintr::Linter(\(source_expression) {
    if (! lintr::is_lint_level(source_expression, 'expression')) {
      return(list())
    }

    xml = source_expression$xml_parsed_content
    bad_expr = xml2::xml_find_all(xml, xpath)

    if (length(bad_expr) == 0L) {
      return(list())
    }

    operator = xml2::xml_text(bad_expr)

    lint_message = sprintf(lint_message_fmt, operator)
    lintr::xml_nodes_to_lints(bad_expr, source_expression, lint_message, type = 'style')
  })
}
