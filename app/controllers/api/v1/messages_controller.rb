class Api::V1::MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update]

  # GET /api/v1/applications/:application_token/chats/:chat_number/messages
  def index
    @messages = Message.where(
      application_token: params[:application_token],
      chat_number: params[:chat_number]
      )
    
    #fetching cache count
    cache_key = "#{params[:application_token]}:chat_number:#{params[:chat_number]}:message_count"
    message_count = $redis.get(cache_key).to_i

    if message_count.zero?
      # If not cached, count from the database and cache it
      message_count = @messages.maximum(:number).to_i
      $redis.set(cache_key, message_count,ex: 43200) # 12 hours
    end

    render json: @messages.as_json(except: [:id])
  end

  # GET /api/v1/applications/:application_token/chats/:chat_number/messages/:number
  def show
    render json: @message.as_json(except: [:id])
  end

  # POST /api/v1/applications/:application_token/chats/:chat_number/messages
  def create
    @message = Message.new(message_params)
    @message.application_token = params[:application_token]
    @message.chat_number = params[:chat_number]

    @chat = Chat.find_by(application_token: params[:application_token], number: params[:chat_number])
    if @chat.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized 
      return 
    end

    cache_key = "#{params[:application_token]}:chat_number:#{params[:chat_number]}:message_count"
    message_count = $redis.get(cache_key).to_i

    # Find the latest chat number if Redis key is empty
    if message_count.zero?
      message_count = set_message_count
      $redis.set(cache_key, message_count,ex: 43200) # 12 hours
    end

    @message.number = $redis.incr(cache_key).to_i

    if @message.save
      render json: @message.number, status: :created
    else
      $redis.decr(cache_key)
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


  # GET /api/v1/applications/:application_token/chats/:chat_number/messages/search
  def search
    query = params[:query]

    if query.blank?
      render json: { error: 'Query parameter cannot be blank' }, status: :bad_request
      return
    end

    # Perform search using Elasticsearch
    search_results = Message.__elasticsearch__.search({
      query: {
        bool: {
          must: [
            { match: { application_token: params[:application_token] } },
            { match: { chat_number: params[:chat_number] } },
            { match: { content: query } } 
          ]
        }
      },
      highlight: {
        fields: {
          content: {} 
        }
      }
    })

    render json: format_search_results(search_results)
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
  
  def set_message_count
    return Message.where(application_token: params[:application_token],chat_number: params[:chat_number]).maximum("number").to_i
  end
  

  def message_params
    params.require(:message).permit(:content, :application_token, :chat_number, :number)
  end
  
  def format_search_results(search_results)
    search_results.map do |result|
      {
        id: result.id,
        content: result._source.content,
        message_number: result._source.message_number,
        chat_number_fk: result._source.chat_number,
        application_token_fk: result._source.application_token,
        created_at: result._source.created_at,
        updated_at: result._source.updated_at,
        highlights: result.highlight&.content 
      }
    end
  end
end




