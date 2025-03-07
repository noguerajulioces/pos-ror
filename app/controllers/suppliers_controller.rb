class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update destroy]

  def index
    @suppliers = Supplier.paginate(page: params[:page], per_page: 10)
  end

  def show; end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)
    if @supplier.save
      redirect_to @supplier, notice: "Proveedor creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @supplier.update(supplier_params)
      redirect_to @supplier, notice: "Proveedor actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @supplier.destroy
    redirect_to suppliers_path, notice: "Proveedor eliminado exitosamente."
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(
      :company_name, :document, :contact_name, :email, :phone, :address, :notes
    )
  end
end
