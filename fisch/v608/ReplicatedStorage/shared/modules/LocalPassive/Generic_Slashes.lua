local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("./PassiveHandler")
local slashes = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("slashes")
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
local world = ReplicatedStorage:WaitForChild("world")
local GenericSlashes = {
	Stab = function(self, p: number?)
		if self.current.data.SlashDisabled then
			return
		end

		local currentConfig = self.currentConfig or self.config
		local v = currentConfig.SlashDamage * (self.current.data.SlashDamageReduction or 1) * (self.progressMult or 1)
		self.progressSelf = (self.progressSelf or 0) + v
		self.current:AddProgress(v)

		if currentConfig.StunTime and not self.current.data.SlashDisableStun then
			local v2 = (currentConfig.StunTime + (self.current.data.SlashStunBuff or 0)) * (self.current.data.SlashStunMult or 1)

			if currentConfig.RawStun then
				self.current.core.fish:RawDelayNextMovement(v2)
			else
				self.current.core.fish:DelayNextMovement(v2)
			end
		end

		self.current.OnSlash:Fire(currentConfig.SourceType, currentConfig.SourceName, v)
		local sound = {}

		for _, childName in typeof(currentConfig.SoundName) == "table" and currentConfig.SoundName or { currentConfig.SoundName or "stabbystab" } do
			table.insert(sound, slashes:FindFirstChild(childName) or slashes.stabbystab)
		end

		local icon = {}

		for _, childName in typeof(currentConfig.IconName) == "table" and currentConfig.IconName or { currentConfig.IconName or "stabbystab" } do
			table.insert(icon, fishing.slashes:FindFirstChild(childName) or fishing.slashes["Default Slash"])
		end

		local gradientColor = currentConfig.GradientColor

		if typeof(gradientColor) == "string" then
			local child = fishing.gradients:FindFirstChild(gradientColor)

			if child then
				gradientColor = child.Color
			end
		end

		local color = gradientColor or rods[self.current.rodName].Color or Color3.new(1, 1, 1)
		local soundPitch

		if currentConfig.SoundPitch then
			soundPitch = currentConfig.SoundPitch
		end

		if p and currentConfig.SlashComboPitch then
			soundPitch = (soundPitch or 1) + p * currentConfig.SlashComboPitch
		end

		return self.current.fx:Slash({
			Time = currentConfig.AnimTime or 0.4,
			Color = color,
			Sound = sound,
			SoundPitch = soundPitch,
			Icon = icon,
			IconRotation = currentConfig.IconRotation,
			IconColor = currentConfig.IconColor,
			FullSize = currentConfig.IconSizeFull,
			EndSize = currentConfig.IconSizeEnd
		})
	end,
	_TrackProgressSpeed = function(self, data, p)
		local progressScaling = p.ProgressScaling

		if not progressScaling then
			return
		end

		if not progressScaling.Reference or progressScaling.Reference <= 0 then
			warn((`ProgressScaling.Reference must be > 0 ({p.SourceName})`))
			return
		end

		local progress = data.progress

		if not progress then
			warn((`ProgressScaling could not read progress ({p.SourceName})`))
			return
		end

		local power = progressScaling.Power or 1
		local min = progressScaling.Min or 0
		local max = progressScaling.Max or 1e999
		local smoothing = progressScaling.Smoothing or 0.35
		self.progressMult = 1
		self.progressSelf = 0
		self.reelTrove:Add(function()
			self.progressMult = 1
			self.progressSelf = 0
		end)
		self.reelTrove:Add(data.OnLogicStep:Connect(function(p2)
			if p2 <= 0 or not data.active then
				return
			end

			local progress2 = data.progress

			if not progress2 then
				return
			end

			local v = progress2 - progress
			progress = progress2

			if not progressScaling.IncludeSelf then
				v -= self.progressSelf
			end

			self.progressSelf = 0
			local v2 = math.clamp((math.max(v, 0) / p2 / progressScaling.Reference) ^ power, min, max)
			local v3 = smoothing > 0 and 1 - math.exp(-p2 / smoothing) or 1
			self.progressMult += (v2 - self.progressMult) * v3
		end))
	end,
	Morph = function(self, _, object2)
		local config = self.config

		if config.MutationOverrides and config.MutationOverrides[object2.fish.Mutation] then
			config = GeneralUtils.applyTable(config, config.MutationOverrides[object2.fish.Mutation])
		end

		self.currentConfig = config

		if config.RequiredConditions then
			for childName, requiredCondition in config.RequiredConditions do
				local child = world:FindFirstChild(childName)

				if not child or child.Value ~= requiredCondition then
					return
				end
			end
		end

		self:_TrackProgressSpeed(object2, config)
		local random = object2:GetRandom(config.SlashChance + 2)
		local total = 0
		local v = 0

		if config.TriggerMode == "FishMove" then
			self.reelTrove:Add(object2.core.fish.OnMovementAttempted:BindAtPriority(
				1000 - config.SlashDamage,
				function(p, p2, p3, p4)
					if config.OnlyOnBar and not object2.onbar or not (random:NextNumber(0, 100) < config.SlashChance and p) then
						return p, p2, p3, p4
					end

					if not object2.data.SlashDisableStun then
						p = false
					end

					local v2 = random:NextInteger(config.SlashComboMin or 1, config.SlashComboMax or 1) + total

					if config.SlashComboRamp then
						total += config.SlashComboRamp
					end

					if config.IntervalRamp then
						v = math.clamp(v + config.IntervalRamp, 0, config.SlashInterval)

						if v >= config.SlashInterval then
							self.current.data.SlashesAtMaxInterval = true
						end
					end

					for i = 1, v2 do
						self:Stab(i)

						if i ~= v2 then
							object2:WaitLogic(config.SlashComboInterval)
						end
					end

					return p, p2, p3, p4
				end
			))
		elseif config.TriggerMode == "Interval" then
			local v2 = false
			local v3 = true
			local total2 = 0
			self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
				if self.current.data.ResetChaoticSlashes then
					total = 0
					v = 0
					total2 = 0
					self.current.data.ResetChaoticSlashes = nil
				end

				total2 += p

				if v3 and not v2 and object2.active and (not config.OnlyOnBar or object2.onbar) then
					v3 = false

					if random:NextNumber(0, 100) < config.SlashChance + (config.SlashRamp or 0) * total2 then
						v2 = true
						local v4 = random:NextInteger(config.SlashComboMin or 1, config.SlashComboMax or 1) + total

						if config.SlashComboRamp then
							total += config.SlashComboRamp
						end

						if config.IntervalRamp then
							v = math.clamp(v + config.IntervalRamp, 0, config.SlashInterval)

							if v >= config.SlashInterval then
								self.current.data.SlashesAtMaxInterval = true
							end
						end

						for i = 1, v4 do
							self:Stab(i)

							if i ~= v4 then
								object2:WaitLogic(config.SlashComboInterval)
							end
						end

						object2:DelayLogic(config.ChaoticSlashes and 0.1 or (config.AnimTime or 0.4) * 1.5, function()
							v2 = false
						end)
					end

					object2:DelayLogic((config.SlashInterval or 0.25) - v, function()
						v3 = true
					end)
				end
			end))
		else
			warn((`Unknown stab TriggerMode "{config.TriggerMode}"`))
		end
	end
}
setmetatable(GenericSlashes, module)
return GenericSlashes