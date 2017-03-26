module PostTextHelpers
  def post_text(action, text)
    @request.env['RAW_POST_DATA'] = text
    post action, params: { format: :text }
    @request.env.delete('RAW_POST_DATA')
  end
end

RSpec.configure do |config|
  config.include PostTextHelpers
end
