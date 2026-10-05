local WerewolfFight = {}
WerewolfFight.Name = "GhostAttack"
WerewolfFight.Type = "Trick"
WerewolfFight.BaseCandy = 10

function WerewolfFight.Server(p, _)
	print("[GhostAttack] Spawning ghost for " .. p.Name)
end

function WerewolfFight.Client(_, _) end

return WerewolfFight