
require "rails_helper"
require "./spec/helpers/users_spec_helper"

RSpec.describe "UserApi", type: :request do
  include UsersSpecHelper
  let!(:users) { create_list(:user, 10) }
  let(:user_id) { users.first.id }
  let(:parameters) do
    { users: [{ email: "sir3n.sn@gmail.com",
                first_name: "kali",
                last_name: "dhul" }], role: "admin" }
  end
  let(:user) { create_admin }
  let(:header) do
    { "Authorization" => token_generator(UserInfo: { email: user.email }) }
  end

  describe "GET /users" do
    context " when unauthorized" do
      before { get "/users" }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { get "/users", headers: header }

      it "returns user object" do
        expect(json).not_to be_empty
        expect(json.size).to eq(11)
      end

      it "returns status code 200" do
        expect(response.status).to eql(200)
      end
    end
  end

  describe "POST /users" do
    context " when unauthorized" do
      before { post "/users", params: parameters }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { post "/users", headers: header, params: parameters }

      it "returns user object " do
        expect(json).not_to be_empty
        expect(json.size).to eq(3)
      end

      it "returns status code 201" do
        expect(response.status).to eql(201)
      end
    end
  end

  describe "GET /users/:id" do
    context " when unauthorized" do
      before { get "/users/#{user_id}" }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { get "/users/#{user_id}", headers: header }

      it "returns user object" do
        expect(response.body).to match(/email/)
      end

      it "returns status code 200" do
        expect(response.status).to eql(200)
      end
    end
  end

  describe "PUT /users/:id" do
    let!(:email) { { email: "infinityWars@gmail.com" } }
    context " when unauthorized" do
      before { put "/users/#{user_id}", params: email }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { put "/users/#{user_id}", headers: header, params: email }

      it "returns user object " do
        expect(response.body).to match(/#{email['email']}/)
      end

      it "returns status code 200" do
        expect(response.status).to eql(200)
      end
    end
  end

  describe "DELETE /users/:id" do
    context " when unauthorized" do
      before { delete "/users/:id" }

      it "returns unauthorized" do
        expect(json).not_to be_empty
        expect(json["error"]).to eql("Unauthorized")
      end

      it "returns status code 401" do
        expect(response.status).to eql(401)
      end
    end

    context "when user is authorized" do
      before { delete "/users/#{user_id}", headers: header }

      it "returns success" do
        expect(json).not_to be_empty
        expect(response.body).to match(/Success/)
      end

      it "returns status code 200" do
        expect(response.status).to eql(200)
      end
    end
  end
end
