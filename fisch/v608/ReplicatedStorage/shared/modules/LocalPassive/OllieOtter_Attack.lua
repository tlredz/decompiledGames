local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local remoteEvent = Net:RemoteEvent("Companion/RequestMood")
local remoteEvent2 = Net:RemoteEvent("Companion/RequestMoodStop")
local OllieOtterAttack = {
	MorphSpear = true,
	Morph = function(p, _, object)
		local scaledConfig = CompanionController.GetScaledConfig(p.config)
		local random = object:GetRandom(23)
		local v = nil

		local function flashBite(flashColor: Color3, duration: number, duration2: number)
			TweenService:Create(
				object.reel_playerbar,
				TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = flashColor
				}
			):Play()

			if v then
				v:Cancel()
			end

			local tween = TweenService:Create(
				object.reel_progress.bar,
				TweenInfo.new(duration2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					BackgroundColor3 = flashColor
				}
			)
			v = tween
			tween:Play()
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.ollieOtter, object.reel, true)
		end

		task.spawn(function()
			object:WaitUntilReady()
			local weight = object.fish.Weight

			if typeof(weight) ~= "number" then
				local v2 = fish[object.fish.Name]
				local weightPool = v2 and v2.WeightPool

				if weightPool then
					weight = weightPool[1] + (weightPool[2] - weightPool[1]) / 2
				else
					weight = scaledConfig.SmallWeightReference
				end
			end

			local v2

			if weight <= scaledConfig.SmallWeightReference then
				v2 = scaledConfig.SmallFishChanceMult
			else
				v2 = 1 + (scaledConfig.SmallFishChanceMult - 1) * (scaledConfig.SmallWeightReference / weight)
			end

			local v3 = math.min(scaledConfig.TriggerChance * v2, 100)
			local total = 0
			local number = random:NextNumber(scaledConfig.IntervalMin, scaledConfig.IntervalMax)
			p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
				if not object.active then
					return
				end

				total += p2

				if total < number then
					return
				end

				total = 0
				number = random:NextNumber(scaledConfig.IntervalMin, scaledConfig.IntervalMax)

				if v3 < random:NextNumber(0, 100) then
					return
				end

				object:AddProgress(scaledConfig.AttackProgress)
				flashBite(scaledConfig.FlashColor, 0.25, 0.3)

				if object.data.OllieTreasure then
					return
				end

				remoteEvent2:FireServer()
				remoteEvent:FireServer("Snap")
			end))
		end)
	end
}
setmetatable(OllieOtterAttack, module)
return OllieOtterAttack