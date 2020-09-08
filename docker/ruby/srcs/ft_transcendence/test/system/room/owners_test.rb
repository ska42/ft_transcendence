require "application_system_test_case"

class Room::OwnersTest < ApplicationSystemTestCase
  setup do
    @room_owner = room_owners(:one)
  end

  test "visiting the index" do
    visit room_owners_url
    assert_selector "h1", text: "Room/Owners"
  end

  test "creating a Owner" do
    visit room_owners_url
    click_on "New Room/Owner"

    click_on "Create Owner"

    assert_text "Owner was successfully created"
    click_on "Back"
  end

  test "updating a Owner" do
    visit room_owners_url
    click_on "Edit", match: :first

    click_on "Update Owner"

    assert_text "Owner was successfully updated"
    click_on "Back"
  end

  test "destroying a Owner" do
    visit room_owners_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Owner was successfully destroyed"
  end
end
