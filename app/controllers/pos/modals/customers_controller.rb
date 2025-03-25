module Pos
  module Modals
    class CustomersController < BaseController
      def search
        render 'pos/modals/customer_search_modal'
      end
    end
  end
end
