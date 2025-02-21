# Main controller
class MainController < ApplicationController
  skip_before_action :authenticate_user!, only: :error
  def search
  end

  def error
    redirect_to :root, alert: I18n.t("controllers.no_page")
  end  
end
