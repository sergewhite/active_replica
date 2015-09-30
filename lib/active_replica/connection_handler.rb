require 'active_support/core_ext/module/delegation'
require 'active_replica/runtime_registry'
require 'concurrent'

module ActiveReplica
  # This class works the same as the default ActiveRecord ConnectionHandler
  # with each method carefully copied and delegated appropriately
  #
  # for single pool operations it delegates to the current active handler
  # for operations over the whole connecton pool list, it delegates to each handler
  #
  class ConnectionHandler
    def initialize(default_connection_handler)
      @shard_to_connection_handler = Concurrent::Map.new(initial_capacity: 2)
      @default_connection_handler = default_connection_handler
    end

    # easy failover to the default
    attr_reader :default_connection_handler

    # the key to the whole thing
    # let us switch the active connection handler
    #
    private def active_connection_handler
      ActiveReplica::RuntimeRegistry.connection_handler || default_connection_handler
    end

    private def active_connection_handler=(connection_handler)
      ActiveReplica::RuntimeRegistry.connection_handler = connection_handler
    end

    # add a shard with connection handler
    #
    def add_shard(shard, connection_handler)
      @shard_to_connection_handler[shard] = connection_handler
    end

    # get the list of shard names
    #
    def shards
      @shard_to_connection_handler.keys
    end

    # get the shard with the connection handler
    #
    def get_shard(shard)
      @shard_to_connection_handler[shard] or fail "no handler for shard #{shard.inspect}"
    end

    # fetch the shard and use it
    #
    def with_shard(shard)
      connection_handler = get_shard(shard)
      with_connection_handler(connection_handler) do
        yield
      end
    end

    # switch the handler for the current thread
    # and ensure its put back at the end
    #
    def with_connection_handler(connection_handler)
      before = active_connection_handler
      self.active_connection_handler = connection_handler
      yield
    ensure
      self.active_connection_handler = before
    end

    # grab the full list of connection handlers
    # to enable clean up methods
    #
    private def connection_handler_list
      @shard_to_connection_handler.values + [default_connection_handler].compact
    end

    # the connection pool list is used for various cleaning tasks
    # it should be modified to return the full list
    # mapped over all children
    #
    def connection_pool_list
      connection_handler_list.flat_map(&:connection_pool_list)
    end
    alias :connection_pools :connection_pool_list

    # delegate establishing a connection to the active handler
    #
    delegate :establish_connection,
             to: :active_connection_handler

    # the active connection method should just delegate
    #
    def active_connections?
      connection_handler_list.any?(&:active_connections)
    end

    # the clear connection methods can be delegated to each connection handler
    #
    def clear_active_connections!
      connection_handler_list.each(&:clear_active_connections!)
    end

    def clear_reloadable_connections!
      connection_handler_list.each(&:clear_reloadable_connections!)
    end

    def clear_all_connections!
      connection_handler_list.each(&:clear_all_connections!)
    end

    # individual handler methods
    # we should just delegate to the active handler
    #
    delegate :retrieve_connection,
             :connected?,
             :remove_connection,
             :retrieve_connection_pool,
             to: :active_connection_handler
  end
end
