local CosmoBerry = {}
CosmoBerry.Name = "Berry Roll"
CosmoBerry.Cost = 600
CosmoBerry.DandyStore = true
CosmoBerry.OverwriteAnimations = {
	Ability = "rbxassetid://98874686617515",
	Decode = "rbxassetid://119699386728294",
	Idle = "rbxassetid://97099524343316",
	Quirk = "rbxassetid://71701359955259",
	Run = "rbxassetid://71584405037730",
	Walk = "rbxassetid://95597558305842"
}
CosmoBerry.FaceTextures = {
	Normal = "rbxassetid://128890345350511",
	Blink = "rbxassetid://104385603193793",
	Hurt = "rbxassetid://84784419796489"
}
CosmoBerry.USE_SKIN_MODEL = true
CosmoBerry.RightHandBone = "head.x"
CosmoBerry.LatchedBoneOffset = CFrame.new(1.4, 2.8, -0.3) * CFrame.Angles(1.5707963267948966, -1.0471975511965976, 0)

function CosmoBerry.ApplySkin(_) end

function CosmoBerry.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(255, 102, 153)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 51, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 153, 204))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 102, 153)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 204, 229))
		})
	end

	if clone:FindFirstChild("HeartPart") then
		clone.HeartPart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 51, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 153, 204))
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

return CosmoBerry