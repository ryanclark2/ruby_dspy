module RubyDSPy
  # Base prediction module for direct LM completion
  class Predict
    include RubyDSPy::Module
    
    attr_reader :lm, :template
    
    # Initialize a new Predict module
    # @param lm [LanguageModel::Base] The language model to use
    # @param template [String, nil] Optional template string
    def initialize(lm: nil, template: nil)
      super()
      @lm = lm || RubyDSPy.configuration.default_lm
      @template = template
      
      raise ArgumentError, "No language model provided" unless @lm
    end
    
    # Generate a prompt from input values
    # @return [String] The generated prompt
    def generate_prompt
      if @template
        fill_template
      else
        default_prompt
      end
    end
    
    # Fill the template with input values
    # @return [String] The filled template
    def fill_template
      result = @template.dup
      
      self.class.signature.input_fields.each do |field|
        value = send(field.name)
        placeholder = "{#{field.name}}"
        result.gsub!(placeholder, value.to_s) if result.include?(placeholder)
      end
      
      result
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
      
      # Add inputs
      self.class.signature.input_fields.each do |field|
        value = send(field.name)
        label = field.name.to_s.gsub('_', ' ').capitalize
        parts << "#{label}:"
        parts << value.to_s
      end
      
      parts.join("\n\n")
    end
    
    # Forward pass to generate completion
    def forward
      prompt = generate_prompt
      response = @lm.complete(prompt)
      
      # Parse the response and set output values
      parse_response(response)
    end
    
    # Parse the response from the language model
    # @param response [String] The model's response
    def parse_response(response)
      # Simple implementation: just assign the response to the first output field
      # More complex parsing can be implemented in subclasses
      output_field = self.class.signature.output_fields.first
      if output_field
        send(:"#{output_field.name}=", response)
      end
    end
  end
end