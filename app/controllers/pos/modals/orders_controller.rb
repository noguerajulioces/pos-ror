module Pos
  module Modals
    class OrdersController < BaseController
      def index
        @orders = Order.on_hold.includes(:table, :customer).order(created_at: :desc)
        render 'pos/modals/orders_modal'
      end
    end
  end
end
