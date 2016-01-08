require 'test_helper'

class AclHelperTest < ActionView::TestCase
  include AclHelper

  def setup
    @kylo = users(:kylo)
    @peaches = users(:peaches)
  end

  test 'current_user? tests the current user' do
    assert_not current_user?(@kylo), 'Not logged in should be false'
    log_in_as @peaches
    assert_not current_user?(@kylo), 'Wrong user should be false'
    assert current_user?(@peaches), 'Correct user should be true'
  end
end