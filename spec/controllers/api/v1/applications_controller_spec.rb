require 'rails_helper'

RSpec.describe Api::V1::ApplicationsController, type: :controller do
  let!(:application) { create(:application) } 

  describe "GET #index" do
    it "returns a list of applications" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Application.count)
    end
  end

  describe "GET #show" do
    context "when the application exists" do
      it "returns the application" do
        get :show, params: { token: application.token }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["deviceName"]).to eq(application.deviceName)
      end
    end

    context "when the application does not exist" do
      it "returns a not found error" do
        get :show, params: { token: "nonexistent_token" }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Application not found")
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_attributes) { { deviceName: "Device"} }

      it "creates a new application" do
        expect {
          post :create, params: { application: valid_attributes }
        }.to change(Application, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { deviceName: ""} }

      it "does not create a new application" do
        expect {
          post :create, params: { application: invalid_attributes }
        }.to_not change(Application, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "when the application exists" do
      let(:new_device_name) { "Updated Device" }

      it "updates the application" do
        patch :update, params: { token: application.token, application: { deviceName: new_device_name } }
        expect(response).to have_http_status(:ok)
        application.reload
        expect(application.deviceName).to eq(new_device_name)
      end
    end

    context "when the application does not exist" do
      it "returns an unauthorized error" do
        patch :update, params: { token: "nonexistent_token", application: { deviceName: "Updated Device" } }
        expect(response).to have_http_status(:not_found)  
        expect(JSON.parse(response.body)["error"]).to eq("Application not found")  
      end
    end
  end
end
