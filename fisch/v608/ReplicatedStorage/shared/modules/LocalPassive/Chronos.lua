game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local Chronos = {
	MorphSpear = true,
	Morph = function(self, _, object)
		if not object.core.fish then
			return
		end

		self.LastFreezeAttempt = tick()
		local random = object:GetRandom(3)
		object.core.fish.OnMovementAttempted:BindAtPriority(-2000, function(p, p2, p3, p4)
			if not (p and tick() - self.LastFreezeAttempt > self.config.FreezeCooldown) then
				return p, p2, p3, p4
			end

			self.LastFreezeAttempt = tick()

			if not (random:NextNumber(0, 100) < self.config.FreezeChance) then
				return p, p2, p3, p4
			end

			if not object.data.SlashDisableStun then
				object:FreezeFish(self.config.FreezeDuration * (self.current.data.SlashStunMult or 1))
			end

			local clone = script.ChronosFlash:Clone()
			clone.Parent = object.reel
			object.renderTweens:CreateAndPlay(clone, TweenInfo.new(3, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1
			}).Completed:Once(function()
				clone:Destroy()
			end)
			ReplicatedStorage.resources.sounds.sfx.ui.chronos:Play()
			object.fx:SpawnShake(object.reel_bar, 0.75, 0.5, 0.01, false)

			if not object.data.SlashDisableStun then
				p = false
			end

			return p, p2, p3, p4
		end)
	end
}
setmetatable(Chronos, module)
return Chronos