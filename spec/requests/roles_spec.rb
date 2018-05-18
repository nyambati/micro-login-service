
require "rails_helper"
require "./spec/helpers/users_spec_helper"

RSpec.describe "RolesApi", type: :request do
  include UsersSpecHelper
  let(:user) { create_admin }
  let(:header) do
    { "Authorization" => token_generator(UserInfo: { email: user.email }) }
  end

  describe "GET /roles" do
    context " when unauthorized" do
      before { get "/roles" }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { get "/roles", headers: header }

      it "returns role object" do
        expect(json).not_to be_empty
        expect(response.body).to match(/admin/)
      end

      it "returns status code 200" do
        expect(response.status).to eql(200)
      end
    end
  end

  describe "POST /roles" do
    let!(:parameters) { { name: "learner", domain: "https://www.google.com" } }
    context " when unauthorized" do
      before { post "/roles", params: parameters }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { post "/roles", headers: header, params: parameters }

      it "returns created role " do
        expect(json).not_to be_empty
        expect(response.body).to match(/www.google.com/)
      end

      it "returns status code 201" do
        expect(response.status).to eql(201)
      end
    end
  end

  describe "GET /roles/:id" do
    let(:role) { Role.create(name: "user", domain: "https://www.google.com") }
    context " when unauthorized" do
      before { get "/roles/#{role.id}" }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { get "/roles/#{role.id}", headers: header }

      it "returns role object" do
        expect(response.body).to match(/domain/)
      end

      it "returns status code 200" do
        expect(response.status).to eql(200)
      end
    end
  end
end
