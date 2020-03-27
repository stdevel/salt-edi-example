restore_website:
  file.managed:
    - name: /srv/www/htdocs/index.html
    - source: salt://website/index.html.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
