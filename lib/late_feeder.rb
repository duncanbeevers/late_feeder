module LateFeeder
  class ConnectionPoolPartnerThread < Thread
    PARTNER_THREAD_KEY = :found
    def initialize
      @spawning_thread = Thread.current
      super()
    end
    
    def object_id
      @spawning_thread.object_id
    end
    
    def [](key)
      PARTNER_THREAD_KEY == key ? super : @spawning_thread[key]
    end
  end
  
  class LateFeedingCollection
    PRESERVE_METHODS = [
      '__send__', '__id__',
      'method_missing',
      'debugger',
      'extend',
      'to_s', 'inspect'
    ]
    def self.remove_instance_methods
      methods_to_remove = (self.instance_methods.map { |m| m.to_s } - PRESERVE_METHODS)
      methods_to_remove.each { |method| undef_method(method) }
    end
    
    def initialize(find_class, *find_args, &find_block)
      @worker = ConnectionPoolPartnerThread.new do
        worker = Thread.current
        find_class.instance_eval do
          worker[ConnectionPoolPartnerThread::PARTNER_THREAD_KEY] = self.find_without_late_feeder(*find_args, &find_block)
          worker.exit
        end
      end
    end
    
    def method_missing(method, *args, &block)
      if !@result
        @worker.join
        @result = @worker[ConnectionPoolPartnerThread::PARTNER_THREAD_KEY]
      end
      @result.send(method, *args, &block)
    end
  end
  
  def self.included(base)
    LateFeedingCollection.remove_instance_methods
    base.class_eval do
      extend ClassMethods
      class << self
        alias_method_chain :find, :late_feeder
      end
    end
  end
  
  module ClassMethods
    def find_with_late_feeder(*args, &block)
      if (:all == args.first)
        LateFeedingCollection.new(self, *args, &block)
      else
        find_without_late_feeder(*args, &block)
      end
    end
  end
end

ActiveRecord::Base.send(:include, LateFeeder)
