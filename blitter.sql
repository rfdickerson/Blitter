DROP KEYSPACE IF EXISTS blitter;
CREATE KEYSPACE blitter with replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
USE blitter;
CREATE TABLE tweets(id uuid, author text, tweet text, subscriber text, timestamp timestamp, primary key(id));
CREATE INDEX on tweets(author);
CREATE INDEX on tweets(subscriber);
CREATE TABLE subscription(id uuid primary key, author text, subscriber text) ;
CREATE INDEX on subscription(author);

INSERT INTO tweets (id, author, tweet, subscriber, timestamp) VALUES (uuid(), 'Robert', 'Having a blast at Try! Swift', 'Jack', toTimestamp(now()));
INSERT INTO tweets (id, author, tweet, subscriber, timestamp) VALUES (uuid(), 'Jack', 'Cassandra Rocks!', 'Robert', toTimestamp(now()));
