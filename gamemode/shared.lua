GM.Name = "Garry's Warehouse"

--------------------
-- Team Variables --
--------------------

TEAM_PLAYER = 1
TEAM_BOSS = 2
TEAM_SPECTATOR = 3

---------------------
-- Round Variables --
---------------------

ROUND_WAIT   = 1
ROUND_PREP   = 2
ROUND_ACTIVE = 3
ROUND_POST   = 4

-------------------
-- Win Variables --
-------------------

WIN_BOSS = 1
WIN_PLAYERS = 2

-----------------------
-- Create Our Bosses --
-----------------------

GM.Bosses = {}
	
function GM:AddBoss(name, mdl, hp, startsound, deathsound, winsound, ragesound, ragedesc, appearson, rageFunc)
	if (!name or !mdl or !hp or !rageFunc) then return end
       
	table.insert(self.Bosses, {Name = name, Model = mdl, Health = hp, StartSound = startsound, DeathSound = deathsound, WinSound = winsound, RageSound = ragesound, RageDesc = ragedesc, AppearsOn = appearson, RageFunc = rageFunc})
end

----------------------
-- Create Our Teams --
----------------------

function GM:CreateTeams()
	team.SetUp(TEAM_PLAYER, "Players", Color(0, 255, 0, 255), true)
	team.SetSpawnPoint(TEAM_PLAYER, "info_player_terrorist")
	team.SetUp(TEAM_BOSS, "Boss", Color(0, 0, 0, 255), false)
	team.SetSpawnPoint(TEAM_BOSS, "info_player_counterterrorist")
	team.SetUp(TEAM_SPECTATOR, "Spectators", Color(155, 155, 155, 255), true)
end

-------------
-- Classes --
-------------

GM.Classes = {}

---------------
-- Inventory --
---------------

GM.Inventory = {}

----------
-- Tips --
----------

GM.Tips = {
	"Press C to view the Boss Queue and your position in it! (Press C to close it when opened)",
	"If you press F2 you'll open the main menu where you can change classes, view bosses and view your inventory!",
	"On the F2 Boss Selection you can choose a boss before your turn, then when your turn comes it'll choose it",
	"Press F1 to exclude you from the boss queue"
}