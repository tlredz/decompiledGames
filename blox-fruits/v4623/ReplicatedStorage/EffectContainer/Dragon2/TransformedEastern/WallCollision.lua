local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage.Util)
return function(p)
	if (p.cf.Position - Workspace.CurrentCamera.CFrame.p).Magnitude > 500 then
		return
	end

	local clone = FX:WaitForChild("EasternDragon").DragonWallImpact:Clone()
	clone:ScaleTo(1.45)
	clone.DragonWallImpact.CFrame = p.cf
	Util.SetParentOverrideWithColor(clone, Workspace._WorldOrigin, p.player, "DragonFruitVFXColor")

	for _, child in ipairs(clone.DragonWallImpact.Particles:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	Util.Sound:Play("EasternHeavenlyDragonFruitWallCollision", clone.DragonWallImpact.Position)
	task.delay(1.4, function()
		if clone ~= nil then
			clone:Destroy()
		end
	end)
end