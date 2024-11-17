class Api::V1::MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update]


  # GET /api/v1/applications/:application_token/chats/:chat_number/messages
  def index
    @messages = Message.where(
      application_token: params[:application_token],
      chat_number: params[:chat_number]
      )
    
    render json: @messages.as_json(except: [:id])
  end

  # GET /api/v1/applications/:application_token/chats/:chat_number/messages/:number
  def show
    render json: @message.as_json(except: [:id])
  end

  # POST /api/v1/applications/:application_token/chats/:chat_number/messages
  def create
    @message = Message.new(message_params)


    @chat = Chat.find_by(application_token: params[:application_token], number: params[:chat_number])
    if @chat.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized 
      return 
    end
    @message.application_token = params[:application_token]
    @message.chat_number = params[:chat_number]

    # Find the latest chat number for the given application
    latest_message = Message.where(application_token: params[:application_token], chat_number: params[:chat_number])
    .order(number: :desc)
    .first

    # Set the number for the new message (if there's no message, start with 1)
    new_message_number = latest_message ? latest_message.number + 1 : 1

    @message.number = new_message_number


    if @message.save
      render json: @message.number, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/applications/:application_token/chats/:chat_number/messages/:number
  def update

    # Locking while updating to handle race condition
    Message.transaction do
      @message = Message.lock.find_by(
        application_token: params[:application_token],
        chat_number: params[:chat_number],
        number: params[:number]
      )

      if @message.nil?
        render json: { error: 'Message not found or Unauthorized' }, status: :unauthorized
        return
      end

      if @message.update(message_params)
        render json: @message.as_json(except: [:id])
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    end

  end


  private

  def set_message
    @message = Message.find_by(
      application_token: params[:application_token],
      chat_number: params[:chat_number],
      number: params[:number]
    )

    render json: { error: 'Unauthorized' }, status: :not_found unless @message
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
