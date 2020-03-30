# restart apache if not running
{% if data['apache2'] and data['apache2']['running'] == false %}
restart-apache2:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - restart_apache2
{% endif %}
