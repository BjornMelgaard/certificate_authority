module ViewHelpers
  def urls
    Rails.application.routes.url_helpers
  end

  def h
    ActionController::Base.helpers
  end
end
