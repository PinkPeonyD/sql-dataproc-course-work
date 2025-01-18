# Music Content Database

## 1. Run OLTP
1.1. Execute the `Create_tables.sql` script.  
1.2. Execute the `Load_data_from_CSV.sql` script (ensure to modify the path inside the script as needed).  
1.3. Execute the `Queries_based_on_OLTP.sql` script.

## 2. Run OLAP
2.1. Execute the `Create_tables.sql` script.  
2.2. Execute the `Load_data_from_OLTP_to_OLAP.sql` script (ensure to modify the `dbname` and `user_name` inside the script).  
2.3. Execute the `Queries_based_on_OLAP.sql` script.

## 3. Explanation of the `genres` Table and Its Isolation

The `genres` table in this script serves as a reference table designed to manage musical genres. Below are the key reasons for including this table and the rationale for its current disconnected state:

### 3.1. Simplified Genre Management
- The `genres` table centralizes information about musical genres, simplifying updates or modifications.
- Example: Correcting a typo in a genre name can be done once in the `genres` table instead of updating it for each song entry.

### 3.2. Avoiding Data Duplication
- Storing genres directly in the `songs` table may lead to inconsistencies (e.g., "Rock", "rock", or "Rock ").
- Using a separate `genres` table ensures that unique genres are stored as individual records.
- The `songs` table can reference genres via a foreign key (`GenreID`), maintaining consistency and eliminating redundancy.

### 3.3. Improved Performance
- Using numerical identifiers (`GenreID`) in the `songs` table saves space compared to storing long genre strings.
- Operations like searching and sorting are faster when using numerical fields instead of strings.

### 3.4. Flexibility and Scalability
- Additional attributes, such as "genre description" or "popularity," can be added to the `genres` table without altering the structure of the `songs` table.
- The `genres` table can be linked to other tables in the future, such as connecting genres to artists if they are associated with performers.

### 3.5. Connections Within the Script Context
- Currently, the `genres` table is not directly linked to the `songs` table.
- Genres are stored as a textual field (`Genre`) in the `songs` table, leaving the `genres` table isolated from the main logic.
- Future improvements could involve:
    - Replacing the `Genre` text field in the `songs` table with a foreign key (`GenreID`).
    - Establishing a relationship such as `songs.GenreID -> genres.GenreID`.

### Conclusion
The `genres` table is a vital part of database design, offering:
- **Data integrity** through centralized genre management.
- **Efficiency** by avoiding redundancy and improving performance.
- **Scalability** for future database enhancements.

Although isolated in the current script, the `genres` table can play a significant role in ensuring a well-structured and flexible database. 
