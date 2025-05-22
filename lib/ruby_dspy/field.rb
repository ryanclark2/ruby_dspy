module RubyDSPy
  # Represents a field in a signature with type information and metadata
  class Field
    attr_reader :name, :type, :description, :default
    
    # Create a new field
    # @param name [Symbol] The name of the field
    # @param type [Class, Symbol] The type of the field
    # @param description [String] Description of the field
    # @param default [Object, nil] Default value
    def initialize(name, type, description: nil, default: nil)
      @name = name
      @type = type
      @description = description
      @default = default
    end
    
    # Validate a value against this field's type
    # @param value [Object] The value to validate
    # @return [Boolean] True if valid, false otherwise
    def valid?(value)
      return true if value.nil? && default.nil?
      return true if type == :any
      
      case type
      when Class
        value.is_a?(type)
      when :string
        value.is_a?(String)
      when :integer
        value.is_a?(Integer)
      when :float
        value.is_a?(Float)
      when :boolean
        value == true || value == false
      when :array
        value.is_a?(Array)
      when :hash
        value.is_a?(Hash)
      when :list
        value.is_a?(Array)
      when :dict
        value.is_a?(Hash)
      else
        false
      end
    end
    
    # Format field for display in signatures
    # @return [String] String representation of the field
    def to_s
      type_str = type.is_a?(Class) ? type.name : type.to_s
      default_str = default.nil? ? "" : " = #{default.inspect}"
      "#{name}: #{type_str}#{default_str}"
    end
  end
end