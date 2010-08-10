# encoding: utf-8

require 'rubygems'
require "rbosa"

class BroadcastRadioPlayer
  def initialize
    @app = OSA.app('QuickTime Player')
    OSA.wait_reply = true
  end
  
  def play(media)
    @app.get_url(media)
    sleep(1)
    @current_media = @app.documents[0]
    @current_media.play
  end  

  def playing?
    @current_media && @current_media.playing?
  end
  
  def pause
    @app.playpause
  end
  
  def stop
    return unless playing?
    @app.close(@current_media)
    @current_podcast = nil
  end
end
