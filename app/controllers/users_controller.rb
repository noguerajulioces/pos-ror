class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy activate]
  before_action :check_super_user_permissions, only: [ :deactivate ]
  before_action :check_edit_permissions, only: [ :edit, :update ]
  before_action :ensure_superadmin_for_roles!, only: [ :show ], if: -> { params[:roles].present? }

  def index
    @users = User.includes(:roles).where(account_id: current_user.account_id).paginate(page: params[:page], per_page: 10)
  end

  def show
    @roles = Role.order(:name)
  end

  def new
    @user = User.new(account_id: current_user.account_id)
  end

  def edit; end

  def create
    @user = User.new(user_params)
    @user.account_id = current_user.account_id

    if @user.save
      redirect_to @user, notice: 'Usuario creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Handle role updates
    if params[:roles].present?
      @user.roles = []
      Array(params[:roles]).each do |name|
        role = Role.find_by(name: name)
        if role
          @user.add_role(role)
        else
          @user.add_role(name)
        end
      end
      redirect_to @user, notice: 'Roles actualizados exitosamente.'
      return
    end

    # Handle regular user updates
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to @user, notice: 'Usuario actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'Usuario eliminado exitosamente.'
  end

  def activate
    if @user.activate!
      redirect_to users_path, notice: 'Usuario activado exitosamente.'
    else
      redirect_to users_path, alert: 'No se pudo activar el usuario.'
    end
  end

  def deactivate
    @user = User.where(account_id: current_user.account_id).find(params[:id])

    if @user == current_user
      redirect_to users_path, alert: 'No puedes desactivar tu propio usuario.'
      return
    end

    unless current_user.can_deactivate_users?
      redirect_to users_path, alert: 'No tienes permisos para desactivar usuarios.'
      return
    end

    if @user.deactivate!
      redirect_to users_path, notice: 'Usuario desactivado exitosamente.'
    else
      redirect_to users_path, alert: 'No se pudo desactivar el usuario.'
    end
  end

  private

  def set_user
    @user = User.where(account_id: current_user.account_id).find(params[:id])
  end

  def user_params
    permitted_params = [ :name, :email, :password, :password_confirmation ]
    permitted_params << :super_user if current_user.super_user?
    params.require(:user).permit(permitted_params)
  end

  def check_super_user_permissions
    unless current_user.can_deactivate_users?
      redirect_to users_path, alert: 'No tienes permisos para realizar esta acción.'
    end
  end

  def check_edit_permissions
    unless current_user.super_user? || @user == current_user
      redirect_to users_path, alert: 'Solo puedes editar tu propio usuario.'
    end
  end

  def ensure_superadmin_for_roles!
    redirect_to root_path, alert: 'No autorizado' unless current_user&.has_role?(:superadmin)
  end
end
