require File.join(File.dirname(__FILE__), 'test_helper')

class User < ActiveRecord::Base
end

class LateFeederTest < Test::Unit::TestCase
  
  def test_get_two_records
    persisted_users = [ Factory(:user), Factory(:user) ]
    found_users = User.find(:all, :limit => 2, :order => 'id')
    assert_equal persisted_users, found_users
  end

end
