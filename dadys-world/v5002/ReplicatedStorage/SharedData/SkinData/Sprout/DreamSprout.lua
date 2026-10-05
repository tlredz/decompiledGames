local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local DreamSprout = {}
DreamSprout.Name = "Star-Time Sprout"
DreamSprout.RightHandBone = "Sprout_rig_v002:R_hand"
DreamSprout.OverwriteAnimations = {
	Run = "rbxassetid://119941992371649",
	Walk = "rbxassetid://102847047822588",
	Idle = "rbxassetid://81109768643568",
	Quirk = "rbxassetid://95325052048978",
	Ability = "rbxassetid://119878706293241",
	Decode = "rbxassetid://98403277717335"
}
DreamSprout.FaceTextures = {
	Blink = "rbxassetid://76773609677199",
	Hurt = "rbxassetid://92472992132382",
	Normal = "rbxassetid://116775966546494"
}
DreamSprout.USE_SKIN_MODEL = true

function DreamSprout.ApplySkin(_) end

function DreamSprout.UseAbility(_, _, p, p2)
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(102, 51, 153)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(51, 51, 153)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(153, 102, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 153, 255))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(102, 102, 204)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 204, 255))
		})
	end

	local _ = p2.Position

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

return DreamSprout