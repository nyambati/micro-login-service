
require "rails_helper"
require "./spec/helpers/users_spec_helper"

RSpec.describe "passwordsApi", type: :request do
  include UsersSpecHelper
  describe "POST /password/forgot" do
    let!(:email) { { email: "sir3n.sn@gmail.com" } }
    context " when email does not exist" do
      before { post "/password/forgot", params: email }

      it "returns record not found" do
        expect(json).not_to be_empty
        expect(json["error"]).to match(/record not found/)
      end

      it "returns status code 404" do
        expect(response.status).to eql(404)
      end
    end

    context "when user is email exists" do
      let(:user) { create_admin }
      before { post "/password/forgot", params: { email: user.email } }

      it "returns success" do
        expect(json).not_to be_empty
        expect(response.body).to match(/Please check your email/)
      end

      it "returns status code 200" do
        expect(response.status).to eql(200)
      end
    end
  end
end
