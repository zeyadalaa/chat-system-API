class Message < ApplicationRecord
  belongs_to :chat, foreign_key: :chat_number, primary_key: :number
  belongs_to :application, foreign_key: :application_token, primary_key: :token
  

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: [:application_token, :chat_number] }
  validates :chat_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :application_token, presence: true
  validates :content, presence: true, length: { maximum: 255 }, allow_nil: false



  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # Define the index settings and mappings with Edge N-Gram
  settings index: {
    analysis: {
      analyzer: {
        edge_ngram_analyzer: { # Define the custom analyzer
          type: 'custom',
          tokenizer: 'edge_ngram_tokenizer',
          filter: ["lowercase"]
        }
      },
      tokenizer: {
        edge_ngram_tokenizer: { # Tokenizer for edge n-grams
          type: 'edge_ngram',
          min_gram: 2,
          max_gram: 10,
          token_chars: ["letter", "digit"]
        }
      }
    }
  } do
    mappings dynamic: false do
      indexes :content, type: 'text', analyzer: 'edge_ngram_analyzer'
      indexes :message_number, type: 'integer'
      indexes :chat_number, type: 'integer'
      indexes :application_token, type: 'text'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
    end
  end

  # Define how the data is indexed into Elasticsearch
  def as_indexed_json(options = {})
    self.as_json(only: [:content, :message_number, :chat_number, :application_token, :created_at, :updated_at])
  end
  

end

