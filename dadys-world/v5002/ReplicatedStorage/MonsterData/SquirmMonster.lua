local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local monsterModules = ReplicatedStorage:WaitForChild("MonsterModules")
local TwistedSquirmConfig = require(monsterModules:WaitForChild("TwistedSquirmConfig"))
TwistedSquirmConfig.Validate()
return {
	Name = TwistedSquirmConfig.STATS.Name,
	Rarity = TwistedSquirmConfig.STATS.Rarity,
	Icon = TwistedSquirmConfig.STATS.Icon,
	Render = TwistedSquirmConfig.STATS.Render,
	VisionRadius = TwistedSquirmConfig.STATS.VisionRadius,
	InstantRadius = TwistedSquirmConfig.STATS.InstantRadius,
	WalkSpeed = TwistedSquirmConfig.STATS.WalkSpeed,
	RunSpeed = TwistedSquirmConfig.STATS.RunSpeed,
	HearingRadius = TwistedSquirmConfig.STATS.HearingRadius,
	Damage = TwistedSquirmConfig.STATS.Damage,
	KillRadius = TwistedSquirmConfig.STATS.KillRadius,
	ResearchRadius = TwistedSquirmConfig.STATS.ResearchRadius,
	SpecialChaser = function(p)
		local SpecialChaserHost = require(ServerScriptService.MonsterAI.BehaviorTree.SpecialChaserHost)
		SpecialChaserHost.start(p)
	end
}