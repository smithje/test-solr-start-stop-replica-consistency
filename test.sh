#!/usr/bin/env bash
set -eux

# Setup environment
docker-compose build --pull --force-rm
docker-compose pull
docker-compose up --force-recreate --always-recreate-deps --renew-anon-volumes --remove-orphans -d zookeeper solr-1 solr-2

# Wait for nodes to come up
docker-compose run --rm tester bash -c "while ! nc -z solr-1 8983; do sleep 1; done"
docker-compose run --rm tester bash -c "while ! nc -z solr-2 8983; do sleep 1; done"

# Create the collection, 1 shard, 2 replicas
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/admin/collections?action=CREATE&name=test&replicationFactor=2&numShards=1'"

# Check collection status
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/admin/collections?action=clusterstatus&wt=json'"

docker-compose stop solr-2

# Add data
docker-compose run --rm tester bash -c "curl -X POST -H 'Content-Type: application/json' 'http://solr-1:8983/solr/test/update/json/docs?commit=true' --data-binary '[{\"id\": \"0\", \"num\": 0}, {\"id\": \"1\", \"num\": 1}, {\"id\": \"2\", \"num\": 2}, {\"id\": \"3\", \"num\": 3}, {\"id\": \"4\", \"num\": 4}, {\"id\": \"5\", \"num\": 5}, {\"id\": \"6\", \"num\": 6}, {\"id\": \"7\", \"num\": 7}, {\"id\": \"8\", \"num\": 8}, {\"id\": \"9\", \"num\": 9}, {\"id\": \"10\", \"num\": 10}, {\"id\": \"11\", \"num\": 11}, {\"id\": \"12\", \"num\": 12}, {\"id\": \"13\", \"num\": 13}, {\"id\": \"14\", \"num\": 14}, {\"id\": \"15\", \"num\": 15}, {\"id\": \"16\", \"num\": 16}, {\"id\": \"17\", \"num\": 17}, {\"id\": \"18\", \"num\": 18}, {\"id\": \"19\", \"num\": 19}, {\"id\": \"20\", \"num\": 20}, {\"id\": \"21\", \"num\": 21}, {\"id\": \"22\", \"num\": 22}, {\"id\": \"23\", \"num\": 23}, {\"id\": \"24\", \"num\": 24}, {\"id\": \"25\", \"num\": 25}, {\"id\": \"26\", \"num\": 26}, {\"id\": \"27\", \"num\": 27}, {\"id\": \"28\", \"num\": 28}, {\"id\": \"29\", \"num\": 29}, {\"id\": \"30\", \"num\": 30}, {\"id\": \"31\", \"num\": 31}, {\"id\": \"32\", \"num\": 32}, {\"id\": \"33\", \"num\": 33}, {\"id\": \"34\", \"num\": 34}, {\"id\": \"35\", \"num\": 35}, {\"id\": \"36\", \"num\": 36}, {\"id\": \"37\", \"num\": 37}, {\"id\": \"38\", \"num\": 38}, {\"id\": \"39\", \"num\": 39}, {\"id\": \"40\", \"num\": 40}, {\"id\": \"41\", \"num\": 41}, {\"id\": \"42\", \"num\": 42}, {\"id\": \"43\", \"num\": 43}, {\"id\": \"44\", \"num\": 44}, {\"id\": \"45\", \"num\": 45}, {\"id\": \"46\", \"num\": 46}, {\"id\": \"47\", \"num\": 47}, {\"id\": \"48\", \"num\": 48}, {\"id\": \"49\", \"num\": 49}, {\"id\": \"50\", \"num\": 50}, {\"id\": \"51\", \"num\": 51}, {\"id\": \"52\", \"num\": 52}, {\"id\": \"53\", \"num\": 53}, {\"id\": \"54\", \"num\": 54}, {\"id\": \"55\", \"num\": 55}, {\"id\": \"56\", \"num\": 56}, {\"id\": \"57\", \"num\": 57}, {\"id\": \"58\", \"num\": 58}, {\"id\": \"59\", \"num\": 59}, {\"id\": \"60\", \"num\": 60}, {\"id\": \"61\", \"num\": 61}, {\"id\": \"62\", \"num\": 62}, {\"id\": \"63\", \"num\": 63}, {\"id\": \"64\", \"num\": 64}, {\"id\": \"65\", \"num\": 65}, {\"id\": \"66\", \"num\": 66}, {\"id\": \"67\", \"num\": 67}, {\"id\": \"68\", \"num\": 68}, {\"id\": \"69\", \"num\": 69}, {\"id\": \"70\", \"num\": 70}, {\"id\": \"71\", \"num\": 71}, {\"id\": \"72\", \"num\": 72}, {\"id\": \"73\", \"num\": 73}, {\"id\": \"74\", \"num\": 74}, {\"id\": \"75\", \"num\": 75}, {\"id\": \"76\", \"num\": 76}, {\"id\": \"77\", \"num\": 77}, {\"id\": \"78\", \"num\": 78}, {\"id\": \"79\", \"num\": 79}, {\"id\": \"80\", \"num\": 80}, {\"id\": \"81\", \"num\": 81}, {\"id\": \"82\", \"num\": 82}, {\"id\": \"83\", \"num\": 83}, {\"id\": \"84\", \"num\": 84}, {\"id\": \"85\", \"num\": 85}, {\"id\": \"86\", \"num\": 86}, {\"id\": \"87\", \"num\": 87}, {\"id\": \"88\", \"num\": 88}, {\"id\": \"89\", \"num\": 89}, {\"id\": \"90\", \"num\": 90}, {\"id\": \"91\", \"num\": 91}, {\"id\": \"92\", \"num\": 92}, {\"id\": \"93\", \"num\": 93}, {\"id\": \"94\", \"num\": 94}, {\"id\": \"95\", \"num\": 95}, {\"id\": \"96\", \"num\": 96}, {\"id\": \"97\", \"num\": 97}, {\"id\": \"98\", \"num\": 98}, {\"id\": \"99\", \"num\": 99}]'"

