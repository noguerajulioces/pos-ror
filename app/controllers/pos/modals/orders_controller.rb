module Pos
  module Modals
    class OrdersController < BaseController
      def index
        @orders = Order.on_hold.order(created_at: :desc)
        render partial: 'orders_modal'
      end
    end
  end
end
