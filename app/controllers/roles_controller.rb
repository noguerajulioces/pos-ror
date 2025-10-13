class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_role, only: [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  def index
    @roles = Role.all.order(:name)
  end

  def show
    @users_with_role = User.joins(:roles).where(roles: { id: @role.id }).distinct
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to roles_path, notice: 'Rol creado exitosamente.' }
        format.json { render json: { success: true, role: @role } }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @role.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to roles_path, notice: 'Rol actualizado exitosamente.' }
        format.json { render json: { success: true, role: @role } }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @role.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # Verificar si hay usuarios con este rol
    users_with_role = User.joins(:roles).where(roles: { id: @role.id }).count

    if users_with_role > 0
      redirect_to roles_path, alert: "No se puede eliminar el rol porque tiene #{users_with_role} usuario(s) asignado(s)."
    else
      @role.destroy
      respond_to do |format|
        format.html { redirect_to roles_path, notice: 'Rol eliminado exitosamente.' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :resource_type, :resource_id)
  end
end
