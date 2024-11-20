# spec/controllers/api/v1/messages_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  let!(:application) { create(:application, deviceName: 'Just testing') }
  let!(:chat) { create(:chat, application_token: application.token, number: 1, title: 'Test Chat') }
  # let!(:message) { create(:message, application_token: application.token, chat_number: chat.number, content: "testing" ) }
  let!(:message) { create(:message, :with_dynamic_content, application_token: application.token, chat_number: chat.number, number:1) }

  
  let(:valid_attributes) { { content: 'New Message Content' } }
  let(:invalid_attributes) { { content: nil } }

  describe 'GET #index' do
    it 'returns a list of messages for the chat' do
      get :index, params: { application_token: message.application_token, chat_number: chat.number }
      expect(response).to have_http_status(:success)
      expect(json.length).to eq(1)
    end

    it 'returns an empty array if no messages exist' do
      get :index, params: { application_token: 'invalid_token', chat_number: 999 }
      expect(response).to have_http_status(:success)
      expect(json).to eq([])
    end
  end

  describe 'GET #show' do
    it 'returns a specific message' do
      get :show, params: { application_token: message.application_token, chat_number: chat.number, number: message.number }
      expect(response).to have_http_status(:success)
      expect(json['content']).to eq(message.content)
    end

    it 'returns an error if the message does not exist' do
      get :show, params: { application_token: message.application_token, chat_number: chat.number, number: 999 }
      expect(response).to have_http_status(:not_found)
      expect(json['error']).to eq('Unauthorized')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new message' do
        post :create, params: { application_token: message.application_token, chat_number: chat.number, message: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(json).to have_key('number')
      end
    end

    context 'with invalid params' do
      it 'returns an error' do
        post :create, params: { application_token: message.application_token, chat_number: chat.number, message: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key('content')
      end
    end

    context 'when chat is unauthorized' do
      it 'returns an error' do
        post :create, params: { application_token: 'invalid_token', chat_number: 999, message: valid_attributes }
        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq('Unauthorized')
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid params' do
      it 'updates the message' do
        patch :update, params: { application_token: message.application_token, chat_number: chat.number, number: message.number, message: valid_attributes }
        expect(response).to have_http_status(:success)
        expect(json['content']).to eq('New Message Content')
      end
    end

    context 'with invalid params' do
      it 'returns an error' do
        patch :update, params: { application_token: message.application_token, chat_number: chat.number, number: message.number, message: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #search' do
    it 'returns search results' do
      get :search, params: { application_token: message.application_token, chat_number: chat.number, query: 'Test' }
      expect(response).to have_http_status(:success)
      expect(json).to be_an(Array)
    end

    it 'returns an error when query is blank' do
      get :search, params: { application_token: message.application_token, chat_number: chat.number, query: '' }
      expect(response).to have_http_status(:bad_request)
      expect(json['error']).to eq('Query parameter cannot be blank')
    end
  end
end
