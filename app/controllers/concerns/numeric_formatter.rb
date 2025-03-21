module NumericFormatter
  extend ActiveSupport::Concern

  module ClassMethods
    # Recibe una lista de atributos que deben limpiarse
    def sanitize_numeric_attributes(*attributes)
      attributes.each do |attribute|
        # Define a custom setter method for each attribute
        define_method("#{attribute}=") do |value|
          if value.is_a?(String) && !value.blank?
            # Elimina los puntos que se usan como separadores de miles
            cleaned_value = value.gsub('.', '')
            # Asigna el valor convertido a entero o a float, según convenga
            converted_value = cleaned_value.include?(',') ?
              cleaned_value.gsub(',', '.').to_f :
              cleaned_value.to_i

            super(converted_value)
          else
            super(value)
          end
        end
      end
    end
  end
end
