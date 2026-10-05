game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local GoliathSiphonophoreBehavior = {}
GoliathSiphonophoreBehavior.__index = GoliathSiphonophoreBehavior

function GoliathSiphonophoreBehavior:Morph(_, object2)
	self.lastFreeze = 0
	self.freezeCount = 0
	self.freezeActive = false
	self.freezeTween = nil
	self.freezeModifier = nil
	self.resilienceReducer = object2:CreateModifier("resilience", "multiply")
	self.random = object2:GetRandom(7)
	local minProgressEfficiency = self.config.MinProgressEfficiency

	if minProgressEfficiency then
		local modifier = object2:CreateModifier("progressefficiency", "add")
		modifier.Value = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyFloor()
			local v = object2.progressefficiency - modifier.Value
			modifier.Value = math.max(0, minProgressEfficiency - v)
		end

		modifier.Value = math.max(0, minProgressEfficiency - (object2.progressefficiency - modifier.Value))
		object2:Update(0)
		self.reelTrove:Add(object2.OnLogicStep:Connect(function()
			if object2.active and not self.freezeActive then
				applyFloor() -- equivalent call inferred; original call site unknown
			end
		end))
	end

	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function GoliathSiphonophoreBehavior:Update(object)
	local config = self.config

	if not object.active or self.freezeActive then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.lastFreeze + config.Cooldown then
		return
	end

	if math.max(config.BaseChance * (1 - self.freezeCount * 0.1), config.BaseChance * 0.5) > self.random:NextNumber(
		0,
		100
	) then
		self.freezeCount += 1
		self.lastFreeze = serverTimeNow
		self.freezeActive = true
		self.freezeModifier = object:CreateModifier("progressefficiency", "force_final")
		self.freezeModifier.Value = 0
		local number = self.random:NextNumber(config.ResilienceReduceMin, config.ResilienceReduceMax)
		self.resilienceReducer.Value = 1 - number

		if self.freezeTween then
			self.freezeTween:Cancel()
			self.freezeTween = nil
		end

		self.freezeTween = object.logicTweens:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				BackgroundColor3 = config.Color,
				BackgroundTransparency = 0.35
			}
		)
		self.freezeTween:Play()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.wave, object.reel, true)
		object:DelayLogic(config.FreezeDuration, function()
			if self.freezeModifier then
				self.freezeModifier:Destroy()
				self.freezeModifier = nil
			end

			if not object.active then
				return
			end

			self.resilienceReducer.Value = 1
			self.freezeActive = false

			if self.freezeTween then
				self.freezeTween:Cancel()
			end

			self.freezeTween = object.logicTweens:Create(
				object.reel_progress.bar,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0
				}
			)
			self.freezeTween:Play()
		end)
	end
end

setmetatable(GoliathSiphonophoreBehavior, module)
return GoliathSiphonophoreBehavior