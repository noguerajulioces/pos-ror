class UnitsController < ApplicationController
  before_action :set_unit, only: [ :edit, :update, :destroy ]

  def index
    @units = Unit.paginate(page: params[:page])
  end

  def new
    @unit = Unit.new
  end

  def edit
  end

  def create
    @unit = Unit.new(unit_params)

    respond_to do |format|
      if @unit.save
        format.turbo_stream
        format.html { redirect_to units_path, notice: 'Unidad creada exitosamente.' }
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.turbo_stream
        format.html { redirect_to units_path, notice: 'Unidad actualizada exitosamente.' }
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @unit.destroy
    redirect_to units_path, notice: 'Unidad eliminada exitosamente.'
  end

  private

  def set_unit
    @unit = Unit.find(params[:id])
  end

  def unit_params
    params.require(:unit).permit(:name, :abbreviation, :description)
  end
end
