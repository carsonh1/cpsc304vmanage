/* Changes made to original schemas:
 * - Added jerseyNumber to Registers table
 * - Renamed Match to TournamentMatch
 * - Merged PlaysIn relation into TournamentMatch; team id attributes not null
 * - Created an id attribute for Tournament for better indexing, modifying the following relations:
 *   - Tournament
 *   - TournamentMatch
 *   - Referees
 *   - Sponsors
 *   - Registers
 * - Changed PK for Sponsors into sponsorsId so that 
 *   the same sponsor can sponsor multiple times for 1 tournament (won't really be used though)
 * - Added ON DELETE CASCADE to:
 *   - Sponsors (Tournament deleted)
 *   - Registers (Tournament deleted)
 *   - Referees (Tournament deleted)
 * - Sponsors table now has an id column as a placeholder PK attribute
 *   in order to allow the same sponsor to sponsor the same tournament multiple times.
 * - Gave Player the "eligible" attribute which is only used for filtering purposes when getting players to add to a team.
 *   It basically tells the user if the player is eligible to participate in vManage tournaments.
 * - Changed Player's id attribute to a SERIAL for easier insertion purposes
 */

DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

/* CREATE TABLE statements
 * arranged in an order that won't cause weird FK issues
 */

CREATE TABLE PostalCode (
	postalCode VARCHAR(6) PRIMARY KEY,
	city VARCHAR(128) NOT NULL
);

CREATE TABLE School (
	schoolId INTEGER PRIMARY KEY,
	name VARCHAR(128) NOT NULL,
	address VARCHAR(128) NOT NULL,
	postal_code VARCHAR(6) NOT NULL,
	FOREIGN KEY (postal_code)
		REFERENCES PostalCode(postalCode)
);

CREATE TABLE Team (
	teamId INTEGER PRIMARY KEY,
	name VARCHAR(128) NOT NULL,
	phoneNumber VARCHAR(16) NOT NULL,
	emailAddress VARCHAR(128) NOT NULL,
	school_id INTEGER NOT NULL,
	FOREIGN KEY (school_id)
		REFERENCES School(schoolId)
);

CREATE TABLE Duration (
	startTime TIMESTAMP,
	endTime TIMESTAMP,
	duration INTEGER NOT NULL,
	PRIMARY KEY (startTime, endTime)
);

CREATE TABLE Tournament (
    tournamentId INTEGER,
	title VARCHAR(128),
	year INTEGER,
	startDate DATE,
	endDate DATE,
	prizeAmount REAL DEFAULT 0, 
	description VARCHAR(128),
	entranceFee REAL DEFAULT 0,
	currentStage VARCHAR(128) NOT NULL,
	PRIMARY KEY (tournamentId)
);

CREATE TABLE Referee (
	ssn INTEGER PRIMARY KEY,
	firstName VARCHAR(128) NOT NULL,
	lastName VARCHAR(128) NOT NULL,
	phoneNumber VARCHAR(16) NOT NULL,
	email VARCHAR(128) NOT NULL
);

CREATE TABLE Player (
	playerId SERIAL,
	height REAL, 
	firstName VARCHAR(128) NOT NULL,
	lastName VARCHAR(128) NOT NULL,
	dateOfBirth DATE NOT NULL,
	eligible BOOLEAN NOT NULL,
	PRIMARY KEY (playerId)
);

CREATE TABLE Sponsor (
	sponsorId INTEGER PRIMARY KEY,
	name VARCHAR(128) NOT NULL,
	phoneNumber VARCHAR(16) NOT NULL,
	email VARCHAR(128) NOT NULL
);

CREATE TABLE FinancialSponsor (
	sponsorId INTEGER,
	invoiceNumber VARCHAR(128),
	PRIMARY KEY (sponsorId),
	FOREIGN KEY (sponsorId)
		REFERENCES Sponsor(sponsorId)
);

CREATE TABLE VenueSponsor(
	sponsorId INTEGER,
	providesEquipment BOOLEAN DEFAULT FALSE,
	PRIMARY KEY (sponsorId),
	FOREIGN KEY (sponsorId)
		REFERENCES Sponsor(sponsorId)
);

