import json
import random
import glob
import time
import pandas as pd
import psutil
import os


import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from spotipy.oauth2 import SpotifyOAuth

from dotenv import load_dotenv


class SpotifyDatasetProcessor:
    def __init__(self, client_id, client_secret, directory=str):
        """
        :param directory: Directory containing the spotify dataset json files
        """
        self.directory = sorted(glob.glob(directory + r"\*json"), key=len)
        self.csv_file = r"mvp\dataset.csv"
        self.client_id = client_id
        self.client_secret = client_secret
        self.sp = self.create_spotify_client()

    def create_empty_csv(self):
        """
        Creates an empty csv file with the columns: artist_name, track_uri, artist_uri, track_name
        """
        if not os.path.exists(self.csv_file):
            columns = ['artist_name', 'track_uri', "artist_uri", 'track_name']
            df = pd.DataFrame(columns=columns)
            df.to_csv(self.csv_file, index=False)
            print(f"{self.csv_file} created with columns: {', '.join(columns)}")

        else:
            print(f"{self.csv_file} already exists.")

    def get_all_tracks_info(self, file_path):
        """
        :param file_path: Path to the json file containing the playlist data
        :return: List of dictionaries containing the track information
        """
        track_data = []

        with open(file_path, "rb") as infile:
            data = json.load(infile)

            for playlist in data['playlists']:
                track_data.extend(playlist['tracks'])

        return track_data

    def clean_data(self):
        """
        Cleans the spotify dataset given and writes it to a csv file
        """
        time_start = time.process_time()
        tracks_list = []
        self.create_empty_csv()

        for file in self.directory:
            track_data = self.get_all_tracks_info(file)
            tracks_list.extend(track_data)

            if int(psutil.virtual_memory().available / 1000000000) <= 3:
                df = pd.DataFrame(tracks_list)
                df.drop(columns=["pos", "duration_ms",
                        "album_name", "album_uri"], inplace=True)
                df.drop_duplicates(
                    subset=["track_uri"], ignore_index=True, inplace=True)
                df.to_csv(r"mvp\dataset.csv", mode="a",
                          index=False, header=False)
                tracks_list.clear()

            percentage_complete = (
                ((int(self.directory.index(file) + 1)) / 1000) * 100)

            print(f"{'{:.2f}'.format(percentage_complete)}% completed")

        if tracks_list:
            df = pd.DataFrame(tracks_list)
            df.drop(columns=["pos", "duration_ms",
                    "album_name", "album_uri"], inplace=True)
            df.drop_duplicates(subset=["track_uri"],
                            ignore_index=True, inplace=True)
            
            df.to_csv(r"mvp\dataset.csv", mode="a", index=False, header=False)

        df = pd.read_csv(r"mvp\dataset.csv")
        df.drop_duplicates(subset=["track_uri"],
                           ignore_index=True, inplace=True)
        df = df.sort_values(by=['track_name', 'artist_name'], ignore_index=True)
        df.to_csv(r"mvp\dataset.csv", mode="w", index=False)

        time_taken = time.process_time() - time_start
        print(f"Time taken: {time_taken} seconds")

    def create_spotify_client(self):
        """
        Creates a Spotify client using the SpotifyClientCredentials manager.
        """
        credentials_manager = SpotifyClientCredentials(
            client_id=self.client_id, client_secret=self.client_secret)
        return spotipy.Spotify(auth_manager=credentials_manager)
    
    def spotify_call(self, func, *args, retries=3):
        """
        Try a Spotify API call a specified number of times.

        Args:
            func (function): The Spotify API function to call
            retries (int): The number of retries to attempt

        Returns:
            The result of the Spotify API call
        """

        for attempt in range(retries):
            try:
                return func(*args)
            except spotipy.exceptions.SpotifyException as e:
                if e.http_status == 401:
                    print(f"401 Unauthorized. Attempt {
                          attempt + 1}/{retries}. Reinitializing client...") 
                    self.sp = self.create_spotify_client()  # Reinitialize the client
                else:
                    print(f"SpotifyException: {e}")
                    raise

    def process_batch(self, batch):
        """
        Extracts audio features for each track in the batch and returns a dataframe with the following columns:
        - artist_pop: The popularity of the artist
        - genres: The genres of the artist
        - danceability: The danceability of the track from 9 to 1
        - energy: The energy of the track
        - key: The key of the track
        - loudness: The loudness of the track
        - mode: The mode of the track
        - speechiness: The speechiness of the track
        - acousticness: The acousticness of the track
        - instrumentalness: The instrumentalness of the track
        - liveness: The liveness of the track
        - valence: The valence of the track
        - tempo: The tempo of the track
        - track_pop: The popularity of the track


        Args:
            batch (pandas DataFrame): A batch of track URIs and artist URIs as a DataFrame

        Returns:
            pandas DataFrame: A dataframe with the extracted track features

        """

        # Separate the artist URIs and track URIs
        artist_uris = batch['artist_uri']
        track_uris = batch['track_uri']

        # Fetch artist information
        artist_info_list = []
        for i in range(0, len(artist_uris), 50):  # batch size of 50 for artist info
            artist_info_list.extend(self.spotify_call(
                self.sp.artists, artist_uris[i:i+50])["artists"])

        artist_info = pd.DataFrame(
            [{'artist_pop': artist['popularity'], 'genres': artist['genres']} for artist in artist_info_list])

        # Fetch track audio features
        track_features_list = []
        for i in range(0, len(track_uris), 100):  # batch size of 100 for audio features
            track_features_list.extend(self.spotify_call(
                self.sp.audio_features, track_uris[i:i+100]))
            for i, track_features in enumerate(track_features_list):
                if track_features is None:
                    track_features_list[i] = {'danceability': None, 'energy': None, 'key': None, 'loudness': None, 'mode': None,
                                              'speechiness': None, 'acousticness': None, 'instrumentalness': None, 'liveness': None, 'valence': None, 'tempo': None}
                else:
                    track_features_list[i] = {k: v for k, v in track_features.items() if k not in [
                        "track_href", "analysis_url", "type", "uri", "duration_ms", "time_signature", "id"]}

        track_features = pd.DataFrame(track_features_list)

        # Fetch track popularity
        track_pop_list = []
        for i in range(0, len(track_uris), 50):  # batch size of 50 for track info
            track_pop_response = self.spotify_call(
                self.sp.tracks, track_uris[i:i+50])
            for track_pop in track_pop_response["tracks"]:
                if track_pop is not None:
                    track_pop_list.append(
                        {'track_pop': track_pop['popularity']})
                else:
                    track_pop_list.append({'track_pop': None})

        track_pop = pd.DataFrame(track_pop_list)

        # Merge dataframes
        audio_features = pd.concat(
            [track_features, track_pop], axis=1)
        track_features = pd.concat(
            [artist_info, audio_features], axis=1)

        return track_features

    def get_audio_features(self, output_file, batch_size=100):
        """
        Extracts music metadata for batches of tracks according to its URIs from the dataset, saves the resulting df from each batch in a list and concatinates the list at the end and saves the df as the output file to disk.

        Args:
            input_file (str): The name of the input CSV file
            output_file (str): The name of the output CSV file
            batch_size (int): The number of tracks to process in each batch

        Returns:
            None
        """
        # Load data
        uri_df = pd.read_csv(r"mvp\dataset.csv", engine="pyarrow").drop(
            columns=["track_name", "artist_name"])

        # Prepare dataframe for results
        df_list = []

        for i in range(0, 1000, batch_size):
            time.sleep(random.uniform(0, 1))
            batch = uri_df.iloc[i:i + batch_size]
            audio_features = self.process_batch(batch)
            df_list.append(audio_features)
            print(len(df_list))
            print(f"Completion: {(i + 1) / len(uri_df) * 100:.2f}%")

        # Save final dataframe
        if not os.path.exists("audio_features.csv"):
            columns = ["artist_pop", "genres", "danceability", "energy", "key", "loudness", "mode",
                       "speechiness", "acousticness", "instrumentalness", "liveness", "valence", "tempo", "track_pop"]
            df = pd.DataFrame(columns=columns)
            df.to_csv(r"mvp\audio_features.csv", index=False)
            print(f"{"audio_features.csv"} created with columns: {
                  ', '.join(columns)}")
        else:
            print(f"{"audio_features.csv"} already exists.")

        audio_features = pd.concat(df_list, ignore_index=True)
        audio_features.to_csv(
            output_file, mode="a", index=False, header=False)
    
    def join_uri(self):
        track_uri = pd.read_csv(r"mvp\dataset.csv", engine="pyarrow")["track_uri"]
        audio_features = pd.read_csv(r"mvp\audio_features.csv", engine="pyarrow")

        audio_features = pd.concat([track_uri, audio_features], axis=1)
        audio_features.to_csv(r"mvp\audio_features.csv", index=False)


load_dotenv(r"mvp\keys.env")
SPOTIFY_CLIENT_SECRET = os.getenv('SPOTIFY_CLIENT_SECRET')
SPOTIFY_CLIENT_ID = os.getenv('SPOTIFY_CLIENT_ID')


processor = SpotifyDatasetProcessor(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET,
                                    directory=r"mvp\spotify_million_playlist_dataset\data")

#processor.clean_data()
#processor.get_audio_features(r"mvp\audio_features.csv")
#processor.join_uri() 

df = pd.read_csv(r"mvp\dataset.csv", engine="pyarrow")
audio_features = pd.read_csv(r"mvp\audio_features.csv", engine="pyarrow")
print(df)
print(audio_features)
