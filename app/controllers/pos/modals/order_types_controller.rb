module Pos
  module Modals
    class OrderTypesController < BaseController
      def show
        render 'pos/modals/order_type_modal'
      end
    end
  end
end
