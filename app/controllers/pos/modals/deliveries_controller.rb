module Pos
  module Modals
    class DeliveriesController < BaseController
      def show
        @delivery_users = User.joins(:roles)
                             .where(roles: { name: 'Delivery' })
                             .where(account_id: current_user.account_id)
                             .active
                             .order(:name)

        render 'pos/modals/delivery_modal'
      end
    end
  end
end
