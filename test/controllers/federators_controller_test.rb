require 'test_helper'

class FederatorsControllerTest < ActionController::TestCase
  test "should get federator" do
    get :federator
    assert_response :success
  end

end
