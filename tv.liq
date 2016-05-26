set("log.stdout", true)
set("osc.port", 6828)
set("frame.video.channels",1)
# set("frame.video.samplerate",12)
# set("frame.duration",1.0/30.0)
# set("frame.video.width",480)
# set("frame.video.height",480)
# img = single("/srv/http/wmbc-black-on-white-square.jpg")
noise_frame = noise()
audio = buffer(buffer=0.1,mksafe(input.jack(id="Video_In")))

meta     = insert_metadata(audio)
insert   = fst(meta)
metafied = snd(meta)
# OSC
def on_meta(m) =
  title = fst(m)
  artist = snd(m)
  # A debug message
  print("Artist: #{artist} Song: #{title}")
  insert([("title","#{title} by #{artist}")])
end
osc.on_string_pair("/metadata",on_meta)
# osc.on_string_pair("/album-art",on_aa)
# def on_aa(m) =
#   title = fst(m)
# end

# muxedNoise = mux_video(video=noise_frame, metafied)
muxedLogo = video.add_image(width=228,height=228,x=46,y=0,file="/srv/http/wmbc-black-on-white-square.png", noise_frame)
muxed = mux_video(video=muxedLogo, mksafe(metafied))

text_height=240 # int_of_string(get("frame.video.height"))
source = video.add_text(y=(text_height-20), metadata="title", "You're listening to WMBC", color=0, muxed)
output.icecast(
        %ogg(%theora(quality=5,width=320,height=240),%vorbis),
        host="localhost",
        port=4088,
        password=icecastpassword,
        name="WMBC-TV",genre="Various",url="wmbc.umbc.edu",description="UMBC's Student Uncensored Freeform Radio",
        mount="/live.ogv",
        source)
