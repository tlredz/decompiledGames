local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	RenderObject = function(list)
		local v = list[1]
		local humanoid = v:WaitForChild("Humanoid")
		local humanoidRootPart = v:WaitForChild("HumanoidRootPart")
		local skin = v:WaitForChild("Stats"):WaitForChild("Skin")
		local v2 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
		local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
		local skinAbilityModule = TowerLUT:GetSkinAbilityModule("Gourdy", skin.Value)

		if skinAbilityModule and skinAbilityModule.UseAbility then
			skinAbilityModule.UseAbility(v)
			return
		end

		local gourdyAOE = ReplicatedStorage.Parts:FindFirstChild("gourdyAOE")

		if not gourdyAOE then
			warn("gourdyAOE mesh not found in ReplicatedStorage.Parts")
			return
		end

		local clone = gourdyAOE:Clone()
		clone.Parent = workspace
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CastShadow = false
		clone.CanTouch = false
		clone.Color = Color3.fromRGB(255, 136, 77)
		clone.Transparency = 0.2
		clone:PivotTo((CFrame.new(humanoidRootPart.Position + Vector3.new(0, -v2 + 0.2, 0))))
		TweenService:Create(clone, TweenInfo.new(1.33, Enum.EasingStyle.Cubic), {
			Size = createVector(19.27, 0.25, 20.0785),
			Transparency = 1,
			CFrame = clone.CFrame * CFrame.Angles(0, -0.7853981633974483, 0)
		}):Play()
		Debris:AddItem(clone, 3)
	end
}