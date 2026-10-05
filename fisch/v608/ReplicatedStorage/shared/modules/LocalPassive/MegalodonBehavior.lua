local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
local MegalodonBehavior = {}
MegalodonBehavior.__index = MegalodonBehavior
MegalodonBehavior.MorphSpear = true
MegalodonBehavior.MorphHarpoon = true

function MegalodonBehavior:Morph(_, object2)
	self.lastRampage = 0
	self.rampageCount = 0
	local barResizer

	if object2.type ~= "harpoon" then
		barResizer = object2:CreateModifier(object2.type == "reel" and "barSize" or "handling", "multiply")
	end

	self.barResizer = barResizer
	self.random = object2:GetRandom(6)
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function MegalodonBehavior:Update(object)
	if not object.active then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.lastRampage + self.config.Cooldown or object.progress < (self.config.MinimumProgress or 0) then
		return
	end

	if math.max(self.config.BaseChance * (1 - self.rampageCount * 0.1), self.config.BaseChance * 0.5) > self.random:NextNumber(
		0,
		100
	) then
		self.rampageCount += 1
		self.lastRampage = serverTimeNow
		object:AddProgress(object.progress * -self.config.ProgressLoss)
		self.reelTrove:Add(fx:ShakeScreen(Players.LocalPlayer, 4, self.config.Duration), "Stop")
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui["break"], object.reel, true)
		object.logicTweens:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				BackgroundColor3 = self.config.Color
			}
		):Play()
		local tweenInfo = TweenInfo.new(self.config.AnimTime, Enum.EasingStyle.Quart)

		if self.barResizer then
			object.logicTweens:Create(self.barResizer, tweenInfo, {
				Value = 1 - self.config.ControlReduce
			}):Play()
			object:DelayLogic(self.config.Duration, function()
				if not self.barResizer then
					return
				end

				object.logicTweens:Create(self.barResizer, tweenInfo, {
					Value = 1
				}):Play()
			end)
		elseif object.type == "harpoon" then
			local v = math.max(self.config.ControlReduce // 0.1, 1)

			for _ = 1, v do
				local button = object.core.pullButtons:SpawnButton()
				button.progressMultiplier /= v
				button:ModifyDespawnTime("add", 3)
				object:WaitLogic(1 / v)
			end
		end
	end
end

setmetatable(MegalodonBehavior, module)
return MegalodonBehavior