local parent = script.Parent
local Data = require(parent.Data)
local parent2 = parent.Parent
local Guid = require(parent2.Guid)
local Tags = require(parent2.Tags)
local Guard = require(parent2.Guard)
local UserId = require(parent2.UserId)
local Signal = require(parent2.Signal)
local Backend = require(parent2.Backend)
local Network = require(parent2.Network)
local Promise = require(parent2.Promise)
local Recents = require(parent2.Recents)
local Ownership = require(parent2.Ownership)
local PlayerData = require(parent2.PlayerData)
local RunContext = require(parent2.RunContext)
local Marketplace = require(parent2.Marketplace)
local Players = game:GetService("Players")
local v = {
	Token = Guard.Any,
	Rolled = Guard.Boolean,
	Roll = Guard.Optional(Guard.Number),
	UnlockedAura = Guard.Optional(Guard.String)
}
local auraRolled = Signal.new()
local Rolls = {
	AuraRolled = auraRolled
}

local function validateAuraRoll(data)
	return {
		Token = data.Token,
		Roll = v.Roll(data.Roll),
		Rolled = v.Rolled(data.Rolled),
		UnlockedAura = v.UnlockedAura(data.UnlockedAura)
	}
end

local event = Network.Event("RELICSxyz_RollForAura", Guard.Any)
local event2 = Network.Event("RELICSxyz_RenewRolls", Guard.Any)
local event3 = Network.Event("RELICSxyz_AuraRolled", validateAuraRoll)
local event4 = Network.Event("RELICSxyz_EquipAura", Guard.Optional(Guard.String))

-- equivalent calls inferred from this helper; original call sites unknown
local function isAurasEnabled()
	local firstTagged = Tags.FindFirstTagged("RelicsFeatures")
	return not firstTagged or firstTagged:GetAttribute("Auras") and true or false
end

local function getAurasConfig()
	local firstTagged = Tags.FindFirstTagged("RelicsAuraConfig")
	local isDemo = Backend.IsDemo()
	local v3

	if firstTagged then
		local attributes = firstTagged:GetAttributes()
		v3 = {
			RollAssetId = tonumber(attributes.RollAssetId),
			RollGamePass = tonumber(attributes.RollGamePass),
			RollsPerDay = tonumber(attributes.RollsPerDay) or 5,
			RollsWithProduct = tonumber(attributes.RollsWithProduct) or 25
		}
	else
		v3 = {
			RollGamePass = nil,
			RollAssetId = nil,
			RollsPerDay = 5,
			RollsWithProduct = 25
		}
	end

	if isDemo then
		v3.RollsPerDay = 1e999
		v3.RollsWithProduct = 1e999
	end

	if not (v3.RollGamePass or v3.RollAssetId) then
		v3.RollsWithProduct = 0
	end

	return v3
end

