require 'spec_helper'
require_relative './support/setup'

describe ActiveReplica do
  it 'works' do
    # check the basics
    expect(User.count).to eq 2
    ActiveRecord::Base.connection_handler.with_shard(:replica) do
      expect(User.count).to eq 2
    end
    expect(User.count).to eq 2

    # now create a new user
    sebastian = User.create!(name: "Sebastian")

    expect(User.pluck(:name).sort).to eq ["Matthew", "Raffi", "Sebastian"]

    with_replica do
      expect(User.pluck(:name).sort).to eq ["Matthew", "Raffi"]
    end

    # delete a post from master
    matthew = User.find_by(name: "Matthew")

    matthew.posts.last.destroy
    matthew.reload
    expect(matthew.posts.map(&:title).sort).to eq([
      "Writing a Connection Handler proxy",
      "Writing the tests for it"
    ])

    with_replica do
      matthew.reload
      expect(matthew.posts.map(&:title).sort).to eq([
        "Uh oh",
        "Writing a Connection Handler proxy",
        "Writing the tests for it"
      ])
    end
  end

  def with_replica
    ActiveRecord::Base.connection_handler.with_shard(:replica) do
      yield
    end
  end
end
