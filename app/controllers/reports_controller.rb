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
               layout: "pdf",
               template: "reports/products",
               disposition: "attachment"
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
      total_value: @products.sum("stock * average_cost"),
      average_margin: @products.average("(price - COALESCE(manual_purchase_price, average_cost)) / NULLIF(COALESCE(manual_purchase_price, average_cost), 0) * 100"),
      stock_health: @products.in_stock.count.to_f / @products.count * 100
    }

    # Stock status breakdown
    @stock_status = {
      active: @products.active.count,
      low_stock: @products.where("stock <= min_stock").count,
      out_of_stock: @products.out_of_stock.count,
      total: @products.count
    }

    # Category analysis with percentage calculation
    @top_categories = Category.joins(:products)
                            .select("categories.*, COUNT(products.id) as products_count")
                            .group("categories.id")
                            .order("products_count DESC")
                            .limit(5)

    # Sales performance (30 days)
    @sales_analysis = {
      top_sellers: Product.joins(:sale_items)
                         .where("sale_items.created_at > ?", 30.days.ago)
                         .group("products.id")
                         .select("products.*, COUNT(sale_items.id) as sales_count")
                         .order("sales_count DESC")
                         .limit(5),

      high_turnover: Product.joins(:sale_items)
                           .group("products.id")
                           .select("products.*, (COUNT(sale_items.id) / NULLIF(products.stock, 0)) as turnover_rate")
                           .order("turnover_rate DESC")
                           .limit(5)
    }

    # Stock movement trends
    @movement_trends = Product.joins(:inventory_movements)
                            .where("inventory_movements.created_at > ?", 30.days.ago)
                            .group("products.id")
                            .select("products.*, SUM(inventory_movements.quantity) as movement_count")
                            .order("movement_count DESC")
                            .limit(5)
  end
end
