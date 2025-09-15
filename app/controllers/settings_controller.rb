class SettingsController < ApplicationController
  def edit
    @settings = Setting.all
  end

  def update_all
    settings_params.each do |var, value|
      setting = Setting.find_by(var: var)
      setting&.update(value: value)
    end

    redirect_to edit_settings_path, notice: 'Configuración actualizada exitosamente'
  end

  def printer
    # Vista de configuración de impresora
  end

  def update_printer
    printer_params.each do |var, value|
      setting = Setting.find_or_create_by(var: var) do |s|
        s.account = current_tenant
      end
      setting.update!(value: value)
    end

    redirect_to printer_settings_path, notice: '🖨️ Configuración de impresora actualizada correctamente.'
  end

  def test_printer
    begin
      # Crear un recibo de prueba
      test_content = <<~TEXT
        ================================
               PRUEBA DE IMPRESION
        ================================

        Fecha: #{Time.current.strftime('%d/%m/%Y %H:%M')}

        Configuración actual:
        - Ancho: #{Setting.get('printer_line_width_chars')} caracteres
        - Papel: #{Setting.get('printer_paper_width_mm')}mm
        - Impresora: #{Setting.get('printer_windows_name')}

        ¡Si ves este mensaje, la#{' '}
        configuración funciona correctamente!

        ================================
      TEXT

      # Usar el PrintServiceNew para probar
      success = PrintServiceNew.send(:print_to_thermal_printer, test_content, 'test')

      if success
        redirect_to printer_settings_path, notice: '✅ Prueba de impresión enviada correctamente.'
      else
        redirect_to printer_settings_path, alert: '⚠️ La impresión se guardó como respaldo. Revisa la configuración.'
      end
    rescue => e
      redirect_to printer_settings_path, alert: "❌ Error en prueba: #{e.message}"
    end
  end

  private

  def settings_params
    params.require(:settings).permit!
  end

  def printer_params
    params.permit(
      :printer_line_width_chars,
      :printer_windows_name,
      :printer_lines_before_cut,
      :printer_cut_command
    )
  end
end
