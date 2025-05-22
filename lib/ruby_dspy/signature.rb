module RubyDSPy
  # Represents a signature with input and output fields
  class Signature
    attr_reader :input_fields, :output_fields
    
    # Create a new signature
    # @param input_fields [Array<Field>] Input fields
    # @param output_fields [Array<Field>] Output fields
    def initialize(input_fields = [], output_fields = [])
      @input_fields = input_fields
      @output_fields = output_fields
    end
    
    # Add an input field to the signature
    # @param name [Symbol] Field name
    # @param type [Class, Symbol] Field type
    # @param description [String, nil] Field description
    # @param default [Object, nil] Default value
    # @return [Field] The created field
    def add_input(name, type, description: nil, default: nil)
      field = Field.new(name, type, description: description, default: default)
      @input_fields << field
      field
    end
    
    # Add an output field to the signature
    # @param name [Symbol] Field name
    # @param type [Class, Symbol] Field type
    # @param description [String, nil] Field description
    # @return [Field] The created field
    def add_output(name, type, description: nil)
      field = Field.new(name, type, description: description)
      @output_fields << field
      field
    end
    
    # Validate input values against input fields
    # @param inputs [Hash] Input values
    # @return [Boolean] True if all inputs are valid
    def validate_inputs(inputs)
      @input_fields.all? do |field|
        value = inputs[field.name]
        field.valid?(value)
      end
    end
    
    # Validate output values against output fields
    # @param outputs [Hash] Output values
    # @return [Boolean] True if all outputs are valid
    def validate_outputs(outputs)
      @output_fields.all? do |field|
        value = outputs[field.name]
        field.valid?(value)
      end
    end
    
    # Create a string representation of the signature
    # @return [String] String representation
    def to_s
      inputs = @input_fields.map(&:to_s).join(", ")
      outputs = @output_fields.map(&:to_s).join(", ")
      "Signature(inputs: [#{inputs}], outputs: [#{outputs}])"
    end
  end
end