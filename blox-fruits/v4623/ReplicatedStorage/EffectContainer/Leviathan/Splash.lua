workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local splash = FX:WaitForChild("Leviathan").Splash
require(ReplicatedStorage:WaitForChild("Util").BoatTween.Lerps)
local _ = Util.BoatTween
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local misc = Util.Luno.Misc
return function(p)
	local scale = p.Scale
	local cFrame = p.CFrame

	if misc.cameraInRange(cFrame.p, 1000) then
		if scale <= 0.5 then
			Util.Sound:Play("WaterSplash3_2", cFrame.p, nil, 1, 1.3)
		else
			Util.Sound:Play("BeastWaterSplash3", cFrame.p, nil, 0.8, 1.5)
		end

		local clone = splash.WaterSplash.WaterSurface:Clone()
		debris:AddItem(clone, 4)
		clone.CFrame = cFrame
		clone.Parent = workspace.Terrain

		for _, child in pairs(clone:GetChildren()) do
			misc.scaleParticle(child, scale, true)
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end
end