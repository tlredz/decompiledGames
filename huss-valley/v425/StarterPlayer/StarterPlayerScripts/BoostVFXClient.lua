local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ParticipantDirectory = require(chickenOrHero.Presentation:WaitForChild("ParticipantDirectory"))
local BoostVFXConfig = require(chickenOrHero.Presentation:WaitForChild("BoostVFXConfig"))
local MovementConfig = require(chickenOrHero.Movement.MovementConfig)
local windTrail = chickenOrHero.Presentation:WaitForChild("WindTrail")
local localPlayer = Players.LocalPlayer
local v = {}
local total = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(k)
	local v2 = v[k]

	if not v2 then
		return
	end

	for _, object in v2.objects do
		object:Destroy()
	end

	v[k] = nil
end

local function add(c, root)
	local v2 = {
		root = root,
		objects = {},
		lines = {},
		untilTime = 0,
		lastStamp = c:GetAttribute("BoostEffectAt"),
		localBoost = false
	}

	for k, v3 in { -1.15, 0, 1.15 } do
		local attachment = Instance.new("Attachment")
		attachment.Name = "BoostWindTop"
		attachment.Parent = root
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "BoostWindBottom"
		attachment2.Parent = root
		local clone = windTrail:Clone()
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		clone.Enabled = false
		clone.Lifetime = BoostVFXConfig.TrailLifetime
		clone.Parent = root
		table.insert(v2.objects, attachment)
		table.insert(v2.objects, attachment2)
		table.insert(v2.objects, clone)
		table.insert(v2.lines, {
			a = attachment,
			b = attachment2,
			trail = clone,
			x = v3,
			y = k == 2 and 0.9 or -0.15
		})
	end

	v[c] = v2
	return v2
end

local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if total >= 0.25 then
		total = 0
		local v2 = {}
		local v3 = {}

		if BoostVFXConfig.Enabled then
			for _, v4 in ParticipantDirectory.list() do
				local character = v4.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					continue
				end

				local magnitude = (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude

				if magnitude < BoostVFXConfig.MaxDistance then
					table.insert(v3, {
						c = character,
						root = humanoidRootPart,
						distance = magnitude
					})
				end
			end
		end

		table.sort(v3, function(a, b)
			return a.distance < b.distance
		end)

		for k, v4 in v3 do
			if BoostVFXConfig.MaxCharacters < k then
				break
			end

			v2[v4.c] = true

			if not v[v4.c] then
				add(v4.c, v4.root)
			end
		end

		for k in v do
			if v2[k] then
				continue
			end

			remove(k) -- equivalent call inferred; original call site unknown
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v2 in v do
		if k.Parent and v2.root.Parent then
			local v3 = k == localPlayer.Character
			local localBoost = v3 and (k:GetAttribute("MovementState") == "Boosting" or k:GetAttribute("MovementState") == "Dashing")
			local boostEffectAt = k:GetAttribute("BoostEffectAt")

			if v3 then
				if localBoost and not v2.localBoost then
					v2.untilTime = serverTimeNow + MovementConfig.Dash.Duration
				end
			elseif type(boostEffectAt) == "number" and boostEffectAt ~= v2.lastStamp then
				v2.untilTime = boostEffectAt + MovementConfig.Dash.Duration + BoostVFXConfig.FadeTail
			end

			v2.lastStamp = boostEffectAt
			v2.localBoost = localBoost
			local tackleStartedAt = k:GetAttribute("TackleStartedAt")
			local tackleDuration = k:GetAttribute("TackleDuration") or 0
			local v5

			if k:GetAttribute("TackleActive") == true and type(tackleStartedAt) == "number" and tackleStartedAt <= serverTimeNow then
				v5 = serverTimeNow < tackleStartedAt + math.clamp(tackleDuration, 0, 0.6)
			else
				v5 = false
			end

			local enabled = BoostVFXConfig.Enabled and not k:GetAttribute("MovementLocked")

			if enabled then
				if v5 then
					enabled = v5
				elseif serverTimeNow < v2.untilTime then
					enabled = not k:GetAttribute("TackleActive")
				else
					enabled = false
				end
			end

			local v7 = v2.root.AssemblyLinearVelocity * createVector(1, 0, 1)
			local unit = v7.Magnitude > 0.5 and v7.Unit or v2.root.CFrame.LookVector
			local cross = unit:Cross(createVector(0, 1, 0))

			for _, line in v2.lines do
				local v8 = v2.root.Position + cross * line.x + createVector(0, 1, 0) * line.y - unit * 0.6
				local v9 = v5 and 0.065 or 0.045
				line.a.WorldPosition = v8 + createVector(0, 1, 0) * v9
				line.b.WorldPosition = v8 - createVector(0, 1, 0) * v9
				line.trail.Lifetime = v5 and 0.24 or BoostVFXConfig.TrailLifetime
				line.trail.Enabled = enabled
			end
		else
			remove(k) -- equivalent call inferred; original call site unknown
		end
	end
end)
script.Destroying:Connect(function()
	heartbeatConnection:Disconnect()

	for k in v do
		remove(k) -- equivalent call inferred; original call site unknown
	end
end)