game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
local Debris = require(game.ReplicatedStorage.Util.Debris)
require(game.ReplicatedStorage.Util.Sound)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local _ = { TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local _ = {
	LeftHand = "LeftWristRigAttachment",
	RightHand = "RightWristRigAttachment",
	LeftLowerArm = "LeftWristRigAttachment",
	RightLowerArm = "RightWristRigAttachment",
	LeftUpperArm = "LeftElbowRigAttachment",
	RightUpperArm = "RightElbowRigAttachment"
}
return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 500 then
		return
	end

	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4.5) * CFrame.Angles(0, 0, 3.141592653589793)
	local clone = script.eff:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin

	if player.God then
		for _, child in pairs(clone.Attachment:GetChildren()) do
			local lifetime = child.Lifetime
			child.Lifetime = NumberRange.new(lifetime.Min * 0.15, lifetime.Max * 0.15)
			child:Emit((math.ceil(child.Rate / 6)))
		end
	end

	local punches = clone.Punches
	local lifetime = clone.Punches.Lifetime
	punches.Lifetime = NumberRange.new(lifetime.Min * 0.65, lifetime.Max * 0.65)
	clone.Punches:Emit(1)
	Debris:AddItem(clone, 1.5)
end