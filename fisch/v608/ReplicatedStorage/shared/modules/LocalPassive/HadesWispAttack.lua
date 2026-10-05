game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local color = Color3.fromRGB(255, 60, 60)
local wisp = script:WaitForChild("Wisp")
local HadesWispAttack = {
	SpawnWisp = function(self)
		local current = self.current

		if not (current and current.active) then
			return
		end

		local reel_bar = current.reel_bar
		local reel = current.reel

		if not (reel_bar and reel) then
			return
		end

		local v = current:GetRandom(math.floor((os.clock())) % 1000 + 7):NextNumber() > 0.5
		local absolutePosition = reel_bar.AbsolutePosition
		local absoluteSize = reel_bar.AbsoluteSize
		local v2 = absolutePosition.Y + absoluteSize.Y / 2
		local X = reel.AbsoluteSize.X
		local v3 = v and -40 or X + 40
		local v4 = v and X + 40 or -40
		local clone = wisp:Clone()
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Position = UDim2.fromOffset(v3, v2)
		clone.Parent = reel
		local imageColor3sByImage = {}

		for _, image in ipairs(clone:GetDescendants()) do
			if image:IsA("ImageLabel") then
				imageColor3sByImage[image] = image.ImageColor3
			end
		end

		self.reelTrove:Add(clone)
		local v5 = false
		local lastTime = os.clock()
		local wispSpeed = self.config.WispSpeed or 0.4

		local function getPlayerBarScreenBounds()
			local reel_playerbar = current.reel_playerbar

			if not reel_playerbar then
				return 0, 0
			end

			local absolutePosition2 = reel_playerbar.AbsolutePosition
			local absoluteSize2 = reel_playerbar.AbsoluteSize
			return absolutePosition2.X, absolutePosition2.X + absoluteSize2.X
		end

		local onLogicStepConnection = nil
		onLogicStepConnection = current.OnLogicStep:Connect(function()
			if current.active and clone.Parent then
				local v6 = os.clock() - lastTime
				local v7 = math.clamp(v6 / wispSpeed, 0, 1)
				local v8 = v3 + (v4 - v3) * v7
				local v9 = math.sin(v6 * 20) * 3
				clone.Position = UDim2.fromOffset(v8, v2 + v9)

				if not v5 then
					local reel_playerbar = current.reel_playerbar
					local X2, v10

					if reel_playerbar then
						local absolutePosition2 = reel_playerbar.AbsolutePosition
						local absoluteSize2 = reel_playerbar.AbsoluteSize
						X2 = absolutePosition2.X
						v10 = absolutePosition2.X + absoluteSize2.X
					else
						X2 = 0
						v10 = 0
					end

					if X2 <= v8 and v8 <= v10 then
						v5 = true
						current:AddProgress(-self.config.ProgressLoss)
						local modifier = current:CreateModifier("progressefficiency", "multiply")
						modifier.Value = self.config.SpeedPenalty
						current:DelayLogic(self.config.SpeedPenaltyDuration, function()
							modifier:Destroy()
						end)
						current.fx:SpawnShake(reel_bar, 0.15, 0.4, 0.012, false)

						for k, imageColor in pairs(imageColor3sByImage) do
							if not k.Parent then
								continue
							end

							k.ImageColor3 = color
							current.logicTweens:Create(k, TweenInfo.new(0.2), {
								ImageColor3 = imageColor
							}):Play()
						end

						if current.reel_progress and current.reel_progress:FindFirstChild("bar") then
							current.logicTweens:Create(
								current.reel_progress.bar,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
								{
									BackgroundColor3 = Color3.fromRGB(100, 255, 140)
								}
							):Play()
						end

						local attack = script:FindFirstChild("Attack")

						if attack then
							fx:PlaySound(attack, script, true)
						end
					end
				end

				if v7 >= 1 then
					onLogicStepConnection:Disconnect()
					clone:Destroy()
				end
			else
				onLogicStepConnection:Disconnect()
				clone:Destroy()
			end
		end)
		self.reelTrove:Add(onLogicStepConnection)
	end,
	Morph = function(self, _, object2)
		local random = object2:GetRandom(3)
		local minInterval = self.config.MinInterval or 4.5
		local maxInterval = self.config.MaxInterval or 9
		local total = 0
		local v = 2 + random:NextNumber(minInterval, maxInterval)
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
			if not object2.active then
				return
			end

			total += p

			if v <= total then
				total = 0
				v = random:NextNumber(minInterval, maxInterval)
				self:SpawnWisp()
			end
		end))
	end
}
setmetatable(HadesWispAttack, module)
return HadesWispAttack