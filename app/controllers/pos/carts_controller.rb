module Pos
  class CartsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    include CartCalculations

    # Add this method to your PosController
    def add_product_to_cart
      @product = Product.find(params[:product_id])
      quantity = params[:quantity].to_i || 1

      # Initialize the cart in the session if it doesn't exist
      session[:cart] ||= []

      # Check if the product is already in the cart
      existing_item = session[:cart].find { |item| item['product_id'] == @product.id }

      if existing_item
        existing_item['quantity'] += quantity
      else
        session[:cart] << {
          'product_id' => @product.id,
          'name' => @product.name,
          'price' => @product.price,
          'quantity' => quantity,
          'image_url' => @product.images.first.present? ? url_for(@product.images.first.image.variant(resize_to_fill: [ 100, 100 ])) : nil
        }
      end

      # Recalculate discount if it's a percentage
      adjust_discount_if_needed

      # Calculate new totals
      totals = calculate_cart_totals

      # Update discount label
      discount_label = session[:discount_percentage] ? "Descuento (#{session[:discount_percentage]}%)" : 'Descuento'

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
              'cart-items-body',
              partial: 'cart_items',
              locals: { cart_items: session[:cart] }
            ),
            turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('discount-label', discount_label)
          ]
        }
        format.json {
          render json: {
            success: true,
            cart: session[:cart],
            totals: totals,
            discount_label: discount_label
          }
        }
      end
    end

    # Add this method to remove an item from the cart
    def remove_from_cart
      product_id = params[:product_id].to_i

      # Initialize the cart in the session if it doesn't exist
      session[:cart] ||= []

      # Remove the item from the cart
      session[:cart].reject! { |item| item['product_id'] == product_id }

      # Recalculate discount if it's a percentage or if cart is empty
      adjust_discount_if_needed

      # Calculate new totals
      totals = calculate_cart_totals

      # Update discount label
      discount_label = session[:discount_percentage] ? "Descuento (#{session[:discount_percentage]}%)" : 'Descuento'

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
              'cart-items-body',
              partial: 'cart_items',
              locals: { cart_items: session[:cart] }
            ),
            turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('discount-label', discount_label)
          ]
        }
        format.json {
          render json: {
            success: true,
            cart: session[:cart],
            totals: totals,
            discount_label: discount_label
          }
        }
      end
    end

    # Add this method to clear the cart
    def clear_cart
      # Reset the cart in the session
      session[:cart] = []

      # Reset discount and discount percentage
      session[:discount] = 0
      session[:discount_percentage] = nil

      # Reset Customers
      session[:customer_name] = nil
      session[:customer_id] = nil

      # Calculate new totals
      totals = calculate_cart_totals

      # Update discount label (will be just "Descuento" since percentage is nil)
      discount_label = 'Descuento'

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
              'cart-items-body',
              partial: 'cart_items',
              locals: { cart_items: [] }
            ),
            turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('discount-label', discount_label)
          ]
        }
        format.json {
          render json: {
            success: true,
            message: 'Carrito borrado exitosamente',
            totals: totals,
            discount_label: discount_label
          }
        }
      end
    end

    # Add this method to your PosController
    def update_quantity
      product_id = params[:product_id]
      quantity = params[:quantity].to_i

      if session[:cart].present?
        item_index = session[:cart].find_index { |item| item['product_id'].to_s == product_id.to_s }

        if item_index
          session[:cart][item_index]['quantity'] = quantity
        end
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('cart-items-body', partial: 'pos/carts/cart_items', locals: { cart_items: session[:cart] }),
            turbo_stream.replace('cart-iva', partial: 'pos/carts/cart_iva'),
            turbo_stream.replace('cart-subtotal', partial: 'pos/carts/cart_subtotal'),
            turbo_stream.replace('cart-discount', partial: 'pos/carts/cart_discount'),
            turbo_stream.replace('cart-total', partial: 'pos/carts/cart_total')
          ]
        end
      end
    end

    # Add this method to your PosController
    def set_customer
      session[:customer_id] = params[:customer_id]
      session[:customer_name] = params[:customer_name]

      render json: { success: true }
    end

    private

    # Helper method to adjust discount based on cart changes
    def adjust_discount_if_needed
      # If cart is empty, reset discount to 0
      if session[:cart].blank?
        session[:discount] = 0
        return
      end

      # Calculate current subtotal
      subtotal = session[:cart].sum { |item| item['price'].to_f * item['quantity'].to_i }

      # If percentage discount is applied, recalculate based on new subtotal
      if session[:discount_percentage].present?
        session[:discount] = subtotal * (session[:discount_percentage].to_f / 100)
      # If fixed discount amount was stored, apply it now that we have products
      elsif session[:discount_fixed_amount].present?
        session[:discount] = [ session[:discount_fixed_amount].to_f, subtotal ].min
      else
        # For fixed discount, ensure it doesn't exceed the subtotal
        if session[:discount].to_f > subtotal
          session[:discount] = subtotal
        end
      end
    end
  end
end
