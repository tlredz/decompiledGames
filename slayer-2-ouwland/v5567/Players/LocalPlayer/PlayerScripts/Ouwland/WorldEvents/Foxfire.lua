local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
local v = {
	["Mushroom Lit Lantern"] = true
}
local foxfireGlow = nil
local v2 = false

local function getTemplate()
	if foxfireGlow ~= nil then
		return foxfireGlow
	end

	foxfireGlow = ReplicatedStorage.Assets:FindFirstChild("FoxfireGlow")

	if foxfireGlow == nil and not v2 then
		v2 = true
		warn("[Foxfire] no ReplicatedStorage.Assets.FoxfireGlow; mushrooms will not glow")
	end

	return foxfireGlow
end

local v3 = {}
local folder = Instance.new("Folder")
local v4 = nil
local parent = nil

local function attach(part)
	if v3[part] ~= nil then
		return
	end

	local basePart

	if part:IsA("BasePart") then
		basePart = part
	else
		basePart = part:FindFirstChildWhichIsA("BasePart", true)
	end

	if basePart == nil then
		return
	end

	if foxfireGlow == nil then
		foxfireGlow = ReplicatedStorage.Assets:FindFirstChild("FoxfireGlow")

		if foxfireGlow == nil and not v2 then
			v2 = true
			warn("[Foxfire] no ReplicatedStorage.Assets.FoxfireGlow; mushrooms will not glow")
		end
	end

	local v5 = foxfireGlow

	if v5 == nil then
		return
	end

	local clone = v5:Clone()
	local ratesByEmitter = {}

	for _, emitter in clone:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		ratesByEmitter[emitter] = emitter.Rate
		emitter.Rate = 0
		emitter.Enabled = true
	end

	clone.Parent = basePart
	local v6 = math.max(basePart.Size.X, basePart.Size.Y, basePart.Size.Z)
	clone.WorldPosition = basePart.Position + Vector3.new(0, v6 * 0.35, 0)
	local surfaceAppearance = basePart:FindFirstChildOfClass("SurfaceAppearance")
	v3[part] = {
		attachment = clone,
		rates = ratesByEmitter,
		surface = surfaceAppearance,
		idleEmissive = surfaceAppearance == nil and 0 or surfaceAppearance.EmissiveStrength,
		dimmed = false,
		burn = 0,
		field = part:HasTag("FoxfireField")
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function detach(k)
	local v5 = v3[k]

	if v5 == nil then
		return
	end

	v3[k] = nil

	if v5.emissiveTween ~= nil then
		v5.emissiveTween:Cancel()
	end

	if v5.surface ~= nil then
		v5.surface.EmissiveStrength = v5.idleEmissive
	end

	v5.attachment:Destroy()
end

local function attachLantern(part)
	if v4 ~= nil then
		return
	end

	local basePart

	if part:IsA("BasePart") then
		basePart = part
	else
		basePart = part:FindFirstChildWhichIsA("BasePart", true)
	end

	if basePart == nil then
		warn("[Foxfire] FoxfireLantern has no BasePart; it can never be taken")
		return
	end

	v4 = part
	parent = part.Parent
	part.Parent = folder
	Utility.CreatePrompt({
		ActionText = "Take it",
		ObjectText = "Lantern",
		HoldDuration = 1,
		MaxActivationDistance = 14,
		Parent = basePart
	}).Triggered:Connect(function()
		part.Parent = folder
		SignalEvent.ToServer("FoxfireTake")
	end)
end

local flag = false
local v5 = false
task.spawn(function()
	PlayerStatResolver.Attach(localPlayer, "Illumination", function()
		flag = false
		v5 = false

		if (PlayerStatResolver.GetStatExcept(localPlayer, "Illumination", "Progression") or 0) <= 0 then
			return
		end

		for _, v6 in Character_info_provider.getEquippedAccessoryStats(localPlayer) do
			if not v[v6] then
				continue
			end

			v5 = true
			return
		end

		flag = true
	end)
end)

local function ownsLantern()
	local data = Utility.GetData(localPlayer)
	return data ~= nil and data.Inventory.Inventory:FindFirstChild("Mushroom Lit Lantern") ~= nil
end

local function step()
	if next(v3) == nil then
		return
	end

	local now = os.clock()
	local character = localPlayer.Character
	local primaryPart

	if character ~= nil then
		primaryPart = character.PrimaryPart or nil
	end

	local v6 = not DayAndNightHandler.IsEnabled() or DayAndNightHandler.IsNight()
	local v7

	if primaryPart == nil then
		v7 = false
	else
		v7 = not flag
	end

	local v8 = v7 and (v5 or Vector3.new(primaryPart.AssemblyLinearVelocity.X, 0, primaryPart.AssemblyLinearVelocity.Z).Magnitude <= 17 * PlayerStatResolver.GetMovementMultiplier(localPlayer))

	for k, v9 in v3 do
		if k.Parent == nil then
			detach(k) -- equivalent call inferred; original call site unknown
		else
			local v10

			if primaryPart == nil then
				v10 = false
			else
				local v11 = primaryPart.Position - k:GetPivot().Position

				if math.abs(v11.Y) <= 10 then
					v10 = Vector3.new(v11.X, 0, v11.Z).Magnitude <= 3
				else
					v10 = false
				end
			end

			local field = v7 and (v9.field or v6)

			if field then
				if v9.wokenAt ~= nil and now - v9.wokenAt > (v9.field and 50 or 6) then
					v9.wokenAt = nil
				end
			else
				v9.wokenAt = nil
				v9.flickerUntil = nil
			end

			if v10 then
				if field then
					if v8 then
						v9.wokenAt = v9.wokenAt or now
						v9.flickerUntil = nil
					else
						v9.wokenAt = nil

						if v9.flickerUntil == nil then
							v9.flickerUntil = now + 0.45
						end
					end
				elseif flag then
					v9.dimUntil = now + 2.5
				end
			end

			if field then
				v9.dimUntil = nil
			end

			if v9.flickerUntil ~= nil and v9.flickerUntil < now then
				v9.flickerUntil = nil
			end

			if v9.dimUntil ~= nil and v9.dimUntil < now then
				v9.dimUntil = nil
			end

			local burn = v9.wokenAt ~= nil and 1 or v9.flickerUntil == nil and 0 or 0.35

			if v9.burn ~= burn then
				local v12 = v9.burn == 1
				v9.burn = burn

				for k2, rate in v9.rates do
					k2.Rate = rate * burn
				end

				if burn == 1 and not v12 then
					for k2 in v9.rates do
						k2:Emit(15)
					end
				end
			end

			local dimmed = v9.wokenAt ~= nil or v9.dimUntil ~= nil

			if v9.dimmed ~= dimmed and v9.surface ~= nil then
				v9.dimmed = dimmed

				if v9.emissiveTween ~= nil then
					v9.emissiveTween:Cancel()
				end

				local tween = TweenService:Create(v9.surface, TweenInfo.new(dimmed and 0.4 or 2.5), {
					EmissiveStrength = dimmed and 3.5 or v9.idleEmissive
				})
				v9.emissiveTween = tween
				tween:Play()
			end
		end
	end

	local v9

	if localPlayer:GetAttribute("FoxfireLit") == true then
		local data = Utility.GetData(localPlayer)
		v9 = data == nil or data.Inventory.Inventory:FindFirstChild("Mushroom Lit Lantern") == nil
	else
		v9 = false
	end

	local parent2

	if v9 then
		parent2 = parent
	else
		parent2 = folder
	end

	if v4 ~= nil and v4.Parent ~= parent2 then
		v4.Parent = parent2
	end
end

for _, v6 in { "Foxfire", "FoxfireField" } do
	CollectionService:GetInstanceAddedSignal(v6):Connect(attach)
	CollectionService:GetInstanceRemovedSignal(v6):Connect(detach)
end

for _, v6 in CollectionService:GetTagged("FoxfireLantern") do
	attachLantern(v6)
end

CollectionService:GetInstanceAddedSignal("FoxfireLantern"):Connect(attachLantern)
local v6 = false

while true do
	task.wait(0.1)

	if not v6 then
		if foxfireGlow == nil then
			foxfireGlow = ReplicatedStorage.Assets:FindFirstChild("FoxfireGlow")

			if foxfireGlow == nil and not v2 then
				v2 = true
				warn("[Foxfire] no ReplicatedStorage.Assets.FoxfireGlow; mushrooms will not glow")
			end
		end

		if foxfireGlow ~= nil then
			v6 = true

			for _, tag in { "Foxfire", "FoxfireField" } do
				for _, v7 in CollectionService:GetTagged(tag) do
					attach(v7)
				end
			end
		end
	end

	step()
end