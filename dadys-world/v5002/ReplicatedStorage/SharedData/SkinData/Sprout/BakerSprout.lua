local BakerSprout = {}
BakerSprout.Name = "Salted Caramel"
BakerSprout.Cost = 600
BakerSprout.DandyStore = true
BakerSprout.RightHandBone = "Sprout_rig_v002:R_hand"
BakerSprout.OverwriteAnimations = {
	Run = "rbxassetid://92575133320301",
	Walk = "rbxassetid://119653669990512",
	Idle = "rbxassetid://111732145549227",
	Quirk = "rbxassetid://99390730937967",
	Ability = "rbxassetid://119810008227544",
	Decode = "rbxassetid://125240083610731"
}
BakerSprout.FaceTextures = {
	Normal = "rbxassetid://136555522228132",
	Blink = "rbxassetid://123999870270631",
	Hurt = "rbxassetid://120705047569413"
}
BakerSprout.USE_SKIN_MODEL = true

function BakerSprout.ApplySkin(_) end

function BakerSprout.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(204, 153, 102)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(153, 102, 51)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 204, 153))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(204, 153, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 229, 204))
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

return BakerSprout