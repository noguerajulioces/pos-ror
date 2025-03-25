module Pos
  module Modals
    class DiscountsController < BaseController
      def show
        render 'pos/modals/discount_modal'
      end
    end
  end
end
