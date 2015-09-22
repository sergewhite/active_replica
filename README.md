# ActiveReplica

ActiveReplica makes it super-easy (and performant) to use a read-only replica with ActiveRecord

## Installation

```ruby
gem 'activereplica'
```

## Usage

# register the master
ActiveReplica.register(ActiveRecord::Base)

# add a replica
ActiveReplica.add_replica(:replica1, { adapter: "sqlite3", database: "tmp/replica1.sql" })

# make sure the connection pools are all established
ActiveReplica.establish_connections

# use the replica

ActiveReplica.using(:replica1) do
  User.includes(:posts).find_each do |user|
    puts "user: #{user.name} has #{user.posts.length} posts"
  end
end
