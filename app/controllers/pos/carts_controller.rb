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
        existing_item['quantity'] = (existing_item['quantity'].to_f + quantity.to_f).to_s
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
          # Replace the entire cart-items container to update both mobile and desktop
          render turbo_stream: [
            turbo_stream.replace(
              'cart-items',
              partial: 'pos/main/cart_items'
            ),
            turbo_stream.update('cart-subtotal-mobile', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-subtotal-desktop', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva-mobile', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva-desktop', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount-mobile', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount-desktop', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total-mobile', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total-desktop', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('delivery-section', partial: 'pos/main/delivery_section', locals: { totals: totals }),
            turbo_stream.update('discount-label-mobile', discount_label),
            turbo_stream.update('discount-label-desktop', discount_label)
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
          # Replace the entire cart-items container to update both mobile and desktop
          render turbo_stream: [
            turbo_stream.replace(
              'cart-items',
              partial: 'pos/main/cart_items'
            ),
            turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('delivery-section', partial: 'pos/main/delivery_section', locals: { totals: totals }),
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
      # Si hay un pedido en espera cargado en el POS, cancelarlo
      if session[:on_hold_order_id].present?
        order = Order.find_by(id: session[:on_hold_order_id])
        order.update(status: 'cancelled') if order&.on_hold?
        session[:on_hold_order_id] = nil
      end

      # Reset the cart in the session
      session[:cart] = []

      # Reset discount and discount percentage
      session[:discount] = 0
      session[:discount_percentage] = nil

      # Reset Customers
      session[:customer_name] = nil
      session[:customer_id] = nil

      # Reset Delivery
      session[:delivery_user_id] = nil
      session[:delivery_user_name] = nil
      session[:delivery_amount] = 0

      # Reset Order Info (Table, Notes, Type)
      session[:table_id] = nil
      session[:order_notes] = nil
      session[:order_type] = 'in_store'

      # Calculate new totals
      totals = calculate_cart_totals

      # Update discount label (will be just "Descuento" since percentage is nil)
      discount_label = 'Descuento'

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
              'cart-items',
              partial: 'pos/main/cart_items'
            ),
            turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('delivery-section', partial: 'pos/main/delivery_section', locals: { totals: totals }),
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
      quantity = params[:quantity].to_f

      if session[:cart].present?
        item_index = session[:cart].find_index { |item| item['product_id'].to_s == product_id.to_s }

        if item_index
          session[:cart][item_index]['quantity'] = quantity
        end
      end

      # Recalculate discount if it's a percentage
      adjust_discount_if_needed

      # Calculate new totals
      totals = calculate_cart_totals

      # Update discount label
      discount_label = session[:discount_percentage] ? "Descuento (#{session[:discount_percentage]}%)" : 'Descuento'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('cart-items', partial: 'pos/main/cart_items'),
            turbo_stream.update('cart-subtotal-mobile', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-subtotal-desktop', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva-mobile', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-iva-desktop', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount-mobile', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-discount-desktop', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total-mobile', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total-desktop', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('delivery-section', partial: 'pos/main/delivery_section', locals: { totals: totals }),
            turbo_stream.update('discount-label-mobile', discount_label),
            turbo_stream.update('discount-label-desktop', discount_label)
          ]
        end
      end
    end

    # Add this method to your PosController
    def set_customer
      session[:customer_id] = params[:customer_id]
      session[:customer_name] = params[:customer_name]

      respond_to do |format|
        format.json { render json: { success: true } }
        format.turbo_stream {
          # Render partials for customer info updates (specify format as :html)
          mobile_content = render_to_string(partial: 'pos/main/customer_info_mobile', locals: { customer_name: session[:customer_name] }, formats: [:html])
          desktop_content = render_to_string(partial: 'pos/main/customer_info_desktop', locals: { customer_name: session[:customer_name] }, formats: [:html])
          
          render turbo_stream: [
            turbo_stream.update('customer-info-mobile', mobile_content),
            turbo_stream.update('customer-info-desktop', desktop_content),
            turbo_stream.update('selected-customer-id-mobile', session[:customer_id] || '')
          ]
        }
      end
    end

    # Add this method to handle delivery assignment
    def assign_delivery
      # Only save delivery amount, not user (user assigned later in orders)
      session[:delivery_amount] = params[:amount].to_f

      # Clear delivery user if amount is 0
      if session[:delivery_amount].zero?
        session[:delivery_user_id] = nil
        session[:delivery_user_name] = nil
        session[:order_type] = 'in_store'
      else
        # Set order type to delivery when amount > 0 and clear table
        session[:order_type] = 'delivery'
        session[:table_id] = nil
      end

      # Calculate new totals
      totals = calculate_cart_totals

      respond_to do |format|
        format.turbo_stream {
          # Preparar script inyectado de cerrado forzado del modal
          modal_close_script = <<~JS
            <script>
              document.querySelectorAll('.fixed.inset-0').forEach(el => {
                if (el.dataset.controller === 'modal') {
                  el.remove();
                }
              });
            </script>
          JS
          
          delivery_label_html = <<~HTML
            <span class="md:hidden text-indigo-600">Delivery</span>
            <span class="hidden md:inline">Delivery</span>
          HTML
          
          # Construir la estructura de streams
          render turbo_stream: [
            turbo_stream.remove('modal'),
            turbo_stream.update('delivery-section', partial: 'pos/main/delivery_section', locals: { totals: totals }),
            turbo_stream.update('cart-total-mobile', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('cart-total-desktop', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
            turbo_stream.update('order-type-display-desktop', "Delivery"),
            turbo_stream.update('order-type-display-mobile', delivery_label_html),
            turbo_stream.replace('table-display-container-mobile', '<div id="table-display-container-mobile"></div>'),
            turbo_stream.replace('table-display-container-desktop', '<div id="table-display-container-desktop"></div>'),
            turbo_stream.append('body', modal_close_script)
          ]
        }
        format.json {
          render json: {
            success: true,
            delivery_amount: totals[:delivery_amount],
            totals: totals,
            order_type: session[:order_type]
          }
        }
      end
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
      subtotal = session[:cart].sum { |item| item['price'].to_f * item['quantity'].to_f }

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
