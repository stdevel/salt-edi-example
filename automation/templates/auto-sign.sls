{# test client is sending new key -- accept this key #}
{% if 'act' in data and data['act'] == 'pend' and data['id'].startswith('client') %}
minion_add:
  wheel.key.accept:
    - match: {{ data['id'] }}
{% endif %}