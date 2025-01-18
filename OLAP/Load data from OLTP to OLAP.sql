CREATE EXTENSION IF NOT EXISTS dblink;


SELECT dblink_connect('oltp_conn', 'dbname=your_dbname host=localhost user=your_username');


CREATE OR REPLACE FUNCTION load_olap_data()
RETURNS VOID AS $$
BEGIN
    INSERT INTO UsersDim (UserID, Name, Email, StartDate, EndDate, IsCurrent)
    SELECT
        u.UserID,
        u.Name,
        u.Email,
        CURRENT_DATE,
        NULL,
        TRUE
    FROM dblink('oltp_conn', 'SELECT UserID, Name, Email FROM Users')
        AS u(UserID INT, Name VARCHAR(255), Email VARCHAR(255))
    ON CONFLICT (UserID)
    DO UPDATE
    SET
        EndDate = CURRENT_DATE - INTERVAL '1 day',
        IsCurrent = FALSE
    WHERE UsersDim.IsCurrent = TRUE;

    INSERT INTO SongsDim (SongID, Title, Genre, Duration, UploadDate)
    SELECT
        s.SongID,
        s.Title,
        s.Genre,
        s.Duration,
        s.UploadDate::DATE
    FROM dblink('oltp_conn', 'SELECT SongID, Title, Genre, Duration, UploadDate FROM Songs')
        AS s(SongID INT, Title VARCHAR(255), Genre VARCHAR(100), Duration INT, UploadDate TIMESTAMP)
    ON CONFLICT (SongID) DO NOTHING;

    INSERT INTO ArtistsDim (ArtistID, Name)
    SELECT
        a.ArtistID,
        a.Name
    FROM dblink('oltp_conn', 'SELECT ArtistID, Name FROM Artists')
        AS a(ArtistID INT, Name VARCHAR(255))
    ON CONFLICT (ArtistID) DO NOTHING;

    INSERT INTO AlbumsDim (AlbumID, Title, ReleaseDate, ArtistDimID)
    SELECT
        al.AlbumID,
        al.Title,
        al.ReleaseDate,
        ad.ArtistDimID
    FROM dblink('oltp_conn', 'SELECT AlbumID, Title, ReleaseDate, ArtistID FROM Albums')
        AS al(AlbumID INT, Title VARCHAR(255), ReleaseDate DATE, ArtistID INT)
    JOIN ArtistsDim ad ON ad.ArtistID = al.ArtistID
    ON CONFLICT (AlbumID) DO NOTHING;

    INSERT INTO GenresDim (GenreID, GenreName)
    SELECT
        g.GenreID,
        g.GenreName
    FROM dblink('oltp_conn', 'SELECT GenreID, GenreName FROM Genres')
        AS g(GenreID INT, GenreName VARCHAR(100))
    ON CONFLICT (GenreID) DO NOTHING;

    INSERT INTO TimeDim (Date, DayOfWeek, Month, Year, Quarter)
    SELECT DISTINCT
        t.Date,
        TO_CHAR(t.Date, 'Day') AS DayOfWeek,
        TO_CHAR(t.Date, 'Month') AS Month,
        EXTRACT(YEAR FROM t.Date) AS Year,
        EXTRACT(QUARTER FROM t.Date) AS Quarter
    FROM (
        SELECT r.ReactionDate::DATE AS Date
        FROM dblink('oltp_conn', 'SELECT ReactionDate FROM Reactions')
            AS r(ReactionDate TIMESTAMP)
        UNION
        SELECT s.UploadDate::DATE AS Date
        FROM dblink('oltp_conn', 'SELECT UploadDate FROM Songs')
            AS s(UploadDate TIMESTAMP)
        UNION
        SELECT sub.SubscriptionDate::DATE AS Date
        FROM dblink('oltp_conn', 'SELECT SubscriptionDate FROM Subscriptions')
            AS sub(SubscriptionDate TIMESTAMP)
    ) t
    ON CONFLICT (Date) DO NOTHING;

    INSERT INTO SongReactionsFact (SongDimID, UserDimID, TimeDimID, ReactionType, ReactionCount)
    SELECT
        sd.SongDimID,
        ud.UserDimID,
        td.TimeDimID,
        r.ReactionType,
        COUNT(r.ReactionID) AS ReactionCount
    FROM dblink('oltp_conn', 'SELECT ReactionID, SongID, UserID, ReactionType, ReactionDate FROM Reactions')
        AS r(ReactionID INT, SongID INT, UserID INT, ReactionType VARCHAR(10), ReactionDate TIMESTAMP)
    JOIN SongsDim sd ON sd.SongID = r.SongID
    JOIN UsersDim ud ON ud.UserID = r.UserID AND ud.IsCurrent = TRUE
    JOIN TimeDim td ON td.Date = r.ReactionDate::DATE
    GROUP BY sd.SongDimID, ud.UserDimID, td.TimeDimID, r.ReactionType;

    INSERT INTO UserSubscriptionsFact (SubscriberDimID, SubscribedToDimID, TimeDimID, SubscriptionCount)
    SELECT
        ud.UserDimID,
        ad.ArtistDimID,
        td.TimeDimID,
        COUNT(s.SubscriberID) AS SubscriptionCount
    FROM dblink('oltp_conn', 'SELECT SubscriberID, SubscribedToID, SubscriptionDate FROM Subscriptions')
        AS s(SubscriberID INT, SubscribedToID INT, SubscriptionDate TIMESTAMP)
    JOIN UsersDim ud ON ud.UserID = s.SubscriberID AND ud.IsCurrent = TRUE
    JOIN ArtistsDim ad ON ad.ArtistID = s.SubscribedToID
    JOIN TimeDim td ON td.Date = s.SubscriptionDate::DATE
    GROUP BY ud.UserDimID, ad.ArtistDimID, td.TimeDimID;
END;
$$ LANGUAGE plpgsql;

SELECT load_olap_data();
