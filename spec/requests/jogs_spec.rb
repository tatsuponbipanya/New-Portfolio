require 'rails_helper'

RSpec.describe "Jogs", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/jogs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/jogs/create"
      expect(response).to have_http_status(:success)
    end
  end

end
