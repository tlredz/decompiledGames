local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.KnockbackLines)
require(game.ReplicatedStorage.Util.ScaleParticle)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
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
local v = { TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local position = humanoidRootPart.Position

	if (position - workspace.CurrentCamera.CFrame.p).Magnitude > 400 then
		return
	end

	Sound:Play("SpringKnock", position)
	local cFrame = humanoidRootPart.CFrame * CFrame.new(1.5, 0, -30)
	local clone = script.eff:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 1)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child.Enabled = true
	end

	for i = 1, 2 do
		local cFrame2 = clone.CFrame * CFrame.new(0, 0, 5) * CFrame.Angles(0, 1.57, 1.57)
		local clone2 = script.Shockwave:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame2
		clone2.Parent = _WorldOrigin
		Debris:AddItem(clone2, 0.5)

		if i == 1 then
			TweenService:Create(clone2, v[1], {
				CFrame = clone2.CFrame * CFrame.new(0, 12, 0),
				Size = Vector3.new(clone2.Size.X * 2, 0, clone2.Size.Z * 2),
				Transparency = 1
			}):Play()
		else
			TweenService:Create(clone2, v[1], {
				CFrame = clone2.CFrame * CFrame.new(0, 17, 0),
				Size = Vector3.new(clone2.Size.X * 3, 0, clone2.Size.Z * 3),
				Transparency = 1
			}):Play()
		end
	end

	task.delay(0.2, function()
		for _, child in pairs(clone.Attachment:GetChildren()) do
			child.Enabled = false
		end
	end)
end