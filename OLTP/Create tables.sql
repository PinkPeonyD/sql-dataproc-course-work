CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Roles (
    RoleID SERIAL PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE UserRoles (
    UserRoleID SERIAL PRIMARY KEY,
    UserID INT NOT NULL,
    RoleID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

CREATE TABLE Songs (
    SongID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Duration INT NOT NULL,
    Genre VARCHAR(100),
    UploadDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (Title)
);

CREATE TABLE Genres (
    GenreID SERIAL PRIMARY KEY,
    GenreName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Artists (
    ArtistID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Albums (
    AlbumID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ReleaseDate DATE,
    ArtistID INT NOT NULL,
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID)
);

CREATE TABLE AlbumSongs (
    AlbumSongID SERIAL PRIMARY KEY,
    AlbumID INT NOT NULL,
    SongID INT NOT NULL,
    FOREIGN KEY (AlbumID) REFERENCES Albums(AlbumID),
    FOREIGN KEY (SongID) REFERENCES Songs(SongID)
);

CREATE TABLE Reactions (
    ReactionID SERIAL PRIMARY KEY,
    SongID INT NOT NULL,
    UserID INT NOT NULL,
    ReactionType VARCHAR(10) CHECK (ReactionType IN ('Like', 'Dislike')),
    ReactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SongID) REFERENCES Songs(SongID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Subscriptions (
    SubscriptionID SERIAL PRIMARY KEY,
    SubscriberID INT NOT NULL,
    SubscribedToID INT NOT NULL,
    SubscriptionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SubscriberID) REFERENCES Users(UserID),
    FOREIGN KEY (SubscribedToID) REFERENCES Artists(ArtistID)
);
