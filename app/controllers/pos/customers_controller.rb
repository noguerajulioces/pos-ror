class Pos::CustomersController < ApplicationController
  def create
    @customer = Customer.new(customer_params)
    @customer.account_id = current_user.account_id

    respond_to do |format|
      if @customer.save
        session[:customer_id] = @customer.id
        session[:customer_name] = @customer.full_name

        format.turbo_stream {
          # Render partials for customer info updates (specify format as :html)
          mobile_content = render_to_string(partial: 'pos/main/customer_info_mobile', locals: { customer_name: @customer.full_name }, formats: [:html])
          desktop_content = render_to_string(partial: 'pos/main/customer_info_desktop', locals: { customer_name: @customer.full_name }, formats: [:html])
          
          render turbo_stream: [
            turbo_stream.remove('modal'),
            turbo_stream.update('customer-info-mobile', mobile_content),
            turbo_stream.update('customer-info-desktop', desktop_content),
            turbo_stream.update('selected-customer-id-mobile', @customer.id)
          ]
        }
        format.html { redirect_back fallback_location: pos_path, notice: 'Cliente creado exitosamente.' }
        format.json { render json: { success: true, customer: @customer } }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            'customer_search_modal',
            partial: 'pos/modals/customer_search_modal',
            locals: { customer: @customer }
          ), status: :unprocessable_entity
        }
        format.html { redirect_back fallback_location: pos_path, alert: 'Error al crear el cliente.' }
        format.json { render json: { success: false, errors: @customer.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

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
    ).tap do |permitted|
      permitted[:email] = nil if permitted[:email].blank?
    end
  end
end
