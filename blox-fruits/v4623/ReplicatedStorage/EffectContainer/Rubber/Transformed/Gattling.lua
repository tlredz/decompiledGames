local createVector = vector.create
game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
require(game.ReplicatedStorage:WaitForChild("Effect"))
require(game.ReplicatedStorage.Util.BezierCurve)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local debris = Util.Debris
local sound = Util.Sound

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
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local v = {
	"RightLowerArm",
	"LeftLowerArm",
	"RightHand",
	"LeftHand",
	"RightUpperArm",
	"LeftUpperArm"
}
return function(player)
	local character = player.Character
	local holding = player.Holding
	local clientStatus = player.ClientStatus
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if (workspace.CurrentCamera.CFrame.Position - primaryPart.Position).magnitude > 500 then
		return
	end

	sound:Play("RubberRocketChargup", primaryPart, nil, 0.8333333333333333)
	task.wait(0.25)

	for _, childName in pairs(v) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 1
		end

		local child2 = humanoid:FindFirstChild(childName .. "_BusoLayer1")
		local child3 = humanoid:FindFirstChild(childName .. "_BusoLayer2")

		if child2 then
			child2.Transparency = 1
		end

		if child3 then
			child3.Transparency = 1
		end
	end

	local effect = createEffect(primaryPart.CFrame, script.rings, "GattlingRings" .. character.Name) -- equivalent call inferred; original call site unknown
	effect.Weld.Part0 = primaryPart
	local effect2 = createEffect(
		primaryPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0),
		script.Dust,
		"GattlingDust" .. character.Name
	) -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local v5 = false
	local now = 0

	while tick() - lastTime < 4 and character:IsDescendantOf(workspace) and not (humanoid.Health <= 0) and holding and holding:IsDescendantOf(workspace) and (not clientStatus or not clientStatus.Parent ~= character) do
		v5 = not holding.Value or v5

		if tick() - lastTime > 0.6666666666666666 and v5 then
			break
		end

		local ray = Ray.new(primaryPart.Position, createVector(0, -10, 0))
		local part = workspace:FindPartOnRayWithWhitelist(ray, { map })

		if part == nil or effect2 == nil or effect2.Parent == nil then
			effect2.Attachment.ParticleEmitter.Enabled = false
			effect2.Attachment.ParticleEmitter2.Enabled = false
		else
			effect2.Attachment.ParticleEmitter.Color = ColorSequence.new(part.Color)
			effect2.Attachment.ParticleEmitter2.Color = ColorSequence.new(part.Color)
			effect2.Orientation = primaryPart.Orientation - createVector(0, 180, 0)
			effect2.CFrame = primaryPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			effect2.Attachment.ParticleEmitter.Enabled = true
			effect2.Attachment.ParticleEmitter2.Enabled = true
		end

		if tick() - now > 0.08333333333333333 then
			sound:Play("RubberCWhoosh", effect2.Position, nil, 1.7)
			now = tick()
		end

		task.wait()
	end

	for _, childName in pairs(v) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 0
		end

		local child2 = humanoid:FindFirstChild(childName .. "_BusoLayer1")
		local child3 = humanoid:FindFirstChild(childName .. "_BusoLayer2")

		if child2 then
			child2.Transparency = 0
		end

		if child3 then
			child3.Transparency = 0
		end
	end

	if effect2 then
		effect2.Attachment.ParticleEmitter.Enabled = false
		effect2.Attachment.ParticleEmitter2.Enabled = false
		debris:AddItem(effect2, 1)
	end

	if effect then
		for _, emitter in pairs(effect:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		pcall(function()
			effect.Weld.Part0 = nil
		end)
		effect.Anchored = true
		debris:AddItem(effect, 1)
	end
end