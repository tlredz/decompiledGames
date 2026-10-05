local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local KnockbackLines = require(game.ReplicatedStorage.Util.KnockbackLines)
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
local v = {
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

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
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
		return
	end

	Sound:Play("SpikeBallSummon", humanoidRootPart)
	local random = Random.new()
	local effect = createEffect(humanoidRootPart.CFrame, script.SpikeBall, "SpikeBall" .. character.Name) -- equivalent call inferred; original call site unknown
	effect.Weld.C0 *= CFrame.Angles(0, 0, 1.57)
	effect.Weld.Part0 = character.HumanoidRootPart
	local weld2 = effect.Weld
	TweenService:Create(effect.Mesh, v[2], {
		Scale = createVector(7.775, 7.775, 7.775)
	}):Play()
	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -5) * CFrame.Angles(0, 1.57, 1.57)
	local clone = script.Shockwave:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	TweenService:Create(clone, v[4], {
		CFrame = clone.CFrame * CFrame.new(0, 7, 0),
		Size = Vector3.new(clone.Size.X * 2.5, 0, clone.Size.Z * 2.5),
		Transparency = 1
	}):Play()
	Debris:AddItem(clone, 0.5)
	task.wait(0.15)
	local effect2 = createEffect(
		humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0),
		script.Dust,
		nil,
		effect
	) -- equivalent call inferred; original call site unknown
	local v5 = 0.016666666666666666
	local total = 0
	local now = 0
	local now2 = 0

	while effect ~= nil and effect.Parent ~= nil and effect.Name ~= "ExpiredBall" and player.Status and player.Status:IsDescendantOf(workspace) and humanoid:IsDescendantOf(workspace) and humanoid.Health > 0 do
		total += v5 * 17.5 * 60
		weld2.C0 = CFrame.new(0, 3, 0) * CFrame.fromEulerAnglesXYZ(math.rad(-total), 3.141592653589793, 1.57)
		local ray = Ray.new(humanoidRootPart.Position, createVector(0, -25, 0))
		local part = workspace:FindPartOnRayWithWhitelist(ray, { map })

		if part then
			effect2.Attachment.Smoke.Color = ColorSequence.new(part.Color)
			effect2.Orientation = humanoidRootPart.Orientation - createVector(0, 180, 0)
			effect2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			effect2.Attachment.Smoke.Enabled = true
		else
			effect2.Attachment.Smoke.Enabled = false
		end

		if tick() - now > 0.125 then
			Sound:Play("SpikeBallGround", humanoidRootPart.Position)
			now = tick()
		end

		if tick() - now2 > 0.066 then
			now2 = tick()
			KnockbackLines({
				MAX = 1,
				ITERATION = 1,
				WIDTH = 0.125,
				LENGTH = 5,
				SPEED = 1,
				COLOR1 = Color3.fromRGB(0, 0, 0),
				COLOR2 = Color3.fromRGB(0, 0, 0),
				STARTPOS = humanoidRootPart.CFrame * CFrame.new(0, math.random(-5, 5), math.random(-10, 5)),
				ENDGOAL = CFrame.new(0, 0, 30)
			})
			local ray2 = Ray.new(effect.Position + Vector3.new(0, 0, math.random(-5, 15)), createVector(0, -25, 0))
			local part2, position = game.Workspace:FindPartOnRayWithWhitelist(ray2, { map })

			if part2 then
				local number = random:NextNumber(0.25, 0.75)
				local number2 = random:NextNumber(0.15, 0.5)
				local clone2 = script.Part:Clone()
				clone2.Size = Vector3.new(clone2.Size.X * number, clone2.Size.Y * number2, clone2.Size.Z * number)
				clone2.Position = position
				clone2.Color = part2.Color
				clone2.Material = part2.Material
				local bodyVelocity = Instance.new("BodyVelocity", clone2)
				bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
				Debris:AddItem(bodyVelocity, 0.3)
				local v8 = math.random(-7, 7)
				local v9 = math.random(10, 15)
				bodyVelocity.Velocity = Vector3.new(v8 * 3, v9 * 2, v8 * 3) * 1.25
				Debris:AddItem(clone2, 1.25)
				clone2.Parent = _WorldOrigin
			end
		end

		v5 = task.wait()
	end

	Sound:Play("SpikeBallDespawn", humanoidRootPart)

	if effect then
		local cFrame2 = effect.CFrame
		effect.Name = "ExpiredBall"
		pcall(function()
			effect.Weld.Part0 = nil
		end)
		effect.CFrame = cFrame2
		effect.Anchored = true
		local dust = effect:FindFirstChild("Dust")

		if dust then
			for _, child in pairs(dust.Attachment:GetChildren()) do
				child.Enabled = false
			end
		end

		for _, child in pairs(effect.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		TweenService:Create(effect.Mesh, v[1], {
			Scale = Vector3.new()
		}):Play()
		Debris:AddItem(effect, 1)
	end
end