class CustomersController < ApplicationController
  before_action :set_customer, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Customer.ransack(params[:q])
    @customers = @q.result(distinct: true).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @customer = Customer.new
  end

  def edit
  end

  def search
    @q = Customer.ransack(first_name_or_last_name_or_document_or_phone_cont: params[:query])
    @customers = @q.result(distinct: true)
    render partial: 'customers/search_results', locals: { customers: @customers }
  end

  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      begin
        if @customer.save
          session[:customer_id] = @customer.id
          session[:customer_name] = @customer.full_name
          # Close the modal and update customer info in the POS view
          format.turbo_stream {
            render turbo_stream: [
              turbo_stream.remove('modal'),
              turbo_stream.update('customer-info', @customer.full_name || "#{@customer.first_name} #{@customer.last_name}".strip),
              turbo_stream.update('selected-customer-id', @customer.id)
            ]
          }
          format.html { redirect_back fallback_location: customer_url(@customer), notice: 'Cliente creado con éxito.' }
          format.json { render json: { success: true, customer: @customer } }
        else
          flash.now[:alert] = "No se pudo crear el cliente: #{@customer.errors.full_messages.join(', ')}"
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace(
              'new_customer_form',
              partial: 'customers/modal_form',
              locals: { customer: @customer }
            ), status: :unprocessable_entity
          }
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @customer.errors.full_messages }, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotUnique => e
        handle_unique_violation(e)
        flash.now[:alert] = @customer.errors.full_messages.join(', ')
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            'new_customer_form',
            partial: 'customers/modal_form',
            locals: { customer: @customer }
          ), status: :unprocessable_entity
        }
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @customer.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def create_form
    @customer = Customer.new(customer_params)

    respond_to do |format|
      begin
        if @customer.save
          format.html { redirect_to customer_url(@customer), notice: 'Cliente creado con éxito.' }
        else
          flash.now[:alert] = "No se pudo crear el cliente: #{@customer.errors.full_messages.join(', ')}"
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace(
              'customer_search_modal',
              partial: 'pos/customer_search_modal',
              locals: { customer: @customer }
            )
          }
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @customer.errors.full_messages }, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotUnique => e
        handle_unique_violation(e)
        flash.now[:alert] = @customer.errors.full_messages.join(', ')
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            'customer_search_modal',
            partial: 'pos/customer_search_modal',
            locals: { customer: @customer }
          )
        }
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @customer.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    begin
      if @customer.update(customer_params)
        redirect_to @customer, notice: 'Cliente actualizado exitosamente.'
      else
        flash.now[:alert] = "No se pudo actualizar el cliente: #{@customer.errors.full_messages.join(', ')}"
        render :edit, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique => e
      handle_unique_violation(e)
      flash.now[:alert] = @customer.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_url, notice: 'Cliente eliminado exitosamente.'
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
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
      @customer.errors.add(:email, 'ya está registrado. Por favor, use otro email.')
    elsif error_message.include?('document')
      @customer.errors.add(:document, 'ya está registrado. Por favor, use otro documento.')
    else
      @customer.errors.add(:base, 'Ya existe un cliente con estos datos. Por favor, verifique la información.')
    end
  end
end
