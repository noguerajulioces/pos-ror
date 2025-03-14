class ReportsController < ApplicationController
  def index
  end

  def products
    @products = Product.includes(:category, :unit)
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "productos_reporte_#{Date.current}",
               layout: 'pdf',
               template: 'reports/products',
               disposition: 'attachment'
      end
    end
  end

  def orders
    @orders = Order.includes(:customer, :user, :order_items)
                  .order(order_date: :desc)
    
    respond_to do |format|
      format.html
      format.pdf
    end
  end

  def stocks
    @stock_movements = InventoryMovement.includes(:product)
                                      .order(created_at: :desc)
    respond_to do |format|
      format.html
      format.xlsx
      format.pdf
    end
  end

  def expenses
    @expenses = Expense.includes(:expense_category)
                      .order(date: :desc)
    respond_to do |format|
      format.html
      format.xlsx
      format.pdf
    end
  end
end