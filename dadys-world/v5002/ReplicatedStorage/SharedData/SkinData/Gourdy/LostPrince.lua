local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LostPrince = {}
LostPrince.Name = "Lost Prince"
LostPrince.TowerName = "Gourdy"
LostPrince.Description = "No description yet"
LostPrince.Mastery = false
LostPrince.Cost = 1200
LostPrince.Requirement1 = { "Pumpkins", 1200 }
LostPrince.Requirement2 = { "Coin", 1200 }
LostPrince.Halloween = true
LostPrince.HolidaySkin = true
LostPrince.HolidayYear = 2025
LostPrince.OverwriteAnimations = {
	Run = "rbxassetid://125257470123606",
	Walk = "rbxassetid://115570433032375",
	Idle = "rbxassetid://72899337699408",
	Quirk = "rbxassetid://88047921813701",
	Ability = "rbxassetid://126143051960402",
	Decode = "rbxassetid://116593203991345"
}
LostPrince.FaceTextures = {
	Normal = "rbxassetid://74144162455123",
	Blink = "rbxassetid://119059374472783",
	Hurt = "rbxassetid://84425683014979"
}
LostPrince.USE_SKIN_MODEL = true

function LostPrince.ApplySkin(_) end

function LostPrince.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
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
	clone.Color = Color3.fromRGB(124, 121, 118)
	clone.Transparency = 0.2
	clone:PivotTo((CFrame.new(humanoidRootPart.Position + Vector3.new(0, -v + 0.2, 0))))
	TweenService:Create(clone, TweenInfo.new(1.33, Enum.EasingStyle.Cubic), {
		Size = createVector(19.27, 0.25, 20.0785),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.Angles(0, -0.7853981633974483, 0)
	}):Play()
	Debris:AddItem(clone, 3)
end

return LostPrince