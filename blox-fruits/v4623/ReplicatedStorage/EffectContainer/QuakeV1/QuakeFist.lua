local createVector = vector.create
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local quakeEffects = FX:WaitForChild("QuakeEffects")
require(game.ReplicatedStorage.EffectContainer.QuakeFistCrack)
require(game.ReplicatedStorage.EffectContainer.quakeRocks)
return function(p)
	local arm = p.arm

	if p.enabled then
		for _, child in pairs(arm:GetChildren()) do
			if child.Name == "quakeSphere" then
				child:Destroy()
			end
		end

		local clone = quakeEffects.quakeSphere:Clone()
		clone.CFrame = arm.CFrame
		clone.Size = createVector(0, 0, 0)
		clone.Transparency = 1
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Size = createVector(1.75, 1.75, 1.75),
			Transparency = 0
		}):Play()
		local weld = Instance.new("Weld")
		weld.Parent = clone
		weld.Part0 = arm
		weld.Part1 = clone
		clone.Parent = arm
	else
		for _, child in pairs(arm:GetChildren()) do
			if child.Name ~= "quakeSphere" then
				continue
			end

			TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			Util.Debris:AddItem(child, 0.25)
		end
	end
end