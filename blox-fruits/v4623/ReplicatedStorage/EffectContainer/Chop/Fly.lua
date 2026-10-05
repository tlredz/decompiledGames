local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.KnockbackLines)
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
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
local v = { TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p, effect)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = effect or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if not character or not character:IsDescendantOf(workspace) or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local effect = createEffect(humanoidRootPart.CFrame, script.eff, "ChopFly" .. character.Name) -- equivalent call inferred; original call site unknown
	effect.Weld.Part0 = character.LowerTorso

	for _, child in pairs(effect.Attachment:GetChildren()) do
		ScaleParticle({
			Emitter = child,
			Scale = 0.4,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
	end

	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -5) * CFrame.Angles(0, 1.57, 1.57)
	local clone = script.Shockwave:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 0.5)
	TweenService:Create(clone, v[1], {
		CFrame = clone.CFrame * CFrame.new(0, 7, 0),
		Size = Vector3.new(clone.Size.X * 2, 0, clone.Size.Z * 2),
		Transparency = 1
	}):Play()
	local effect2 = createEffect(
		humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0),
		script.Dust,
		nil,
		effect
	) -- equivalent call inferred; original call site unknown
	Sound:Play("ChopFlightStart", humanoidRootPart)
	local lastTime = tick()
	local v5 = nil

	while effect ~= nil and effect.Parent ~= nil and effect.Name == "ChopFly" .. character.Name and character:IsDescendantOf(workspace) and player.Holding and player.Holding:IsDescendantOf(workspace) and player.Holding.Value do
		local ray = Ray.new(humanoidRootPart.Position, createVector(0, -10, 0))
		local part = workspace:FindPartOnRayWithWhitelist(ray, { map })

		if part then
			effect2.Attachment.Smoke.Color = ColorSequence.new(part.Color)
			effect2.Attachment.Rocks.Color = ColorSequence.new(part.Color)
			effect2.Orientation = humanoidRootPart.Orientation - createVector(0, 180, 0)
			effect2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			effect2.Attachment.Rocks.Enabled = true
			effect2.Attachment.Smoke.Enabled = true
		else
			effect2.Attachment.Smoke.Enabled = false
			effect2.Attachment.Rocks.Enabled = false
		end

		if tick() - lastTime > 0.5 and not v5 then
			v5 = Sound:Play("ChopFlightLoop", humanoidRootPart)
		end

		task.wait()
	end

	if v5 then
		Sound:FadeOut(v5, 0.5)
	end

	local child = _WorldOrigin:FindFirstChild("ChopFly" .. character.Name)

	if child then
		child.Name = "ExpiredEffect"
		pcall(function()
			child.Weld.Part0 = nil
		end)
		child.Anchored = true
		local dust = child:FindFirstChild("Dust")

		if dust then
			for _, child2 in pairs(dust.Attachment:GetChildren()) do
				child2.Enabled = false
			end
		end

		for _, child2 in pairs(child.Attachment:GetChildren()) do
			child2.Enabled = false
		end

		Debris:AddItem(child, 1)
	end

	Sound:Play("ChopReassemble", humanoidRootPart)
end