CREATE TABLE Sponsors(
	sponsorsId INTEGER PRIMARY KEY,
	sponsor_id INTEGER,
	tournament_id INTEGER,
	amount FLOAT DEFAULT 0,
	FOREIGN KEY (sponsor_id)
		REFERENCES Sponsor (sponsorId),
	FOREIGN KEY (tournament_id) 
		REFERENCES Tournament (tournamentId)
		ON DELETE CASCADE
);

CREATE TABLE Venue (
	venue_id INTEGER,
	hourlyCost REAL DEFAULT 0,
	address VARCHAR(128) NOT NULL,
	province VARCHAR(128) NOT NULL,
	city VARCHAR(128) NOT NULL,
	name VARCHAR(128) NOT NULL,
	sponsor_id INTEGER,
	PRIMARY KEY (venue_id),
	FOREIGN KEY (sponsor_id) REFERENCES Sponsor(sponsorId)
);

CREATE TABLE TournamentMatch (
	matchId INTEGER,
	startTime TIMESTAMP,
	endTime TIMESTAMP,
	stage VARCHAR(128),
	tournament_id INTEGER,
	venue_id INTEGER NOT NULL,
	team_id1 INTEGER NOT NULL,
	team_id2 INTEGER NOT NULL,
	score1 INTEGER DEFAULT 0,
	score2 INTEGER DEFAULT 0,
	PRIMARY KEY (matchId, tournament_id),
	FOREIGN KEY (startTime, endTime)
		REFERENCES Duration(startTime, endTime),
	FOREIGN KEY (tournament_id)
		REFERENCES Tournament(tournamentId)
		ON DELETE CASCADE,
	FOREIGN KEY (venue_id)
		REFERENCES Venue(venue_id),
	FOREIGN KEY (team_id1)
		REFERENCES Team(teamId),
	FOREIGN KEY (team_id2)
		REFERENCES Team(teamId)
);

CREATE TABLE Referees (
	referee_ssn INTEGER,
	match_id INTEGER,
	tournament_id INTEGER,
	cost REAL DEFAULT 0,  
	PRIMARY KEY (referee_ssn, match_id, tournament_id),
	FOREIGN KEY (referee_ssn)
		REFERENCES Referee(ssn),
	FOREIGN KEY (match_id, tournament_id)
		REFERENCES TournamentMatch(matchId, tournament_id)
		ON DELETE CASCADE
);

CREATE TABLE Registers(
	tournament_id INTEGER,
	player_id INTEGER,
	team_id INTEGER,
	jerseyNumber INTEGER,
	PRIMARY KEY (tournament_id, player_id),
	FOREIGN KEY (tournament_id)
		REFERENCES Tournament (tournamentId)
		ON DELETE CASCADE,
	FOREIGN KEY (player_id) 
		REFERENCES Player (playerId),
	FOREIGN KEY (team_id)
		REFERENCES Team (teamId)
);


/* INSERT INTO statements
 * arranged in an order that won't cause weird FK issues
 */

/* PostalCode */

INSERT INTO PostalCode (postalCode, city)
VALUES ('V5V2A2', 'Vancouver');

INSERT INTO PostalCode (postalCode, city)
VALUES ('V5W1P3', 'Vancouver');

INSERT INTO PostalCode (postalCode, city)
VALUES ('V5B4A1', 'Burnaby');

INSERT INTO PostalCode (postalCode, city)
VALUES ('V6B4N6', 'Vancouver');

INSERT INTO PostalCode (postalCode, city)
VALUES ('V5A1S6', 'Burnaby');

INSERT INTO PostalCode (postalCode, city)
VALUES ('V3J7X5', 'Burnaby');

INSERT INTO PostalCode (postalCode, city)
VALUES ('V6K2J6', 'Vancouver');

INSERT INTO PostalCode (postalCode, city)
VALUES ('V6R2C9', 'Vancouver');


/* School */

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (1, 'Karasuno High', '419 East 24th AVE', 'V5V2A2');

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (2, 'Shiratorizawa Academy', '530 East 41st AVE', 'V5W1P3');

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (3, 'Date Tech High', '751 Hammarskjold Dr', 'V5B4A1');

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (4, 'Aoba Johsai High', '555 W Hastings St #1200', 'V6B4N6');

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (5, 'Inarizaki High', '8888 University Dr', 'V5A1S6');

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (6, 'Nekoma High', '8800 Eastlake Dr', 'V3J7X5');

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (7, 'Fukurodani Academy', '2706 Trafalgar St', 'V6K2J6');

