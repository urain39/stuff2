BEGIN {
  FS="@#$_&-"
}

/^\S.+$/ {
  # Add new URI if NAME is not empty
  if (NAME) {
    URIS[NAME] = sprintf("%s\n%s", NAME, OPTIONS)
  }
  # Reset
  NAME = $0
  OPTIONS = ""
}

/^\s.+$/ {
  OPTIONS = sprintf("%s%s\n", OPTIONS, $0)
}

END {
  for (NAME in URIS) {
    printf("%s", URIS[NAME])
  }
}
