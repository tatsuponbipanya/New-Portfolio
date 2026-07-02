require 'rails_helper'

RSpec.describe 'Games', type: :request do
  describe 'GET /mega_punch' do
    it 'returns http success' do
      get '/games/mega_punch'
      expect(response).to have_http_status(:success)
    end
  end
end
