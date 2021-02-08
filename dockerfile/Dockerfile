FROM amazon/opendistro-for-elasticsearch:1.12.0
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch repository-gcs
ADD scripts/ /usr/share/elasticsearch/bin/scripts
ENTRYPOINT ["/usr/share/elasticsearch/bin/scripts/entrypoint.sh"]
