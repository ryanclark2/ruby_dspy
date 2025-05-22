require 'faraday'
require 'faraday/retry'
require 'json'

module RubyDSPy
  module LanguageModel
    # Base class for language model implementations
    class Base
      attr_reader :model_name, :temperature
      
      # Initialize a new language model
      # @param model_name [String] The name of the model
      # @param temperature [Float] Sampling temperature
      def initialize(model_name:, temperature: 0.0)
        @model_name = model_name
        @temperature = temperature
      end
      
      # Generate a completion from the language model
      # @param prompt [String] The prompt to complete
      # @param **kwargs [Hash] Additional arguments for the model
      # @return [String] The generated completion
      def complete(prompt, **kwargs)
        raise NotImplementedError, "Subclasses must implement #complete"
      end
      
      # Generate completions for multiple prompts
      # @param prompts [Array<String>] The prompts to complete
      # @param **kwargs [Hash] Additional arguments for the model
      # @return [Array<String>] The generated completions
      def batch_complete(prompts, **kwargs)
        prompts.map { |prompt| complete(prompt, **kwargs) }
      end
    end
    
    # OpenAI language model implementation
    class OpenAI < Base
      # Initialize a new OpenAI language model
      # @param api_key [String] OpenAI API key
      # @param model_name [String] Model name (default: gpt-3.5-turbo)
      # @param temperature [Float] Sampling temperature
      def initialize(api_key:, model_name: "gpt-3.5-turbo", temperature: 0.0)
        super(model_name: model_name, temperature: temperature)
        @api_key = api_key
      end
      
      # Generate a completion using the OpenAI API
      # @param prompt [String] The prompt to complete
      # @param max_tokens [Integer, nil] Maximum tokens to generate
      # @return [String] The generated completion
      def complete(prompt, max_tokens: nil)
        is_chat_model = @model_name.include?("gpt") || @model_name.include?("turbo")
        
        if is_chat_model
          response = chat_complete(prompt, max_tokens: max_tokens)
        else
          response = text_complete(prompt, max_tokens: max_tokens)
        end
        
        response
      end
      
      private
      
      # Create a Faraday connection with retry
      # @return [Faraday::Connection] The connection
      def connection
        @connection ||= Faraday.new(url: 'https://api.openai.com') do |f|
          f.request :json
          f.request :retry, max: 2, interval: 0.5, 
                           retry_statuses: [429, 500, 502, 503, 504]
          f.adapter Faraday.default_adapter
          f.headers['Authorization'] = "Bearer #{@api_key}"
          f.headers['Content-Type'] = 'application/json'
        end
      end
      
      # Complete using the chat API
      # @param prompt [String] The prompt to complete
      # @param max_tokens [Integer, nil] Maximum tokens to generate
      # @return [String] The generated completion
      def chat_complete(prompt, max_tokens: nil)
        payload = {
          model: @model_name,
          messages: [{ role: "user", content: prompt }],
          temperature: @temperature
        }
        payload[:max_tokens] = max_tokens if max_tokens
        
        response = connection.post('/v1/chat/completions', payload.to_json)
        data = JSON.parse(response.body)
        
        if response.success?
          data.dig("choices", 0, "message", "content").to_s.strip
        else
          raise "OpenAI API error: #{data['error']['message']}"
        end
      end
      
      # Complete using the completions API
      # @param prompt [String] The prompt to complete
      # @param max_tokens [Integer, nil] Maximum tokens to generate
      # @return [String] The generated completion
      def text_complete(prompt, max_tokens: nil)
        payload = {
          model: @model_name,
          prompt: prompt,
          temperature: @temperature
        }
        payload[:max_tokens] = max_tokens if max_tokens
        
        response = connection.post('/v1/completions', payload.to_json)
        data = JSON.parse(response.body)
        
        if response.success?
          data.dig("choices", 0, "text").to_s.strip
        else
          raise "OpenAI API error: #{data['error']['message']}"
        end
      end
    end
    
    # Anthropic language model implementation
    class Anthropic < Base
      # Initialize a new Anthropic language model
      # @param api_key [String] Anthropic API key
      # @param model_name [String] Model name (default: claude-3-opus-20240229)
      # @param temperature [Float] Sampling temperature
      def initialize(api_key:, model_name: "claude-3-opus-20240229", temperature: 0.0)
        super(model_name: model_name, temperature: temperature)
        @api_key = api_key
      end
      
      # Generate a completion using the Anthropic API
      # @param prompt [String] The prompt to complete
      # @param max_tokens [Integer, nil] Maximum tokens to generate
      # @return [String] The generated completion
      def complete(prompt, max_tokens: nil)
        payload = {
          model: @model_name,
          messages: [{ role: "user", content: prompt }],
          temperature: @temperature
        }
        payload[:max_tokens] = max_tokens if max_tokens
        
        response = connection.post('/v1/messages', payload.to_json)
        data = JSON.parse(response.body)
        
        if response.success?
          data.dig("content", 0, "text").to_s.strip
        else
          raise "Anthropic API error: #{data['error']['message']}"
        end
      end
      
      private
      
      # Create a Faraday connection with retry
      # @return [Faraday::Connection] The connection
      def connection
        @connection ||= Faraday.new(url: 'https://api.anthropic.com') do |f|
          f.request :json
          f.request :retry, max: 2, interval: 0.5, 
                           retry_statuses: [429, 500, 502, 503, 504]
          f.adapter Faraday.default_adapter
          f.headers['x-api-key'] = @api_key
          f.headers['anthropic-version'] = '2023-06-01'
          f.headers['Content-Type'] = 'application/json'
        end
      end
    end
  end
end