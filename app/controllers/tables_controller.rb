class TablesController < ApplicationController
  before_action :set_table, only: %i[show edit update destroy]

  def index
    @q = Table.ransack(params[:q])
    @tables = @q.result(distinct: true).order(:name).paginate(page: params[:page], per_page: 10)
  end

  def show; end

  def new
    @table = Table.new
  end

  def create
    @table = Table.new(table_params)
    @table.account_id = current_user.account_id

    if @table.save
      redirect_to tables_path, notice: 'Mesa creada exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @table.update(table_params)
      redirect_to tables_path, notice: 'Mesa actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @table.orders.any?
      redirect_to tables_path, alert: 'No se puede eliminar una mesa con órdenes asociadas.'
    else
      @table.destroy
      redirect_to tables_path, notice: 'Mesa eliminada exitosamente.'
    end
  end

  private

  def set_table
    @table = Table.find(params[:id])
  end

  def table_params
    params.require(:table).permit(:name, :active)
  end
end

