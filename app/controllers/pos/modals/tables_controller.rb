module Pos
  module Modals
    class TablesController < BaseController
      def show
        @tables = Table.active.order(:name)
        render json: @tables.map { |table| { id: table.id, name: table.name } }
      end
    end
  end
end

