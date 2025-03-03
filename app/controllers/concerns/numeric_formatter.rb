module NumericFormatter
  extend ActiveSupport::Concern

  module ClassMethods
    # Recibe una lista de atributos que deben limpiarse
    def sanitize_numeric_attributes(*attributes)
      before_validation do
        attributes.each do |attribute|
          raw_value = self[attribute]
          if raw_value.is_a?(String)
            # Elimina los puntos que se usan como separadores de miles
            cleaned_value = raw_value.gsub(".", "")
            # Asigna el valor convertido a entero o a float, según convenga
            self[attribute] = cleaned_value.include?(",") ? cleaned_value.gsub(",", ".").to_f : cleaned_value.to_i
          end
        end
      end
    end
  end
end
