class Api::V1::ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show, :update]

  # GET /api/v1/applications/:application_id/chats
  def index
    @chats = @application.chats
    render json: @chats
  end

  # GET /api/v1/applications/:application_id/chats/:id
  def show
    render json: @chat
  end

  # POST /api/v1/applications/:application_id/chats
  def create

    @chat = @application.chats.new(chat_params)
    @chat.application_token = @application.token
    
    # Find the latest chat number for the given application
    latest_chat = @application.chats.order(number: :desc).first

    # Set the number for the new chat (if there's no chat, start with 1)
    new_chat_number = latest_chat ? latest_chat.number + 1 : 1

    @chat.number = new_chat_number
    
    if @chat.save
      render json: @chat.id, status: :created
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/applications/:application_id/chats/:id
  def update
    token = request.headers['Authorization']
      
    #locking while update to handle race condition
    Chat.transaction do
      @chat = Chat.lock.find_by(id: params[:id], application_token: token)
      if @chat.nil?
        render json: { error: 'Unauthorized' }, status: :unauthorized
        return
      end
  
      if @chat.update(chat_params)
        render json: @chat
      else
        render json: @chat.errors, status: :unprocessable_entity
      end
    end
  end

  private

  # Find the parent application
  def set_application
    @application = Application.find_by(id: params[:application_id])

    unless @application
      render json: { error: 'Application not found' }, status: :not_found
    end
  end

  # Find the specific chat
  def set_chat
    token = request.headers['Authorization']
    @chat = @application.chats.find_by(id: params[:id], application_token: token)
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @chat
  end

  # Permit chat parameters
  def chat_params
    params.require(:chat).permit(:title) 
  end
end
