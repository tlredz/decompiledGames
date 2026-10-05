local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local MossjawBehavior = {}
MossjawBehavior.__index = MossjawBehavior
MossjawBehavior.MorphSpear = true
MossjawBehavior.MorphHarpoon = true

function MossjawBehavior:Morph(_, object2)
	self.lastSnap = 0
	self.snapCount = 0
	self.snapActive = false
	self.snapTween = nil
	local accelMultiply

	if object2.type == "reel" then
		accelMultiply = object2:CreateModifier("accel", "multiply")
	elseif object2.type == "stab" then
		accelMultiply = object2:CreateModifier("piercing", "multiply")
	end

	self.accelMultiply = accelMultiply
	self.random = object2:GetRandom(5)
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)

	if object2.type == "harpoon" then
		object2.core.pullButtons.OnButtonAdd:Connect(function(state)
			if self.snapActive then
				state.requiredClicks *= 2
				state.clicksRemaining *= 2
				state.progressMultiplier /= 2
			end
		end)
	end
end

function MossjawBehavior:Update(object)
	if not object.active then
		return
	end

	local config = self.config
	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.lastSnap + config.Cooldown then
		return
	end

	if math.max(config.BaseChance * (1 - self.snapCount * 0.1), config.BaseChance * 0.5) > self.random:NextNumber(
		0,
		100
	) then
		self.snapCount += 1
		self.lastSnap = serverTimeNow
		self.snapActive = true
		object:AddProgress(-config.ProgressLoss)

		if object.reel_playerbar then
			TweenService:Create(
				object.reel_playerbar,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = config.Color
				}
			):Play()
		end

		if self.snapTween then
			self.snapTween:Cancel()
		end

		self.snapTween = TweenService:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
			{
				BackgroundColor3 = config.Color
			}
		)
		self.snapTween:Play()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.snap, object.reel, true)

		if self.accelMultiply then
			self.accelMultiply.Value = config.AccelMultiply
		end

		object:DelayLogic(config.Duration, function()
			if not object.active then
				return
			end

			if self.accelMultiply then
				self.accelMultiply.Value = 1
			end

			self.snapActive = false

			if self.snapTween then
				self.snapTween:Cancel()
				self.snapTween = TweenService:Create(
					object.reel_progress.bar,
					TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					}
				)
				self.snapTween:Play()
			end
		end)
	end
end

setmetatable(MossjawBehavior, module)
return MossjawBehavior