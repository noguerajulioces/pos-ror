module Pos
  module Modals
    class BaseController < ApplicationController
      layout false
      
      private
      
      def mobile_device?
        browser = Browser.new(request.user_agent, accept_language: request.accept_language)
        browser.device.mobile? || browser.device.tablet?
      end
      
      helper_method :mobile_device?
    end
  end
end
