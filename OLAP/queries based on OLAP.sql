--1: Find the most popular genres by total reactions (likes and dislikes)
SELECT
    g.GenreName AS Genre,
    SUM(sr.ReactionCount) AS TotalReactions
FROM
    SongReactionsFact sr
JOIN
    SongsDim s ON sr.SongDimID = s.SongDimID
JOIN
    GenresDim g ON s.Genre = g.GenreName
GROUP BY
    g.GenreName
ORDER BY
    TotalReactions DESC;


--2: Analyze user subscription trends by year and quarter
SELECT
    td.Year,
    td.Quarter,
    SUM(us.SubscriptionCount) AS TotalSubscriptions
FROM
    UserSubscriptionsFact us
JOIN
    TimeDim td ON us.TimeDimID = td.TimeDimID
GROUP BY
    td.Year, td.Quarter
ORDER BY
    td.Year ASC, td.Quarter ASC;


--3: Top 5 artists by the number of subscriptions
SELECT
    a.Name AS ArtistName,
    SUM(us.SubscriptionCount) AS TotalSubscriptions
FROM
    UserSubscriptionsFact us
JOIN
    ArtistsDim a ON us.SubscribedToDimID = a.ArtistDimID
GROUP BY
    a.Name
ORDER BY
    TotalSubscriptions DESC
LIMIT 5;


--4: Reaction trends over time by reaction type
SELECT
    td.Year,
    td.Month,
    sr.ReactionType,
    SUM(sr.ReactionCount) AS TotalReactions
FROM
    SongReactionsFact sr
JOIN
    TimeDim td ON sr.TimeDimID = td.TimeDimID
GROUP BY
    td.Year, td.Month, sr.ReactionType
ORDER BY
    td.Year ASC,
    td.Month ASC,
    sr.ReactionType;

