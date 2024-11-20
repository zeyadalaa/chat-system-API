require 'rails_helper'

RSpec.describe Api::V1::ChatsController, type: :controller do
  let!(:application) { create(:application, deviceName: 'Just testing') }
  let!(:chat) { create(:chat, application_token: application.token, number: 1, title: 'Test Chat') }
  
  let(:valid_attributes) { { title: 'New Chat' } }
  let(:invalid_attributes) { { title: nil } }

  describe 'GET #index' do
    context 'when there are chats' do
      it 'returns all chats for the application' do
        get :index, params: { application_token: chat.application_token }
        expect(response).to have_http_status(:success)
        expect(json.length).to eq(1)
      end
    end

    context 'when there are no chats' do
      it 'returns an empty array' do
        get :index, params: { application_token: 'invalid_token' }
        expect(response).to have_http_status(:success)
        expect(json).to eq([])
      end
    end

    context 'when cache is used' do
      it 'fetches the count from Redis' do
        allow($redis).to receive(:get).with("#{application.token}:chat_count").and_return('1')
        get :index, params: { application_token: chat.application_token }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #show' do
    context 'when chat exists' do
      it 'returns the specific chat' do
        get :show, params: { application_token: chat.application_token, number: chat.number }
        expect(response).to have_http_status(:success)
        expect(json['title']).to eq('Test Chat')
      end
    end

    context 'when chat does not exist' do
      it 'returns an error' do
        get :show, params: { application_token: chat.application_token, number: 9999999 }
        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new chat' do
        post :create, params: { application_token: chat.application_token, chat: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(json).to have_key('number')
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'when chat exists' do
      context 'with valid params' do
        it 'updates the chat' do
          patch :update, params: { application_token: chat.application_token, number: chat.number, chat: valid_attributes }
          expect(response).to have_http_status(:success)
          expect(json['title']).to eq('New Chat')
        end
      end
    end

    context 'when chat does not exist' do
      it 'returns an error' do
        patch :update, params: { application_token: chat.application_token, number: 999, chat: valid_attributes }
        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end
end
