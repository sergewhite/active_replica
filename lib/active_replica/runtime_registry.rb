require 'active_support/per_thread_registry'

module ActiveReplica
  # This is a thread locals registry for ActiveReplica.
  #
  # Taken from ActiveRecord's equivalent
  # we use it to switch and access the connection_handler
  #
  class RuntimeRegistry # :nodoc:
    extend ActiveSupport::PerThreadRegistry

    attr_accessor :active_replica, :connection_handler

    [:active_replica, :connection_handler].each do |val|
      class_eval %{ def self.#{val}; instance.#{val}; end }, __FILE__, __LINE__
      class_eval %{ def self.#{val}=(x); instance.#{val}=x; end }, __FILE__, __LINE__
    end
  end
end
