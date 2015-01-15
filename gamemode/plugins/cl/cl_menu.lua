net.Receive("gware_mainmenu", function(len, CLIENT)
	GAMEMODE:CreateMainMenu()
end)

net.Receive("gw_chooseboss", function(len, CLIENT)
	GAMEMODE:CreateBossSelection(net.ReadInt(32), net.ReadInt(32))
end)

net.Receive("gware_pickclass", function(len, CLIENT)
	GAMEMODE:CreateClassSelection()
end)