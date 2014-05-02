littlesis_client
================

A simple client library for using the LittleSis API

```
require 'littlesis_client'

# begin with an instance of the littlesis api client
client = LittlesisClient.new('YOUR_API_KEY', "api.littlesis.org")

# get an entity by littlesis id
# the id is the nummeric part of a littlesis entity url
# eg, larry summers is http://littlesis.org/person/14597/Larry_Summers
# and his id is 14597
id = 14597
entity = client.entity.get(id)

# search for entities by name
query = "larry summers"
entities = client.entity.search(query)

# get all entities that have a connection to a given entity
id = 14597
related_entities = client.entity.get_related_entities(id)
```
