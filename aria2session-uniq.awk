/^[^ \t]/ {
  # Add new URI if NAME is not empty
  if (NAME) {
    URIS[NAME] = sprintf("%s\n%s", NAME, OPTIONS)
  }
  # Reset
  NAME = $0
  OPTIONS = ""
  SAFE = 1
}

/^[ \t]/ {
  OPTIONS = sprintf("%s%s\n", OPTIONS, $0)
  SAFE = 0
}

END {
  if (!SAFE) {
    URIS[NAME] = sprintf("%s\n%s", NAME, OPTIONS)
  }

  for (NAME in URIS) {
    printf("%s", URIS[NAME])
  }
}
