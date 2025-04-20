module Modal
  class CustomersController < ApplicationController
    def create
      @customer = Customer.new(customer_params)

      respond_to do |format|
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
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace(
              'new_customer_form',
              partial: 'customers/modal_form',
              locals: { customer: @customer }
            ), status: :unprocessable_entity
          }
          format.html { render 'customers/new', status: :unprocessable_entity }
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
      )
    end
  end
end