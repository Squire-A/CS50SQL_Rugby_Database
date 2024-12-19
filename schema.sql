-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Represent the teams
CREATE TABLE "teams" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "location" TEXT NOT NULL,
    "founded" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent players that have played for various teams
CREATE TABLE "players" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "date_of_birth" NUMERIC NOT NULL,
    "height" NUMERIC,
    "weight" NUMERIC,
    "primary_position" INT NOT NULL CHECK("primary_position" BETWEEN 1 AND 15),
    "nationality" TEXT,
    "team_id" INT NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("team_id") REFERENCES "teams"("id")
);

-- Represent the matches the teams play in
CREATE TABLE "matches" (
    "id" INTEGER,
    "home_team_id" INTEGER NOT NULL,
    "away_team_id" INTEGER NOT NULL,
    "date" NUMERIC NOT NULL,
    "home_score" INTEGER,
    "away_score" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("home_team_id") REFERENCES "teams"("id"),
    FOREIGN KEY("away_team_id") REFERENCES "teams"("id")
);

-- Represent which players played in which match
CREATE TABLE "player_appearance_stats" (
    "player_id" INTEGER NOT NULL,
    "match_id" INTEGER NOT NULL,
    "starter" INTEGER NOT NULL CHECK("starter" IN (0, 1)),
    "position_played" INT CHECK("position_played" BETWEEN 1 AND 15),
    "minutes_played" INT,
    "meters_made" INT,
    "carries" INT,
    "turnovers_won" INT,
    "tackles_made" INT,
    "tackles_missed" INT,
    "handling_errors" INT,
    FOREIGN KEY("player_id") REFERENCES "players"("id"),
    FOREIGN KEY("match_id") REFERENCES "matches"("id")
);

-- Represent the various events that would be tracked by time in a match, e.g. 'try_scored', 'substituted_on', 'penalty_kick_made', 'penalty_kick_missed' etc.
CREATE TABLE "event_types" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- Represent the significant events in matches
CREATE TABLE "match_events" (
    "match_id" INTEGER NOT NULL,
    "player_id" INTEGER NOT NULL,
    "team_id" INTEGER NOT NULL,
    "game_time" NUMERIC NOT NULL,
    "type_id" INTEGER NOT NULL,
    FOREIGN KEY("match_id") REFERENCES "matches"("id"),
    FOREIGN KEY("player_id") REFERENCES "players"("id"),
    FOREIGN KEY("team_id") REFERENCES "teams"("id"),
    FOREIGN KEY("type_id") REFERENCES "event_types"("id")
);

-- Create indexes on common searches
CREATE INDEX "player_search" ON "players"("first_name", "last_name");
CREATE INDEX "team_search" ON "teams"("name");

-- Creat common views, such as leaderboards for players with the most tries scored.
-- Show the top try scorers in the league
CREATE VIEW "top_try_scorers" AS
SELECT "first_name", "last_name", COUNT("match_events"."type_id") AS 'Tries'
FROM "players"
JOIN "match_events" ON "players"."id" = "match_events"."player_id"
WHERE "match_events"."type_id" = (SELECT "id" FROM "event_types" WHERE "name" = 'Try Scored')
GROUP BY "players"."id"
ORDER BY "Tries" DESC
LIMIT 10;

-- Show who has the best tackle completion in the league
CREATE VIEW "tackle_percentage" AS
SELECT "first_name" AS 'First Name', "last_name" AS 'Last Name',
    SUM("tackles_made") AS 'Tackles Made', SUM("tackles_missed") AS 'Tackles Missed',
    ROUND((SUM("tackles_made")*1.0/(SUM("tackles_made") + SUM("tackles_missed"))) * 100, 2) AS 'Tackle Completion Rate (%)'
FROM "players" JOIN "player_appearance_stats" ON "players"."id" = "player_appearance_stats"."player_id"
GROUP BY "players"."id"
ORDER BY "Tackle Completion Rate (%)" DESC
LIMIT 10;

-- Create a league table showing games played, won, drawn, lost ordered by points where teams get 5 for winning and 2 for drawing
CREATE VIEW "league_table" AS
SELECT "teams"."name",
    COUNT(*) AS 'Matches Played',
    SUM(
        "matches"."home_team_id" = "teams"."id" AND "matches"."home_score" > "matches"."away_score"
        OR "matches"."away_team_id" = "teams"."id" AND "matches"."home_score" < "matches"."away_score")
        AS 'Wins',
    SUM(
        ("matches"."home_team_id" = "teams"."id"
        OR "matches"."away_team_id" = "teams"."id")
        AND "matches"."home_score" = "matches"."away_score")
        AS 'Draws',
    SUM("matches"."home_team_id" = "teams"."id" AND "matches"."home_score" < "matches"."away_score"
        OR "matches"."away_team_id" = "teams"."id" AND "matches"."home_score" > "matches"."away_score")
        AS 'Losses',
    SUM(
        "matches"."home_team_id" = "teams"."id" AND "matches"."home_score" > "matches"."away_score"
        OR "matches"."away_team_id" = "teams"."id" AND "matches"."home_score" < "matches"."away_score") * 5
        + SUM(
            ("matches"."home_team_id" = "teams"."id"
            OR "matches"."away_team_id" = "teams"."id")
            AND "matches"."home_score" = "matches"."away_score") * 2
        AS "points"
FROM "teams" JOIN "matches"
ON "teams"."id" = "matches"."home_team_id" OR "teams"."id" = "matches"."away_team_id"
GROUP BY "teams"."id"
ORDER BY "Points" DESC;
