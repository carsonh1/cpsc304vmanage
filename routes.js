const router = require('express').Router();
const database = require('./database');

router.get('/seed', (req, res, next) => {
    database.runSeed();
    res.render('seed');
});

router.get('/', (req, res, next) => {
    res.render('home');
})

router.get('/test', (req, res, next) => {
    const lmaos = [{ f: "Carson", l: "Hoang" }, { f: "David", l: "Nguyen" }, { f: "Linus", l: "Hung" }];
    res.render('test', { lmaos });
});

// Division
// EFFECT: Gets players that participates in all of the selected tournaments
router.post('/tournaments', async (req, res, next) => {
    const { tournamentIds } = req.body;
    if (!tournamentIds) {
        return res.redirect('/tournaments');
    }
    const rows = await database.query("SELECT P.firstName, P.lastName, P.height, P.dateOfBirth FROM Player P WHERE NOT EXISTS ((SELECT T.tournamentId FROM Tournament T WHERE T.tournamentId = ANY($1::int[])) EXCEPT (SELECT R.tournament_id FROM Registers R WHERE R.player_id = P.playerId));", [tournamentIds]);
    const players = rows;
    res.render('playersDivision', { players });
});

// Aggregation with GROUP BY Query
// EFFECT: Gets all tournaments, as well as the amount of teams 
router.get('/tournaments', async (req, res, next) => {
    const rows = await database.query("SELECT tournamentId, title, year, startDate, endDate, COUNT(DISTINCT R.team_id) AS teamsCount FROM Tournament T, Registers R WHERE T.tournamentId = R.tournament_id GROUP BY tournamentId, title, year, startDate, endDate UNION SELECT tournamentId, title, year, startDate, endDate, 0 AS teamsCount FROM Tournament T WHERE T.tournamentId NOT IN (SELECT R.tournament_id FROM Registers R) ORDER BY startDate;");
    const tournaments = rows;
    res.render('tournaments', { tournaments });
});

// Aggregation with Having
// EFFECT: Gets all the teams that have over 6 players in a tournament
router.get('/tournaments/:id/completedteams', async (req, res, next) => {
    const { id } = req.params;
    const teams = await database.query("SELECT teamId, name, phoneNumber, emailAddress FROM Team WHERE teamId IN (SELECT team_id FROM Registers WHERE tournament_id = $1 GROUP BY team_id HAVING COUNT(*) >= 6);", [id])
    res.render('completedTeams', { teams });
})

// Projection Query
// EFFECT: Gets all Teams and their basic information (does not display their school's information, however)
router.get('/teams', async (req, res, next) => {
    const rows = await database.query("SELECT teamId, name, phoneNumber, emailAddress FROM Team;")
    const teams = rows;
    res.render('teams', { teams });
});

// Join Query
// EFFECT: Gets all tournaments that a team has participated in
router.get('/teams/:teamId', async (req, res, next) => {
    const { teamId } = req.params;
    const rows = await database.query("SELECT DISTINCT TR.tournamentId, TR.title, TR.startDate FROM Team T, Registers R, Tournament TR WHERE T.teamId = $1 AND T.teamId = R.team_id AND TR.tournamentId = R.tournament_id ORDER BY TR.startDate;", [teamId]);
    if (rows.length === 0) {
        res.redirect(`/teams`);
    } else {
        let firstTournament = rows[0];
        res.redirect(`/teams/${teamId}/${firstTournament.tournamentid}`);
    }
});

// Get all players that participated in tournament for team
router.get('/teams/:teamId/:tournamentId', async (req, res, next) => {
    const { teamId, tournamentId } = req.params;
    const rows = await database.query("SELECT DISTINCT TR.tournamentId, TR.title, TR.startDate, TR.year FROM Team T, Registers R, Tournament TR WHERE T.teamId = $1 AND T.teamId = R.team_id AND TR.tournamentId = R.tournament_id ORDER BY TR.startDate;", [teamId]);
    const team_tournaments = rows;
    let players = [];
    players = await database.query("SELECT P.playerId, height, firstName, lastName, dateOfBirth, jerseyNumber FROM Player P, Registers R WHERE R.tournament_id = $1 AND R.team_id = $2 AND R.player_id = P.playerId;", [tournamentId, teamId]);
    const teamDetails = await database.query("SELECT name FROM Team WHERE teamId = $1", [teamId]);
    const tournamentYearTitle = await database.query("SELECT title, year FROM Tournament WHERE tournamentId = $1", [tournamentId]);
    res.render('teamPlayers', { team_tournaments, teamId, players, teamDetails, tournamentId, tournamentYearTitle });
});

// Get the form to insert player
router.get('/teams/:teamId/:tournamentId/insertPlayer', async (req, res, next) => {
    const { teamId, tournamentId } = req.params;
    let existPlayers = [];
    existPlayers = await database.query("SELECT P.playerId, P.firstName, P.lastName FROM Player P WHERE P.eligible AND NOT EXISTS (SELECT * FROM Registers R WHERE R.player_id = P.playerId AND R.tournament_id = $1);", [tournamentId]);
    res.render('insertPlayer', { player: {}, teamId, tournamentId, existPlayers });
});

