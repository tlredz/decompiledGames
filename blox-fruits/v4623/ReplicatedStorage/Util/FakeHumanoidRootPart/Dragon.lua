local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local function GetDragonHitPart(data)
	local replicationValues = data.ReplicationValues

	if tick() - replicationValues.DragonLastHitPartTick.Value < 0.022222222222222223 then
		local Global = require(game.ReplicatedStorage.Global)
		Global.TestGamePrint("Values.DragonLastHitPartTick.Value < 1/45", debug.info(3, "s"))
		rawset(data, "lastAccessedFrom", debug.info(3, "s"))
		return replicationValues.DragonLastHitPart.Value
	elseif replicationValues.DragonLastHitPart.Value then
		if tick() - replicationValues.DragonLastHitPartTick.Value < 1 then
			local v = rawget(data, "lastAccessedFrom")
			local v2 = debug.info(3, "s")

			if v2 == v then
				local Global = require(game.ReplicatedStorage.Global)
				Global.TestGamePrint("callerScript==lastAccess on DragonRoot", v2)
				return replicationValues.DragonLastHitPart.Value
			else
				local Global = require(game.ReplicatedStorage.Global)
				Global.TestGamePrint("wrong access|", v2, "|expect|", v, "|(IT'S NOT AN ERROR.)")
			end
		else
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGamePrint("Unset expired attack on dragon")
			rawset(data, "lastAccessedFrom", nil)
			replicationValues.DragonLastHitPart.Value = nil
		end
	end
end

local function setWasHit(p, instance)
	local replicationValues = p.ReplicationValues
	replicationValues.DragonLastHitPartTick.Value = tick()

	if typeof(instance) == "Instance" or instance == nil then
		replicationValues.DragonLastHitPart.Value = instance
	end
end

local function getEffectPart(p)
	return rawget(p, "lastHitEffectPart") or p.__Reference
end

local function setEffectPart(p, p2)
	rawset(p, "lastHitEffectPart", p2)
end

return {
	metatable = {
		__index = function(data, p)
			local __Reference = data.__Reference

			if p == "Position" then
				local dragonHitPart = GetDragonHitPart(data)

				if dragonHitPart then
					return dragonHitPart.Position
				end

				return __Reference.Position
			elseif p == "CFrame" then
				local dragonHitPart = GetDragonHitPart(data)

				if dragonHitPart then
					return dragonHitPart.CFrame
				end

				return __Reference.CFrame
			else
				if p == "Anchored" then
					return true
				elseif p == "GetAttribute" then
					return function(p2, attributeName)
						local v = rawget(p2, attributeName)

						if v == nil then
							return (__Reference:GetAttribute(attributeName))
						end

						return v
					end
				elseif p == "PrimaryPart" then
					return __Reference
				elseif p == "GetEffectPart" then
					return getEffectPart
				elseif p == "SetEffectPart" then
					return setEffectPart
				elseif p == "SetWasHit" then
					return setWasHit
				elseif p == "SetHitPart" then
					return setWasHit
				end

				if data.DataValues[p] then
					return data.ReplicationValues[p].Value
				end

				local v = __Reference[p]

				if typeof(v) == "function" then
					return function(_, ...)
						return v(__Reference, ...)
					end
				end

				return v
			end
		end,
		__newindex = function(data, p, cframe)
			if data.DataValues[p] then
				data.ReplicationValues[p].Value = cframe
				return
			end

			if p == "CFrame" then
				if data.Western then
					data.Western:PivotTo(cframe)
				elseif data.Eastern and isServer then
					if (cframe.Position - data.CFrame.Position).Magnitude < 500 then
						return
					end

					data.Eastern:PivotTo(cframe)
					local playerFromCharacter = game.Players:GetPlayerFromCharacter(data.__Reference.Parent)

					if playerFromCharacter then
						local Global = require(game.ReplicatedStorage.Global)
						local wrappedPlayer = Global.getWrappedPlayer(playerFromCharacter)

						if wrappedPlayer then
							wrappedPlayer.safeTeleport(cframe.Position, true)
						end
					end
				end
			end

			data.__Reference[p] = cframe
		end
	},
	ReplicationValues = {
		DragonLastHitPartTick = "NumberValue",
		DragonLastHitPart = "ObjectValue"
	},
	Attributes = {
		CanPortal = true
	},
	onApply = function(self)
		self.Western = self.__Reference.Parent:FindFirstChild("WesternDragonRig") or false

		if self.Western then
			self.Western = self.Western:FindFirstChild("Rig")
			return
		end

		self.Eastern = self.__Reference.Parent:FindFirstChild("EasternBloxfruitsDragon") or false
		local _ = self.Eastern
	end
}