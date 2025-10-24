# frozen_string_literal: true

module RequestSpecHelper
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end
