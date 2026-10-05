local VintageCosmo = {
	Name = "Vintage Cosmo",
	Mastery = true
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
VintageCosmo.OverwriteAnimations = {}
VintageCosmo.FaceTextures = {
	Normal = "rbxassetid://120078634022508",
	Blink = "rbxassetid://124440939694350",
	Hurt = "rbxassetid://116130160756022"
}
VintageCosmo.USE_SKIN_MODEL = false

function VintageCosmo.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("MeshPart") or part:HasTag("DontChangeTexture") then
			continue
		end

		part.TextureID = VintageCosmo.FaceTextures.Normal
	end
end

function VintageCosmo.UseAbility(_, _, p, p2)
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(128, 128, 128)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))
		})
	end

	if clone:FindFirstChild("HeartPart") then
		clone.HeartPart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
		})
	end

	local function chase()
		local position = clone.Position
		Movement.parabola(clone, position, p2, 20, 25, 0.5)
	end

	local position = clone.Position
	Movement.parabola(clone, position, p2, 20, 25, 0.5)

	if clone then
		clone.SmokePart.Enabled = false
		clone.Transparency = 1
		clone.HeartPart:Emit(10)

		if clone:FindFirstChild("Eat") then
			clone.Eat:Play()
		end
	end
end

return VintageCosmo