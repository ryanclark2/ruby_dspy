require 'spec_helper'

RSpec.describe RubyDSPy::Module do
  # Define a test module class
  class TestModule < RubyDSPy::Module
    input :name, :string, description: "A name"
    input :age, :integer, description: "An age", default: 30
    output :greeting, :string, description: "A greeting"
    
    def forward
      self.greeting = "Hello, #{name}! You are #{age} years old."
    end
  end
  
  describe 'basic functionality' do
    it 'defines input and output fields' do
      expect(TestModule.signature.input_fields.size).to eq(2)
      expect(TestModule.signature.output_fields.size).to eq(1)
      
      name_field = TestModule.signature.input_fields.first
      expect(name_field.name).to eq(:name)
      expect(name_field.type).to eq(:string)
      expect(name_field.description).to eq("A name")
      
      greeting_field = TestModule.signature.output_fields.first
      expect(greeting_field.name).to eq(:greeting)
      expect(greeting_field.type).to eq(:string)
      expect(greeting_field.description).to eq("A greeting")
    end
    
    it 'sets inputs from initialization' do
      mod = TestModule.new(name: "Alice")
      expect(mod.name).to eq("Alice")
      expect(mod.age).to eq(30) # Default value
    end
    
    it 'generates outputs in forward pass' do
      mod = TestModule.new(name: "Bob", age: 25)
      result = mod.call
      
      expect(mod.greeting).to eq("Hello, Bob! You are 25 years old.")
      expect(result[:greeting]).to eq("Hello, Bob! You are 25 years old.")
    end
    
    it 'updates inputs from call method' do
      mod = TestModule.new(name: "Charlie")
      result = mod.call(name: "Dave", age: 40)
      
      expect(mod.name).to eq("Dave")
      expect(mod.age).to eq(40)
      expect(result[:greeting]).to eq("Hello, Dave! You are 40 years old.")
    end
  end
end