Kaminari.configure do |config|
  config.default_per_page = ApplicationController::RECORDS_PER_PAGE
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.param_name = :page
end
