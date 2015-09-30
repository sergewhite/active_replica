# ActiveReplica

ActiveReplica makes it super-easy (and performant) to use a read-only replica with ActiveRecord

## Installation

```ruby
gem 'activereplica'
```

## Usage

```
# add named replicas
>> ActiveReplica.add_replica(:follower_1, adapter: "sqlite3", database: "replica1.sqlite")
>> ActiveReplica.add_replica(:follower_2, adapter: "sqlite3", database: "replica2.sqlite")

# get a list of replicas
>> ActiveReplica.replicas
=> [:follower_1, :follower_2]

# use a specified replica
>> ActiveReplica.with_replica(:follower_1) do
>>   User.count
>> end
```

That's it

## Logging

Replica logging is not enabled by default.

If you want it, you can just require it.

```
require 'active_replica/logging'
```

Then your logs will get decorated.

```
[Replica: follower_1]   (6.6ms)  SELECT COUNT(*) FROM "users"
```
