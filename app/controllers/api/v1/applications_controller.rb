class Api::V1::ApplicationsController < ApplicationController
    before_action :set_application, only: [:show, :update]
    before_action :authenticate_application_show, only: [:show]

    # GET /api/v1/applications
    def index
      @applications = Application.all
      render json: @applications.as_json(except: [:id])
    end

    # GET /api/v1/applications/:token
    def show
      render json: @application.as_json(except: [:id])
    end

    # POST /api/v1/applications
    def create
      @application = Application.new(application_params)
      
      if @application.save
        render json: @application.as_json(except: [:id]), status: :created
      else
        render json: @application.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/applications/:token
    def update
      # Locking while updating to handle race condition
      Application.transaction do
        @application = Application.lock.find_by(token: params[:token])

        if @application.nil? 
          render json: { error: 'Unauthorized' }, status: :unauthorized
          return
        end

        if @application.update(application_params)
          render json: @application.as_json(except: [:id])
        else
          render json: @application.errors, status: :unprocessable_entity
        end
      end
    end

    private

    def set_application
        @application = Application.find_by!(token: params[:token])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Application not found' }, status: :not_found
    end

    def authenticate_application_show
      token = request.headers['Authorization']
      @application = Application.find_by(token: params[:token])
      if @application.nil? && @application.token != token
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @application
      end
    end


    def application_params
      params.require(:application).permit(:deviceName, :password)
    end
    
end