module Pos
  module Modals
    class CustomersController < BaseController
      def search
        render partial: 'customer_search_modal'
      end
    end
  end
end
