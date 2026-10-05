local CareBearCosmo = {}
CareBearCosmo.Name = "Share Bear"
CareBearCosmo.RobuxCost = script:GetAttribute("RobuxCost") or -1
CareBearCosmo.Unlocks = DateTime.fromUniversalTime(2026, 5, 26, 19, 0, 0)
CareBearCosmo.ProductId = 3576325230
CareBearCosmo.OverwriteAnimations = {
	Ability = "rbxassetid://98874686617515",
	Decode = "rbxassetid://74610538783111",
	Idle = "rbxassetid://97099524343316",
	Quirk = "rbxassetid://71701359955259",
	Run = "rbxassetid://85362254758095",
	Walk = "rbxassetid://119000852061913"
}
CareBearCosmo.FaceTextures = {
	Normal = "rbxassetid://99796332464070",
	Blink = "rbxassetid://74438924835839",
	Hurt = "rbxassetid://89132000804992"
}
CareBearCosmo.USE_SKIN_MODEL = true
CareBearCosmo.RightHandBone = "head.x"
CareBearCosmo.LatchedBoneOffset = CFrame.new(1.5, 2.6, 0) * CFrame.Angles(1.5707963267948966, -0.8726646259971648, 0)

function CareBearCosmo.ApplySkin(_) end

function CareBearCosmo.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position
	local v = {
		Color_1 = Color3.fromRGB(125, 203, 216),
		Color_2 = Color3.fromRGB(219, 126, 181),
		Color_3 = Color3.fromRGB(181, 154, 193),
		Color_4 = Color3.fromRGB(114, 70, 155)
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

return CareBearCosmo