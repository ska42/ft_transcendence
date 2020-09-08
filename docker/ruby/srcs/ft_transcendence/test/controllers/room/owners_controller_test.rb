require 'test_helper'

class Room::OwnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room_owner = room_owners(:one)
  end

  test "should get index" do
    get room_owners_url
    assert_response :success
  end

  test "should get new" do
    get new_room_owner_url
    assert_response :success
  end

  test "should create room_owner" do
    assert_difference('Room::Owner.count') do
      post room_owners_url, params: { room_owner: {  } }
    end

    assert_redirected_to room_owner_url(Room::Owner.last)
  end

  test "should show room_owner" do
    get room_owner_url(@room_owner)
    assert_response :success
  end

  test "should get edit" do
    get edit_room_owner_url(@room_owner)
    assert_response :success
  end

  test "should update room_owner" do
    patch room_owner_url(@room_owner), params: { room_owner: {  } }
    assert_redirected_to room_owner_url(@room_owner)
  end

  test "should destroy room_owner" do
    assert_difference('Room::Owner.count', -1) do
      delete room_owner_url(@room_owner)
    end

    assert_redirected_to room_owners_url
  end
end
