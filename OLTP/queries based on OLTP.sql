--1. Query to Get the Most Popular Songs (Based on Likes)
SELECT
    s.Title AS SongTitle,
    COUNT(r.ReactionID) AS TotalLikes
FROM
    Songs s
JOIN
    Reactions r ON s.SongID = r.SongID
WHERE
    r.ReactionType = 'Like'
GROUP BY
    s.SongID, s.Title
ORDER BY
    TotalLikes DESC
LIMIT 5;


--2. Query to Get User Subscription Details
SELECT DISTINCT
    u.Name AS SubscriberName,
    a.Name AS SubscribedArtist,
    s.SubscriptionDate
FROM
    Subscriptions s
JOIN
    Users u ON s.SubscriberID = u.UserID
JOIN
    Artists a ON s.SubscribedToID = a.ArtistID
ORDER BY
    s.SubscriptionDate DESC;

