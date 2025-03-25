module Pos
  module Modals
    class OrderTypesController < BaseController
      def show
        render partial: 'order_type_modal'
      end
    end
  end
end
