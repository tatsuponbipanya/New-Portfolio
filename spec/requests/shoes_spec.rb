require 'rails_helper'

RSpec.describe "Shoes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/shoes/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/shoes/new"
      expect(response).to have_http_status(:success)
    end
  end

end