docker-compose start solr-2

docker-compose run --rm tester bash -c "while ! nc -z solr-2 8983; do sleep 1; done"

sleep 10 

# Check collection status
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/admin/collections?action=clusterstatus&wt=json'"

# solr-1 should have received the documents
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/test/select?q=*:*&distrib=false&rows=2'"

# solr-2 should have received the documents
docker-compose run --rm tester bash -c "curl 'http://solr-2:8983/solr/test/select?q=*:*&distrib=false&rows=2'"

# Update a document
docker-compose run --rm tester bash -c "curl -X POST -H 'Content-Type: application/json' 'http://solr-1:8983/solr/test/update/json/docs?commit=true' --data-binary '{\"id\": \"1\", \"num\":10}'"

sleep 5

# solr-1 should have the change
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/test/select?q=id:1&distrib=false'"

# solr-2 should have the change
docker-compose run --rm tester bash -c "curl 'http://solr-2:8983/solr/test/select?q=id:1&distrib=false'"

# Stop solr-2
docker-compose stop solr-2

# Update id 1 when solr-2 is stopped
docker-compose run --rm tester bash -c "curl -X POST -H 'Content-Type: application/json' 'http://solr-1:8983/solr/test/update/json/docs?commit=true' --data-binary '{\"id\": \"1\", \"num\": 20}'"

# solr-1 should have the change
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/test/select?q=id:1&distrib=false'"

docker-compose start solr-2

docker-compose run --rm tester bash -c "while ! nc -z solr-2 8983; do sleep 1; done"

sleep 10

# Check collection status
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/admin/collections?action=clusterstatus&wt=json'"

# solr-2 should have the change
docker-compose run --rm tester bash -c "curl 'http://solr-2:8983/solr/test/select?q=id:1&distrib=false'"

# Stop solr-2
docker-compose stop solr-2

# Update id 1 when solr-2 is stopped
docker-compose run --rm tester bash -c "curl -X POST -H 'Content-Type: application/json' 'http://solr-1:8983/solr/test/update/json/docs?commit=true' --data-binary '{\"id\": \"1\", \"num\": 30}'"

# solr-1 should have the change
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/test/select?q=id:1&distrib=false'"

docker-compose start solr-2

docker-compose run --rm tester bash -c "while ! nc -z solr-2 8983; do sleep 1; done"

sleep 10

# Check collection status
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/admin/collections?action=clusterstatus&wt=json'"

# solr-1 should have the change
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/test/select?q=id:1&distrib=false'"

# solr-2 should have the change
docker-compose run --rm tester bash -c "curl 'http://solr-2:8983/solr/test/select?q=id:1&distrib=false'"

echo "num should be [30]"

echo "restart solr-1, forcing solr-2 to become leader"

docker-compose restart solr-1

docker-compose run --rm tester bash -c "while ! nc -z solr-1 8983; do sleep 1; done"


# solr-1 now reverts to the old value
docker-compose run --rm tester bash -c "curl 'http://solr-1:8983/solr/test/select?q=id:1&distrib=false'"

docker-compose down -v --rmi all --remove-orphans

