class SettingsController < ApplicationController
  def edit
    @settings = Setting.all
  end

  def update_all
    settings_params.each do |key, value|
      setting = Setting.find_by(key: key)
      setting&.update(value: value)
    end

    redirect_to edit_settings_path, notice: "Configuración actualizada exitosamente"
  end

  private

  def settings_params
    params.require(:settings).permit!
  end
end
