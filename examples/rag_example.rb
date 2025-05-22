require 'ruby_dspy'

# Set up OpenAI configuration (replace with your API key)
RubyDSPy.configure do |config|
  config.default_lm = RubyDSPy::LanguageModel::OpenAI.new(
    api_key: ENV['OPENAI_API_KEY'],
    model_name: "gpt-3.5-turbo"
  )
end

# Create some sample documents
documents = [
  RubyDSPy::Document.new(1, "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write."),
  RubyDSPy::Document.new(2, "Python is a programming language that lets you work quickly and integrate systems more effectively. It supports multiple programming paradigms."),
  RubyDSPy::Document.new(3, "JavaScript is a scripting language that enables you to create dynamically updating content, control multimedia, animate images, and much more."),
  RubyDSPy::Document.new(4, "Ruby on Rails is a web application framework written in Ruby. It is designed to make programming web applications easier by making assumptions about what every developer needs to get started."),
  RubyDSPy::Document.new(5, "Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort. It's not a full MVC framework like Rails, but can be used for small applications or APIs.")
]

# Create a retriever
retriever = RubyDSPy::SimpleRetriever.new(documents)

# Define a QA generator that uses retrieved context
class ContextQA < RubyDSPy::Predict
  input :question, :string, description: "The question to answer"
  input :context, :string, description: "Relevant context for answering the question"
  output :answer, :string, description: "The answer to the question based on the context"
  
  # Override to create a better prompt with context
  def default_prompt
    <<~PROMPT
      Please answer the question based only on the provided context. If the context doesn't contain the answer, say "I don't have enough information to answer this question."
      
      Context:
      #{context}
      
      Question: #{question}
      
      Answer:
    PROMPT
  end
end

# Define a RAG system using our components
class RubyDocsQA < RubyDSPy::RAG
  input :question, :string, description: "The question about Ruby to answer"
  output :answer, :string, description: "The answer to the question about Ruby"
  
  def initialize
    generator = ContextQA.new
    super(retriever: retriever, generator: generator, num_docs: 2)
  end
end

# Create and use the RAG system
rag = RubyDocsQA.new
result = rag.call(question: "What is Ruby on Rails?")
puts "Question: What is Ruby on Rails?"
puts "Answer: #{result[:answer]}"
puts

result = rag.call(question: "What is Sinatra?")
puts "Question: What is Sinatra?"
puts "Answer: #{result[:answer]}"
puts

result = rag.call(question: "What programming language has a focus on simplicity?")
puts "Question: What programming language has a focus on simplicity?"
puts "Answer: #{result[:answer]}"