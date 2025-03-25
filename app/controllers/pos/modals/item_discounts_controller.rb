module Pos
  module Modals
    class OrderTypesController < BaseController
      def show
        render 'pos/modals/discounts'
      end
    end
  end
end