// Insert Query
router.post('/teams/:teamId/:tournamentId', async (req, res, next) => {
    const { teamId, tournamentId } = req.params;
    const player = req.body;
    if (player.existingPlayerId == 'nothing') {
        // existing player dropdown not selected
        const newPlayerId = await database.query("INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible) VALUES ($1, $2, $3, $4, TRUE) RETURNING playerId;", [player.height, player.firstName, player.lastName, player.dateOfBirth]);
        await database.query("INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber) VALUES ($1, $2, $3, $4);", [tournamentId, newPlayerId[0].playerid, teamId, player.jerseyNumber]);
    } else {
        // existing player dropdown selected; overrides everything else
        await database.query("INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber) VALUES ($1, $2, $3, $4);", [tournamentId, player.existingPlayerId, teamId, player.jerseyNumber]);
    }
    res.redirect(`/teams/${teamId}/${tournamentId}`);
});

// Delete query
router.get('/teams/:teamId/:tournamentId/delete/:playerId', async (req, res, next) => {
    const { teamId, tournamentId, playerId } = req.params;
    await database.query("DELETE FROM Registers WHERE tournament_id = $1 AND player_id = $2 AND team_id = $3;", [tournamentId, playerId, teamId]);
    // await database.query("DELETE FROM Player WHERE playerId = $1", [playerId]);
    res.redirect(`/teams/${teamId}/${tournamentId}`);
});

// Nested Aggregation with Group By
// EFFECT: Gets the team that participated in the most tournaments
router.get('/mostActiveTeam', async(req, res, next) => {
    const row = await database.query("SELECT DISTINCT R.team_id FROM Registers R GROUP BY R.team_id HAVING COUNT(DISTINCT(R.tournament_id)) >= ALL (SELECT COUNT(DISTINCT R.tournament_id) FROM Registers R GROUP BY R.team_id);");
    const mostActiveTeam = row;
    res.status(200).json({mostActiveTeam});
})

// Update query
// EFFECT: Gets all Player attributes from an arbitrary Player
router.get('/player/:playerId', async (req, res, next) => {
    const { playerId } = req.params;
    const { teamId, tournamentId } = req.query;
    const rows = await database.query("SELECT * FROM Player P WHERE P.playerId = $1", [playerId]);
    const player = rows[0];
    res.render('player', { player, teamId, tournamentId });
});

// EFFECT: Update Player attributes for Player specified above
router.post('/player/:playerId', async (req, res, next) => {
    const { playerId } = req.params;
    if (req.body.eligible == null) req.body.eligible = false;
    const player = req.body;
    const rows = await database.query("UPDATE Player P SET height = $2, firstName = $3, lastName = $4, dateOfBirth = $5, eligible = $6 WHERE P.playerId = $1", [playerId, player.height, player.firstName, player.lastName, player.dateOfBirth, player.eligible]);
    res.redirect(`/teams/${player.teamId}/${player.tournamentId}`);
});

// Selection query
// EFFECT: If a start and end date are specified in a search, only return all TournamentMatch records between those dates. Otherwise, just show all TournamentMatch records.
router.get('/matches', async (req, res, next) => {
    const { startDate, endDate } = req.query;
    let rows;
    if (startDate && endDate) {
        rows = await database.query("SELECT T.year, T.title, M.starttime, M.endtime, M.stage, T1.name AS \"team1\", M.score1, M.score2, T2.name AS \"team2\" FROM TournamentMatch M, Team T1, Team T2, Tournament T WHERE $1 <= M.startTime AND M.endTime::date <= $2 AND T1.teamId = M.team_id1 AND T2.teamId = M.team_id2 AND T.tournamentId = M.tournament_id ORDER BY M.starttime;", [startDate, endDate]);
    }
    else if (startDate) {
        rows = await database.query("SELECT T.year, T.title, M.starttime, M.endtime, M.stage, T1.name AS \"team1\", M.score1, M.score2, T2.name AS \"team2\" FROM TournamentMatch M, Team T1, Team T2, Tournament T WHERE $1 <= M.startTime AND T1.teamId = M.team_id1 AND T2.teamId = M.team_id2 AND T.tournamentId = M.tournament_id ORDER BY M.starttime;", [startDate]);
    }
    else if (endDate) {
        rows = await database.query("SELECT T.year, T.title, M.starttime, M.endtime, M.stage, T1.name AS \"team1\", M.score1, M.score2, T2.name AS \"team2\" FROM TournamentMatch M, Team T1, Team T2, Tournament T WHERE M.endTime::date <= $1 AND T1.teamId = M.team_id1 AND T2.teamId = M.team_id2 AND T.tournamentId = M.tournament_id ORDER BY M.starttime;", [endDate]);
    }
    else {
        rows = await database.query("SELECT T.year, T.title, M.starttime, M.endtime, M.stage, T1.name AS \"team1\", M.score1, M.score2, T2.name AS \"team2\" FROM TournamentMatch M, Team T1, Team T2, Tournament T WHERE T1.teamId = M.team_id1 AND T2.teamId = M.team_id2 AND T.tournamentId = M.tournament_id ORDER BY M.starttime;")
    }
    const matches = rows;
    res.render('matches', { matches, startDate, endDate });
});

module.exports = router;