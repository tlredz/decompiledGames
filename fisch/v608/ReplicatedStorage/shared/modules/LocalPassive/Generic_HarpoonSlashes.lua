local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local harpoonGuns = require(ReplicatedStorage.shared.modules.library.harpoonGuns)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("./PassiveHandler")
local slashes = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("slashes")
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
ReplicatedStorage:WaitForChild("world")
local GenericHarpoonSlashes = {
	Stab = function(self, targetButton, value: number?)
		if self.harpoon_current.data.SlashDisabled then
			return
		end

		local config = self.config
		local soundName = typeof(config.SoundName) == "table" and config.SoundName or { config.SoundName or "stabbystab" }
		local sound = {}

		for _, childName in ipairs(soundName) do
			table.insert(sound, slashes:FindFirstChild(childName) or slashes.stabbystab)
		end

		self.harpoon_current.OnSlash:Fire("harpoon", self.config.SourceId, value or 1)
		local iconName = typeof(config.IconName) == "table" and config.IconName or { config.IconName or "Default" }
		local icon = {}

		for _, childName in ipairs(iconName) do
			table.insert(icon, fishing.slashes:FindFirstChild(childName) or fishing.slashes["Default Slash"])
		end

		local gradientColor = config.GradientColor

		if typeof(gradientColor) == "string" then
			local child = fishing.gradients:FindFirstChild(gradientColor)

			if child then
				gradientColor = child.Color
			else
				gradientColor = nil
			end
		end

		local color = gradientColor or harpoonGuns[self.harpoon_current.harpoonName].Color or Color3.new(1, 1, 1)
		local soundPitch

		if config.SoundPitch then
			soundPitch = config.SoundPitch
		end

		return self.harpoon_current.fx:Slash({
			TargetButton = targetButton,
			Time = config.AnimTime or 0.4,
			Color = color,
			Sound = sound,
			SoundPitch = soundPitch,
			Icon = icon,
			IconRotation = config.IconRotation,
			IconColor = config.IconColor,
			FullSize = config.IconSizeFull,
			EndSize = config.IconSizeEnd
		})
	end,
	MorphHarpoon = function(self, _, object2)
		local random = object2:GetRandom(2 + self.config.SlashChance)

		if self.config.TriggerMode == "ButtonSpawn" then
			self.reelTrove:Add(object2.core.pullButtons.OnButtonAdd:Connect(function(object3)
				object2:WaitLogic(0.1)

				if random:NextNumber(0, 100) < self.config.SlashChance and not (object3.removing or object2.lastInputWasMiss) then
					local v = not self.config.AllowMultipleClicks and 1 or object3.clicksRemaining

					for i = 1, v do
						if object3.removing then
							break
						end

						self:Stab(object3.buttonObject, i)
						object3:Click("auto", self.config.SourceId)

						if i ~= v then
							object2:WaitLogic(self.config.MultiClickInterval or 0)
						end
					end
				end
			end))
		else
			warn((`Unknown stab TriggerMode "{self.config.TriggerMode}"`))
		end
	end
}
setmetatable(GenericHarpoonSlashes, module)
return GenericHarpoonSlashes