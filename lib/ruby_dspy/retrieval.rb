module RubyDSPy
  # Document class for retrieval
  class Document
    attr_reader :id, :text, :metadata
    
    # Initialize a new document
    # @param id [String, Integer] Document ID
    # @param text [String] Document text content
    # @param metadata [Hash] Additional metadata
    def initialize(id, text, metadata = {})
      @id = id
      @text = text
      @metadata = metadata
    end
    
    # Convert to string representation
    # @return [String] String representation
    def to_s
      "Document(id=#{@id}, text=#{@text[0..50]}...)"
    end
  end
  
  # Base retriever interface
  class Retriever
    # Retrieve documents based on a query
    # @param query [String] The search query
    # @param k [Integer] Number of documents to retrieve
    # @return [Array<Document>] Retrieved documents
    def retrieve(query, k = 5)
      raise NotImplementedError, "Subclasses must implement #retrieve"
    end
  end
  
  # Simple in-memory retriever using string matching
  class SimpleRetriever < Retriever
    # Initialize with a collection of documents
    # @param documents [Array<Document>] Documents to search
    def initialize(documents)
      @documents = documents
    end
    
    # Retrieve documents based on a query
    # @param query [String] The search query
    # @param k [Integer] Number of documents to retrieve
    # @return [Array<Document>] Retrieved documents
    def retrieve(query, k = 5)
      # Simple search using case-insensitive substring matching
      # (In a real implementation, this would use vector embeddings or proper search)
      query_terms = query.downcase.split(/\s+/)
      
      ranked_docs = @documents.map do |doc|
        text = doc.text.downcase
        score = query_terms.sum { |term| text.include?(term) ? 1 : 0 }
        [doc, score]
      end
      
      # Sort by score (descending) and take top k
      ranked_docs.sort_by { |_, score| -score }.take(k).map(&:first)
    end
  end
  
  # RAG (Retrieval-Augmented Generation) module
  class RAG
    include RubyDSPy::Module
    
    attr_reader :retriever, :generator, :num_docs
    
    # Initialize a new RAG module
    # @param retriever [Retriever] Document retriever
    # @param generator [Predict] Generation module
    # @param num_docs [Integer] Number of documents to retrieve
    def initialize(retriever:, generator:, num_docs: 3)
      super()
      @retriever = retriever
      @generator = generator
      @num_docs = num_docs
    end
    
    # Forward pass for the RAG module
    def forward
      # Get query from first input field
      query_field = self.class.signature.input_fields.first
      query = send(query_field.name) if query_field
      
      # Retrieve relevant documents
      documents = @retriever.retrieve(query, @num_docs)
      
      # Format documents for the generator
      context = format_documents(documents)
      
      # Run the generator with the combined query and context
      inputs = {}
      self.class.signature.input_fields.each do |field|
        inputs[field.name] = send(field.name)
      end
      
      # Add context to the generator
      generator_inputs = inputs.merge(context: context)
      results = @generator.call(**generator_inputs)
      
      # Set output values from generator's outputs
      self.class.signature.output_fields.each do |field|
        if results.key?(field.name)
          send(:"#{field.name}=", results[field.name])
        end
      end
    end
    
    private
    
    # Format documents for inclusion in the prompt
    # @param documents [Array<Document>] Retrieved documents
    # @return [String] Formatted document text
    def format_documents(documents)
      return "" if documents.empty?
      
      parts = ["Here are some relevant documents:"]
      
      documents.each_with_index do |doc, i|
        parts << "[Document #{i+1}]"
        parts << doc.text
      end
      
      parts << "Please use these documents to help answer the question."
      parts.join("\n\n")
    end
  end
end