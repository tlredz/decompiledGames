local SnowtimeCosmo = {}
SnowtimeCosmo.Name = "Snow-Time Cosmo"
SnowtimeCosmo.OverwriteAnimations = {
	Ability = "rbxassetid://98874686617515",
	Decode = "rbxassetid://119699386728294",
	Idle = "rbxassetid://97099524343316",
	Quirk = "rbxassetid://71701359955259",
	Run = "rbxassetid://113465393346450",
	Walk = "rbxassetid://95597558305842"
}
SnowtimeCosmo.FaceTextures = {
	Normal = "rbxassetid://92140477601284",
	Blink = "rbxassetid://113949043102321",
	Hurt = "rbxassetid://74370278760373"
}
SnowtimeCosmo.USE_SKIN_MODEL = true

function SnowtimeCosmo.ApplySkin(_) end

function SnowtimeCosmo.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(210, 121, 255),
		Color_2 = Color3.fromRGB(193, 69, 255),
		Color_3 = Color3.fromRGB(248, 153, 255),
		Color_4 = Color3.fromRGB(255, 210, 251)
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

return SnowtimeCosmo