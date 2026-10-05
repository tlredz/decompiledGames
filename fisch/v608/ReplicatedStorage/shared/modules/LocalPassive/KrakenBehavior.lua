local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
local KrakenBehavior = {}
KrakenBehavior.__index = KrakenBehavior
KrakenBehavior.MorphSpear = true
KrakenBehavior.MorphHarpoon = true

function KrakenBehavior:Morph(_, object2)
	self.tentacleCooldown = 6
	self.lastTentacle = 0
	self.tentacleCount = 0
	self.BASE_CHANCE = 0.11
	self.isFlinging = false
	self.progressValue = object2:CreateModifier("progress", "add")
	self.random = object2:GetRandom(6)
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function KrakenBehavior:Update(object)
	if not object.active then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.lastTentacle + self.tentacleCooldown then
		return
	end

	if math.max(self.config.BaseChance * (1 - self.tentacleCount * 0.1), self.config.BaseChance * 0.5) > self.random:NextNumber(
		0,
		100
	) and not self.isFlinging then
		self.tentacleCount += 1
		self.lastTentacle = serverTimeNow
		self.isFlinging = true
		local v = math.random() < 0.5
		local v2 = v and -1 or 1

		if object.core.rod then
			object.core.rod:LockInput(self.config.LockTime, v2)
			object.core.rod:ApplyImpulse(v2 * self.config.FlingPower)
		end

		local v3 = object.logicTweens:Create(
			self.progressValue,
			TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Value = self.progressValue.Value - self.config.ProgressLoss
			}
		)
		local v4 = object.logicTweens:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
			{
				BackgroundColor3 = Color3.fromRGB(19, 0, 33)
			}
		)
		v3:Play()
		v4:Play()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.krakenhit, object.reel, true)

		if object.type == "harpoon" then
			object:TweenModifier(
				"movementfactor",
				"multiply",
				0.3333333333333333,
				1,
				TweenInfo.new(self.config.LockTime)
			)
		else
			local frame = Instance.new("Frame")
			frame.Name = "KrakenTentacleCue"
			frame.Size = UDim2.fromScale(0.12, 1)
			frame.Position = v and UDim2.fromScale(0, 0) or UDim2.fromScale(0.88, 0)
			frame.BackgroundColor3 = self.config.Color
			frame.BackgroundTransparency = 0.7
			frame.Parent = object.reel_playerbar
			local v5 = object.logicTweens:Create(
				frame,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					BackgroundTransparency = 0.2
				}
			)
			local v6 = object.logicTweens:Create(
				frame,
				TweenInfo.new(2.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundTransparency = 1
				}
			)
			v5:Play()
			v5.Completed:Connect(function()
				v6:Play()
			end)
		end

		object:DelayLogic(self.config.LockTime, function()
			self.isFlinging = false
		end)
	end
end

setmetatable(KrakenBehavior, module)
return KrakenBehavior