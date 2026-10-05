local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local scaleParticle2 = Util.ScaleParticle2
return function(data)
	local cFrame = data.CFrame
	local super = data.Super
	local scale = data.Scale or 1

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1000 then
		return
	end

	Util.Sound:Play("BeastWaterSplash3", cFrame.Position, nil, math.random(15, 16) / 10, 2)
	local clone = script.SharkSplash:Clone()
	debris:AddItem(clone, 3)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone.SeaLevel:GetChildren()) do
		scaleParticle2(child, scale, true)
		child:Emit(child:GetAttribute("EmitCount"))
	end

	if super then
		clone.ChargeLines.Position = createVector(0, -10, 0)
		local children = clone.ChargeLines:GetChildren()

		for _, v in pairs(children) do
			scaleParticle2(v, scale, true)
		end

		for _ = 1, 10 do
			for _, v in pairs(children) do
				v:Emit(v:GetAttribute("EmitCount"))
			end

			task.wait(0.05)
		end
	end
end