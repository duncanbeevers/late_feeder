require File.join(File.dirname(__FILE__), 'test_helper')

class User < ActiveRecord::Base
end

class LateFeederTest < Test::Unit::TestCase
  def setup
    User.delete_all
  end
  
  def test_get_two_records
    persisted_users = [ Factory(:user), Factory(:user) ]
    found_users = User.find(:all, :limit => 2, :order => 'id')
    assert_equal persisted_users, found_users
  end
  
  def test_iteration
    persisted_users = [ Factory(:user), Factory(:user) ]
    
    found_users = User.find(:all, :limit => 2, :order => 'id')
    
    found_users.each_with_index do |found_user, i|
      assert_equal persisted_users[i], found_user
    end
  end
  
end
