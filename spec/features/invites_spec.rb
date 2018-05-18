# spec/features/creating_farm_spec.rb
require "rails_helper"
require "./spec/helpers/users_spec_helper"

RSpec.describe "shows page logo", type: :feature do
  include UsersSpecHelper
  it "shows invites" do
    visit "/invites"
    expect(page).to have_content "Andela Guest Setup"
    click_button "Request New Link"
    expect(page).to have_content "Sorry record not found"
  end
end
