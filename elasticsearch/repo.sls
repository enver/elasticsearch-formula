{% set version = salt['pillar.get']('elasticsearch:version', [])[:2]|join('.') %}
{%- if grains['os_family'] == 'RedHat' %}
elasticsearch-repo-key:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - onlyif: "[ `rpm -qi gpg-pubkey-d88e42b4-52371eca | wc -l` -le 1 ]"

elasticsearch-repo:
  pkgrepo:
    - managed
    - humanname: Elasticsearch repository for {{ version }} packages
    - baseurl: http://packages.elastic.co/elasticsearch/{{ version }}/centos
    - gpgcheck: 1
    - gpgkey: https://packages.elastic.co/GPG-KEY-elasticsearch
    - enabled: 1
    - require:
      - cmd: elasticsearch-repo-key
{%- endif %}
