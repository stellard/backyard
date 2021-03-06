module Backyard
  class Configuration

    def initialize
      @model_configuration ||= {}
    end

    def name_attribute(attribute, options = {})
      raise "missing the :for options" unless options.has_key?(:for)
      [*options[:for]].each do |model_type|
        model = adapter_instance.class_for_type(model_type)
        config_for(model).name_attributes << attribute
      end
    end

    def name_for(*model_types, &block)
      model_types.each do |model_type|
        klass = adapter_instance.class_for_type(model_type)
        config_for(klass).name_blocks << block
      end
    end

    def use_adapter(adapter)
      @adapter = adapter
    end

    def config_for(model_type)
      @model_configuration[model_type] ||= Model.new
    end

    def adapter_instance
      return @adapter_instance if @adapter_instance
      @adapter ||= :factory_girl
      require File.join('backyard', 'adapter', "#{@adapter}")
      adapter_class = @adapter.to_s.split('_').map!{ |w| w.capitalize }.join
      @adapter_instance = eval "Backyard::Adapter::#{adapter_class}.new"
    end

    class Model
      attr_writer :name_attributes, :name_blocks
      def name_attributes
        @name_attributes ||= []
      end

      def name_blocks
        @name_blocks ||= []
      end
    end

  end
end
