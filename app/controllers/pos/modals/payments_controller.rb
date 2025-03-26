module Pos
  module Modals
    class PaymentsController < BaseController
      def show
        render 'pos/modals/payment_modal'
      end
    end
  end
end
