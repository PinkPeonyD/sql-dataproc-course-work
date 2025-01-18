# Music content database

1. Run OLTP:
    1.1. Create_tables.sql script;
    1.2. Load_data_from_CSV.sql script (change path inside script);
    1.3. Queries_based_on_OLTP.sql script;
2. Run OLAP:
    2.1. Create_tables.sql script;
    2.2. Load_data_from_OLTP_to_OLAP.sql script (change dbname and user_name inside script);
    2.3. Queries_based_on_OLAP.sql script;
3. Explanation of why there is a genres table and why it is not connected to other tables

   The genres table in this script serves as a reference table designed to manage musical genres. The primary reasons for using this table are as follows:

   3.1. Simplified Genre Management
   The genres table centralizes information about musical genres. This simplifies the process of adding, modifying, or deleting genres.
   For example, if a genre needs correction (e.g., due to a typo), it is sufficient to update the record in the genres table rather than updating it for every song.

   3.2. Avoiding Data Duplication
   Storing genres as plain text in the songs table can lead to duplication issues (e.g., "Rock", "rock", or "Rock ").
   By using a separate genres table, unique genres are stored as individual records. In the songs table, a foreign key (GenreID) references genres.GenreID, ensuring consistency and avoiding redundancy.

   3.3. Improved Performance
   The genres table helps save database space by using numerical identifiers (GenreID) instead of storing lengthy strings (genre names) in the songs table.
   Searching and sorting operations are faster when dealing with numerical fields rather than strings.

   3.4. Flexibility and Scalability
   If additional attributes need to be added to genres (e.g., "genre description" or "popularity"), this can be done without altering the structure of the songs table.
   The genres table can also be linked to other tables in the future (e.g., artists if genres also apply to performers).

   3.5. Connections Within the Script Context
   In this script, the genres table is not directly linked to the songs table. Instead, genres are stored as a textual field (Genre) within the songs table, leaving the genres table isolated from the main logic.
   However, it can be utilized to:

   Replace the Genre text field in the songs table with a foreign key (GenreID).
   Establish a relationship such as songs.GenreID -> genres.GenreID.
   
   The genres table is valuable for maintaining data integrity and structure, minimizing redundancy, improving performance, and allowing for the database's scalability and flexibility.
