module Pos
  module Modals
    class DeliveriesController < BaseController
      def show
        render 'pos/modals/delivery_modal'
      end
    end
  end
end
