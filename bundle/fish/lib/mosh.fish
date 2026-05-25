function ms
  set TARGET $argv
  # Add work-specific branches here in your fork, e.g.:
  #   if string match '*.your-company.local' $TARGET
  #     mosh --server /path/to/custom/mosh-server $TARGET
  #     return
  #   end
  mosh $TARGET
end
