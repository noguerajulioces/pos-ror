module Pos
  module Modals
    class PaymentsController < BaseController
      def show
        render partial: 'payment_modal'
      end
    end
  end
end
