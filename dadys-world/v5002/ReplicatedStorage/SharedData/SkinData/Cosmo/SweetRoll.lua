local SweetRoll = {}
SweetRoll.Name = "Sweet Roll"
SweetRoll.TowerName = "Cosmo"
SweetRoll.Description = "No description yet"
SweetRoll.Mastery = false
SweetRoll.Cost = 600
SweetRoll.Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0)
SweetRoll.Christmas = true
SweetRoll.HolidaySkin = true
SweetRoll.OverwriteAnimations = {
	Ability = "rbxassetid://98874686617515",
	Decode = "rbxassetid://119699386728294",
	Idle = "rbxassetid://97099524343316",
	Quirk = "rbxassetid://71701359955259",
	Run = "rbxassetid://116534472990251",
	Walk = "rbxassetid://95597558305842"
}
SweetRoll.FaceTextures = {
	Normal = "rbxassetid://82923875987576",
	Blink = "rbxassetid://90489343727112",
	Hurt = "rbxassetid://104169958445540"
}
SweetRoll.USE_SKIN_MODEL = true

function SweetRoll.ApplySkin(_) end

function SweetRoll.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(174, 227, 255),
		Color_2 = Color3.fromRGB(241, 164, 255),
		Color_3 = Color3.fromRGB(174, 254, 255),
		Color_4 = Color3.fromRGB(233, 202, 255)
	}

	if clone:IsA("BasePart") then
		clone.Color = v.Color_1
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v.Color_1),
			ColorSequenceKeypoint.new(1, v.Color_3)
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v.Color_2),
			ColorSequenceKeypoint.new(1, v.Color_4)
		})
	end

	if clone:FindFirstChild("HeartPart") then
		clone.HeartPart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v.Color_1),
			ColorSequenceKeypoint.new(1, v.Color_3)
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

return SweetRoll