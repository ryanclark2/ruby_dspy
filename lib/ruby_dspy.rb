require_relative "ruby_dspy/version"
require_relative "ruby_dspy/signature"
require_relative "ruby_dspy/field"
require_relative "ruby_dspy/module"
require_relative "ruby_dspy/predict"
require_relative "ruby_dspy/chain_of_thought"
require_relative "ruby_dspy/language_model"
require_relative "ruby_dspy/retrieval"

module RubyDSPy
  class Error < StandardError; end
  
  # Configuration class for the RubyDSPy library
  class Configuration
    attr_accessor :default_lm, :cache_dir, :log_level
    
    def initialize
      @default_lm = nil
      @cache_dir = File.join(Dir.home, ".ruby_dspy", "cache")
      @log_level = :info
    end
  end
  
  # Access to the global configuration
  def self.configuration
    @configuration ||= Configuration.new
  end
  
  # Configure the library
  # @yield [config] Configuration object
  # @example
  #   RubyDSPy.configure do |config|
  #     config.default_lm = RubyDSPy::LanguageModel::OpenAI.new(api_key: "your-api-key")
  #     config.cache_dir = "/custom/cache/path"
  #   end
  def self.configure
    yield(configuration)
  end
end