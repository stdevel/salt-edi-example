# restore website
restore-website:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - restore_website
