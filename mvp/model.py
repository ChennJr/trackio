import json
import glob
import pandas as pd


class SpotifyDatasetProcessor:
    def __init__(self, directory):
        self.directory = sorted(glob.glob(directory + "\*json"), key=len)
        print(self.directory)
    
    def clean_data(self):
        df_list = []
        df = pd.DataFrame()

        for file in self.directory:
            with open(file, "rb") as infile:
                data = json.load(infile)
                
                for playlist in data['playlists']:
                    df_list.append(pd.DataFrame(playlist['tracks']))

                print(f"Number of playlists added: {len(df_list)}")

        df = pd.concat(df_list, ignore_index=True)
        df.drop_duplicates(subset=["track_uri"], inplace=True)
        print(f"Number of unique tracks: {len(df)}")
        df.to_csv("dataset.csv", index=False)


processor = SpotifyDatasetProcessor(directory="mvp\spotify_million_playlist_dataset\data")

processor.clean_data()
df = pd.read_csv("dataset.csv")
print(df)