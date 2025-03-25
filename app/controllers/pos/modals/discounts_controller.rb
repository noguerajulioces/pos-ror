module Pos
  module Modals
    class DiscountsController < BaseController
      def show
        product_id = params[:product_id]
        @current_discount = 0

        if session[:cart].present?
          item = session[:cart].find { |i| i['product_id'].to_s == product_id.to_s }
          @current_discount = item['discount_percentage'] if item && item['discount_percentage'].present?
        end

        render partial: 'pos/discount/modal'
      end
    end
  end
end
