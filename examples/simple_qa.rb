require 'ruby_dspy'

# Set up OpenAI configuration (replace with your API key)
RubyDSPy.configure do |config|
  config.default_lm = RubyDSPy::LanguageModel::OpenAI.new(
    api_key: ENV['OPENAI_API_KEY'],
    model_name: "gpt-3.5-turbo"
  )
end

# Define a simple QA model
class QA < RubyDSPy::Predict
  input :question, :string, description: "The question to answer"
  output :answer, :string, description: "The answer to the question"
end

# Define a QA model with Chain of Thought
class QAWithCoT < RubyDSPy::ChainOfThought
  input :question, :string, description: "The question to answer"
  output :answer, :string, description: "The answer to the question"
end

# Create and run the simple QA model
qa = QA.new
result = qa.call(question: "What is the capital of France?")
puts "Simple QA:"
puts "Question: What is the capital of France?"
puts "Answer: #{result[:answer]}"
puts

# Create and run the CoT model
cot_qa = QAWithCoT.new
result = cot_qa.call(question: "If a train travels at 120 km/h, how far will it go in 2.5 hours?")
puts "Chain of Thought QA:"
puts "Question: If a train travels at 120 km/h, how far will it go in 2.5 hours?"
puts "Reasoning: #{cot_qa.reasoning}"
puts "Answer: #{result[:answer]}"