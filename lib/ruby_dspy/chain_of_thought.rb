module RubyDSPy
  # Chain of Thought module for reasoning-based prediction
  class ChainOfThought < Predict
    attr_accessor :reasoning
    
    # Initialize a new ChainOfThought module
    # @param lm [LanguageModel::Base] The language model to use
    # @param template [String, nil] Optional template string
    def initialize(lm: nil, template: nil)
      super(lm: lm, template: template)
      @reasoning = nil
    end
    
    # Generate a default prompt if no template is provided
    # @return [String] The default prompt
    def default_prompt
      parts = []
      
      # Add signature information
      parts << "Task:"
      
      output_fields = self.class.signature.output_fields
      if output_fields.any?
        output_desc = output_fields.map do |field|
          "#{field.name}" + (field.description ? " (#{field.description})" : "")
        end.join(", ")
        
        parts << "Generate the following: #{output_desc}"
      end
      
      # Add CoT instruction
      parts << "Let's think through this step by step to ensure we have the right answer."
      
      # Add inputs
      self.class.signature.input_fields.each do |field|
        value = send(field.name)
        label = field.name.to_s.gsub('_', ' ').capitalize
        parts << "#{label}:"
        parts << value.to_s
      end
      
      parts.join("\n\n")
    end
    
    # Parse the response from the language model
    # @param response [String] The model's response
    def parse_response(response)
      # Extract reasoning and answer from the response
      reasoning_pattern = /Let's think through this step by step|Let me think|Let's analyze|Step 1|First,|To solve this|Reasoning:|I'll analyze/i
      answer_pattern = /Therefore,|Thus,|In conclusion,|So,|The answer is|Final answer:|Answer:/i
      
      lines = response.split("\n")
      reasoning_lines = []
      answer_lines = []
      
      # Check if we're in reasoning or answer section
      in_answer = false
      
      lines.each do |line|
        if !in_answer && line.match?(answer_pattern)
          in_answer = true
        end
        
        if in_answer
          answer_lines << line
        else
          reasoning_lines << line
        end
      end
      
      # If no clear distinction, use a heuristic: last 1-2 lines are likely the answer
      if answer_lines.empty? && lines.size > 2
        reasoning_lines = lines[0...-2]
        answer_lines = lines[-2..-1]
      elsif answer_lines.empty?
        # Just take the last line as answer if we can't find a clear distinction
        reasoning_lines = lines[0...-1]
        answer_lines = [lines.last]
      end
      
      # Store the reasoning
      @reasoning = reasoning_lines.join("\n").strip
      
      # Extract answer and set to the first output field
      answer = answer_lines.join("\n").strip
      
      output_field = self.class.signature.output_fields.first
      if output_field
        send(:"#{output_field.name}=", answer)
      end
    end
  end
end