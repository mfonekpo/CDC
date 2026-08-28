FROM fluent/fluentd:edge-debian

USER root

RUN mkdir -p /home/fluent/.local/share/gem/ruby/3.4.0/cache \
    && chown -R fluent:fluent /home/fluent/.local
    
RUN fluent-gem install fluent-plugin-grafana-loki

USER fluent
