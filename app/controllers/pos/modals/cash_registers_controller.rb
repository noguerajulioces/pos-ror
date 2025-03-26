module Pos
  module Modals
    class CashRegistersController < BaseController
      def show
        render partial: 'cash_register_modal'
      end
    end
  end
end
