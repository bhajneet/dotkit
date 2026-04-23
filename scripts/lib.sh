#!/bin/sh
# Shared utilities

# Print non-blank, non-comment lines from a config file.
parse_list() {
  grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$'
}
