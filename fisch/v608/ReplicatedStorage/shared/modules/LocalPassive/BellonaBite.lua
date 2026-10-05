local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local violentSlash = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("violentSlash")
local BellonaBite = {}
BellonaBite.__index = BellonaBite

function BellonaBite:Morph(_, object2)
	self.lastBite = 0
	self.biteCount = 0
	self.biteActive = false
	self.barResizer = object2:CreateModifier("barSize", "multiply")
	self.random = object2:GetRandom(6)
	object2.OnFishMove:Connect(function()
		self:Update()
	end)
end

function BellonaBite:Update()
	if not self.current.active then
		return
	end

	local current = self.current
	local config = self.config
	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.lastBite + config.Cooldown or current.progress < (config.MinimumProgress or 0) then
		return
	end

	if math.max(config.BaseChance * (1 - self.biteCount * 0.1), config.BaseChance * 0.5) > self.random:NextNumber(
		0,
		100
	) then
		self.biteCount += 1
		self.lastBite = serverTimeNow
		self.biteActive = true
		current:AddProgress(current.progress * -config.ProgressLoss)
		fx:PlaySound(violentSlash, current.reel, true)
		task.spawn(function()
			local tweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

			for _ = 1, 6 do
				if not current.active then
					break
				end

				local rotation = math.random(-2, 2)
				local tween = TweenService:Create(current.reel_playerbar, tweenInfo, {
					Rotation = rotation
				})
				tween:Play()
				tween.Completed:Wait()
			end

			if current.active then
				TweenService:Create(current.reel_playerbar, TweenInfo.new(0.15), {
					Rotation = 0
				}):Play()
			end
		end)
		TweenService:Create(
			current.reel_progress.bar,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				BackgroundColor3 = config.Color
			}
		):Play()
		TweenService:Create(
			current.reel_playerbar,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				BackgroundColor3 = config.Color
			}
		):Play()
		local tweenInfo = TweenInfo.new(config.AnimTime, Enum.EasingStyle.Quart)
		current.logicTweens:CreateAndPlay(self.barResizer, tweenInfo, {
			Value = 1 - config.ControlReduce
		})
		current:DelayLogic(config.Duration, function()
			current.logicTweens:CreateAndPlay(self.barResizer, tweenInfo, {
				Value = 1
			})
			self.biteActive = false
		end)
	end
end

setmetatable(BellonaBite, module)
return BellonaBite