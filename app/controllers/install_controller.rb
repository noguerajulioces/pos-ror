class InstallController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'install'
  
  def index
    # Página pública para instalación de PWA
  end
end
