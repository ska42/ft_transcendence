require 'test_helper'

class Admin::BansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_ban = admin_bans(:one)
  end

  test "should get index" do
    get admin_bans_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_ban_url
    assert_response :success
  end

  test "should create admin_ban" do
    assert_difference('Admin::Ban.count') do
      post admin_bans_url, params: { admin_ban: { login: @admin_ban.login, reason: @admin_ban.reason } }
    end

    assert_redirected_to admin_ban_url(Admin::Ban.last)
  end

  test "should show admin_ban" do
    get admin_ban_url(@admin_ban)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_ban_url(@admin_ban)
    assert_response :success
  end

  test "should update admin_ban" do
    patch admin_ban_url(@admin_ban), params: { admin_ban: { login: @admin_ban.login, reason: @admin_ban.reason } }
    assert_redirected_to admin_ban_url(@admin_ban)
  end

  test "should destroy admin_ban" do
    assert_difference('Admin::Ban.count', -1) do
      delete admin_ban_url(@admin_ban)
    end

    assert_redirected_to admin_bans_url
  end
end
