game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local fullBodyTori = FX:WaitForChild("Phoenix1").FullBodyTori

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local _ = {
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart

	if player.Adding then
		local stringValue = Instance.new("StringValue", character)
		stringValue.Name = "FullBody"
		Util.Sound:Play("Phoenix1Appear", humanoidRootPart)
		local cFrame = humanoidRootPart.CFrame
		local bird = fullBodyTori.Bird
		local v = "FullBody" .. character.Name
		local clone = bird:Clone()
		clone.Name = v or clone.Name

		if bird:IsA("Model") then
			clone:SetPrimaryPartCFrame(cFrame)
		else
			clone.CFrame = cFrame
		end

		clone.Parent = character or _WorldOrigin
		clone.RootWeld.Part0 = humanoidRootPart
		clone.AnimationController:LoadAnimation(clone.Idle):Play()
		local cFrame2 = humanoidRootPart.CFrame * CFrame.Angles(1.57, 0, 0)
		local release = fullBodyTori.release
		local clone2 = release:Clone()
		clone2.Name = clone2.Name

		if release:IsA("Model") then
			clone2:SetPrimaryPartCFrame(cFrame2)
		else
			clone2.CFrame = cFrame2
		end

		clone2.Parent = _WorldOrigin
		Debris:AddItem(clone2, 2)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	else
		local fullBody = character:FindFirstChild("FullBody")

		if not fullBody then
			return
		end

		if fullBody then
			fullBody:Destroy()
		end

		local child = character:FindFirstChild("FullBody" .. character.Name)

		if not child then
			return
		end

		child:Destroy()
		Util.Sound:Play("Phoenix1Disappear", humanoidRootPart)
		local cFrame = humanoidRootPart.CFrame * CFrame.Angles(1.57, 0, 0)
		local release = fullBodyTori.release
		local clone = release:Clone()
		clone.Name = clone.Name

		if release:IsA("Model") then
			clone:SetPrimaryPartCFrame(cFrame)
		else
			clone.CFrame = cFrame
		end

		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 2)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end
end