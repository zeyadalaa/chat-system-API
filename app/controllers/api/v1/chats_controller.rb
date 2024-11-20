class Api::V1::ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :update]

  # GET /api/v1/applications/:application_token/chats
  def index
    @chats = Chat.where(application_token: params[:application_token])
    #fetching cache count
    cache_key = "#{params[:application_token]}:chat_count"
    chat_count = $redis.get(cache_key).to_i

    if chat_count.zero?
      # If not cached, count from the database and cache it
      chat_count =  @chats.maximum(:number).to_i
      $redis.set(cache_key, chat_count,ex: 43200) # 12 hours
    end
  
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
    

    cache_key = "#{@chat.application_token}:chat_count"
    chat_count = $redis.get(cache_key).to_i
    Rails.logger.info "cacheing of cache_key #{cache_key}  =   #{chat_count}"

    
  # Find the latest chat number if Redis key is empty
    if chat_count.zero?
      chat_count = set_chat_counter
      $redis.set(cache_key, chat_count.to_i,ex: 43200) # 12 hours
    end

    @chat.number = $redis.incr(cache_key).to_i

    Rails.logger.info "chat.number after : #{@chat.number}"

    if @chat.save

      render json: @chat.number, status: :created
    else
      $redis.decr(cache_key)
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
  
  def set_chat_counter
    return Chat.where(application_token: params[:application_token]).maximum("number")
  end

  def chat_params
    params.require(:chat).permit(:title)
  end

end
