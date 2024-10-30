import json
import glob
import time
import pandas as pd

class SpotifyDatasetProcessor:
    def __init__(self, directory):
        self.directory = sorted(glob.glob(directory + r"\*json"), key=len)
    
    def get_all_tracks_info(self, file_path):
        track_data = []

        with open(file_path, "rb") as infile:
            data = json.load(infile)

            for playlist in data['playlists']:
                track_data.extend(playlist['tracks'])

        return track_data

    def clean_data(self):
        time_start = time.process_time()
        tracks_list = []
        chunk_size = 2500000
        for file in self.directory:
            track_data = self.get_all_tracks_info(file)
            tracks_list.extend(track_data)

            if len(tracks_list) >= chunk_size:
                df = pd.DataFrame(tracks_list)
                df.drop(columns=["pos", "duration_ms", "album_name", "album_uri"], inplace=True)
                df.drop_duplicates(subset=["track_uri"], ignore_index=True, inplace=True)
                df.to_csv(r"mvp\dataset.csv", mode="a", index=False)
                tracks_list.clear()
            
            percentage_complete = (((int(self.directory.index(file) + 1)) / 1000) * 100)

            print(f"{'{:.2f}'.format(percentage_complete)}% completed")

        
        df = pd.DataFrame(tracks_list)
        df.drop(columns=["pos", "duration_ms", "album_name", "album_uri"], inplace=True)
        df.drop_duplicates(subset=["track_uri"], ignore_index=True, inplace=True)
        df.to_csv(r"mvp\dataset.csv", mode="a", index=False)

        df = pd.read_csv(r"mvp\dataset.csv")
        df.drop_duplicates(subset=["track_uri"], ignore_index=True, inplace=True)
        df.to_csv(r"mvp\dataset.csv", mode="w", index=False)

        time_taken = time.process_time() - time_start
        print(f"Time taken: {time_taken} seconds")


processor = SpotifyDatasetProcessor(directory=r"mvp\spotify_million_playlist_dataset\data")
processor.clean_data()
df = pd.read_csv(r"mvp\dataset.csv")
print(df)
