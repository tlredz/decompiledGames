local ChocoBerry = {}
ChocoBerry.Name = "ChocoBerry"
ChocoBerry.Cost = 600
ChocoBerry.DandyStore = true
ChocoBerry.RightHandBone = "Sprout_rig_v002:R_hand"
ChocoBerry.OverwriteAnimations = {
	Run = "rbxassetid://136753682677000",
	Walk = "rbxassetid://131738208704497",
	Idle = "rbxassetid://109309683006409",
	Quirk = "rbxassetid://103021570924562",
	Ability = "rbxassetid://90848318586643",
	Decode = "rbxassetid://83606906784741"
}
ChocoBerry.FaceTextures = {
	Normal = "rbxassetid://80785358680340",
	Blink = "rbxassetid://114455104394566",
	Hurt = "rbxassetid://107771852734095"
}
ChocoBerry.USE_SKIN_MODEL = true

function ChocoBerry.ApplySkin(_) end

function ChocoBerry.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(92, 51, 23)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(92, 51, 23)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 102, 153)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 90, 43))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(92, 51, 23)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 153, 204)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 114, 66))
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

return ChocoBerry