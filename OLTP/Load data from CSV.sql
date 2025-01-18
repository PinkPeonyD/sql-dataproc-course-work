CREATE OR REPLACE FUNCTION load_music_data(
    users_path TEXT,
    roles_path TEXT,
    user_roles_path TEXT,
    songs_path TEXT,
    genres_path TEXT,
    artists_path TEXT,
    albums_path TEXT,
    album_songs_path TEXT,
    reactions_path TEXT,
    subscriptions_path TEXT
)
RETURNS VOID AS $$
BEGIN
    CREATE TEMP TABLE temp_users (
        Name VARCHAR(255),
        Email VARCHAR(255),
        PasswordHash VARCHAR(255),
        RegistrationDate TIMESTAMP
    );

    EXECUTE FORMAT('COPY temp_users(Name, Email, PasswordHash, RegistrationDate) FROM %L DELIMITER '','' CSV HEADER', users_path);

    INSERT INTO Users (Name, Email, PasswordHash, RegistrationDate)
    SELECT Name, Email, PasswordHash, RegistrationDate
    FROM temp_users
    ON CONFLICT (Email) DO NOTHING;

    CREATE TEMP TABLE temp_roles (
        RoleName VARCHAR(50)
    );

    EXECUTE FORMAT('COPY temp_roles(RoleName) FROM %L DELIMITER '','' CSV HEADER', roles_path);

    INSERT INTO Roles (RoleName)
    SELECT RoleName
    FROM temp_roles
    ON CONFLICT (RoleName) DO NOTHING;

    CREATE TEMP TABLE temp_user_roles (
        UserID INT,
        RoleID INT
    );

    EXECUTE FORMAT('COPY temp_user_roles(UserID, RoleID) FROM %L DELIMITER '','' CSV HEADER', user_roles_path);

    INSERT INTO UserRoles (UserID, RoleID)
    SELECT ur.UserID, ur.RoleID
    FROM temp_user_roles ur
    WHERE EXISTS (SELECT 1 FROM Users u WHERE u.UserID = ur.UserID)
      AND EXISTS (SELECT 1 FROM Roles r WHERE r.RoleID = ur.RoleID)
    ON CONFLICT DO NOTHING;

    CREATE TEMP TABLE temp_songs (
        Title VARCHAR(255),
        Duration INT,
        Genre VARCHAR(100),
        UploadDate TIMESTAMP
    );

    EXECUTE FORMAT('COPY temp_songs(Title, Duration, Genre, UploadDate) FROM %L DELIMITER '','' CSV HEADER', songs_path);

    INSERT INTO Songs (Title, Duration, Genre, UploadDate)
    SELECT Title, Duration, Genre, UploadDate
    FROM temp_songs
    ON CONFLICT (Title) DO NOTHING;

    CREATE TEMP TABLE temp_genres (
        GenreName VARCHAR(100)
    );

    EXECUTE FORMAT('COPY temp_genres(GenreName) FROM %L DELIMITER '','' CSV HEADER', genres_path);

    INSERT INTO Genres (GenreName)
    SELECT GenreName
    FROM temp_genres
    ON CONFLICT (GenreName) DO NOTHING;

    CREATE TEMP TABLE temp_artists (
        Name VARCHAR(255)
    );

    EXECUTE FORMAT('COPY temp_artists(Name) FROM %L DELIMITER '','' CSV HEADER', artists_path);

    INSERT INTO Artists (Name)
    SELECT Name
    FROM temp_artists
    ON CONFLICT (Name) DO NOTHING;

    CREATE TEMP TABLE temp_albums (
        Title VARCHAR(255),
        ReleaseDate DATE,
        ArtistID INT
    );

    EXECUTE FORMAT('COPY temp_albums(Title, ReleaseDate, ArtistID) FROM %L DELIMITER '','' CSV HEADER', albums_path);

    INSERT INTO Albums (Title, ReleaseDate, ArtistID)
    SELECT ta.Title, ta.ReleaseDate, ta.ArtistID
    FROM temp_albums ta
    WHERE EXISTS (SELECT 1 FROM Artists a WHERE a.ArtistID = ta.ArtistID)
      AND NOT EXISTS (
          SELECT 1
          FROM Albums a
          WHERE a.Title = ta.Title AND a.ArtistID = ta.ArtistID
      );

    CREATE TEMP TABLE temp_album_songs (
        AlbumID INT,
        SongID INT
    );

    EXECUTE FORMAT('COPY temp_album_songs(AlbumID, SongID) FROM %L DELIMITER '','' CSV HEADER', album_songs_path);

    INSERT INTO AlbumSongs (AlbumID, SongID)
    SELECT AlbumID, SongID
    FROM temp_album_songs
    WHERE EXISTS (SELECT 1 FROM Albums a WHERE a.AlbumID = temp_album_songs.AlbumID)
      AND EXISTS (SELECT 1 FROM Songs s WHERE s.SongID = temp_album_songs.SongID)
    ON CONFLICT DO NOTHING;

    CREATE TEMP TABLE temp_reactions (
        SongID INT,
        UserID INT,
        ReactionType VARCHAR(10),
        ReactionDate TIMESTAMP
    );

    EXECUTE FORMAT('COPY temp_reactions(SongID, UserID, ReactionType, ReactionDate) FROM %L DELIMITER '','' CSV HEADER', reactions_path);

    INSERT INTO Reactions (SongID, UserID, ReactionType, ReactionDate)
    SELECT SongID, UserID, ReactionType, ReactionDate
    FROM temp_reactions
    WHERE EXISTS (SELECT 1 FROM Songs s WHERE s.SongID = temp_reactions.SongID)
      AND EXISTS (SELECT 1 FROM Users u WHERE u.UserID = temp_reactions.UserID)
    ON CONFLICT DO NOTHING;

    CREATE TEMP TABLE temp_subscriptions (
        SubscriberID INT,
        SubscribedToID INT,
        SubscriptionDate TIMESTAMP
    );

    EXECUTE FORMAT('COPY temp_subscriptions(SubscriberID, SubscribedToID, SubscriptionDate) FROM %L DELIMITER '','' CSV HEADER', subscriptions_path);

    INSERT INTO Subscriptions (SubscriberID, SubscribedToID, SubscriptionDate)
    SELECT SubscriberID, SubscribedToID, SubscriptionDate
    FROM temp_subscriptions
    WHERE EXISTS (SELECT 1 FROM Users u WHERE u.UserID = temp_subscriptions.SubscriberID)
      AND EXISTS (SELECT 1 FROM Artists a WHERE a.ArtistID = temp_subscriptions.SubscribedToID)
    ON CONFLICT DO NOTHING;

    DROP TABLE IF EXISTS temp_users, temp_roles, temp_user_roles, temp_songs, temp_genres, temp_artists, temp_albums, temp_album_songs, temp_reactions, temp_subscriptions;
END;
$$ LANGUAGE plpgsql;


SELECT load_music_data(
    'your_path/data/users.csv',
    'your_path/data/roles.csv',
    'your_path/data/userRoles.csv',
    'your_path/data/songs.csv',
    'your_path/data/genres.csv',
    'your_path/data/artists.csv',
    'your_path/data/albums.csv',
    'your_path/data/albumSongs.csv',
    'your_path/data/reactions.csv',
    'your_path/data/subscriptions.csv'
);
