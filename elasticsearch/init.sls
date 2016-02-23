{%- from 'elasticsearch/map.jinja' import elasticsearch with context %}
{% set config = salt['pillar.get']('elasticsearch:config', '') %}
{% set version = salt['pillar.get']('elasticsearch:version', [])|join('.') %}

include:
  - elasticsearch.repo

elasticsearch:
  pkg:
    - installed
    - version: {{ version }}
    - name: {{ elasticsearch.pkg }}
    - require:
      - pkgrepo: elasticsearch-repo

  file.serialize:
    - name: /etc/elasticsearch/elasticsearch.yml
    - dataset_pillar: elasticsearch:config
    - formatter: YAML
    - user: elasticsearch
    - group: elasticsearch
    - mode: 644
    - require:
      - pkg: elasticsearch

  service:
    - name: {{ elasticsearch.svc }}
    - running
    - enable: True
    - require:
      - pkg: elasticsearch
      - augeas: elasticsearch-sysconfig
      - file: elasticsearch

elasticsearch-sysconfig:
  augeas:
    - change
    - context: /files{{ elasticsearch.syscfg }}
    - changes:
      {% for key, val in elasticsearch.sysconfig.iteritems() %}
      - set {{ key }} {{ val }}
      {% endfor %}
    - formatter: YAML
    - require:
      - pkg: elasticsearch