Rails.logger = ActiveSupport::BufferedLogger.new(Rails.root.join("log","production.log"))
