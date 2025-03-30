module Pos
  module Modals
    class ItemDiscountsController < ApplicationController
      def show
        product_id = params[:product_id]
        @current_discount = 0

        if session[:cart].present?
          item = session[:cart].find { |i| i['product_id'].to_s == product_id.to_s }
          if item
            @current_discount = item['discount_type_mode'] == 'amount' ?
              item['discount_amount'] :
              (item['discount_percentage'] || 0)
          end
        end

        render 'pos/modals/item_discount_modal', locals: { product_id: product_id }
      end
    end
  end
end
