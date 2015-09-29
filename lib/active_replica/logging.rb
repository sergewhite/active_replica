# Implementation courtesy of db-charmer.
# Via Octopus
module ActiveReplica
  module AdapterExtension
    class InstrumenterDecorator < BasicObject
      def initialize(adapter, instrumenter)
        @adapter = adapter
        @instrumenter = instrumenter
      end

      def instrument(name, payload = {}, &block)
        payload[:active_replica] = ::ActiveReplica.active_replica
        @instrumenter.instrument(name, payload, &block)
      end

      def method_missing(meth, *args, &block)
        @instrumenter.send(meth, *args, &block)
      end
    end

    def self.included(base)
      base.alias_method_chain :initialize, :active_replica
    end

    def active_replica
      @config[:active_replica]
    end

    def initialize_with_active_replica(*args)
      initialize_without_active_replica(*args)
      @instrumenter = InstrumenterDecorator.new(self, @instrumenter)
    end
  end

  module LogSubscriber
    def self.included(base)
      base.send(:attr_accessor, :active_replica)
      base.alias_method_chain :sql, :active_replica
      base.alias_method_chain :debug, :active_replica
    end

    def sql_with_active_replica(event)
      self.active_replica = event.payload[:active_replica]
      sql_without_active_replica(event)
    end

    def debug_with_active_replica(msg)
      conn = active_replica ? color("[Replica: #{active_replica}]", ActiveSupport::LogSubscriber::GREEN, true) : ''
      debug_without_active_replica(conn + msg)
    end
  end
end

ActiveRecord::LogSubscriber.send(:include, ActiveReplica::LogSubscriber)
ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, ActiveReplica::AdapterExtension)
