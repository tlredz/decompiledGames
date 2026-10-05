local GoldenBerry = {}
GoldenBerry.Name = "Golden Berry"
GoldenBerry.RightHandBone = "R_hand"
GoldenBerry.OverwriteAnimations = {
	Run = "rbxassetid://116212095301372",
	Walk = "rbxassetid://110812880513482",
	Idle = "rbxassetid://133583675606982",
	Quirk = "rbxassetid://109297695199263",
	Ability = "rbxassetid://122299255606529",
	Decode = "rbxassetid://83325834468570"
}
GoldenBerry.FaceTextures = {
	Normal = "rbxassetid://134746101768587",
	Blink = "rbxassetid://87376584488183",
	Hurt = "rbxassetid://130874560835194"
}
GoldenBerry.USE_SKIN_MODEL = true

function GoldenBerry.ApplySkin(_) end

function GoldenBerry.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(211, 166, 25),
		Color_2 = Color3.fromRGB(190, 70, 80),
		Color_3 = Color3.fromRGB(250, 225, 124),
		Color_4 = Color3.fromRGB(217, 120, 133)
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

return GoldenBerry