local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CarrotCake = {}
CarrotCake.Name = "Carrot Cake"
CarrotCake.TowerName = "Cosmo"
CarrotCake.Description = "No description yet"
CarrotCake.Mastery = false
CarrotCake.Cost = 600
CarrotCake.Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W2
CarrotCake.Easter = true
CarrotCake.HolidaySkin = true
CarrotCake.OverwriteAnimations = {
	Ability = "rbxassetid://98874686617515",
	Decode = "rbxassetid://119699386728294",
	Idle = "rbxassetid://97099524343316",
	Quirk = "rbxassetid://71701359955259",
	Run = "rbxassetid://71584405037730",
	Walk = "rbxassetid://95597558305842"
}
CarrotCake.FaceTextures = {
	Normal = "rbxassetid://126211870391380",
	Blink = "rbxassetid://121209350539350",
	Hurt = "rbxassetid://112199933846413"
}
CarrotCake.USE_SKIN_MODEL = true

function CarrotCake.ApplySkin(_) end

function CarrotCake.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage2.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage2.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(247, 187, 108),
		Color_2 = Color3.fromRGB(210, 197, 155),
		Color_3 = Color3.fromRGB(233, 175, 76),
		Color_4 = Color3.fromRGB(255, 224, 216)
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

return CarrotCake