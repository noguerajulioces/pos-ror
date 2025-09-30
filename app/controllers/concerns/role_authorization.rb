module RoleAuthorization
  extend ActiveSupport::Concern

  # Este concern NO se incluye automáticamente
  # Cada controlador que necesite autorización debe incluirlo explícitamente
  # Ejemplo: include RoleAuthorization en el controlador

  included do
    # CanCanCan ya maneja la autorización con load_and_authorize_resource
    # Solo agregamos un rescue_from para manejar errores de autorización
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.html do
          flash[:alert] = 'No tienes permisos para acceder a esta sección.'
          redirect_to(request.referer || root_path)
        end
        format.json { render json: { error: 'No autorizado' }, status: :forbidden }
      end
    end
  end
end
