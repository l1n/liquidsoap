#!/usr/bin/liquidsoap

set("log.stdout", true)
set("server.telnet", true)
set("harbor.bind_addr","0.0.0.0")
set("osc.port", 6727)

mpd = fallback([
        request.queue(id="request"),
	input.jack(id="MusicPD"),
	])
remote   = input.harbor("/",port=4089,password=icecast-password)
booth    = input.jack(id="Booth In")
booth_s  = strip_blank(max_blank=20.,booth)
# record   = input.jack(id="Record In")
# record_s = strip_blank(max_blank=5.,record)
mixed    = fallback(track_sensitive=false, [
           remote,
           booth_s,
#            record_s,
           mpd
           ])
meta     = insert_metadata(mixed)
insert   = fst(meta)
radio    = snd(meta)

# output.icecast(%ogg(%flac(channels=2, samplerate=44100, bits_per_sample=16)),
#   host="localhost",port=4088,password=icecast-password,
#   mount="live.flac",radio)
output.icecast(%ogg(%vorbis.abr(channels=2, samplerate=44100, bitrate=256)),
  host="localhost",port=4088,password=icecast-password,
  name="WMBC (Vorbis)",genre="Various",url="wmbc.umbc.edu",description="UMBC's Student Uncensored Freeform Radio",
  mount="live.ogg",radio)
output.icecast(%mp3.abr(stereo=true, samplerate=44100, bitrate=256), 
  host="localhost",port=4088,password=icecast-password,
  name="WMBC (MPEG)",genre="Various",url="wmbc.umbc.edu",description="UMBC's Student Uncensored Freeform Radio",
  mount="live.mp3",radio)
output.jack(id="monitor", radio)

def on_meta(m) =
  title = fst(m)
  artist = snd(m)
  # A debug message
  print("Artist: #{artist} Song: #{title}")
  insert([("song","#{title} by #{artist}"),("title","#{title}"),("artist","#{artist}")])
end

osc.on_string_pair("/metadata",on_meta)
