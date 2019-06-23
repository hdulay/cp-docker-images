CREATE STREAM pageviews
  (viewtime BIGINT,
   userid VARCHAR,
   pageid VARCHAR)
  WITH (KAFKA_TOPIC='pageviews',
        VALUE_FORMAT='DELIMITED');

