class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    # Redirigir a delivery si el usuario tiene rol Delivery
    if current_user.has_role?('Delivery')
      redirect_to delivery_index_path
      nil
    end

    # Para otros usuarios, mostrar la página de inicio normal
  end
end
