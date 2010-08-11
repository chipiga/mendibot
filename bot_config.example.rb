require 'bitly'
require 'google_translate' # gem google-translate
require 'twitter'
require 'htmlentities'

helpers do
  def bitly
    @bitly ||= Bitly.new('bitly_username', 'bitly_api_key')
  end

  def translator
    @translator ||= Google::Translator.new
  end

  def twitter
    @twitter ||= Twitter::Base.new(Twitter::HTTPAuth.new('twitter@email.com', 'password'))
  end

  def entities
    @entities ||= HTMLEntities.new
  end
end
