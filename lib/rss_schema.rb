# encoding: utf-8

module SaidFm
  class ThemeEntry
    include SAXMachine
    include Feedzirra::FeedEntryUtilities
    element :title
  end

  class PodcastRSSEntry
    include SAXMachine
    include Feedzirra::FeedEntryUtilities
    element :title
    
    element :pubDate, :as => :published
    element :pubdate, :as => :published

    element :guid, :as => :id
    
    element :"itunes:duration", :as => :itunes_duration
    element :enclosure, :value => :url, :as => :audio_uri

    element :"saidfm:theme", :as => :theme, :class => SaidFm::ThemeEntry
  end
  
  class PodcastRSS
    include SAXMachine
    include Feedzirra::FeedUtilities
    elements :item, :as => :entries, :class => SaidFm::PodcastRSSEntry
    attr_accessor :feed_url
    def self.able_to_parse?(xml)
      xml =~ /\<rss|\<rdf/
    end
  end
end

Feedzirra::Feed.add_feed_class(SaidFm::PodcastRSS)
