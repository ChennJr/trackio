import json
import random
import time
import os
import numpy as np

import pandas as pd
import psutil
import ast
from textblob import TextBlob
from sklearn.preprocessing import MinMaxScaler
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
import faiss
import sqlite3
from sqlite3 import Error

import bcrypt
from collections import Counter

import spotipy
from spotipy.oauth2 import SpotifyClientCredentials, SpotifyOAuth
import deezer
import sys



def get_file_path(filename):
    if getattr(sys, 'frozen', False):  # Running from PyInstaller bundle
        base_path = sys._MEIPASS  # Temporary folder where PyInstaller extracts files
    else:
        base_path = os.path.dirname(os.path.abspath(__file__))  # Normal script path

    return os.path.join(base_path, filename)

class SpotifyDatasetProcessor:
    def __init__(self, client_id, client_secret):
        """
        :param directory: Directory containing the spotify dataset json files
        """
        self.directory = ""
        self.csv_file = get_file_path("dataset.csv")
        self.audio_features_file = get_file_path("audio_features.csv")
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
                df.to_csv(get_file_path("dataset.csv"), mode="a",
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

            df.to_csv(get_file_path("dataset.csv"), mode="a", index=False, header=False)

        df = pd.read_csv(get_file_path("dataset.csv"))
        df.drop_duplicates(subset=["track_uri"],
                           ignore_index=True, inplace=True)
        df = df.sort_values(
            by=['track_name', 'artist_name'], ignore_index=True)
        df.to_csv(self.csv_file, mode="w", index=False)

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
        uri_df = pd.read_csv(self.csv_file, engine="pyarrow").drop(
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
        if not os.path.exists(output_file):
            columns = ["artist_pop", "genres", "danceability", "energy", "key", "loudness", "mode",
                       "speechiness", "acousticness", "instrumentalness", "liveness", "valence", "tempo", "track_pop"]
            df = pd.DataFrame(columns=columns)
            df.to_csv(output_file, index=False)
            print(f"{output_file} created with columns: {
                  ', '.join(columns)}")
        else:
            print(f"{output_file} already exists.")

        audio_features = pd.concat(df_list, ignore_index=True)
        audio_features.to_csv(
            output_file, mode="a", index=False, header=False)

    def join_uri(self):
        track_uri = pd.read_csv(self.csv_file, engine="pyarrow")[
            "track_uri"]
        audio_features = pd.read_csv(
            self.audio_features_file, engine="pyarrow")

        audio_features = pd.concat([track_uri, audio_features], axis=1)
        audio_features.to_csv(get_file_path("audio_features.csv"), index=False)

    def join_dataset(self):
        dataset = pd.read_csv(self.csv_file, engine="pyarrow")
        audio_features = pd.read_csv(
            self.audio_features_file, engine="pyarrow")
        full_dataset = pd.concat([dataset, audio_features], axis=1)
        full_dataset.to_csv(get_file_path("full_dataset.csv"), index=False)


class ContentBasedFilter:
    def __init__(self, client_id, client_secret):
        self.full_dataset = pd.read_csv(
            get_file_path("full_dataset.csv"), engine="pyarrow",)
        self.client_id = client_id
        self.client_secret = client_secret
        self.sp = self.create_spotify_client()
        self.feature_matrix = np.load(get_file_path("feature_matrix_normalised.npy"))
        self.index = faiss.read_index(get_file_path("index_file.index"))
        self.uri_array = np.array(self.full_dataset["track_uri"])
        
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
    
    def get_subjectivity(self, text):
        """
        Get the subjectivity of a text
        """
        return TextBlob(text).sentiment.subjectivity

    def get_polarity(self, text):
        """
        Get the polarity of a text
        """
        return TextBlob(text).sentiment.polarity

    def get_analysis(self, score, task="polarity"):
        """
        Get the analysis of a text based on its score
        """
        if task == "subjectivity":
            if score < 1/3:
                return "low"
            elif score > 1/3:
                return "high"
            else:
                return "medium"
        else:
            if score < 0:
                return 'Negative'
            elif score == 0:
                return 'Neutral'
            else:
                return 'Positive'

    def sentiment_analysis(self, df, text_col):
        """
        Perform sentiment analysis on a text column in a dataframe
        """

        # Apply functions and store results in new columns using .loc
        df.loc[:, 'subjectivity'] = df[text_col].apply(
            self.get_subjectivity).apply(lambda x: self.get_analysis(x, "subjectivity"))
        df.loc[:, 'polarity'] = df[text_col].apply(
            self.get_polarity).apply(self.get_analysis)

        return df

    def ohe_prep(self, df, column, new_name):
        """
        One-hot encode a column in a dataframe
        """

        tf_df = pd.get_dummies(df[column], dtype="uint8")
        feature_names = tf_df.columns
        tf_df.columns = [new_name + "|" + str(i) for i in feature_names]
        tf_df.reset_index(drop=True, inplace=True)
        return tf_df

    def convert_to_list(self, genre_str):
        '''
        Convert a string of genres to a list and replace spaces in genre name with underscores
        '''

        try:
            return [genre.replace(" ", "_") for genre in ast.literal_eval(genre_str)]
        except (ValueError, SyntaxError):
            return []

    def process_data(self):
        '''
        Process the full dataset to create a final set of features that is machine readable that will be used to generate recommendations
        '''

        full_dataset = self.full_dataset.convert_dtypes("str").drop(columns=["artist_name", "artist_uri"])
        full_dataset["track_name"] = full_dataset["track_name"].fillna("")
        float_cols = full_dataset.select_dtypes(include=['Float64']).columns

        # Tfidf genre lists
        tfidf = TfidfVectorizer()
        tfidf_matrix = tfidf.fit_transform(full_dataset['genres'].apply(self.convert_to_list).str.join(" "))
        svd = TruncatedSVD(n_components=100)
        genre_df = pd.DataFrame(svd.fit_transform(tfidf_matrix), dtype=np.float32)
        genre_df.columns = [f'genre_{i+1}' for i in range(genre_df.shape[1])]

        # Sentiment analysis
        df = self.sentiment_analysis(full_dataset, "track_name")

        # One-hot Encoding
        subject_ohe = self.ohe_prep(df, 'subjectivity', 'subject') * 0.3
        polar_ohe = self.ohe_prep(df, 'polarity', 'polar') * 0.5
        key_ohe = self.ohe_prep(df, 'key', 'key') * 0.5
        mode_ohe = self.ohe_prep(df, 'mode', 'mode') * 0.5

        # Scale popularity columns
        pop = full_dataset[["artist_pop", "track_pop"]]
        pop_scaled = pd.DataFrame(MinMaxScaler().fit_transform(pop), columns=pop.columns, dtype=np.float32) * 0.2

        # Scale audio columns
        floats = full_dataset[float_cols]
        floats_scaled = pd.DataFrame(MinMaxScaler().fit_transform(floats), columns=floats.columns, dtype=np.float32) * 0.2

        feature_vectors = np.hstack([floats_scaled.values, genre_df.values, pop_scaled.values,
                                     subject_ohe.values, polar_ohe.values, key_ohe.values, mode_ohe.values])
        feature_df = pd.DataFrame(feature_vectors, columns=[f'feature_{i+1}' for i in range(feature_vectors.shape[1])], dtype=np.float32)

        feature_df.fillna(0, inplace=True)

        feature_df.to_hdf(get_file_path("complete_feature_df.h5"), key="df", mode="w")
        print("Complete feature df saved to disk")

    def create_feature_matrix(self):
        """
        Load the feature df from disk and convert to feature matrix

        Returns:
            feature_matrix (numpy array): Feature matrix
        """

        try:
            feature_df = pd.read_hdf(get_file_path("complete_feature_df.h5"), key="df")
            print("Feature df loaded")

            feature_matrix = feature_df.values
            feature_matrix = feature_matrix.astype(np.float32)
            feature_matrix = np.ascontiguousarray(feature_matrix)
            print("Converted to feature matrix")

            return feature_matrix

        except Exception as e:
            print(f"An error occurred: {e}")
            raise

    def normalise_feature_matrix(self):
        """
        Normalise the feature matrix for L2 distance and save the normalised feature matrix to disk

        """

        feature_matrix = self.create_feature_matrix()
        # Normalize feature matrix for L2 distance
        faiss.normalize_L2(feature_matrix)  
        print("Feature matrix normalized shape:", feature_matrix.shape)

        if os.path.exists(get_file_path("feature_matrix_normalised.npy")):
            os.remove(get_file_path("feature_matrix_normalised.npy"))

        np.save(get_file_path("feature_matrix_normalised.npy"), feature_matrix)
        print("Feature matrix saved to disk")

    def normalise_track_vector(self, feature_matrix, track_uri):
        """
        Normalise the track vector for L2 distance and save it to disk

        Args:
            full_df (pandas dataframe): Dataframe with track information
            feature_matrix (numpy array): Feature matrix
            track_uri (str): Track URI

        Returns:
            None
        """

        track_index = self.full_dataset.index[self.full_dataset["track_uri"] == track_uri].tolist(
        )

        if not track_index:
            raise ValueError("Track URI not found in the DataFrame")

        track_index = track_index[0]

        track_vector = feature_matrix[track_index].reshape(1, -1)

        track_vector = np.ascontiguousarray(track_vector)
        faiss.normalize_L2(track_vector)

        return track_vector

    def create_index(self):
        """
        Get the similarities between the track vector and the feature matrix using FAISS

        Returns:
            indices (numpy array): Indices of the most similar tracks
            distances (numpy array): Distances of the most similar tracks
        """

        try:
            # Create a new index
            if os.path.exists(get_file_path("feature_matrix_normalised.npy")):
                pass

            else:
                self.normalise_feature_matrix()
            feature_matrix = np.load(get_file_path("feature_matrix_normalised.npy"))
            index = faiss.IndexFlatIP(feature_matrix.shape[1])

            index.add(feature_matrix)

            if os.path.exists(get_file_path("index_file.index")):
                os.remove(get_file_path("index_file.index"))

            faiss.write_index(index, get_file_path("index_file.index"))

        except Exception as e:
            print(f"An error occurred: {e}")
            raise
    
    def get_index(self, uri):
        try:
            return self.full_dataset.index[self.full_dataset["track_uri"] == uri].tolist()[0]
        
        except IndexError:
            return None
    
    def get_weighted_vector(self, vectors, weights=None):
        if not vectors:
            return np.zeros(self.feature_matrix.shape[1])

        # Convert vectors to a numpy array
        vectors = np.array(vectors, dtype=np.float32)

        # If weights are not provided, use equal weights
        if weights is None:
            weights = np.ones(len(vectors))

        # Ensure weights are a numpy array
        weights = np.array(weights, dtype=np.float32)

        # Normalize the weights
        weights /= np.sum(weights)

        # Compute the weighted average of the vectors
        weighted_vector = np.average(vectors, axis=0, weights=weights)

        return weighted_vector

    def get_similarities(self, track_uris_with_opinions):
        """
        Get the similarities between the track vector and the feature matrix using FAISS

        Args:
            track_uri

        Returns:
            indices (numpy array): Indices of the most similar tracks
            distances (numpy array): Distances of the most similar tracks
        """

        
        if len(track_uris_with_opinions) > 1:
            
            
            liked_indices = [idx for uri, opinion, idx in track_uris_with_opinions if opinion == 1]
            disliked_indices = [idx for uri, opinion, idx in track_uris_with_opinions if opinion == 0]

        

            liked_vectors = self.feature_matrix[liked_indices] if liked_indices else np.zeros((1, self.feature_matrix.shape[1]))
            disliked_vectors = self.feature_matrix[disliked_indices] if disliked_indices else np.zeros((1, self.feature_matrix.shape[1]))

            liked_vector = self.get_weighted_vector(liked_vectors) if liked_indices else np.zeros(self.feature_matrix.shape[1])
            disliked_vector = self.get_weighted_vector(disliked_vectors) if disliked_indices else np.zeros(self.feature_matrix.shape[1])

            combined_vector = liked_vector - disliked_vector if liked_indices and disliked_indices else liked_vector if liked_indices else -disliked_vector

            combined_vector = np.ascontiguousarray(combined_vector.reshape(1, -1))
            combined_vector = combined_vector.astype(np.float32)
            faiss.normalize_L2(combined_vector)

            distances, indices = self.index.search(combined_vector, 50)
            return indices[0], distances[0]

        else:
            try:
                track_vector = self.normalise_track_vector(self.feature_matrix, track_uris_with_opinions[0][0])
                distances, indices = self.index.search(track_vector, 50)
                return indices[0], distances[0]
            except Exception as e:
                print(f"An error occurred: {e}")
                raise
        
    def random_uri(self):
        return self.full_dataset.sample(n=1)["track_uri"].tolist()
    
    def get_uris(self, indices):
        return self.full_dataset["track_uri"][indices].tolist()

    def search_tracks_by_name(self, track_name):
        """
        Search for tracks by name within the full_dataset

        Args:
            track_name (str): The name of the track to search for

        Returns:
            list: A list of track details dictionaries
        """
        matching_tracks = self.full_dataset[self.full_dataset["track_name"].str.contains(track_name, case=False, na=False, regex=True)]
        if matching_tracks.empty:
            return False, []
        
        
        return True, matching_tracks["track_uri"].head(50).tolist()

    def search_tracks_by_uri(self, track_uri):
        """
        Search for a track by URI within the full_dataset

        Args:
            track_uri (str): The URI of the track to search for

        Returns:
            dict: A dictionary of track details if found, otherwise None
        """
        if track_uri in (self.full_dataset["track_uri"]).values:
            return True
        return False
    
    def update_track_database(self):
        if not os.path.exists(get_file_path('user_track_uris')):
            os.makedirs(get_file_path('user_track_uris'))
        csv_files = [os.path.join(get_file_path('user_track_uris'), f) for f in os.listdir(get_file_path('user_track_uris')) if f.endswith('.csv')]

        # Merge all CSV files into one DataFrame, removing duplicates
        df_list = [pd.read_csv(file) for file in csv_files]
        merged_df = pd.concat(df_list).drop_duplicates().reset_index(drop=True)

        track_info_list = []
        batch_size = 50
        for i in range(0, len(merged_df), batch_size):
            batch = merged_df['track_uri'][i:i + batch_size].tolist()
            track_infos = self.spotify_call(self.sp.tracks, batch)['tracks']
            track_features = self.spotify_call(self.sp.audio_features, batch)

            for track_info, track_feature in zip(track_infos, track_features):
                if track_info and track_feature:
                    artist_info = self.sp.artist(track_info['artists'][0]['id']) if track_info['artists'] else None
                    track_info_list.append({
                        'artist_name': track_info['artists'][0]['name'] if track_info['artists'] else None,
                        'track_uri': track_info['uri'],
                        'artist_uri': track_info['artists'][0]['uri'] if track_info['artists'] else None,
                        'track_name': track_info['name'],
                        'artist_pop': artist_info['popularity'] if artist_info else None,
                        'genres': artist_info['genres'] if artist_info else None,
                        'danceability': track_feature['danceability'],
                        'energy': track_feature['energy'],
                        'key': track_feature['key'],
                        'loudness': track_feature['loudness'],
                        'mode': track_feature['mode'],
                        'speechiness': track_feature['speechiness'],
                        'acousticness': track_feature['acousticness'],
                        'instrumentalness': track_feature['instrumentalness'],
                        'liveness': track_feature['liveness'],
                        'valence': track_feature['valence'],
                        'tempo': track_feature['tempo'],
                        'track_pop': track_info['popularity']
                    })

        # Create a DataFrame from the track info list
        track_info_df = pd.DataFrame(track_info_list)

        self.full_dataset = pd.concat([self.full_dataset, track_info_df], ignore_index=True).drop_duplicates(subset="track_uri")
        self.full_dataset.to_csv(get_file_path("full_dataset.csv"), index=False)
        self.process_data()
        self.create_index()
        


class Database:
    DATABASE_FILE = get_file_path("users.db")

    def __init__(self):
        self.create_table()

    def create_connection(self):

        connection = None
        try:
            connection = sqlite3.connect(self.DATABASE_FILE)
            return connection
        
        except Error as e:
            print(e)
        
        return connection

    def create_table(self):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()

                cursor.execute('''CREATE TABLE IF NOT EXISTS users (
                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    email TEXT NOT NULL UNIQUE,
                                    first_name TEXT NOT NULL,
                                    last_name TEXT NOT NULL,
                                    password TEXT NOT NULL,
                                    account_type TEXT DEFAULT 'user'
                                );''')
                connection.commit()
            except Error as e:
                print(e)
            
            finally:
                connection.close()

    def insert_user(self, email, first_name, last_name, password):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
                cursor.execute('''INSERT INTO users (email, first_name, last_name, password) VALUES (?, ?, ?, ?);''', (email, first_name, last_name, hashed_password))
                connection.commit()
            
            except Error as e:
                print(e)
            
            finally:
                connection.close()
    
    def verify_user(self, email, password):
        """ verify the user's credentials """
        connection = self.create_connection()
        if connection is not None:
            try:
                c = connection.cursor()
                c.execute("SELECT password FROM users WHERE email = ?", (email,))
                result = c.fetchone()
                if result and bcrypt.checkpw(password.encode('utf-8'), result[0]):
                    return True
                else:
                    return False
            except Error as e:
                print(e)
                return False
            finally:
                connection.close()
    
    def verify_user_forgotten_password(self, email, first_name, last_name):
        connection = self.create_connection()
        if connection is not None:
            try:
                c = connection.cursor()
                c.execute("SELECT 1 FROM users WHERE email = ? AND first_name = ? AND last_name = ?", (email, first_name, last_name))
                result = c.fetchone()
                return result is not None
            except Error as e:
                print(e)
                return False
            finally:
                connection.close()
    
    def update_password(self, email, password):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
                cursor.execute('''UPDATE users SET password = ? WHERE email = ?;''', (hashed_password, email))
                connection.commit()
            except Error as e:
                print(e)
            finally:
                connection.close()
    
    def email_exists(self, email):
        connection = self.create_connection()
        if connection is not None:
            try:
                c = connection.cursor()
                c.execute("SELECT 1 FROM users WHERE email = ?", (email,))
                result = c.fetchone()
                return result is not None
            except Error as e:
                print(e)
                return False
            finally:
                connection.close()

    def get_user_id(self, email):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute('''SELECT id FROM users WHERE email = ?;''', (email,))
                user_id = cursor.fetchone()
                return user_id[0] if user_id else None
            except Error as e:
                print(e)
            finally:
                connection.close()

    def get_opinions(self, user_id):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute('''SELECT track_uri, opinion FROM user_opinions WHERE user_id = ?;''', (user_id,))
                rows = cursor.fetchall()
                return rows
            except Error as e:
                print(e)
            finally:
                connection.close()           
    
    def save_opinions(self, user_id, track_uri, opinion, idx):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute("""
                    INSERT INTO user_opinions (user_id, track_uri, opinion)
                    VALUES (?, ?, ?)
                    ON CONFLICT(user_id, track_uri) DO UPDATE SET opinion=excluded.opinion
                """, (user_id, track_uri, opinion))
                
                cursor.execute("""
                    INSERT OR IGNORE INTO tracks (track_uri, idx)
                    VALUES (?, ?)
                """, (track_uri, idx))
                connection.commit()
            except Error as e:
                print(e)
            finally:
                connection.close()

    def delete_opinion(self, user_id, track_uri):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute('''
                    DELETE FROM user_opinions WHERE user_id = ? AND track_uri = ?;
                ''', (user_id, track_uri))
                connection.commit()
            except Error as e:
                print(e)
            finally:
                connection.close()


    def get_user_liked_track_uris(self, user_id):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute("SELECT track_uri FROM user_opinions WHERE user_id = ? AND opinion = 1", (user_id,))
                track_uris = [row[0] for row in cursor.fetchall()]
                return track_uris
            except Error as e:
                print(e)
            finally:
                connection.close()
        return []
    
    def get_user_track_uris(self, user_id):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute("SELECT track_uri FROM user_opinions WHERE user_id = ?", (user_id,))
                track_uris = [row[0] for row in cursor.fetchall()]
                connection.close()
                return track_uris
            except Error as e:
                print(e)
            finally:
                connection.close()
        return []
    
    def get_user_track_uris_with_opinions(self, user_id):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute('''
                    SELECT u.track_uri, u.opinion, t.idx 
                    FROM user_opinions u 
                    JOIN tracks t ON u.track_uri = t.track_uri 
                    WHERE u.user_id = ?;
                ''', (user_id,))
                track_uris_with_opinions = cursor.fetchall()
                connection.close()
                return track_uris_with_opinions
            except Error as e:
                print(e)
            finally:
                connection.close()
        return []
    
    def get_account_type(self, user_id):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute("SELECT account_type FROM users WHERE id = ?", (user_id,))
                account_type = cursor.fetchone()
                return account_type[0] if account_type else None
            except Error as e:
                print(e)
            finally:
                connection.close()
        return None
    
    def get_user_tracks_with_opinions(self, user_id):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute('''
                    SELECT u.track_uri, u.opinion
                    FROM user_opinions u 
                    WHERE u.user_id = ? AND u.opinion IN (0, 1);
                ''', (user_id,))
                track_uris_with_opinions = cursor.fetchall()
                connection.close()
                return track_uris_with_opinions
            except Error as e:
                print(e)
            finally:
                connection.close()
        return []
    
    def get_opinions_by_uris(self, track_uris):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute('''
                    SELECT track_uri, opinion
                    FROM user_opinions
                    WHERE track_uri IN ({seq})
                '''.format(seq=','.join(['?']*len(track_uris))), tuple(track_uris))
                opinions = cursor.fetchall()
                return opinions
            except Error as e:
                print(e)
            finally:
                connection.close()
        return []
    
    def get_username(self, user_id):
        connection = self.create_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute("SELECT first_name FROM users WHERE id = ?", (user_id,))
                username = cursor.fetchone()
                return username[0] if username else None
            except Error as e:
                print(e)
            finally:
                connection.close()
        return None



class SpotifyClient:
    def __init__(self, client_id, client_secret):
        self.client_id = client_id
        self.client_secret = client_secret
        self.access_token = False
        self.sp = self.create_spotify_client()
        self.deezer = deezer.Client()
        self.sp_oauth = SpotifyOAuth(self.client_id, self.client_secret, "http://localhost:8888/callback", scope="user-library-read user-read-email user-read-private playlist-read-private user-read-playback-state user-top-read")

    def create_spotify_client(self):
        client_credentials_manager = SpotifyClientCredentials(client_id=self.client_id, client_secret=self.client_secret)
        return spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    
    def get_track_details(self, track_uris, market="US"):
        track_details_list = []
        
        tracks = self.sp.tracks(track_uris, market=market)['tracks']
        for i, track in enumerate(tracks):
            album_cover = track['album']['images'][0]['url'] if track['album']['images'] else None
            artist_name = track['artists'][0]['name'] if track['artists'] else None
            track_name = track['name']
            track_uri = track_uris[i]


            track_details_list.append({
                'album_cover': album_cover,
                'artist_name': artist_name,
                'track_name': track_name,
                'track_uri': track_uri,
            })

        return track_details_list
    
    def get_preview_url(self, track_name, artist_name):
        query = f"{track_name} {artist_name}"
        retries = 3
        for attempt in range(retries):
            try:
                deezer_data = self.deezer.search(query)
                preview_url = deezer_data[0].preview if deezer_data else None
                return preview_url
            except Exception as e:
                if attempt < retries - 1:
                    print(f"Error occurred: {e}. Retrying... ({attempt + 1}/{retries})")
                    time.sleep(0.2)
                else:
                    print(f"Failed to retrieve data after {retries} attempts. Error: {e}")
                    return None
                
    def connect_spotify(self):
        auth_url = self.sp_oauth.get_authorize_url()
        return auth_url

    def handle_spotify_callback(self, response_url):
        code = self.sp_oauth.parse_response_code(response_url)
        token_info = self.sp_oauth.get_access_token(code)
        self.access_token = token_info['access_token']
        self.sp = spotipy.Spotify(auth=self.access_token)
    
    def get_user_playlists(self):
        playlists = self.sp.current_user_playlists()
        return playlists["items"]

    def get_playlist_tracks(self, playlist_id):
        tracks = []
        results = self.sp.playlist_tracks(playlist_id)
        tracks.extend(results['items'])
        while results['next']:
            results = self.sp.next(results)
            tracks.extend(results['items'])
        return tracks

    def collect_all_track_uris(self):
        track_uris = []
        playlists = self.get_user_playlists()
        for playlist in playlists:
            tracks = self.get_playlist_tracks(playlist['id'])
            for track in tracks:
                track_info = track['track']
                if track_info:
                    track_uris.append(track_info['uri'])
        
        df = pd.DataFrame(track_uris, columns=['track_uri'])
        user_id = self.sp.current_user()['id']
        file_name = f"user_track_uris/{user_id}_track_uris.csv"
        df.to_csv(get_file_path(file_name), index=False)
        print("Track URIs saved to user_track_uris/user_track_uris.csv")
    
    def get_currently_playing(self):
        if self.access_token:
            currently_playing = self.sp.current_playback()
            if currently_playing and currently_playing['is_playing']:
                track = currently_playing['item']
                track_details = {
                    'track_name': track['name'],
                    'artist_name': track['artists'][0]['name'],
                    'album_cover': track['album']['images'][0]['url'] if track['album']['images'] else None,
                    'playing_status': currently_playing['is_playing']
                }
                return track_details
            return {
                'track_name': None,
                'artist_name': None,
                'album_cover': "assets/Blank.svg",
                'playing_status': False
            }
        else:
            return {
                'track_name': None,
                'artist_name': None,
                'album_cover': "assets/Blank.svg",
                'playing_status': False
            }
    
    def get_top_genres(self, time_range='medium_term', limit=50):
        if self.access_token:
            top_artists = self.sp.current_user_top_artists(time_range=time_range, limit=limit)
            genres = []
            for artist in top_artists['items']:
                genres.extend(artist['genres'])
            
            genre_counts = Counter(genres)
            top_genres = [genre for genre, count in genre_counts.most_common(5)]
            return top_genres
        
        return []
    
    def get_top_artists(self, time_range='medium_term', limit=50):
        if self.access_token:
            top_artists = self.sp.current_user_top_artists(time_range=time_range, limit=limit)
            return top_artists['items']
        return []




