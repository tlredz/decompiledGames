local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FreshFall = {}
FreshFall.Name = "Fresh Fall"
FreshFall.TowerName = "Gourdy"
FreshFall.Description = "No description yet"
FreshFall.Mastery = false
FreshFall.Cost = 600
FreshFall.Halloween = true
FreshFall.HolidaySkin = true
FreshFall.HolidayYear = 2025
FreshFall.OverwriteAnimations = {
	Run = "rbxassetid://72719917770090",
	Walk = "rbxassetid://99465780231519",
	Idle = "rbxassetid://139969994295032",
	Quirk = "rbxassetid://99840317570192",
	Ability = "rbxassetid://117040006124925",
	Decode = "rbxassetid://112117584626127"
}
FreshFall.FaceTextures = {
	Normal = "rbxassetid://86275444472858",
	Blink = "rbxassetid://121055530834823",
	Hurt = "rbxassetid://91841073260873"
}
FreshFall.USE_SKIN_MODEL = true

function FreshFall.ApplySkin(_) end

function FreshFall.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(164, 212, 134)
	clone.Transparency = 0.2
	clone:PivotTo((CFrame.new(humanoidRootPart.Position + Vector3.new(0, -v + 0.2, 0))))
	TweenService:Create(clone, TweenInfo.new(1.33, Enum.EasingStyle.Cubic), {
		Size = createVector(19.27, 0.25, 20.0785),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.Angles(0, -0.7853981633974483, 0)
	}):Play()
	Debris:AddItem(clone, 3)
end

return FreshFall