INSERT INTO School (schoolId, name, address, postal_code)
VALUES (8, 'Kakugawa High', '3939 W 16th Ave', 'V6R2C9');


/* Team */

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (1, 'Karasuno A', '0000000001', 'kukai@vsb.bc.ca', 1);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (2, 'Shiratorizawa', '0000000002', 'twashijo@vsb.bc.ca', 2);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (3, 'Date Tech', '0000000003', 'toiwake@burnabyschools.ca', 3);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (4, 'Aoba Johsai', '0000000004', 'nirihata@vsb.bc.ca', 4);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (5, 'Karasuno B', '0000000001', 'kukai@vsb.bc.ca', 1);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (6, 'Inarizaki', '0000000005', 'nkurosu@burnabyschools.ca', 5);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (7, 'Nekoma', '0000000006', 'ynekomata@burnabyschools.ca', 6);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (8, 'Fukurodani', '0000000007', 'yshirofuku@burnabyschools.ca', 7);

INSERT INTO Team (teamId, name, phoneNumber, emailAddress, school_id)
VALUES (9, 'Kakugawa', '0000000008', 'gsakakibara@vsb.bc.ca', 8);


/* Duration */

INSERT INTO Duration (startTime, endTime, duration)
VALUES ('2012-10-10 08:00:00', '2012-10-10 10:30:00', 150);

INSERT INTO Duration (startTime, endTime, duration)
VALUES ('2012-10-12 11:00:00', '2012-10-12 13:30:00', 150);

INSERT INTO Duration (startTime, endTime, duration)
VALUES ('2012-10-14 14:00:00', '2012-10-14 17:30:00', 210);

INSERT INTO Duration (startTime, endTime, duration)
VALUES ('2014-04-05 08:00:00', '2014-04-05 10:30:00', 150);

INSERT INTO Duration (startTime, endTime, duration)
VALUES ('2014-04-15 11:00:00', '2014-04-15 13:30:00', 150);


/* Tournament
   currentStage can be one of:
   - Finished (all games done)
   - Playoffs (default if 1 stage)
   - Qualifiers (only if there's 2 stages which is the max)
   - Cancelled (should have no matches, and never will as long as this remains)
 */

INSERT INTO Tournament (tournamentId, title, year, startDate, endDate, prizeAmount, description, entranceFee, currentStage)
VALUES (1, 'Fall Volleyball Tournament', 2013, '2012-10-10', '2012-10-14', 100, 'Single elimination bracket with 4 teams', 10, 'Finished');

INSERT INTO Tournament (tournamentId, title, year, startDate, endDate, prizeAmount, description, entranceFee, currentStage)
VALUES (2, 'Winter Volleyball Tournament', 2013, '2013-01-20', '2013-01-21', 200, 'Two day, double elimination bracket with 5 teams', 20, 'Cancelled');

INSERT INTO Tournament (tournamentId, title, year, startDate, endDate, prizeAmount, description, entranceFee, currentStage)
VALUES (3, 'Spring Volleyball Tournament', 2013, '2013-05-05', '2013-06-15', 300, 'Season-long two stage league with 5 teams', 30, 'Cancelled');

INSERT INTO Tournament (tournamentId, title, year, startDate, endDate, prizeAmount, description, entranceFee, currentStage)
VALUES (4, 'Fall Volleyball Tournament', 2014, '2013-10-15', '2013-12-15', 400, 'Season-long two stage league with 10 teams', 40, 'Cancelled');

INSERT INTO Tournament (tournamentId, title, year, startDate, endDate, prizeAmount, description, entranceFee, currentStage)
VALUES (5, 'Spring Volleyball Tournament', 2014, '2014-04-05', '2014-04-25', 500, 'Single elimination bracket with 4 teams', 50, 'Playoffs');


/* Referee */

INSERT INTO Referee (ssn, firstName, lastName, phoneNumber, email)
VALUES (123456789, 'Sakata', 'Gintoki', '1000000001', 'sgintoki@yorozuya.edo');

