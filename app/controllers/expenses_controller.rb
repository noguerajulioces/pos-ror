class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy]

  def index
    @q = Expense.ransack(params[:q])
    @expenses = @q.result(distinct: true).includes(:payment_method).paginate(page: params[:page], per_page: 10)
  end

  def show; end

  def new
    @expense = Expense.new
  end

  def edit; end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save
      redirect_to expenses_url, notice: 'Gasto creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_url, notice: 'Gasto actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_url, notice: 'Gasto eliminado exitosamente.'
  end

  private

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:expense_date, :amount, :description, :category, :payment_method_id, :reference_number)
  end
end
