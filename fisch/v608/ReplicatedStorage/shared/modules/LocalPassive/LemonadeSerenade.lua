local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
local random = Random.new()
local LemonadeSerenade = {
	EndCharge = function(self)
		local currentCharge = math.floor(self.currentCharge)

		if self.config.PreservePartialCharge then
			self.currentCharge %= 1
		else
			self.currentCharge = 0
		end

		if currentCharge <= 0 then
			return
		end

		for i = 1, currentCharge do
			local v = i
			self.current:DelayLogic((i - 1) * 0.1, function()
				if not self.current then
					return
				end

				local maid = self.reelTrove:Extend()
				local total = 0
				local number = random:NextNumber(
					self.current.barPosition - self.current.barSize / 2,
					self.current.barPosition + self.current.barSize / 2
				)
				local number2 = self.random:NextNumber(0.1, 0.9)
				local v2 = maid:Add(script.juiceDrop:Clone())
				v2.Position = UDim2.fromScale(number, 1)

				if self.config.OverrideDropletIcon then
					v2.Image = self.config.OverrideDropletIcon
				end

				v2.Parent = self.container
				maid:Add(self.current.OnLogicStep:Connect(function(p: number)
					total += p
					local v3 = math.clamp(total / self.config.DropAnimTime, 0, 1)
					local v4 = math.sin(v3 * 3.141592653589793)
					v2.Position = UDim2.fromScale(math.lerp(number, number2, v3), 1 - v4)
					v2.Rotation = math.lerp(0, number < number2 and 180 or -180, v3)
					v2.Size = UDim2.fromScale(math.lerp(0.015, 0.05, v4), (math.lerp(0.2, 0.05, v4)))
				end))
				self.current:DelayLogic(self.config.DropAnimTime, function()
					self.reelTrove:Remove(maid)

					if self.current then
						if self.current:IsInBar(number2, 0.015) then
							fx:PlaySound(script.hit, self.reel, v * 0.1 + 0.8)
							self.current:AddProgress(self.config.DropsProgressOnBar)
							self.dropsCaught += 1
						else
							self.current:AddProgress(self.config.DropsProgressOffBar)
						end
					end
				end)
				fx:PlaySound(script.launch, self.reel, v * 0.1 + 0.8)
			end)
		end
	end,
	Morph = function(self, p, object2)
		object2:Preload(script:GetChildren())
		object2.core.ui.InputGuide_Enabled = false
		object2.core.ui.OnBarEffects_Enabled = false
		self.random = object2:GetRandom(33)
		self.currentCharge = 0
		self.isCharging = false
		self.dropCharge = script.dropCharge:Clone()
		self.dropCharge.Parent = object2.reel_playerbar
		self.currentIcons = table.create(self.config.MaxDrops)
		self.iconStates = table.create(self.config.MaxDrops, false)
		local modifier = object2:CreateModifier("barSize", "add")
		local modifier2 = object2:CreateModifier("barMoveSpeed", "multiply")
		local modifier3 = object2:CreateModifier("accel", "multiply")
		self.dropsCaught = 0
		self.reelTrove:Add(object2.BuildEndingData:Bind(function(p2)
			p2.LemonadeSerenade_DropsCaught = self.dropsCaught
			return p2
		end))
		local v = 0

		for i = 1, self.config.MaxDrops do
			local clone = script.dropIcon:Clone()
			clone.LayoutOrder = i
			clone.UIScale.Scale = 0
			clone.UIGradient.Offset = Vector2.zero

			if self.config.OverrideDropletIcon then
				clone.Image = self.config.OverrideDropletIcon
			end

			clone.Parent = self.dropCharge
			self.currentIcons[i] = clone
		end

		self.container = script.juiceContainer:Clone()
		self.container.Parent = object2.reel_bar
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p2)
			if not object2.active or object2.isPaused then
				return
			end

			local currentCharge = self.currentCharge

			if self.isCharging then
				self.currentCharge = math.clamp(
					self.currentCharge + self.config.DropsPerSecond * p2,
					0,
					self.config.MaxDrops
				)
			elseif self.config.PreservePartialCharge then
				self.currentCharge %= 1
			else
				self.currentCharge = 0
			end

			for k, currentIcon in self.currentIcons do
				local currentCharge2 = self.currentCharge
				local v2 = k - 1 < currentCharge2

				if self.iconStates[k] ~= v2 then
					object2.logicTweens:Create(currentIcon.UIScale, tweenInfo, {
						Scale = v2 and 1 or 0
					}):Play()
					self.iconStates[k] = v2
				end

				local imageColor

				if k <= self.currentCharge then
					imageColor = Color3.fromRGB(255, 255, 255)
				else
					imageColor = Color3.fromRGB(153, 153, 153)
				end

				currentIcon.ImageColor3 = imageColor

				if v2 or self.config.PreservePartialCharge then
					currentIcon.UIGradient.Offset = Vector2.new(0, -(self.currentCharge - (k - 1)))
				end
			end

			if math.floor(self.currentCharge) > math.floor(currentCharge) and self.currentCharge >= 1 then
				fx:PlaySound(script.ready, p, 0.8 + (self.currentCharge - 1) * 0.1)
			end

			local v2 = modifier
			local smoothDamp, v3 = TweenService:SmoothDamp(
				modifier.Value,
				self.currentCharge / self.config.MaxDrops * -self.config.MaxControlLoss,
				v,
				0.25,
				nil,
				p2
			)
			v2.Value = smoothDamp
			v = v3
			local onbar = self.isCharging and self.current.onbar

			if onbar then
				if self.current.fishPosition <= self.current.barPosition then
					onbar = self.current.core.fish.CurrentTarget <= self.current.barPosition
				else
					onbar = false
				end
			end

			modifier2.Value = not onbar and 1 or self.config.ChargingAccel
			modifier3.Value = onbar and 3 or 1
		end))
		task.spawn(function()
			object2:WaitUntilReady()

			if object2.data.LemonsFalling then
				object2:AddProgress(100)
			end

			self.reelTrove:Add(object2.OnBarDirectionChange:Connect(function(p2)
				if p2 == 1 then
					self.isCharging = true
					return
				end

				if self.isCharging then
					self:EndCharge()
				end

				self.isCharging = false

				if not self.config.PreservePartialCharge then
					self.currentCharge = 0
					return
				end

				self.currentCharge %= 1
			end))
		end)
	end
}
setmetatable(LemonadeSerenade, module)
return LemonadeSerenade