INSERT INTO Referee (ssn, firstName, lastName, phoneNumber, email)
VALUES (123456790, 'Shinsuke', 'Takasugi', '1000000002', 'stakasugi@kiheitai.edo');

INSERT INTO Referee (ssn, firstName, lastName, phoneNumber, email)
VALUES (123456791, 'Toshiro', 'Hijikata', '1000000003', 'thijikata@shinsengumi.edo');

INSERT INTO Referee (ssn, firstName, lastName, phoneNumber, email)
VALUES (123456792, 'Sogo', 'Okita', '1000000004', 'sokita@shinsengumi.edo');

INSERT INTO Referee (ssn, firstName, lastName, phoneNumber, email)
VALUES (123456793, 'Isao', 'Kondo', '1000000005', 'ikondo@shinsengumi.edo');

INSERT INTO Referee (ssn, firstName, lastName, phoneNumber, email)
VALUES (123456794, 'Kotaro', 'Katsura', '1000000006', 'zura@jouishihshi.edo');


/* Player */

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (176.8, 'Daichi', 'Sawamura', '1994-12-31', FALSE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (174.3, 'Koshi', 'Sugawara', '1994-06-13', FALSE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (184.7, 'Asahi', 'Azumane', '1995-01-01', FALSE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (159.3, 'Yu', 'Nishinoya', '1995-10-10', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (177.2, 'Ryuunosuke', 'Tanaka', '1996-03-03', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (175.4, 'Chikara', 'Ennoshita', '1995-12-26', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (162.8, 'Shoyo', 'Hinata', '1996-06-21', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (180.6, 'Tobio', 'Kageyama', '1996-12-22', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (188.3, 'Kei', 'Tsukishima', '1996-09-27', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (189.5, 'Wakatoshi', 'Ushijima', '1994-08-13', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (179.5, 'Eita', 'Semi', '1994-11-11', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (182.7, 'Reon', 'Ohira', '1994-10-30', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (187.7, 'Satori', 'Tendo', '1994-05-20', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (181.5, 'Tsutomu', 'Goshiki', '1996-08-22', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (174.8, 'Kenjiro', 'Shirabu', '1995-05-04', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (191.8, 'Takanobu', 'Aone', '1995-08-13', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (184.2, 'Kenji', 'Futakuchi', '1995-11-10', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (191.5, 'Kanji', 'Koganegawa', '1996-07-09', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (186.8, 'Yasushi', 'Kamasaki', '1994-11-08', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (176.3, 'Kaname', 'Moniwa', '1994-09-06', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (174.3, 'Takehito', 'Sasaya', '1995-02-10', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (184.3, 'Toru', 'Oikawa', '1994-07-20', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (187.9, 'Issei', 'Matsukawa', '1995-03-01', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (179.3, 'Hajime', 'Iwaizumi', '1994-06-10', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (189.2, 'Yutaro', 'Kindaichi', '1996-06-06', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (178.8, 'Kentaro', 'Kyotani', '1995-12-07', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (171.2, 'Shinji', 'Watari', '1995-04-03', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (175.2, 'Shinsuke', 'Kita', '1994-07-05', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (183.6, 'Atsumu', 'Miya', '1995-10-05', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (183.8, 'Osamu', 'Miya', '1995-10-05', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (185.7, 'Rintaro', 'Suna', '1996-01-25', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (184.7, 'Aran', 'Ojiro', '1994-04-04', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (191.5, 'Ren', 'Omimi', '1995-02-17', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (187.7, 'Tetsuro', 'Kuroo', '1994-11-17', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (176.5, 'Nobuyuki', 'Kai', '1994-04-08', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (165.2, 'Morisuke', 'Yaku', '1994-08-08', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (176.7, 'Taketora', 'Yamamoto', '1996-02-22', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (169.2, 'Kenma', 'Kozume', '1995-10-16', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (178.3, 'Shohei', 'Fukunaga', '1995-09-29', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (187.8, 'Tatsuki', 'Washio', '1994-08-29', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (181.5, 'Yamato', 'Sarukui', '1994-08-02', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (185.3, 'Kotaro', 'Bokuto', '1994-09-20', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (182.3, 'Keiji', 'Akaashi', '1995-12-05', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (178.8, 'Akinori', 'Konoha', '1994-09-30', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (164.7, 'Haruki', 'Komi', '1995-01-23', TRUE);

/* additional adds */
INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (174.7, 'Hisashi', 'Kinoshita', '1996-02-15', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (180.2, 'Kazuhito', 'Narita', '1995-08-17', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (182.8, 'Akira', 'Kunimi', '1997-03-25', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (184.7, 'Takahiro', 'Hanamaki', '1995-01-27', FALSE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (180.3, 'Hitoshi', 'Ginjima', '1995-08-21', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (186.2, 'Yutaka', 'Obara', '1995-12-15', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (175.2, 'Taro', 'Onagawa', '1995-12-14', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (188.3, 'Taichi', 'Kawanishi', '1995-04-15', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (174.3, 'Hayato', 'Yamagata', '1995-02-14', FALSE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (185.3, 'So', 'Inuoka', '1996-11-01', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (194.3, 'Lev', 'Haiba', '1996-10-30', TRUE);

INSERT INTO Player (height, firstName, lastName, dateOfBirth, eligible)
VALUES (201.2, 'Yudai', 'Hyakuzawa', '1996-04-03', TRUE);


/* Sponsor */

INSERT INTO Sponsor (sponsorId, name, phoneNumber, email)
VALUES (1, 'Shinomiya Group', '2000000001', 'kshinomiya@shinomiya.jp');

INSERT INTO Sponsor (sponsorId, name, phoneNumber, email)
VALUES (2, 'Dai Li', '2000000002', 'lfeng@daili.ek');

INSERT INTO Sponsor (sponsorId, name, phoneNumber, email)
VALUES (3, 'Rath', '2000000003', 'kkazuto@rath.jp');

INSERT INTO Sponsor (sponsorId, name, phoneNumber, email)
VALUES (4, 'Survey Corps', '2000000004', 'surveycorps@gov.eld');

INSERT INTO Sponsor (sponsorId, name, phoneNumber, email)
VALUES (5, 'Kiheitai', '2000000005', 'info@kiheitai.edo');


/* FinancialSponsor */

INSERT INTO FinancialSponsor (sponsorId, invoiceNumber)
VALUES (1, '123456781');

INSERT INTO FinancialSponsor (sponsorId, invoiceNumber)
VALUES (2, '123456782');

INSERT INTO FinancialSponsor (sponsorId, invoiceNumber)
VALUES (3, '123456783');

INSERT INTO FinancialSponsor (sponsorId, invoiceNumber)
VALUES (4, '123456784');

INSERT INTO FinancialSponsor (sponsorId, invoiceNumber)
VALUES (5, '123456785');


/* VenueSponsor */

INSERT INTO VenueSponsor (sponsorId, providesEquipment)
VALUES (1, TRUE);

INSERT INTO VenueSponsor (sponsorId, providesEquipment)
VALUES (2, TRUE);

INSERT INTO VenueSponsor (sponsorId, providesEquipment)
VALUES (3, FALSE);

INSERT INTO VenueSponsor (sponsorId, providesEquipment)
VALUES (4, FALSE);

INSERT INTO VenueSponsor (sponsorId, providesEquipment)
VALUES (5, TRUE);


/* Sponsors
 * If Sponsors is a FinancialSponsor, amount must not be 0.
 * If Sponsors is a VenueSponsor, amount must be 0.
 * This is for the WHERE when deleting Sponsors records.
 * It's fine to have multiple Sponsors records for the same VenueSponsor and Tournament.
 * But it'll never happen.
 */

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (1, 1, 1, 100000000);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (2, 1, 1, 20000);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (3, 1, 1, 500000);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id)
VALUES (4, 1, 1); /* venue sponsored */

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (5, 2, 1, 200);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (6, 2, 1, 340);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id)
VALUES (7, 2, 1); /* venue sponsored */

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (8, 3, 1, 100);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (9, 3, 1, 400);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (10, 3, 1, 4300);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id)
VALUES (11, 3, 1); /* venue sponsored */

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (12, 4, 5, 50);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (13, 4, 5, 440);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (14, 4, 5, 4320);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id)
VALUES (15, 4, 5); /* venue sponsored */

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (16, 5, 5, 2000);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (17, 5, 5, 2050);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (18, 5, 5, 420);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id, amount)
VALUES (19, 5, 5, 6900);

INSERT INTO Sponsors (sponsorsId, sponsor_id, tournament_id)
VALUES (20, 5, 5); /* venue sponsored */


/* Venue */

INSERT INTO Venue (venue_id, hourlyCost, address, province, city, name, sponsor_id)
VALUES (1, 9.99, '6487 Knight St', 'BC', 'Vancouver', 'Pewter Arena', 1);

INSERT INTO Venue (venue_id, hourlyCost, address, province, city, name, sponsor_id)
VALUES (2, 19.99, '4500 Still Creek Dr', 'BC', 'Burnaby', 'Cerulean Stadium', 2);

INSERT INTO Venue (venue_id, hourlyCost, address, province, city, name, sponsor_id)
VALUES (3, 29.99, '1147 Davie St', 'BC', 'Vancouver', 'Vermillion Place', 3);

INSERT INTO Venue (venue_id, hourlyCost, address, province, city, name, sponsor_id)
VALUES (4, 39.99, '3789 Royal Oak Ave', 'BC', 'Burnaby', 'Celadon Colosseum', 4);

INSERT INTO Venue (venue_id, hourlyCost, address, province, city, name, sponsor_id)
VALUES (5, 49.99, '1024 Fraser St', 'BC', 'Vancouver', 'Saffron Arena', 5);


/* TournamentMatch 
   stage can be one of:
   - Playoffs (default if 1 stage)
   - Qualifiers (only if there's 2 stages, which is the max)
*/

INSERT INTO TournamentMatch (matchId, startTime, endTime, stage, tournament_id, venue_id, team_id1, team_id2, score1, score2)
VALUES (1, '2012-10-10 08:00:00', '2012-10-10 10:30:00', 'Playoffs', 1, 1, 1, 4, 1, 2);

INSERT INTO TournamentMatch (matchId, startTime, endTime, stage, tournament_id, venue_id, team_id1, team_id2, score1, score2)
VALUES (2, '2012-10-12 11:00:00', '2012-10-12 13:30:00', 'Playoffs', 1, 2, 2, 3, 2, 0);

INSERT INTO TournamentMatch (matchId, startTime, endTime, stage, tournament_id, venue_id, team_id1, team_id2, score1, score2)
VALUES (3, '2012-10-14 14:00:00', '2012-10-14 17:30:00', 'Playoffs', 1, 3, 2, 4, 3, 1);

INSERT INTO TournamentMatch (matchId, startTime, endTime, stage, tournament_id, venue_id, team_id1, team_id2, score1, score2)
VALUES (4, '2014-04-05 08:00:00', '2014-04-05 10:30:00', 'Playoffs', 5, 4, 5, 6, 2, 1);

INSERT INTO TournamentMatch (matchId, startTime, endTime, stage, tournament_id, venue_id, team_id1, team_id2, score1, score2)
VALUES (5, '2014-04-15 11:00:00', '2014-04-15 13:30:00', 'Playoffs', 5, 4, 7, 8, 1, 2);


/* Referees */

INSERT INTO Referees (referee_ssn, match_id, tournament_id, cost)
VALUES (123456789, 1, 1, 10);

INSERT INTO Referees (referee_ssn, match_id, tournament_id, cost)
VALUES (123456790, 2, 1, 20);

INSERT INTO Referees (referee_ssn, match_id, tournament_id, cost)
VALUES (123456791, 3, 1, 30);

INSERT INTO Referees (referee_ssn, match_id, tournament_id, cost)
VALUES (123456792, 3, 1, 40);

INSERT INTO Referees (referee_ssn, match_id, tournament_id, cost)
VALUES (123456793, 4, 5, 50);

INSERT INTO Referees (referee_ssn, match_id, tournament_id, cost)
VALUES (123456794, 5, 5, 60);


/* Registers */
/* Karasuno A to Fall, 2013 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 1, 1, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 2, 1, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 3, 1, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 4, 1, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 5, 1, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 6, 1, 6);

/* Shiratorizawa to Fall, 2013 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 10, 2, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 11, 2, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 12, 2, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 13, 2, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 14, 2, 8);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 15, 2, 10);

/* Date Tech to Fall, 2013 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 16, 3, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 17, 3, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 18, 3, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 19, 3, 6); /* placeholder jersey # */

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 20, 3, 5); /* placeholder jersey # */

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 21, 3, 3); /* placeholder jersey # */

/* Aoba Johsai to Fall, 2013 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 22, 4, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 23, 4, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 24, 4, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 25, 4, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 26, 4, 16);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 27, 4, 7);

/* Karasuno B to Spring, 2014 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 4, 5, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 5, 5, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 6, 5, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 7, 5, 10);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 8, 5, 9);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 9, 5, 11);

/* Inarizaki to Spring, 2014 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 28, 6, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 29, 6, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 30, 6, 11);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 31, 6, 10);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 32, 6, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 33, 6, 2);

/* Nekoma to Spring, 2014 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 34, 7, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 35, 7, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 36, 7, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 37, 7, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 38, 7, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 39, 7, 6);

/* Fukurodani to Spring, 2014 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 40, 8, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 41, 8, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 42, 8, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 43, 8, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 44, 8, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 45, 8, 11);

/* Karasuno A to Winter, 2013 (2)
   + Hisashi Kinoshita (46)
   + Kazuhito Narita (47)
   - Ryunosuke Tanaka
   - Asahi Azumane
   */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 1, 1, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 2, 1, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 46, 1, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 4, 1, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 47, 1, 8);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 6, 1, 6);

/* Aoba Johsai to Winter, 2013 (2)
   + Akira Kunimi (48)
   + Takahiro Hanamaki (49)
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 22, 4, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 23, 4, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 24, 4, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 25, 4, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 26, 4, 16);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 27, 4, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 48, 4, 13);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 49, 4, 3);

/* Inarizaki to Winter, 2013 
   + Hitoshi Ginjima (50)
   - Ren Omimi (33) 
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 28, 6, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 29, 6, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 30, 6, 11);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 31, 6, 10);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 32, 6, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 50, 6, 5);


/* Date to Spring, 2013 
   + Yutaka Obara (51)
   + Taro Onagawa (52)
   - Takehito Sasaya (21)
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 16, 3, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 17, 3, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 18, 3, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 19, 3, 6); /* placeholder jersey # */

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 20, 3, 5); /* placeholder jersey # */

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 51, 3, 12);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 52, 3, 8);

/* Fukurodani to Spring, 2013 
   no changes, except to jersey numbers
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 40, 8, 12);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 41, 8, 13);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 42, 8, 14);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 43, 8, 15);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 44, 8, 17);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 45, 8, 21);

/* Shiratorizawa to Spring, 2013 
   + Taichi Kawanishi (53)
   + Hayato Yamagata (54)
   - Tsutomu Goshiki (14)
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 10, 2, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 11, 2, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 12, 2, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 13, 2, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 53, 2, 12);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 15, 2, 10);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 54, 2, 14);

/* Nekoma to Spring, 2013
   + So Inuoka (55)
   + Lev Haiba (56)
 */
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 34, 7, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 35, 7, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 36, 7, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 37, 7, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 38, 7, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 39, 7, 6);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 55, 7, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 56, 7, 11);


/* Karasuno B to Fall, 2014 
   + Hisashi Kinoshita (46)
   + Kazuhito Narita (47)
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 1, 1, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 2, 1, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 46, 1, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 4, 1, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 47, 1, 8);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 6, 1, 6);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 3, 1, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 5, 1, 5);

/* Date to Fall, 2014 
   + Taro Onagawa (52)
   - Takehito Sasaya (21)
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 16, 3, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 17, 3, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 18, 3, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 19, 3, 6); /* placeholder jersey # */

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 20, 3, 5); /* placeholder jersey # */

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 52, 3, 8);

/* Nekoma to Fall, 2014 
   + Lev Haiba (56)
   - Shohei Fukunaga
*/
INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 34, 7, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 35, 7, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 36, 7, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 37, 7, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 38, 7, 5);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 55, 7, 7);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 56, 7, 11);

/* Dummy Registers
   effectively the same 1 player team for each tournament
*/

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (1, 57, 9, 1);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (2, 57, 9, 2);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (3, 57, 9, 3);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (4, 57, 9, 4);

INSERT INTO Registers (tournament_id, player_id, team_id, jerseyNumber)
VALUES (5, 57, 9, 5);