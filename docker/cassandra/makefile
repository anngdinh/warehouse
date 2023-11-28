include ../Makefile.Common

cqlsh:
	docker-compose exec cassandra cqlsh

# CREATE KEYSPACE tutorial WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': '3'}  AND durable_writes = true;
# USE tutorial;
# CREATE TABLE posts (    id int PRIMARY KEY,    title text,    content text );

# SELECT * FROM posts;
# INSERT INTO posts (id, title, content) VALUES(1,'First post!', 'This is my first post!');
# SELECT * FROM posts;