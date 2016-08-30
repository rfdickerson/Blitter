DROP KEYSPACE IF EXISTS blitter;
CREATE KEYSPACE blitter with replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
USE blitter;

CREATE TABLE bleet(id uuid, author text, message text, subscriber text, postdate timestamp, primary key(id));
CREATE INDEX on bleet(author);
CREATE INDEX on bleet(subscriber);
CREATE TABLE subscription(id uuid primary key, author text, subscriber text);
CREATE INDEX on subscription(author);

INSERT INTO bleet (id, author, message, subscriber, postdate) VALUES (uuid(), 'Robert', 'Having a blast at Try! Swift', 'Jack', toTimestamp(now()));
INSERT INTO bleet (id, author, message, subscriber, postdate) VALUES (uuid(), 'Jack', 'Cassandra Rocks!', 'Robert', toTimestamp(now()));

INSERT INTO subscription (id, author, subscriber) VALUES (uuid(), 'Robert', 'Jack');