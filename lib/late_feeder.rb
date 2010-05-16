module LateFeeder
  class LateFeedingCollection
    def initialize(*args, &block)
    end
  end
  
  def self.included(base)
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
        LateFeedingCollection.new(*args, &block)
      else
        find_without_late_feeder(*args, &block)
      end
    end
  end
end

ActiveRecord::Base.send(:include, LateFeeder)
