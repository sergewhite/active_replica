require 'active_record'

master_spec = {
  adapter: 'sqlite3',
  database: 'tmp/master.sqlite'
}

replica_spec = {
  adapter: 'sqlite3',
  database: 'tmp/replica.sqlite'
}

ActiveRecord::Base.establish_connection(master_spec)

ActiveRecord::Schema.define(version: 0) do
  create_table :users, force: true do |t|
    t.string :name
  end

  create_table :posts, force: true do |t|
    t.string :title
    t.string :body
    t.references :user
  end
end

class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end

# create 2 users
matthew = User.create!(name: "Matthew")
raffi = User.create!(name: "Raffi")

matthew.posts.create!(title: "Writing a Connection Handler proxy", body: "a load of blurb")
matthew.posts.create!(title: "Writing the tests for it", body: "way more work than the code")
uhoh = matthew.posts.create!(title: "Uh oh", body: "don't think he meant to write this")

# now create a replica

`cp #{master_spec[:database]} #{replica_spec[:database]}`

# now set the handler

default_handler = ActiveRecord::Base.default_connection_handler
handler = ActiveReplica::ConnectionHandler.new(default_handler)
ActiveRecord::Base.default_connection_handler = handler


spec = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new("replica" => replica_spec).spec(:replica)
replica_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
replica_handler.establish_connection(ActiveRecord::Base, spec)
handler.add_shard(:replica, replica_handler)
