#!/bin/sh
# Shared utilities sourced by all provision scripts.

# Print non-blank, non-comment lines from a config file.
parse_list() {
  grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$'
}
