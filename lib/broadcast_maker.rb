# encoding: utf-8

require 'rubygems'
require "feedzirra"
require "rss_schema"

class BroadcastMaker
  
  CHANNELS = {
    :theme_of_the_day => "http://rss.said.fm/v0.1/themes/theme_of_the_day.xml"
  }

  def initialize(args)
    @broadcasts = []
  end

  def create_broadcast_for_channel(channel=:theme_of_the_day, todays_date)
    channel_feed = CHANNELS[:channel]
    return unless channel_feed

    todays_entries = get_channel_feed_entries_for(todays_date, channel_feed)

    todays_channel_title = todays_entries[0].theme.title
    @broadcasts << create_broadcast_for(channel, todays_date, todays_channel_title)
  end

  private

  def get_channel_feed_entries_for(date, channel_feed)
    feed = Feedzirra::Feed.fetch_and_parse(channel_feed)
    feed.entries.collect do |entry|
      entry if entry.published.to_date == date
    end
  end

  def create_broadcast_for_channel(channel, todays_date, todays_channel_title)
    broadcast = Broadcast.new(channel, todays_date)
    
    broadcast.add_entry "media::#{Dir.getwd}/../media/morning_greeting.mp3"
    broadcast.add_entry "media::#{Dir.getwd}/../media/theme_of_the_day_broadcast_intro.mp3"
    broadcast.add_entry "say::#{todays_channel_title}"
    broadcast.add_entry "media::#{Dir.getwd}/../media/our_first_programme.mp3"

    todays_entries.each_with_index do |entry, index|
      broadcast.add_entry "say::#{entry.title}"
      broadcast.add_entry "media::#{entry.audio_uri}"
      broadcast.add_entry "media::#{Dir.getwd}/../media/next_programme.mp3" unless index + 1 == todays_entries.size
    end
    broadcast.add_entry "media::#{Dir.getwd}/../media/conclusion.mp3"
    broadcast
  end
end

class Broadcast
  def initialize(channel, date)
    @channel = channel
    @date = date
    @state = :new
    @queue = []
  end

  def add_entry(content)
    @queue << content
  end
end
