class ReportsController < ApplicationController
  def index
  end

  def products
    @products = Product.includes(:category, :unit)
                      .paginate(page: params[:page], per_page: 15)

    respond_to do |format|
      format.html
      format.pdf do
        # For PDF we don't want pagination, so we get all products
        @products_for_pdf = Product.includes(:category, :unit)
        render pdf: "productos_reporte_#{Date.current}",
               layout: 'pdf',
               template: 'reports/products',
               disposition: 'attachment',
               page_size: 'A4',
               encoding: 'UTF-8'
      end
    end
  end

  def orders
    @orders = Order.includes(:customer, :user, :payment_method, :order_items)
                  .order(order_date: :desc)
                  .paginate(page: params[:page], per_page: 15)

    respond_to do |format|
      format.html
    end
  end

  def expenses
    @q = Expense.ransack(params[:q])
    @expenses = @q.result.includes(:payment_method)
                        .order(expense_date: :desc)
                        .paginate(page: params[:page], per_page: 15)

    @total = @expenses.sum(:amount)

    respond_to do |format|
      format.html
      format.pdf
    end
  end

  def stocks
    @products = Product.includes(:category, :unit)

    # Basic inventory metrics
    @inventory_metrics = {
      total_value: @products.sum('stock * average_cost'),
      average_margin: @products.average('(price - COALESCE(manual_purchase_price, average_cost)) / NULLIF(COALESCE(manual_purchase_price, average_cost), 0) * 100'),
      stock_health: @products.in_stock.count.to_f / @products.count * 100
    }

    # Stock status breakdown
    @stock_status = {
      active: @products.active.count,
      low_stock: @products.where('min_stock IS NOT NULL AND stock <= min_stock').count,
      out_of_stock: @products.out_of_stock.count,
      total: @products.count
    }

    # Category analysis with percentage calculation
    @top_categories = Category.joins(:products)
                            .select('categories.*, COUNT(products.id) as products_count')
                            .group('categories.id')
                            .order('products_count DESC')
                            .limit(5)

    # Sales performance (30 days)
    @sales_analysis = {
      top_sellers: Product.joins(:sale_items)
                         .where('sale_items.created_at > ?', 30.days.ago)
                         .group('products.id')
                         .select('products.*, COUNT(sale_items.id) as sales_count')
                         .order('sales_count DESC')
                         .limit(5),

      high_turnover: Product.joins(:sale_items)
                           .group('products.id')
                           .select('products.*, (COUNT(sale_items.id) / NULLIF(products.stock, 0)) as turnover_rate')
                           .order('turnover_rate DESC')
                           .limit(5)
    }

    # Stock movement trends
    @movement_trends = Product.joins(:inventory_movements)
                            .where('inventory_movements.created_at > ?', 30.days.ago)
                            .group('products.id')
                            .select('products.*, SUM(inventory_movements.quantity) as movement_count')
                            .order('movement_count DESC')
                            .limit(5)
  end

  def income_expenses
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_month

    # Get completed orders for incomes
    @orders = Order.where(status: 'completed', order_date: @start_date.beginning_of_day..@end_date.end_of_day).order(order_date: :asc)
    @incomes_total = @orders.sum(:total_amount)

    # Get expenses
    @expenses = Expense.where(expense_date: @start_date..@end_date).order(expense_date: :asc)
    @expenses_total = @expenses.sum(:amount)

    @balance = @incomes_total - @expenses_total

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "ingresos_gastos_#{@start_date}_al_#{@end_date}",
               layout: 'pdf',
               template: 'reports/income_expenses',
               disposition: 'attachment'
      end
      format.csv do
        require 'csv'
        csv_data = CSV.generate(headers: true) do |csv|
          csv << ["Fecha", "Tipo", "Descripción", "Monto"]
          
          @orders.each do |order|
            csv << [order.order_date.to_date, "Ingreso", "Orden ##{order.id}", order.total_amount]
          end
          
          @expenses.each do |expense|
            csv << [expense.expense_date, "Gasto", expense.description, expense.amount]
          end
          
          csv << []
          csv << ["TOTAL INGRESOS", "", "", @incomes_total]
          csv << ["TOTAL GASTOS", "", "", @expenses_total]
          csv << ["BALANCE", "", "", @balance]
        end
        send_data csv_data, filename: "ingresos_gastos_#{@start_date}_al_#{@end_date}.csv", type: "text/csv"
      end
    end
  end

  def credits
    @q = Order.where(status: 'pending_payment').ransack(params[:q])
    @orders = @q.result.includes(:customer, :user)
                  .order(order_date: :desc)

    @total_amount = @orders.sum(:total_amount)
    @total_paid = @orders.joins(:order_payments).sum('order_payments.amount')
    @total_outstanding = @total_amount - @total_paid

    @orders_paginated = @orders.paginate(page: params[:page], per_page: 15)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "reporte_creditos_#{Date.current}",
               layout: 'pdf',
               template: 'reports/credits',
               disposition: 'attachment',
               page_size: 'A4',
               encoding: 'UTF-8'
      end
      format.csv do
        require 'csv'
        csv_data = CSV.generate(headers: true) do |csv|
          csv << ["Fecha", "Cliente", "Vendedor", "Total", "Pagado", "Pendiente"]
          @orders.each do |order|
            csv << [
              order.order_date.strftime("%d/%m/%Y"),
              order.customer&.name || "N/A",
              order.user.name,
              order.total_amount,
              order.total_paid,
              order.outstanding_balance
            ]
          end
          csv << []
          csv << ["TOTALES", "", "", @total_amount, @total_paid, @total_outstanding]
        end
        send_data csv_data, filename: "reporte_creditos_#{Date.current}.csv"
      end
    end
  end
end
