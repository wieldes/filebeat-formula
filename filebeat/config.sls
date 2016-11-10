{% from "filebeat/map.jinja" import conf with context %}

{% set ssl_cert = salt['pillar.get']('filebeat:logstash:tls:ssl_cert', 'salt://filebeat/files/ca.pem') %}
{% set ssl_cert_path = salt['pillar.get']('filebeat:logstash:tls:ssl_cert_path') %}
{% set managed_cert = salt['pillar.get']('filebeat:logstash:tls:managed_cert', True) %}
{% if salt['pillar.get']('filebeat:logstash:tls:enabled', False) and ssl_cert and ssl_cert_path and managed_cert %}
{{ ssl_cert_path }}:
  file.managed:
    - source: {{ ssl_cert }}
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - filebeat.config
{% endif %}

filebeat.config:
  file.managed:
    - name: {{ conf.config_path }}
    - source: {{ conf.config_source }}
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
# unfortunately, filebeat is restarted by cmd until tty issues are resolved
      - cmd: filebeat.service

{% if conf.runlevels_install %}
filebeat.runlevels_install:
  cmd.run:
    - name: update-rc.d filebeat defaults 95 10
{% endif %}
