CREATE TABLE UsersDim (
    UserDimID SERIAL PRIMARY KEY,
    UserID INT NOT NULL,
    Name VARCHAR(255),
    Email VARCHAR(255),
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BOOLEAN DEFAULT TRUE
);

CREATE UNIQUE INDEX idx_usersdim_userid ON UsersDim (UserID);

CREATE TABLE SongsDim (
    SongDimID SERIAL PRIMARY KEY,
    SongID INT NOT NULL,
    Title VARCHAR(255),
    Genre VARCHAR(100),
    Duration INT,
    UploadDate DATE
);

CREATE UNIQUE INDEX idx_songsdim_songid ON SongsDim (SongID);

CREATE TABLE ArtistsDim (
    ArtistDimID SERIAL PRIMARY KEY,
    ArtistID INT NOT NULL,
    Name VARCHAR(255)
);

CREATE UNIQUE INDEX idx_artistsdim_artistid ON ArtistsDim (ArtistID);

CREATE TABLE AlbumsDim (
    AlbumDimID SERIAL PRIMARY KEY,
    AlbumID INT NOT NULL,
    Title VARCHAR(255),
    ReleaseDate DATE,
    ArtistDimID INT NOT NULL,
    FOREIGN KEY (ArtistDimID) REFERENCES ArtistsDim(ArtistDimID)
);

CREATE UNIQUE INDEX idx_albumsdim_albumid ON AlbumsDim (AlbumID);

CREATE TABLE GenresDim (
    GenreDimID SERIAL PRIMARY KEY,
    GenreID INT NOT NULL,
    GenreName VARCHAR(100)
);

CREATE UNIQUE INDEX idx_genresdim_genreid ON GenresDim (GenreID);

CREATE TABLE TimeDim (
    TimeDimID SERIAL PRIMARY KEY,
    Date DATE NOT NULL,
    DayOfWeek VARCHAR(20),
    Month VARCHAR(20),
    Year INT,
    Quarter INT
);

CREATE UNIQUE INDEX idx_timedim_date ON TimeDim (Date);

CREATE TABLE SongReactionsFact (
    FactID SERIAL PRIMARY KEY,
    SongDimID INT NOT NULL,
    UserDimID INT NOT NULL,
    TimeDimID INT NOT NULL,
    ReactionType VARCHAR(10),
    ReactionCount INT,
    FOREIGN KEY (SongDimID) REFERENCES SongsDim(SongDimID),
    FOREIGN KEY (UserDimID) REFERENCES UsersDim(UserDimID),
    FOREIGN KEY (TimeDimID) REFERENCES TimeDim(TimeDimID)
);

CREATE TABLE UserSubscriptionsFact (
    FactID SERIAL PRIMARY KEY,
    SubscriberDimID INT NOT NULL,
    SubscribedToDimID INT NOT NULL,
    TimeDimID INT NOT NULL,
    SubscriptionCount INT,
    FOREIGN KEY (SubscriberDimID) REFERENCES UsersDim(UserDimID),
    FOREIGN KEY (SubscribedToDimID) REFERENCES ArtistsDim(ArtistDimID),
    FOREIGN KEY (TimeDimID) REFERENCES TimeDim(TimeDimID)
);
