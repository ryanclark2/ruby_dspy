# RubyDSPy

A Ruby implementation of Stanford's [DSPy](https://github.com/stanfordnlp/dspy) framework for programming language models.

## Overview

RubyDSPy provides a structured way to build AI applications with language models, focusing on:

- **Declarative programming** instead of brittle prompts
- **Composable modules** for building complex AI systems
- **Signature-based interfaces** for type safety and validation
- Support for **chain-of-thought reasoning** and **retrieval-augmented generation**

## Installation

```bash
gem install ruby_dspy
```

Or add to your Gemfile:

```ruby
gem 'ruby_dspy'
```

## Quick Start

```ruby
require 'ruby_dspy'

# Configure a language model
RubyDSPy.configure do |config|
  config.default_lm = RubyDSPy::LanguageModel::OpenAI.new(
    api_key: ENV['OPENAI_API_KEY'],
    model_name: "gpt-3.5-turbo"
  )
end

# Define a simple question-answering module
class QA < RubyDSPy::Predict
  input :question, :string, description: "The question to answer"
  output :answer, :string, description: "The answer to the question"
end

# Use the module
qa = QA.new
result = qa.call(question: "What is the capital of France?")
puts result[:answer] # Paris
```

## Key Components

### Module

The base class for all DSPy modules, supporting input and output signatures.

```ruby
class Summarizer < RubyDSPy::Module
  input :text, :string, description: "Text to summarize"
  output :summary, :string, description: "Concise summary"
  
  def forward
    # Custom implementation logic
  end
end
```

### Predict

A module for generating completions using language models.

```ruby
class TextClassifier < RubyDSPy::Predict
  input :text, :string, description: "Text to classify"
  output :category, :string, description: "Category label"
end
```

### ChainOfThought

Extends Predict with step-by-step reasoning.

```ruby
class MathSolver < RubyDSPy::ChainOfThought
  input :problem, :string, description: "Math problem to solve"
  output :solution, :string, description: "Solution to the problem"
end
```

### RAG (Retrieval-Augmented Generation)

Combines document retrieval with text generation.

```ruby
class DocumentQA < RubyDSPy::RAG
  input :question, :string, description: "Question about documents"
  output :answer, :string, description: "Answer based on documents"
end
```

## Language Model Support

- OpenAI (GPT-3.5, GPT-4)
- Anthropic (Claude models)

## Examples

See the `examples/` directory for complete examples:

- Simple question answering
- Chain-of-thought reasoning
- Retrieval-augmented generation

## Development

```bash
# Clone the repository
git clone https://github.com/yourusername/ruby_dspy.git
cd ruby_dspy

# Install dependencies
bundle install

# Run tests
bundle exec rspec
```

## License

MIT

## Acknowledgements

This project is inspired by [DSPy](https://github.com/stanfordnlp/dspy), a Python framework developed by the Stanford NLP group.