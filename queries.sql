-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- Find all matches for a particular team given the team name
SELECT * FROM "matches"
WHERE "home_team_id" = (
    SELECT "id" FROM "teams"
    WHERE "name" = 'Team A'
)
OR "away_team_id" = (
    SELECT "id" FROM "teams"
    WHERE "name" = 'Team A'
);

-- Find a players average statistics across all their games played given their first and last name
SELECT "first_name", "last_name", AVG("minutes_played") AS 'Minutes Per Game',
    AVG("meters_made") AS 'Meters Made Per Game', AVG("carries"),
    ROUND(SUM("meters_made")*1.0/SUM("carries"), 2) AS 'Average Meters Per Carry'
FROM "players" JOIN "player_appearance_stats" ON "players"."id" = "player_appearance_stats"."player_id"
WHERE "players"."first_name" = 'John' AND "players"."last_name" = 'Doe';

-- Find all match results for a given date:
SELECT * FROM "matches"
WHERE "date" = '2024-01-15';

-- Add teams to the "teams" table:
INSERT INTO teams (name, location, founded) VALUES
('Bath', 'Spring Gardens Rd, Bathwick, Bath BA2 4DS', 1865),
('Exeter', 'Sandy Park Stadium, Sandy Park Way, Exeter EX2 7NN', 1872);

-- Add players to the "players" table
INSERT INTO players (first_name, last_name, date_of_birth, height, weight, primary_position, nationality, team_id) VALUES
('Sam', 'Jones', '1990-05-15', 180.6, 80.2, 10, 'WAL', 1),
('John', 'Smith', '1992-08-22', 175.4, 75.9, 9, 'ENG', 2);

-- Add match results to "matches" table:
INSERT INTO matches (home_team_id, away_team_id, date, home_score, away_score) VALUES
(1, 2, '2024-01-15', 21, 17),
(3, 4, '2024-01-16', 10, 10);

-- Add match stats for players to "player_appearances_table":
INSERT INTO player_appearance_stats (player_id, match_id, starter, position_played, minutes_played, meters_made, carries, turnovers_won, tackles_made, tackles_missed, handling_errors) VALUES
(1, 1, 1, 10, 80, 120, 15, 2, 10, 1, 3),
(2, 1, 1, 5, 80, 100, 10, 1, 8, 2, 2);


