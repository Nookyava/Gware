util.AddNetworkString("gware_mainmenu")

function GM:ShowTeam(ply)
	net.Start("gware_mainmenu")
	net.Send(ply)
end

net.Receive("gw_pickclass", function(len, ply)
	local class = net.ReadString()
	local ply = net.ReadEntity()
	
	ply.Class = class
	player_manager.SetPlayerClass(ply, class)
end)