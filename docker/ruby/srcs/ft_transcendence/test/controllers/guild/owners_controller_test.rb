require 'test_helper'

class Guild::OwnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guild_owner = guild_owners(:one)
  end

  test "should get index" do
    get guild_owners_url
    assert_response :success
  end

  test "should get new" do
    get new_guild_owner_url
    assert_response :success
  end

  test "should create guild_owner" do
    assert_difference('Guild::Owner.count') do
      post guild_owners_url, params: { guild_owner: {  } }
    end

    assert_redirected_to guild_owner_url(Guild::Owner.last)
  end

  test "should show guild_owner" do
    get guild_owner_url(@guild_owner)
    assert_response :success
  end

  test "should get edit" do
    get edit_guild_owner_url(@guild_owner)
    assert_response :success
  end

  test "should update guild_owner" do
    patch guild_owner_url(@guild_owner), params: { guild_owner: {  } }
    assert_redirected_to guild_owner_url(@guild_owner)
  end

  test "should destroy guild_owner" do
    assert_difference('Guild::Owner.count', -1) do
      delete guild_owner_url(@guild_owner)
    end

    assert_redirected_to guild_owners_url
  end
end
