local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VintageGourdy = {
	Name = "Vintage Gourdy",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Hurt = "rbxassetid://128073737258478",
		Blink = "rbxassetid://77065389159468",
		Normal = "rbxassetid://140490493798295"
	},
	USE_SKIN_MODEL = false
}

function VintageGourdy.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageGourdy.FaceTextures.Normal
		end
	end
end

function VintageGourdy.UseAbility(instance)
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

return VintageGourdy