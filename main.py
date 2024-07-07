import os

import music_tag
import paramiko
from dotenv import load_dotenv

load_dotenv()

SSH_HOST = os.getenv("HOST")
SSH_LOGIN = os.getenv("LOGIN")
SSH_PASSWORD = os.getenv("PASSWORD")

MUSIC_DIRECTORY = os.getenv("MUSIC_DIRECTORY")


def make_tags():
    if len(os.listdir(MUSIC_DIRECTORY)) == 0:
        raise FileNotFoundError("В папке с музыкой не обнаружено ни одного файла.")
    print("Начало редактирования метаданных.")
    for filename in os.listdir(MUSIC_DIRECTORY):
        file_path = os.path.join(MUSIC_DIRECTORY, filename)
        if os.path.isfile(file_path) and filename.endswith((".mp3", "aac", "m4a", ".ogg", ".wav")):
            f = music_tag.load_file(file_path)
            filename_split = " - "
            if not f["artist"] and not f["tracktitle"]:
                try:
                    filename_split = filename.split("-")
                except Exception:
                    print(f"Произошла ошибка при обработке метаданных трека: {filename}, пропуск.")
                    continue
                finally:
                    artist, track_title = filename_split[0], filename_split[1]
                    track_title = track_title[:-4]
                    f["artist"] = artist
                    f["tracktitle"] = track_title
                    f.save()
                    print(filename, "отредактирован.")
            else:
                print(filename, "пропущен.")
    print("Все метаданные отредактированы.")


def send_to_host():
    print("Начало передачи файлов.\nЖанры: Рок - 1. Рэп - 2. Электро - 3.")
    count_sent_files = 0
    count_files = len(os.listdir(MUSIC_DIRECTORY))

    host = SSH_HOST
    port = 22
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=host, username=SSH_LOGIN, password=SSH_PASSWORD, port=port)
    sftp = client.open_sftp()
    for filename in os.listdir(MUSIC_DIRECTORY):
        count_sent_files += 1
        file_path = os.path.join(MUSIC_DIRECTORY, filename)
        if os.path.isfile(file_path) and filename.endswith((".mp3", ".aac", ".m4a", ".ogg", ".wav")):
            genre = int(input(f"Введите жанр(цифру) для {filename}: "))
            destination = f'/home/radio/music/{genre}/{filename}'
            sftp.put(file_path, destination)
            os.remove(file_path)
            print(f"{filename} был отправлен. ({count_sent_files} / {count_files})")
    sftp.close()
    client.close()
    print(f"Было передано {count_sent_files} / {count_files} файлов.")


if __name__ == "__main__":
    try:
        make_tags()
        send_to_host()
    except Exception as e:
        print(e)
    finally:
        input("Нажмите Enter для выхода")
