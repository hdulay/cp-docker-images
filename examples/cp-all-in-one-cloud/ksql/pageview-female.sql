set 'producer.interceptor.classes'='io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor';
set 'consumer.interceptor.classes'='io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor';

CREATE STREAM pageviews_female AS SELECT users.userid AS userid, pageid, regionid, gender FROM pageviews LEFT JOIN users ON pageviews.userid = users.userid WHERE gender = 'FEMALE';
