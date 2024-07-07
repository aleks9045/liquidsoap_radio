#разрешение запуска от root / permission to run the script from the root user
settings.init.allow_root.set(true)
settings.frame.duration := 0.08

#функции для метаданных / metadata functions
song_artist = ref('')
song_title = ref('')

def get_metadata(m) =
song_artist := m["artist"]
song_title := m["title"]
end

def get_track_name_text()
"$(artist) - $(title)" % [ 
("artist", song_artist()),    
("title", song_title())
]
end 

#следующая песня / next song
def log_next(r)
m = request.metadata(r)
file.write(data="#{metadata.artist(m)} - #{metadata.title(m)}", "/home/radio/src/next_song.txt")
true
end

next_song = (file.getter("/home/radio/src/next_song.txt"))

# источник аудио / audio source
audio1 = mksafe(playlist(reload=1800, reload_mode="seconds", "/home/radio/music/1/", check_next=log_next))
audio2 = mksafe(playlist(reload=1800, reload_mode="seconds", "/home/radio/music/2/", check_next=log_next))
audio3 = mksafe(playlist(reload=1800, reload_mode="seconds", "/home/radio/music/3/", check_next=log_next))
radio = switch([({8h or 11h or 14h or 17h or 20h or 23h or 2h or 5h}, audio1), ({9h or 12h or 15h or 18h or 21h or 24h or 3h or 6h}, audio2), ({10h or 13h or 16h or 19h or 22h or 1h or 4h or 7h}, audio3)])
radio = amplify(0.25, radio)
#источник видео / video source
background = single("/home/radio/video/video.gif")
background = video.add_image(x=1120, y=10, width=150, height=150, file="/home/radio/image/logo.png", background)
#вызов метаданных / calling metadata
radio.on_track(get_metadata)


#отрисовка текста / drawtext
font = "/home/radio/font/Everson Mono Bold.ttf"
small_font_size = 26
main_font_size = 32

background = video.add_text(color=0x000000, font=font, x=52, y=471, size=small_font_size,
"сейчас играет:",
background)
background = video.add_text(color=0xFFFFFF, font=font, x=50, y=470, size=small_font_size,
"сейчас играет:",
background)

background = video.add_text(color=0x000000, font=font, x=52, y=501, size=main_font_size,
get_track_name_text,
background)
background = video.add_text(color=0xFFFFFF, font=font, x=50, y=500, size=main_font_size,
get_track_name_text,
background)

background = video.add_text(color=0x000000, font=font, x=52, y=571, size=small_font_size,
"далее в эфире:",
background)
background = video.add_text(color=0xFFFFFF, font=font, x=50, y=570, size=small_font_size,
"далее в эфире:",
background)

background = video.add_text(color=0x000000, font=font, x=52, y=601, size=main_font_size,
next_song,
background)
background = video.add_text(color=0xFFFFFF, font=font, x=50, y=600, size=main_font_size,
next_song,
background)

#полоска трека
background = video.add_rectangle(color=0xFFFFFF, x=0, y=670, height=20, width={int(1280.0*source.elapsed(radio) / source.duration(radio))}, background)

#бегущая строка
background = video.add_rectangle(color=0x000000, x=0, y=690, height=30, width=1280, background)

x_pos = ref(-1280)

def make_shift ()
  x_pos := if x_pos() > 0 then -1280
          else  x_pos() + 4 end
  x_pos()
end

background = video.add_text(color=0xFFFFFF, font=font, x={make_shift()}, y=688, size=24,
"наш проект можно поддержать. задонатьте по ссылке в описани стрима или постов                наш проект можно поддержать. задонатьте по ссылке в описани стрима или постов",
background)

# смешивание / mixing sources
radio = source.mux.video(video=background, radio)

#rtmp+codec
tg_url = file.contents("/home/radio/src/tg_url.txt")
vk_url = file.contents("/home/radio/src/vk_url.txt")

enc = %ffmpeg(format="flv",
%video(codec="libx264", width=1280, height=720, pixel_format="yuv420p",
b="3000k", maxrate="3000k", minrate="3000k", bufsize="3000k", profile="Main", preset="veryfast", framerate=24, g=32),
%audio(codec="aac", samplerate=44100, b="128k"))

#вывод / output
output.url(fallible=true, url=tg_url, enc, radio)
output.url(fallible=true, url=vk_url, enc, radio)
