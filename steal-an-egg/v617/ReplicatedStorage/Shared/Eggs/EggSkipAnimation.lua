local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local EggActionMovement = require(script.Parent.EggActionMovement)
local EggRenderer = require(script.Parent.EggRenderer)
local t = require(ReplicatedStorage.Packages.t)
local skipEggEffect = ReplicatedStorage.Assets.Particles["Egg Open"].SkipEggEffect
return {
	Play = function(instance)
		t.strict(t.instanceIsA("Model"))(instance)
		EggRenderer.DisableCollisions(instance)
		local pivot = instance:GetPivot()
		local clone = skipEggEffect.Attachment:Clone()
		clone.Parent = workspace.Terrain
		local total = 0

		for _, descendant in clone:GetDescendants() do
			descendant.Enabled = true
		end

		clone.WorldCFrame = pivot * CFrame.Angles(0, 0, 3.141592653589793)

		while total < 1.2 do
			total += RunService.Heartbeat:Wait()
			local value = TweenService:GetValue(total / 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			EggActionMovement.SetPivot(
				instance,
				pivot * CFrame.Angles(0, math.rad(value * 1080), 0) * CFrame.Angles(
					0,
					0,
					(math.rad(math.sin(1080 * value) * 35 * (1 - value)))
				)
			)
		end

		for _, descendant in clone:GetDescendants() do
			descendant.Enabled = false
		end

		Debris:AddItem(clone, 5)
	end
}