local function getMaxRolls(p: number)
	local aurasConfig = getAurasConfig()
	local rollGamePass = aurasConfig.RollGamePass
	local rollAssetId = aurasConfig.RollAssetId
	local rollsPerDay = aurasConfig.RollsPerDay
	local v3 = true

	if not (rollGamePass or rollAssetId) then
		return rollsPerDay, true
	end

	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return rollsPerDay, v3
	end

	local v4 = {}

	if rollGamePass and rollGamePass > 0 then
		table.insert(v4, {
			Id = rollGamePass,
			InfoType = Enum.InfoType.GamePass
		})
	end

	if rollAssetId and rollAssetId > 0 then
		table.insert(v4, {
			Id = rollAssetId,
			InfoType = Enum.InfoType.Asset
		})
	end

	if not (#v4 > 0) then
		return rollsPerDay, v3
	end

	local bulkResolveOwnership = Marketplace.BulkResolveOwnership(playerByUserId, v4)

	if not bulkResolveOwnership then
		return rollsPerDay, v3
	end

	local v5, v6 = bulkResolveOwnership:await()

	if not v5 then
		v3 = false
		return rollsPerDay, false
	end

	for _, v7 in ipairs(v6) do
		if v7 then
			return aurasConfig.RollsWithProduct, v3
		end
	end

	return rollsPerDay, v3
end

local function renewRollsImpl(userId: number)
	local v3 = PlayerData.Get(userId)

	if not v3.IsLoaded then
		return Promise.reject("Player data not loaded!")
	end

	local lastRenew = v3.CurrentData.Auras.LastRenew or 0
	local now = os.time()

	if now - lastRenew > 86400 then
		local maxRolls, v4 = getMaxRolls(userId)

		if v4 then
			return v3:Patch(function(p)
				p.Auras.Rolls = maxRolls
				p.Auras.LastRenew = now
			end)
		end
	end

	return Promise.reject("Cannot renew rolls at this time!")
end

local function rollAuraImpl(p: number, token)
	local v3 = PlayerData.Get(p)

	if not v3.IsLoaded then
		return Promise.reject("Player data not loaded!")
	end

	local rolls = v3.CurrentData.Auras.Rolls or 0

	if rolls == 0 then
		return Promise.resolve({
			Rolled = false,
			Token = token
		})
	end

	local roll = math.random()
	local result = {
		Rolled = true,
		Roll = roll,
		Token = token
	}
	return v3:Patch(function(p3)
		local auras = p3.Auras
		p3.Auras.Rolls = math.max(0, rolls - 1)

		if roll < 0.05 then
			local v5 = {}
			local total = 0

			for k, v6 in Data.GetAuras() do
				local chance = v6.Chance

				if not (chance > 0) then
					continue
				end

				table.insert(v5, {
					Name = k,
					Weight = chance
				})
				total += chance
			end

			local v6 = math.random() * total
			local v7 = 0

			for _, v8 in ipairs(v5) do
				local v9 = v7 + v8.Weight

				if v7 <= v6 and v6 <= v9 then
					local name = v8.Name
					auras.Unlocks[name] = true
					result.UnlockedAura = name
				end

				v7 = v9
			end
		end
	end):andThen(function()
		return result
	end)
end

local function equipAuraImpl(p, aura: string?, _: boolean?)
	local v3 = aura and Data.FindAura(aura)
	local v4 = PlayerData.Get(p.UserId)

	if not v4.IsLoaded then
		return Promise.reject("Player data not loaded!")
	end

	if not isAurasEnabled() and aura ~= nil then
		return Promise.reject("Auras feature disabled")
	end

	local auras = v4.CurrentData.Auras
	local unlocks = auras.Unlocks

	if aura and v3 and not unlocks[aura] then
		local v5 = Ownership.Get(v3)

		if #v5 > 0 then
			local v6, v7 = Marketplace.BulkResolveOwnership(p, v5):await()

			if v6 then
				for _, v9 in ipairs(v7) do
					if not v9 then
						continue
					end

					unlocked = true
					break
				end
			end
		end

		if not unlocked then
			warn("Aura", aura, "is not unlocked.")
			return Promise.reject("Aura not unlocked!")
		end
	end

	if auras.Aura == aura then
		return Promise.reject("Aura already equipped!")
	end

	return v4:Patch(function(p2)
		local auras2 = p2.Auras
		auras2.Aura = aura

		if aura and not auras2.Unlocks[aura] then
			auras2.Unlocks[aura] = true
		end
	end):andThen(function()
		if aura then
			Recents.PushRecentAura(aura, p.UserId)
		end
	end)
end

function Rolls.EquipAura(p: string?, p2: number?)
	if RunContext.IsServer then
		assert(p2, "UserId is required on server.")
		local playerByUserId = Players:GetPlayerByUserId(p2)

		if playerByUserId then
			equipAuraImpl(playerByUserId, p)
		else
			warn("Player not found for userId:", p2)
		end
	else
		if not RunContext.IsEdit then
			event4:Client():Fire(p)
			return
		end

		equipAuraImpl(Players.LocalPlayer, p)
	end
end

function Rolls.RollForAura()
	if not RunContext.IsEdit then
		return Promise.new(function(callback, _)
			local v3 = Guid.Create()
			event:Client():Fire(v3)
			local v4

			repeat
				v4 = auraRolled:Wait()
			until v4.Token == v3

			callback(v4)
		end)
	end

	return rollAuraImpl((UserId.Get()))
end

function Rolls.CanRenewRolls(p: number)
	local v3 = PlayerData.Read()

	if not v3 then
		return false
	end

	local now = os.time()
	local auras = v3.Auras

	if now - (auras.LastRenew or 0) > 86400 then
		local maxRolls, v4 = getMaxRolls(p)

		if v4 and auras.Rolls < maxRolls then
			return true
		end
	end

	return false
end

function Rolls.RenewRolls()
	if not RunContext.IsEdit then
		event2:Client():Fire()
		return
	end

	local StudioService = game:GetService("StudioService")
	renewRollsImpl(StudioService:GetUserId())
end

if RunContext.IsServer then
	local aurasConfig = getAurasConfig()
	local rollGamePass = aurasConfig.RollGamePass
	local rollAssetId = aurasConfig.RollAssetId

	if rollGamePass or rollAssetId then
		local rollsPerDay = aurasConfig.RollsPerDay
		local rollsWithProduct = aurasConfig.RollsWithProduct
		local v3 = rollsWithProduct - rollsPerDay

		local function onPurchaseFinished(p, p2: number, p3)
			local v4 = rollGamePass

			if v4 then
				if p2 == rollGamePass then
					v4 = p3 == Enum.InfoType.GamePass
				else
					v4 = false
				end
			end

			local v5 = rollAssetId

			if v5 then
				if p2 == rollAssetId then
					v5 = p3 == Enum.InfoType.Asset
				else
					v5 = false
				end
			end

			if v4 or v5 then
				PlayerData.Load(p.UserId):andThen(function(object)
					local rolls = object.CurrentData.Auras.Rolls or 0

					if rolls < rollsWithProduct then
						object:Patch(function(p4)
							local auras = p4.Auras
							auras.Rolls = math.max(0, rolls + v3)
							auras.LastRenew = os.time()
						end)
					end
				end)
			end
		end

		Marketplace.PromptPurchaseFinished:Connect(onPurchaseFinished)
	end

	for _, clickDetector in Tags.GetTagged("RelicsDebugResetRolls") do
		if clickDetector:IsA("ClickDetector") then
			clickDetector.MouseClick:Connect(function(p)
				PlayerData.Load(p.UserId):andThen(function(object)
					local maxRolls, v3 = getMaxRolls(p.UserId)

					if v3 then
						object:Patch(function(p2)
							local auras = p2.Auras
							auras.Rolls = maxRolls
							auras.LastRenew = os.time()
						end)
					end
				end)
			end)
		end
	end

	local function onPlayerAdded(instance)
		local userId = instance.UserId
		PlayerData.Load(userId):andThen(function()
			local v3 = PlayerData.Get(userId)
			local firstTagged = Tags.FindFirstTagged("RelicsFeatures")

			if firstTagged and not firstTagged:GetAttribute("Auras") and v3.CurrentData.Auras.Aura ~= nil then
				v3:Patch(function(p)
					p.Auras.Aura = nil
				end)
			end

			v3:Connect("Auras/Aura", function(rELICSxyz_Aura: string?)
				if isAurasEnabled() then
					instance:SetAttribute("RELICSxyz_Aura", rELICSxyz_Aura)
				else
					instance:SetAttribute("RELICSxyz_Aura", nil)
				end
			end)
			local aura = v3.CurrentData.Auras.Aura

			if isAurasEnabled() then
				instance:SetAttribute("RELICSxyz_Aura", aura)
			else
				instance:SetAttribute("RELICSxyz_Aura", nil)
			end
		end)
	end

	local server = event2:Server()
	local server2 = event4:Server()
	local server3 = event:Server()
	server:On(function(p)
		renewRollsImpl(p.UserId)
	end)
	server2:On(function(p, p2: string?)
		equipAuraImpl(p, p2)
	end)
	server3:On(function(p, token)
		local server4 = event3:Server()
		rollAuraImpl(p.UserId, token):andThen(function(p3)
			server4:Fire(p, p3)
		end):catch(function(p3)
			warn("Failed to roll aura for player", p.Name, "-", p3, debug.traceback())
			server4:Fire(p, {
				Token = token,
				Rolled = false
			})
		end)
	end)
	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v3 in Players:GetPlayers() do
		local userId = v3.UserId
		local v5 = v3
		PlayerData.Load(userId):andThen(function()
			local v6 = PlayerData.Get(userId)
			local firstTagged = Tags.FindFirstTagged("RelicsFeatures")

			if firstTagged and not firstTagged:GetAttribute("Auras") and v6.CurrentData.Auras.Aura ~= nil then
				v6:Patch(function(p)
					p.Auras.Aura = nil
				end)
			end

			v6:Connect("Auras/Aura", function(rELICSxyz_Aura: string?)
				if isAurasEnabled() then
					v5:SetAttribute("RELICSxyz_Aura", rELICSxyz_Aura)
				else
					v5:SetAttribute("RELICSxyz_Aura", nil)
				end
			end)
			local aura = v6.CurrentData.Auras.Aura

			if isAurasEnabled() then
				v5:SetAttribute("RELICSxyz_Aura", aura)
			else
				v5:SetAttribute("RELICSxyz_Aura", nil)
			end
		end)
	end

	local firstTagged = Tags.FindFirstTagged("RelicsFeatures")

	if firstTagged then
		firstTagged:GetAttributeChangedSignal("Auras"):Connect(function()
			local firstTagged2 = Tags.FindFirstTagged("RelicsFeatures")

			if firstTagged2 and not firstTagged2:GetAttribute("Auras") then
				for _, v3 in Players:GetPlayers() do
					local v4 = v3
					PlayerData.Load(v3.UserId):andThen(function(object)
						if object.CurrentData.Auras.Aura ~= nil then
							object:Patch(function(p)
								p.Auras.Aura = nil
							end)
						end

						v4:SetAttribute("RELICSxyz_Aura", nil)
					end)
				end
			end
		end)
		return Rolls
	end
else
	event3:Client():On(function(p)
		auraRolled:Fire(p)
	end)
end

return Rolls