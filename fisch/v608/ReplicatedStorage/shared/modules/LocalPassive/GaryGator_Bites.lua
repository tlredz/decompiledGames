local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local remoteEvent = Net:RemoteEvent("Companion/RequestMood")
local GaryGatorBites = {
	MorphSpear = true,
	Morph = function(p, _, object)
		local scaledConfig = CompanionController.GetScaledConfig(p.config)
		local random = object:GetRandom(7)
		local v = nil

		local function flashBite(color: Color3, duration: number, duration2: number)
			object.logicTweens:Create(
				object.reel_playerbar,
				TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = color
				}
			):Play()

			if v then
				v:Cancel()
			end

			local v2 = object.logicTweens:Create(
				object.reel_progress.bar,
				TweenInfo.new(duration2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					BackgroundColor3 = color
				}
			)
			v = v2
			v2:Play()
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.snap, object.reel, true)
		end

		task.spawn(function()
			object:WaitUntilReady()
			local v2 = not scaledConfig.AttemptImmediate and 0 or scaledConfig.MiniBiteInterval
			local total = 0
			local now = -1e999
			p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
				if not object.active then
					return
				end

				v2 += p2

				if v2 >= scaledConfig.MiniBiteInterval then
					v2 = 0

					if random:NextNumber(0, 100) <= scaledConfig.MiniBiteChance then
						object:AddProgress(scaledConfig.MiniBiteProgress)
						flashBite(scaledConfig.MiniBiteColor, 0.25, 0.3)
						remoteEvent:FireServer("Snap")
					end
				end

				total += p2

				if total >= scaledConfig.InstantBiteInterval then
					total = 0

					if tick() - now >= scaledConfig.InstantBiteCooldown and random:NextNumber(0, 100) <= scaledConfig.InstantBiteChance then
						now = tick()
						object:AddProgress(scaledConfig.InstantBiteProgress)
						flashBite(scaledConfig.InstantBiteColor, 0.4, 0.5)
						remoteEvent:FireServer("DeathRoll")
					end
				end
			end))
		end)
	end
}
setmetatable(GaryGatorBites, module)
return GaryGatorBites