workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

for _, emitter in pairs(script.string:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		emitter.Color = ColorSequence.new(Color3.new(1, 0.2, 0.2))
	end
end

return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local v = cFrame * CFrame.new(0, 0, -2.5)
	local clone = script.one:Clone()
	clone.CFrame = v * CFrame.new(0, 0, -1) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone.Parent = workspace._WorldOrigin
	TweenService:Create(clone, tweenInfo, {
		CFrame = clone.CFrame * CFrame.Angles(0, 0, -15)
	}):Play()

	for _, decal in pairs(clone:GetChildren()) do
		if decal:IsA("Decal") then
			TweenService:Create(decal, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	local clone2 = script.string:Clone()
	clone2.CFrame = v * CFrame.new(0, 0, 1) * CFrame.Angles(-1.5707963267948966, 0, -1.5707963267948966)
	clone2.Parent = workspace._WorldOrigin

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	Util.Debris:AddItem(clone2, 4)
	Util.Debris:AddItem(clone, 3)
	Util.Sound:Play("ElectricStabThing2", cFrame)
end