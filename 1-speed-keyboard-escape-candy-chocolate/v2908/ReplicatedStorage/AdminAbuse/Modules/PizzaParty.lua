local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local DanceSpawner = require(ReplicatedStorage.Utilities.Events.DanceSpawner)
local ParticleZone = require(ReplicatedStorage.Utilities.Events.ParticleZone)
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local SharedSyncedEvent = require(script.Parent.Parent.SharedSyncedEvent)
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local pizzaParty = EventsConfig.PizzaParty
local localPlayer = Players.LocalPlayer
local v = nil

local function getNotificationSystem()
	if not v then
		local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
		v = NotificationSystem
	end

	return v
end

local color = Color3.fromRGB(255, 225, 180)
local v2 = DanceSpawner.new({
	spinSpeed = 10,
	jumpFreq = 5,
	jumpHeight = 2
})

local function makeVFXPizza()
	local clone = ReplicatedStorage.Assets.Events:WaitForChild("Pizza"):Clone()
	clone.Name = "PizzaVFX"
	clone.Size = createVector(5, 0.5, 5)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CastShadow = false
	clone.Parent = workspace
	return clone
end

local function getVFXPizza()
	local templates = ReplicatedStorage:FindFirstChild("Templates")
	local pizzas = templates and templates:FindFirstChild("Pizzas")

	if pizzas then
		local children = pizzas:GetChildren()

		if #children > 0 then
			local clone = children[math.random(1, #children)]:Clone()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function forceVFX(p)
				p.Anchored = true
				p.CanCollide = false
			end

			if clone:IsA("BasePart") then
				forceVFX(clone) -- equivalent call inferred; original call site unknown
			else
				for _, part in ipairs(clone:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					forceVFX(part) -- equivalent call inferred; original call site unknown
				end
			end

			clone.Parent = workspace
			return clone
		end
	end

	local clone = ReplicatedStorage.Assets.Events:WaitForChild("Pizza"):Clone()
	clone.Name = "PizzaVFX"
	clone.Size = createVector(5, 0.5, 5)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CastShadow = false
	clone.Parent = workspace
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPizzaCF(part, cFrame)
	if part:IsA("BasePart") then
		part.CFrame = cFrame
	else
		part:PivotTo(cFrame)
	end
end

local v3 = PartyEvent.new({
	IsAdminAbuse = false,
	NeedsDuration = true,
	MaxDurationSeconds = 1200,
	DefaultDurationSeconds = 600,
	RequiresRespawnRefire = true,
	SkipDoorTransition = true,
	Sounds = { "rbxassetid://126430501965399" }
})

function v3.OnStart(_, p, _, _, p2)
	p._vfx = nil
	p._nextVfx = os.clock()
	p._lastNow = nil
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.Parent = Lighting
	p._orangeFilter = colorCorrectionEffect
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.5), {
		TintColor = color,
		Brightness = 0.01,
		Contrast = 0.02,
		Saturation = 0.04
	}):Play()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectTool(child)
		if child.Name ~= "PizzaSlice" then
			return
		end

		p.janitor:Add(child.Activated:Connect(function()
			if not v then
				local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
				v = NotificationSystem
			end

			v:ShowGeneralNotification("PIZZA TIME X2 SPEED!", Color3.fromRGB(255, 200, 50))
		end))
	end

	local backpack = localPlayer:FindFirstChild("Backpack")

	if backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			connectTool(child) -- equivalent call inferred; original call site unknown
		end

		p.janitor:Add(backpack.ChildAdded:Connect(connectTool))
	end

	local particleZone = ParticleZone.new({
		diameter = 40
	})
	particleZone:setup(p.janitor, CFrame.new(p2.CFrame.Position))
	p.particleZone = particleZone
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://88867975870506"
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.2),
		NumberSequenceKeypoint.new(0.5, 1.5),
		NumberSequenceKeypoint.new(1, 0.4)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Speed = NumberRange.new(2, 6)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Lifetime = NumberRange.new(3, 6)
	particleEmitter.Rate = 20
	particleEmitter.RotSpeed = NumberRange.new(-45, 45)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.LockedToPart = true
	particleEmitter.Parent = particleZone.part
	local pizzaSlice = ReplicatedStorage.Assets.Events:FindFirstChild("PizzaSlice")

	if not pizzaSlice then
		warn("[PizzaParty] Modèle \"PizzaSlice\" introuvable dans ReplicatedStorage")
		return
	end

	local v5 = { pizzaSlice }
	local v6 = SharedSyncedEvent.new(pizzaParty.SyncChannelName)
	p.janitor:Add(v6, "destroy")
	local v7 = false

	local function trySpawn(list)
		if v7 or type(list) ~= "table" or #list == 0 then
			return
		end

		v7 = true
		v2:setupAtPositions(p.janitor, list, v5)
	end

	v6:onChange("Positions", trySpawn)
	local positions = v6:get("Positions")

	if not v7 and type(positions) == "table" and #positions ~= 0 then
		v7 = true
		v2:setupAtPositions(p.janitor, positions, v5)
	end
end

function v3.OnRender(_, state, lastNow, _, instance, p)
	if state.particleZone then
		state.particleZone:update(p.CFrame.Position)
	end

	v2:update(lastNow)
	local v4 = lastNow - (state._lastNow or lastNow)
	state._lastNow = lastNow

	if v4 <= 0 then
		return
	end

	if state._nextVfx <= lastNow then
		if state._vfx and state._vfx.part.Parent then
			state._vfx.part:Destroy()
		end

		local players = Players:GetPlayers()

		if #players > 0 then
			local player = players[math.random(1, #players)]

			if player.Character then
				local vFXPizza = getVFXPizza()
				state.janitor:Add(vFXPizza)
				state._vfx = {
					part = vFXPizza,
					endTime = lastNow + 10,
					angle = 0,
					userId = player.UserId
				}
			end
		end

		state._nextVfx = lastNow + 8
	end

	local _vfx = state._vfx

	if not _vfx then
		return
	end

	if _vfx.endTime <= lastNow or not _vfx.part.Parent then
		if _vfx.part.Parent then
			_vfx.part:Destroy()
		end

		state._vfx = nil
	else
		local playerByUserId = Players:GetPlayerByUserId(_vfx.userId)
		local humanoidRootPart = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		_vfx.angle += 3.141592653589793 * v4
		setPizzaCF(
			_vfx.part,
			CFrame.new(humanoidRootPart.Position + createVector(0, -3, 0)) * CFrame.Angles(0, _vfx.angle, 0)
		) -- equivalent call inferred; original call site unknown

		if playerByUserId == localPlayer and instance and instance.Parent then
			instance.CFrame *= CFrame.Angles(0, 1.3962634015954636 * v4, 0)
		end
	end
end

function v3.OnStop(_, state)
	if state._vfx and state._vfx.part.Parent then
		state._vfx.part:Destroy()
	end

	state._vfx = nil
	local _orangeFilter = state._orangeFilter

	if _orangeFilter and _orangeFilter.Parent then
		local tween = TweenService:Create(_orangeFilter, TweenInfo.new(1.5), {
			TintColor = Color3.new(1, 1, 1),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
		tween.Completed:Once(function()
			_orangeFilter:Destroy()
		end)
		tween:Play()
	end

	state._orangeFilter = nil
end

return v3