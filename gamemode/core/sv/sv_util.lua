function util.GetAlivePlayers()
   local alive = {}
   for k, p in pairs(player.GetAll()) do
      if IsValid(p) and p:Alive() then
         table.insert(alive, p)
      end
   end

   return alive
end

function util.GetNextAlivePlayer(ply)
   local alive = util.GetAlivePlayers()

   if #alive < 1 then return nil end

   local prev = nil
   local choice = nil

   if IsValid(ply) then
      for k,p in pairs(alive) do
         if prev == ply then
            choice = p
         end

         prev = p
      end
   end

   if not IsValid(choice) then
      choice = alive[1]
   end

   return choice
end

function GM:ShutDown()
	for _, players in ipairs(player.GetAll()) do
		players:SetPData("gw_credits", players:GetCredits())
	end
end

function GM:ShowHelp(ply)
	ply.NotBoss = !ply.NotBoss

	net.Start("gw_showhelp")
	net.Send(ply)
end