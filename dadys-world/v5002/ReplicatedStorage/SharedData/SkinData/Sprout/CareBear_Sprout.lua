local CareBearSprout = {}
CareBearSprout.Name = "Tenderheart Bear"
CareBearSprout.RobuxCost = script:GetAttribute("RobuxCost") or -1
CareBearSprout.Unlocks = DateTime.fromUniversalTime(2026, 5, 26, 19, 0, 0)
CareBearSprout.ProductId = 3576327394
CareBearSprout.RightHandBone = "R_hand"
CareBearSprout.OverwriteAnimations = {
	Run = "rbxassetid://107205275436764",
	Walk = "rbxassetid://100021971802496",
	Idle = "rbxassetid://105955030550602",
	Quirk = "rbxassetid://72357498491135",
	Decode = "rbxassetid://95453847870530",
	Ability = "rbxassetid://91564287033992"
}
CareBearSprout.FaceTextures = {
	Normal = "rbxassetid://131083200202491",
	Blink = "rbxassetid://76738905094770",
	Hurt = "rbxassetid://138546236442712"
}
CareBearSprout.USE_SKIN_MODEL = true

function CareBearSprout.ApplySkin(_) end

function CareBearSprout.UseAbility(_, _, p, p2)
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

return CareBearSprout