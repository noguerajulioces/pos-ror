class ClientsController < ApplicationController
  before_action :set_client, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Customer.ransack(params[:q])
    @clients = @q.result(distinct: true).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @client = Customer.new
  end

  def edit
  end

  def create
    @client = Customer.new(client_params)

    respond_to do |format|
      begin
        if @client.save
          format.html { redirect_to client_url(@client), notice: 'Cliente creado con éxito.' }
          format.json { render json: { success: true, client: @client } }
        else
          flash.now[:alert] = "No se pudo crear el cliente: #{@client.errors.full_messages.join(', ')}"
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @client.errors.full_messages }, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotUnique => e
        handle_unique_violation(e)
        flash.now[:alert] = @client.errors.full_messages.join(', ')
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @client.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      begin
        if @client.update(client_params)
          format.html { redirect_to client_url(@client), notice: 'Cliente actualizado exitosamente.' }
          format.json { render json: { success: true, client: @client } }
        else
          flash.now[:alert] = "No se pudo actualizar el cliente: #{@client.errors.full_messages.join(', ')}"
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @client.errors.full_messages }, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotUnique => e
        handle_unique_violation(e)
        flash.now[:alert] = @client.errors.full_messages.join(', ')
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @client.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: 'Cliente eliminado exitosamente.'
  end

  private

  def set_client
    @client = Customer.find(params[:id])
  end

  def client_params
    params.require(:customer).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :address,
      :city,
      :state,
      :zip_code,
      :country,
      :notes,
      :document
    )
  end

  def handle_unique_violation(exception)
    error_message = exception.message
    
    if error_message.include?('email')
      @client.errors.add(:email, 'ya está registrado. Por favor, use otro email.')
    elsif error_message.include?('document')
      @client.errors.add(:document, 'ya está registrado. Por favor, use otro documento.')
    else
      @client.errors.add(:base, 'Ya existe un cliente con estos datos. Por favor, verifique la información.')
    end
  end
end
