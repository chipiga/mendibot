require 'rubygems'
require 'isaac'
require "#{File.dirname(__FILE__)}/bot_config"
require File.join(File.dirname(__FILE__), 'plugins')
require 'rest-client'
require 'json'
require 'date'
# require 'ruby-debug'

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

on :channel, /^!bitly shorten (.*)$/ do
  msg channel, Plugins::Bitly.process('shorten', match[0])
end

on :channel, /^!bitly info (.*)$/ do
  msg channel, Plugins::Bitly.process('info', match[0])
end

on :channel, /^!bitly stats (.*)$/ do
  msg channel, Plugins::Bitly.process('stats', match[0])
end

on :channel, /^!translate (.*?) (.*?)$/ do
  msg channel, Plugins::Translate.process(match[0], match[1])
end

on :channel, /^!twitter status (.*)$/ do
  msg channel, Plugins::Twitter.process('status', match[0])
end

on :channel, /^!twitter update (.*)$/ do
  msg channel, Plugins::Twitter.process('update', match[0])
end
