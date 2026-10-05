local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
return function(instance, p)
	Utility:PlayParticles(instance.Primary)
	Utility:CreateSound("rbxassetid://98948832050219", 2, 1, instance.Primary, true, 5)
	Utility:CreateSound("rbxassetid://129130524317348", 1.5, 1, instance.Primary, true, 5)
	instance.Flag.CFrame *= CFrame.new(0, 4, 0)
	instance.Flag.Color = DuelLibrary:GetTeamColor(p)
	instance.Flag.Transparency = 0
	local pivot = instance:GetPivot()
	local cframe = CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	local scale = instance:GetScale()
	local v = scale * 0.5
	Utility:RenderstepForLoop(0, 100, 2, function(p2)
		local v2 = 1 - (1 - p2 / 100) ^ 3
		instance:ScaleTo(v + (scale - v) * v2)
		instance:PivotTo(pivot * CFrame.Angles(0, 0 + 9.42477796076938 * v2, 0) * cframe:Lerp(CFrame.identity, v2))
	end)
end