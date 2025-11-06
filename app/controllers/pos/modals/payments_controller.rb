module Pos
  module Modals
    class PaymentsController < BaseController
      def show
        # Meseros no pueden acceder al modal de pago
        if current_user.has_role?(:mesero)
          render json: { error: 'Los meseros no pueden procesar pagos' }, status: :forbidden
          return
        end
        
        render 'pos/modals/payment_modal'
      end
    end
  end
end
