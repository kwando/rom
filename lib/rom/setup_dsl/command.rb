module ROM
  # Setup DSL-specific command extensions
  #
  # @private
  class Command
    # Generate a command subclass
    #
    # This is used by Setup#commands DSL and its `define` block
    #
    # @api private
    def self.build_class(name, relation, options = {}, &block)
      type = options.fetch(:type) { name }
      command_type = Inflector.classify(type)
      adapter = options.fetch(:adapter)
      parent = adapter_namespace(adapter).const_get(command_type)
      class_name = generate_class_name(adapter, command_type, relation)

      ClassBuilder.new(name: class_name, parent: parent).call do |klass|
        klass.register_as(name)
        klass.relation(relation)
        klass.class_eval(&block) if block
      end
    end

    # Create a command subclass name based on adapter, type and relation
    #
    # @api private
    def self.generate_class_name(adapter, command_type, relation)
      pieces = ['ROM']
      pieces << Inflector.classify(adapter)
      pieces << 'Commands'
      pieces << "#{command_type}[#{Inflector.classify(relation)}s]"
      pieces.join('::')
    end
  end
end
