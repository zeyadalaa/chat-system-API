class Api::V1::ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :update]

  # GET /api/v1/applications/:application_token/chats
  def index
    @chats = Chat.where(application_token: params[:application_token])
    render json: @chats.as_json(except: [:id])
  end

  # GET /api/v1/applications/:application_token/chats/:number
  def show
    render json: @chat.as_json(except: [:id])
  end

  # POST /api/v1/applications/:application_token/chats
  def create
    @chat = Chat.new(chat_params)
    @chat.application_token = params[:application_token]

    # Find the latest chat number for the given application
    latest_chat = Chat.where(application_token: params[:application_token]).order(number: :desc).first

    # Set the number for the new chat (if there's no chat, start with 1)
    new_chat_number = latest_chat ? latest_chat.number + 1 : 1

    @chat.number = new_chat_number

    if @chat.save
      render json: @chat.number, status: :created
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/applications/:application_token/chats/:number
  def update
    # Locking while updating to handle race condition
    Chat.transaction do
      @chat = Chat.lock.find_by(number: params[:number], application_token: params[:application_token])

      if @chat.nil?
        render json: { error: 'Unauthorized' }, status: :unauthorized
        return
      end

      if @chat.update(chat_params)
        render json: @chat.as_json(except: [:id])
      else
        render json: @chat.errors, status: :unprocessable_entity
      end
    end
  end

  private

  # Find the specific chat by number
  def set_chat
    @chat = Chat.find_by(application_token: params[:application_token], number: params[:number])
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @chat
  end

  # Permit chat parameters
  def chat_params
    params.require(:chat).permit(:title)
  end
end
