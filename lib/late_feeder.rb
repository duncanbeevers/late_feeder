module LateFeeder
  class ConnectionPoolPartnerThread < Thread
    attr_reader :object_id
    def initialize(object_id)
      @object_id = object_id
      super()
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
      @worker = ConnectionPoolPartnerThread.new(Thread.current.object_id) do
        worker = Thread.current
        find_class.instance_eval do
          worker[:found] = self.find_without_late_feeder(*find_args, &find_block)
          worker.exit
        end
      end
    end
    
    def method_missing(method, *args, &block)
      begin
        # puts "method_missing: #[{self.__object_id__}] #{method.inspect} #{@result.inspect}"
        if !@result
          @worker.join
          # puts "Setting result to #{@worker[:found]}"
          @result = @worker[:found]
        end
        answer = @result.send(method, *args, &block)
        # puts "#{method.inspect}: #{answer.inspect}"
        answer
      ensure
        
      end
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
