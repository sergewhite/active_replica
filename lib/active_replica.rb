require 'active_replica/version'
require 'active_replica/connection_handler'
require 'active_replica/railtie' if defined?(Rails)
require 'active_support/core_ext/module/attribute_accessors' # mattr_accessor

module ActiveReplica
  mattr_accessor :connection_handler

  def self.setup(active_record)
    default_handler = active_record.default_connection_handler
    active_handler = ActiveReplica::ConnectionHandler.new(default_handler)
    self.connection_handler = active_handler
    ActiveRecord::Base.default_connection_handler = active_handler
  end

  def self.add_replica(name, config)
    handler = handler_for_config(config)
    self.connection_handler.add_shard(name, handler)
  end

  def self.replicas
    self.connection_handler.shards
  end

  def self.active_replica
    ActiveReplica::RuntimeRegistry.active_replica
  end

  def self.with_replica(name)
    before = ActiveReplica::RuntimeRegistry.active_replica
    ActiveReplica::RuntimeRegistry.active_replica = name
    self.connection_handler.with_shard(name) do
      yield
    end
  ensure
    ActiveReplica::RuntimeRegistry.active_replica = before
  end

  def self.handler_for_config(config)
    spec = spec_for_config(config)
    ActiveRecord::ConnectionAdapters::ConnectionHandler.new.tap do |handler|
      handler.establish_connection(ActiveRecord::Base, spec)
    end
  end

  def self.spec_for_config(config)
    ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new("replica" => config).spec(:replica)
  end
end
