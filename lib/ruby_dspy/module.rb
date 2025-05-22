module RubyDSPy
  # Base class for all DSPy modules
  class Module
    attr_reader :signature
    
    # Class methods for RubyDSPy modules
    module ClassMethods
      # Define an input field for the module
      # @param name [Symbol] Field name
      # @param type [Class, Symbol] Field type
      # @param description [String, nil] Field description
      # @param default [Object, nil] Default value
      def input(name, type, description: nil, default: nil)
        signature.add_input(name, type, description: description, default: default)
        
        # Define accessor methods for the input
        define_method(name) do
          instance_variable_get(:"@#{name}")
        end
        
        define_method(:"#{name}=") do |value|
          instance_variable_set(:"@#{name}", value)
        end
      end
      
      # Define an output field for the module
      # @param name [Symbol] Field name
      # @param type [Class, Symbol] Field type
      # @param description [String, nil] Field description
      def output(name, type, description: nil)
        signature.add_output(name, type, description: description)
        
        # Define accessor methods for the output
        define_method(name) do
          instance_variable_get(:"@#{name}")
        end
        
        define_method(:"#{name}=") do |value|
          instance_variable_set(:"@#{name}", value)
        end
      end
      
      # Get or create the signature for this class
      # @return [Signature] The class signature
      def signature
        @signature ||= Signature.new
      end
    end
    
    # When this module is included in a class, extend the class with the ClassMethods
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # Initialize a new module
    # @param kwargs [Hash] Keyword arguments to set as inputs
    def initialize(**kwargs)
      @signature = self.class.signature
      
      # Set inputs from keyword arguments
      kwargs.each do |key, value|
        if respond_to?(:"#{key}=")
          send(:"#{key}=", value)
        end
      end
    end
    
    # Forward a call to the module's forward method
    # @param kwargs [Hash] Input arguments
    # @return [Hash] Output values
    def call(**kwargs)
      # Set inputs
      kwargs.each do |key, value|
        if respond_to?(:"#{key}=")
          send(:"#{key}=", value)
        end
      end
      
      # Call the forward method
      forward
      
      # Collect outputs
      outputs = {}
      self.class.signature.output_fields.each do |field|
        outputs[field.name] = send(field.name) if respond_to?(field.name)
      end
      
      outputs
    end
    
    # Main method to override in subclasses
    def forward
      raise NotImplementedError, "Subclasses must implement #forward"
    end
    
    # Format module for display
    # @return [String] String representation
    def to_s
      "#{self.class.name}(#{self.class.signature})"
    end
  end
end