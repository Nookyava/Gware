surface.CreateFont( "HUDText", {
	font = "JungleFever",
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "HUDText_Rage", {
	font = "JungleFever",
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

net.Receive("gw_lms", function(len, CLIENT)
	surface.PlaySound("music/HL1_song25_REMIX3.mp3")
end)

function GM:Initialize()
	self.Notifications = {}
	
	timer.Create("gw_tips", 120, 0, function()
		chat.AddText(Color(255, 140, 0), table.Random(self.Tips))
	end)
end

function GM:OnPlayerChat(ply, txt, team, dead)
	local tag = evolve.ranks[ply:EV_GetRank()]
	
	local tab = {}
 
	if ( dead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end
		
	if ( team ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end
		
	if ( IsValid( ply ) ) then
		table.insert( tab, tag.Color)
		table.insert( tab, "[" .. tag.Title .. "] ")
		table.insert( tab, ply )
	else
		table.insert( tab, "Console" )
	end
		
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..txt )
		
	chat.AddText( unpack( tab ) )
	
	return true
end