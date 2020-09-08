require "application_system_test_case"

class Admin::BansTest < ApplicationSystemTestCase
  setup do
    @admin_ban = admin_bans(:one)
  end

  test "visiting the index" do
    visit admin_bans_url
    assert_selector "h1", text: "Admin/Bans"
  end

  test "creating a Ban" do
    visit admin_bans_url
    click_on "New Admin/Ban"

    fill_in "Login", with: @admin_ban.login
    fill_in "Reason", with: @admin_ban.reason
    click_on "Create Ban"

    assert_text "Ban was successfully created"
    click_on "Back"
  end

  test "updating a Ban" do
    visit admin_bans_url
    click_on "Edit", match: :first

    fill_in "Login", with: @admin_ban.login
    fill_in "Reason", with: @admin_ban.reason
    click_on "Update Ban"

    assert_text "Ban was successfully updated"
    click_on "Back"
  end

  test "destroying a Ban" do
    visit admin_bans_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ban was successfully destroyed"
  end
end
