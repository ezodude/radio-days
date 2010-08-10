# encoding: utf-8

require 'rubygems'
require "feedzirra"
require "lib/rss_schema"
require "lib/broadcast_radio_player"

class BroadcastMaker
  
  CHANNELS = {
    :theme_of_the_day => "http://rss.said.fm/v0.1/themes/theme_of_the_day.xml"
  }

  def initialize
    @broadcasts = []
  end

  def make_broadcast_for_channel(channel, todays_date)
    channel_feed = CHANNELS[channel]
    #p [:channel_feed, channel_feed]
    return if channel_feed.nil?

    todays_entries = get_channel_feed_entries_for(todays_date, channel_feed)
    #p [:todays_entries, todays_entries]

    todays_channel_title = todays_entries[0].theme.title
    @broadcasts << create_broadcast_for_channel(channel, todays_date, todays_channel_title, todays_entries)
    @broadcasts[0]
  end

  private

  def get_channel_feed_entries_for(date, channel_feed)
    feed = Feedzirra::Feed.fetch_and_parse(channel_feed)
    feed.entries.collect do |entry|
      entry if entry.published.to_date == date
    end.compact
  end

  def create_broadcast_for_channel(channel, todays_date, todays_channel_title, todays_entries)
    broadcast = Broadcast.new(channel, todays_date)
    
    broadcast.add_entry "media::http://localhost:4000/media/morning_greetings.mp3"
    broadcast.add_entry "media::http://localhost:4000/media/theme_of_the_day_broadcast_intro.mp3"
    broadcast.add_entry "say::#{todays_channel_title}"
    broadcast.add_entry "media::http://localhost:4000/media/our_first_programme.mp3"
    
    #p [:todays_entries_size, todays_entries.size]

    todays_entries.each_with_index do |entry, index|
      #p [:entry, entry.title]
      broadcast.add_entry "say::#{entry.title}"
      broadcast.add_entry "media::#{entry.audio_uri}"
      broadcast.add_entry "media::http://localhost:4000/media/next_programme.mp3" unless index + 1 == todays_entries.size
    end
    broadcast.add_entry "media::http://localhost:4000/media/conclusion.mp3"
    broadcast
  end
end

class Broadcast
  def initialize(channel, date)
    @channel = channel
    @date = date
    @queue = []
    @player = BroadcastRadioPlayer.new
  end

  def add_entry(content)
    @queue << content
  end

  def play
    @queue.each do |item|
      broadcast_entry_parts = item.split("::")
      type = broadcast_entry_parts[0]
      to_broadcast = broadcast_entry_parts[1]
      
      #p [:to_broadcast, to_broadcast]

      if type == "media" 
        @player.play(to_broadcast)
        sleep(1) while @player.playing?
      else
        `say #{to_broadcast}`
      end
    end
  end
end
