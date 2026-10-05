local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local module = require("./PassiveHandler")
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
local slashes = ReplicatedStorage.resources.sounds.sfx.fishing.slashes
local fishing = ReplicatedStorage.resources.replicated.fishing

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveInterval(data, object)
	if SharedWeather.IsActive("Windy") then
		return object:NextNumber(data.WindyIntervalMin, data.WindyIntervalMax)
	end

	return object:NextNumber(data.IntervalMin, data.IntervalMax)
end

local Gusts = {
	BuildSlashOptions = function(self, items)
		local config = self.config
		local result = {
			Time = config.AnimTime or 0.35,
			Color = config.GradientColor or Color3.fromRGB(198, 233, 255),
			Sound = slashes:FindFirstChild(config.SoundName or "") or slashes.stabbystabpaperfan,
			SoundPitch = config.SoundPitch,
			Icon = fishing.slashes:FindFirstChild(config.IconName or "") or fishing.slashes["Paper Fan Rod"],
			IconColor = config.IconColor
		}

		if items then
			for k, item in items do
				result[k] = item
			end
		end

		return result
	end,
	Morph = function(self, _, object2)
		local config = self.config
		local random = object2:GetRandom(37)
		local total = 0
		local interval = resolveInterval(config, random) -- equivalent call inferred; original call site unknown
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
			if not object2.active or object2.data.SlashDisabled then
				return
			end

			total += p

			if total < interval then
				return
			end

			total = 0
			interval = resolveInterval(config, random) -- equivalent call inferred; original call site unknown
			local v3 = config.SlashDamage * (object2.data.SlashDamageReduction or 1)
			object2:AddProgress(v3)

			if not object2.data.SlashDisableStun and random:NextNumber(0, 100) < config.StunChance then
				object2.core.fish:DelayNextMovement((config.StunTime + (object2.data.SlashStunBuff or 0)) * (object2.data.SlashStunMult or 1))
			end

			object2.OnSlash:Fire(config.SourceType, config.SourceName, v3)
			object2.fx:Slash(self:BuildSlashOptions())
			object2.fx:SpawnShake(object2.reel_bar, 0.2, 0.3, 0.02, false)
		end))
	end,
	MorphHarpoon = function(self, _, object2)
		local config = self.config
		local random = object2:GetRandom(37)
		local total = 0
		local interval = resolveInterval(config, random) -- equivalent call inferred; original call site unknown
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
			if not object2.active then
				return
			end

			total += p

			if total < interval then
				return
			end

			local activeButton = object2.activeButtons[1]

			if not activeButton then
				return
			end

			total = 0
			interval = resolveInterval(config, random) -- equivalent call inferred; original call site unknown
			object2:AddProgress(config.SlashDamage)
			object2.OnSlash:Fire(config.SourceType, config.SourceName, config.SlashDamage)
			object2.fx:Slash(self:BuildSlashOptions({
				TargetButton = activeButton.buttonObject
			}))
		end))
	end
}
setmetatable(Gusts, module)
return Gusts