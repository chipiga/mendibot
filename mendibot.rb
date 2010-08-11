require 'rubygems'
require 'isaac'
require "#{File.dirname(__FILE__)}/bot_config"
require 'rest-client'
require 'json'
require 'date'

$topics = {}

on :channel, /^!site$/ do
  msg channel, "http://university.rubymendicant.com"
end

on :channel, /^!topic (.*)/ do
  $topics[channel] = match[0]
  msg channel, "The topic is now #{$topics[channel]}"
end

on :channel, /^!topic$/ do
  topic = $topics[channel]
  if topic
    msg channel, "The topic is currently #{$topics[channel]}"
  else
    msg channel, "The topic is not currently set"
  end
end

on :channel do
  msg = { 
    :channel     => channel, 
    :handle      => nick, 
    :body        => message, 
    :recorded_at => DateTime.now,
    :topic       => $topics[channel]
  }.to_json
  
  service["/chat/messages.json"].post(:message => msg)
end

on :channel, /^!bitly (.*?) (.*?)$/ do
  case match[0]
  when 'shorten' # Get shorten URL
    begin
      result = bitly.shorten(match[1]).short_url
    rescue Exception => e
      result = "Error: " + e.message
    end
  when 'info'
    begin
      result = bitly.info(match[1]).long_url
    rescue Exception => e
      result = "Error: " + e.message
    end
  when 'stats'
    begin
      b = bitly.stats(match[1]).stats
      result = "Clicks: #{b['clicks']}, User clicks: #{b['userClicks']}"
    rescue Exception => e
      result = "Error: " + e.message
    end
  else
    result = 'Unknown command. Currently support only shorten, info and stats commands'
  end
  msg channel, result
end

on :channel, /^!translate (.*?) (.*?)$/ do
  begin
    if match[0].include?('|')
      from = match[0].split('|').first
      to = match[0].split('|').last
    else
      from = translator.detect_language(match[1])['language']
      to = match[0]
    end
    result = entities.decode(translator.translate(from.to_sym, to.to_sym, match[1]))
  rescue Exception => e
    result = "Error: " + e.message
  end
  msg channel, result
end

on :channel, /^!twitter (.*?) (.*?)$/ do
  case match[0]
  when 'status' # Get user status and try translate it to english
    begin
      result = Twitter.user(match[1]).status.text
      from = translator.detect_language(result)['language']
      to = 'en'
      result = entities.decode(translator.translate(from.to_sym, to.to_sym, result)) unless from == to
    rescue Exception => e
      result = "Error: " + e.message unless e.class.to_s.include?('Google::Translator') # Ignore translation errors
    end
  when 'update' # Update user status, automatically short URLs through bit.ly
    begin
      text = match[1]

      URI.extract(text, "http").each{|url| text.sub!(url, bitly.shorten(url).short_url)}

      t = twitter.update(text)
      result = "http://twitter.com/#{t.user.screen_name}/status/#{t.id}"
    rescue Exception => e
      result = "Error: " + e.message
    end
  else
    result = 'Unknown command. Currently support only status and update commands'
  end
  msg channel, result
end
