local createVector = vector.create
local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage.Util.LightningBolt3)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)

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
	TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local FX = require(game.ReplicatedStorage:WaitForChild("FX"))
return function(player)
	local character = player.Character
	local duration = player.Duration
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 600 then
		return
	end

	local clone = script.DashTrail:Clone()
	clone.Parent = character
	local attachment = Instance.new("Attachment", humanoidRootPart)
	local attachment2 = Instance.new("Attachment", humanoidRootPart)
	attachment.Position = createVector(0, -3, 0)
	attachment2.Position = createVector(0, 3, 0)
	clone.Attachment0 = attachment
	clone.Attachment1 = attachment2
	task.delay(duration, function()
		clone.Enabled = false
		Debris:AddItem(clone, 0.26)
		Debris:AddItem(attachment, 0.26)
		Debris:AddItem(attachment2, 0.26)
	end)

	if player.Super then
		Util.Sound:Play("MinkDash", humanoidRootPart)
	end

	local ray = Ray.new(humanoidRootPart.Position, createVector(0, -7, 0))
	local part, _ = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })

	if part then
		local cFrame = humanoidRootPart.CFrame
		local clone2 = script.Dust:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		clone2.Weld.Part0 = humanoidRootPart
		clone2.Attachment.sm2.Color = ColorSequence.new(part.Color)
		task.delay(duration + 0.05, function()
			clone2.Attachment.sm2.Enabled = false
			Debris:AddItem(clone2, 0.7)
		end)
	end

	local cFrame2 = humanoidRootPart.CFrame * CFrame.Angles(0, 3.14, 0)
	local clone2 = script.eff:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame2
	clone2.Parent = _WorldOrigin

	if player.Super then
		task.delay(0.03333333333333333, function()
			local unit = (humanoidRootPart.Velocity * createVector(1, 0, 1)).Unit

			if unit ~= unit then
				unit = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
			end

			local clone3 = FX:WaitForChild("WindBalls").WindBall:Clone()
			clone3.Color = Color3.fromRGB(70, 255, 67)
			clone3.Size *= 0.2
			clone3.CFrame = CFrame.new(humanoidRootPart.Position)
			clone3.Parent = _WorldOrigin
			local WindBall = require(script.WindBall)
			WindBall(clone3, script.WindBallFX, 0.15, clone3.CFrame.Position, unit * 250, createVector(0, 0, 0))
		end)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Rate *= 3
			end
		end
	end

	clone2.Weld.Part0 = humanoidRootPart
	Debris:AddItem(clone2, 1)

	for i = 1, 2 do
		local clone3 = script["Lines" .. i]:Clone()

		if i == 1 then
			clone3.Color = ColorSequence.new(humanoidRootPart.Parent.Head.Color)
		else
			clone3.Color = ColorSequence.new(humanoidRootPart.Parent.UpperTorso.Color)
		end

		clone3.Parent = humanoidRootPart
		clone3:Emit(3)
		Debris:AddItem(clone3, 1.25)
	end

	local cFrame3 = player.CFrame * CFrame.Angles(0, 1.57, 1.57)
	local clone3 = script.Color1:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame3
	clone3.Parent = _WorldOrigin
	Debris:AddItem(clone3, 0.5)
	TweenService:Create(clone3, v[3], {
		Size = clone3.Size * (player.Super and 5 or 2),
		CFrame = clone3.CFrame * CFrame.new(0, player.Super and 15 or 10, 0) * CFrame.Angles(0, 3.14, 0),
		Transparency = 1
	}):Play()
	local flag = true
	local descendants

	if player.Super then
		resume(create(function()
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.upVector * -20,
				raycastParams
			)
			local position = raycastResult.Position

			while flag do
				local ray2 = Ray.new(humanoidRootPart.Position, humanoidRootPart.CFrame.upVector * -20)
				local part2, v5 = workspace:FindPartOnRayWithWhitelist(ray2, { map })

				if part2 and raycastResult then
					local magnitude = (v5 - position).Magnitude

					if magnitude > 1 then
						local clone4 = script.burnTrail:Clone()
						clone4.CFrame = CFrame.new(position, v5) * CFrame.new(0, 0, -magnitude / 2)
						clone4.Size = Vector3.new(1, 1, magnitude)
						clone4.Parent = _WorldOrigin
						task.delay(0.5, function()
							Debris:AddItem(clone4, 1)
							TweenService:Create(clone4, v[2], {
								Transparency = 1
							}):Play()
						end)
					end
				end

				wait()
				position = v5
			end
		end))
		descendants = character:GetDescendants()

		for _, instance in pairs(descendants) do
			if not ((instance:IsA("BasePart") or instance:IsA("Decal")) and instance.Transparency < 1) then
				continue
			end

			local numberValue = Instance.new("NumberValue", instance)
			numberValue.Name = "OldTransparencyTP"
			numberValue.Value = instance.Transparency
			instance.Transparency = 1
		end
	end

	local _ = humanoidRootPart.CFrame
	task.wait(duration)
	local _ = player.Super

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	flag = false

	if player.Super then
		for _, instance in pairs(descendants) do
			if not (instance:IsA("BasePart") or instance:IsA("Decal")) then
				continue
			end

			local oldTransparencyTP = instance:FindFirstChild("OldTransparencyTP")

			if not oldTransparencyTP then
				continue
			end

			instance.Transparency = oldTransparencyTP.Value
			oldTransparencyTP:Destroy()
		end
	end
end