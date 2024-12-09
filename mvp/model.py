import json
import random
import glob
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
        self.csv_file = r"dataset.csv"
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
                df.to_csv(r"dataset.csv", mode="a",
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

            df.to_csv(r"dataset.csv", mode="a", index=False, header=False)

        df = pd.read_csv(r"dataset.csv")
        df.drop_duplicates(subset=["track_uri"],
                           ignore_index=True, inplace=True)
        df = df.sort_values(
            by=['track_name', 'artist_name'], ignore_index=True)
        df.to_csv(r"dataset.csv", mode="w", index=False)

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
        uri_df = pd.read_csv(r"dataset.csv", engine="pyarrow").drop(
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
            df.to_csv(r"audio_features.csv", index=False)
            print(f"{"audio_features.csv"} created with columns: {
                  ', '.join(columns)}")
        else:
            print(f"{"audio_features.csv"} already exists.")

        audio_features = pd.concat(df_list, ignore_index=True)
        audio_features.to_csv(
            output_file, mode="a", index=False, header=False)

    def join_uri(self):
        track_uri = pd.read_csv(r"dataset.csv", engine="pyarrow")[
            "track_uri"]
        audio_features = pd.read_csv(
            r"audio_features.csv", engine="pyarrow")

        audio_features = pd.concat([track_uri, audio_features], axis=1)
        audio_features.to_csv(r"audio_features.csv", index=False)

    def join_dataset(self):
        dataset = pd.read_csv(r"dataset.csv", engine="pyarrow")
        audio_features = pd.read_csv(
            r"audio_features.csv", engine="pyarrow")
        full_dataset = pd.concat([dataset, audio_features], axis=1)
        full_dataset.to_csv(r"full_dataset.csv", index=False)


class ContentBasedFilter:
    def __init__(self):
        self.full_dataset = pd.read_csv(
            r"full_dataset.csv", engine="pyarrow")

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

        full_dataset = self.full_dataset.convert_dtypes(
            "str").drop(columns=["artist_name", "artist_uri"])
        full_dataset["track_name"] = full_dataset["track_name"].fillna("")
        float_cols = full_dataset.dtypes[full_dataset.dtypes ==
                                         'Float64'].index.values

        # Tfidf genre lists
        tfidf = TfidfVectorizer()
        tfidf_matrix = tfidf.fit_transform(full_dataset['genres'].apply(
            self.convert_to_list).str.join(" "))
        print("Tfidf matrix created")
        svd = TruncatedSVD(n_components=100)
        tfidf_matrix = svd.fit_transform(tfidf_matrix)
        print("SVD matrix created")
        genre_df = pd.DataFrame(tfidf_matrix).astype(np.float64)
        genre_df.columns = [f'{
            i+1}' for i in range(genre_df.shape[1])]
        genre_df.reset_index(drop=True, inplace=True)

        # Sentiment analysis
        df = self.sentiment_analysis(full_dataset, "track_name")

        # One-hot Encoding
        subject_ohe = (self.ohe_prep(df, 'subjectivity',
                       'subject') * 0.3)
        polar_ohe = (self.ohe_prep(df, 'polarity', 'polar')
                     * 0.5)
        key_ohe = (self.ohe_prep(df, 'key', 'key') * 0.5)
        mode_ohe = (self.ohe_prep(df, 'mode', 'mode') * 0.5)

        # Scale popularity columns
        pop = full_dataset[["artist_pop", "track_pop"]].reset_index(drop=True)
        scaler = MinMaxScaler()
        pop_scaled = (pd.DataFrame(scaler.fit_transform(pop),
                      columns=pop.columns) * 0.2)

        # Scale audio columns
        floats = full_dataset[float_cols].reset_index(drop=True)
        scaler = MinMaxScaler()
        floats_scaled = (pd.DataFrame(scaler.fit_transform(
            floats), columns=floats.columns) * 0.2)

        feature_vectors = np.hstack([floats_scaled.values, genre_df.values, pop_scaled.values,
                                    subject_ohe.values, polar_ohe.values, key_ohe.values, mode_ohe.values], dtype=np.float32)
        n_features = feature_vectors.shape[1]

        feature_column_names = [f'feature_{i+1}' for i in range(n_features)]

        # Convert the feature_vectors array to a DataFrame
        feature_df = pd.DataFrame(
            feature_vectors, columns=feature_column_names).astype(np.float32)

        print("Complete feature df created")
        print(feature_df)

        feature_df.fillna(0, inplace=True)

        if os.path.exists(r"complete_feature_df.h5"):
            os.remove(r"complete_feature_df.h5")

        feature_df.to_hdf(r"complete_feature_df.h5", key="df", mode="w")
        print("Complete feature df saved to disk")

    def create_feature_matrix(self):
        """
        Load the feature df from disk and convert to feature matrix

        Returns:
            feature_matrix (numpy array): Feature matrix
        """

        try:
            feature_df = pd.read_hdf(r"complete_feature_df.h5", key="df")
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
        faiss.normalize_L2(feature_matrix)  # Avoid division by zero
        print("Feature matrix normalized shape:", feature_matrix.shape)

        if os.path.exists(r"feature_matrix_normalised.npy"):
            os.remove(r"feature_matrix_normalised.npy")

        np.save(r"feature_matrix_normalised.npy", feature_matrix)
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
        print(track_uri)
        full_dataset = pd.read_csv(r"full_dataset.csv", engine="pyarrow")

        track_index = full_dataset.index[full_dataset["track_uri"] == track_uri].tolist(
        )

        if not track_index:
            raise ValueError("Track URI not found in the DataFrame")

        track_index = track_index[0]

        # Get the first matching index
        print(f"Track index for URI {track_uri}: {track_index}")

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
            if os.path.exists(r"feature_matrix_normalised.npy"):
                pass

            else:
                self.normalise_feature_matrix()
            feature_matrix = np.load(r"feature_matrix_normalised.npy")
            index = faiss.IndexFlatIP(feature_matrix.shape[1])
            print("FAISS index created")

            index.add(feature_matrix)

            if os.path.exists(r"index_file.index"):
                os.remove(r"index_file.index")

            faiss.write_index(index, r"index_file.index")
            print("FAISS index saved to disk")

        except Exception as e:
            print(f"An error occurred: {e}")
            raise

    def get_similarities(self, track_uri):
        """
        Get the similarities between the track vector and the feature matrix using FAISS

        Args:
            track_uri

        Returns:
            indices (numpy array): Indices of the most similar tracks
            distances (numpy array): Distances of the most similar tracks
        """

        try:
            start = time.time()
            feature_matrix = np.load(r"feature_matrix_normalised.npy")
            track_vector = self.normalise_track_vector(
                feature_matrix, track_uri)
            print(track_vector)
            # Load the index
            index = faiss.read_index(r"index_file.index")
            print("FAISS index loaded")

            distances, indices = index.search(track_vector, 10)
            print("Distances:", distances)
            print("Indices:", indices)

            print(f"Time taken to search: {time.time() - start:.2f} seconds")

            return indices[0], distances[0]

        except Exception as e:
            print(f"An error occurred: {e}")
            raise


class Database:
    DATABASE_FILE = "users.db"

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
                                    password TEXT NOT NULL
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
    
    def email_exists(self, email):
        connection = self.create_connection()
        if connection is not None:
            try:
                c = connection.cursor()
                c.execute("SELECT 1 FROM users WHERE email = ?", (email,))
                result = c.fetchone()
                print(result)
                return result is not None
            except Error as e:
                print(e)
                return False
            finally:
                connection.close()
    
def query_users():
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    print("\nData in 'users' table:")
    for user in users:
        print(user)
    conn.close()

user_db = Database()



load_dotenv(r"keys.env")
SPOTIFY_CLIENT_SECRET = os.getenv('SPOTIFY_CLIENT_SECRET')
SPOTIFY_CLIENT_ID = os.getenv('SPOTIFY_CLIENT_ID')


processor = SpotifyDatasetProcessor(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET,
                                    directory=r"spotify_million_playlist_dataset\data")

cbf = ContentBasedFilter()

# processor.clean_data()
# processor.get_audio_features(r"mvp\audio_features.csv")
# processor.join_uri()

# dataset = pd.read_csv(r"mvp\dataset.csv", engine="pyarrow")
# audio_features = pd.read_csv(r"mvp\audio_features.csv", engine="pyarrow")
#full_dataset = pd.read_csv(r"full_dataset.csv", engine="pyarrow")

#cbf.process_data()
#cbf.create_index()
#indices, distances = cbf.get_similarities(
#    track_uri="spotify:track:2MYl0er3UZ1RlKwRb5LODh")
#similar_tracks = full_dataset.iloc[indices]
#similar_tracks = similar_tracks[['track_name', 'artist_name', 'track_uri', 'genres', 'acousticness',
#                                 'danceability', 'energy', 'instrumentalness', 'liveness', 'loudness', 'speechiness', 'valence', 'tempo']]
#print(similar_tracks)
