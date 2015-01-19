net.Receive("gw_playerchoice", function(len, CLIENT)
	GAMEMODE:Notify(net.ReadString() .. " has been chosen to be the boss!", Color(255, 255, 255), 5)
end)

net.Receive("gware_roundover", function(len, CLIENT)
	surface.PlaySound(net.ReadString())
	GAMEMODE:Notify("The round has ended", Color(255, 255, 255), 10)
	
	GAMEMODE:ResetAllStats()
end)

function GM:ResetAllStats()
	for _, ply in ipairs(player.GetAll()) do
		ply.IsAServant = false
		ply.Servant = nil
	end
end