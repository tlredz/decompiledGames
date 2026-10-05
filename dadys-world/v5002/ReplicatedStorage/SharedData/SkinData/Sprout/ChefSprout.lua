local ChefSprout = {}
ChefSprout.Name = "Chef Sprout"
ChefSprout.TowerName = "Sprout"
ChefSprout.RightHandBone = "R_hand"
ChefSprout.OverwriteAnimations = {
	Run = "rbxassetid://121095396581425",
	Walk = "rbxassetid://81958827238462",
	Idle = "rbxassetid://114106585889662",
	Quirk = "rbxassetid://97220026045046",
	Decode = "rbxassetid://121011146958667",
	Ability = "rbxassetid://80124235922998"
}
ChefSprout.FaceTextures = {
	Normal = "rbxassetid://93171545167877",
	Hurt = "rbxassetid://120962040246916",
	Blink = "rbxassetid://109759857170916"
}
ChefSprout.USE_SKIN_MODEL = true

function ChefSprout.ApplySkin(_) end

function ChefSprout.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(190, 70, 80),
		Color_2 = Color3.fromRGB(211, 166, 25),
		Color_3 = Color3.fromRGB(149, 187, 153),
		Color_4 = Color3.fromRGB(221, 143, 153)
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

return ChefSprout