local Noiseform = {}
game:GetService("ContentProvider")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local fx = require(ReplicatedStorage.shared.modules.fx)
ReplicatedStorage:WaitForChild("world")
local tweenInfo = TweenInfo.new(0.3)
local v = { Color3.fromRGB(38, 255, 128), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0) }

function Noiseform:Laser(p: number, color: Color3?)
	if not (self.reel and self.current and self.current.active) then
		return
	end

	local laserSound = script.LaserSound
	local playerbar = self.reel.playerbar
	local reel_bar = self.current.reel_bar
	local clone = script.Laser:Clone()
	clone.Size = UDim2.new(0, self.config.LaserSize, 50, 0)
	clone.Position = UDim2.new(p, 0, 0, 0)
	clone.Parent = reel_bar
	laserSound.PlaybackSpeed = Random.new():NextNumber(0.95, 1.1)
	laserSound:Play()
	self.current.fx:SpawnShake(self.reel, 0.5, 3, 0.01, true)
	task.spawn(function()
		local glow = clone.Glow

		while clone.Parent do
			local color2 = color or Color3.fromRGB(221, 255, 171)

			if not color and playerbar.BackgroundTransparency > 0 then
				color2 = Color3.fromRGB(72, 40, 34)
			end

			glow.BackgroundColor3 = color2
			clone.BackgroundColor3 = color2
			task.wait()
		end
	end)
	self.current:DelayLogic(self.config.BeamLife, function()
		self.current.logicTweens:CreateAndPlay(clone, TweenInfo.new(self.config.BeamLife), {
			Size = UDim2.new(0, 0, 50, 0)
		})
		local glow = clone.Glow
		local v2 = self.current.logicTweens:CreateAndPlay(glow, TweenInfo.new(3), {
			BackgroundTransparency = 1
		})
		v2.Completed:Once(function()
			clone:Destroy()
		end)
		v2:Play()
	end)
end

local function beamZone(reel_bar, p: number, zoneWidth: number, backgroundColor: Color3)
	local clone = script.beamZone:Clone()
	clone.Size = UDim2.new(zoneWidth, 0, 1, 0)
	clone.Position = UDim2.new(p, 0, 0, 0)
	clone.BackgroundColor3 = backgroundColor
	clone.Parent = reel_bar
	return clone
end

function Noiseform:Morph(instance, object2)
	object2:Preload({ script })
	local random = object2:GetRandom(5)
	local neverWrong = true
	local now = 0
	object2.BuildEndingData:Bind(function(p)
		p.neverWrong = neverWrong
		return p
	end)
	local rhytmicActive = object2.data.RhytmicActive
	local v3 = self.reelTrove:Add(script.RhythmicOverlay:Clone())
	v3.BackgroundTransparency = 1
	v3.Parent = object2.reel
	object2.OnMinigameEnd:Once(function()
		if v3 and v3.BackgroundTransparency < 1 then
			TweenService:Create(v3, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1
			}):Play()
		end

		if self.StartingToLaser then
			self.StartingToLaser = false
			object2:AddCleanupDelay(1)
			script.SparedSound:Play()
			local clone = script.Spared:Clone()
			clone.Parent = self.current.reel
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				TextTransparency = 1
			}):Play()
		end
	end)

	if rhytmicActive then
		script.RhythmicActive:Play()
		v3.BackgroundColor3 = Color3.new(255, 255, 255)
		v3.BackgroundTransparency = 0
		TweenService:Create(v3, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			BackgroundColor3 = Color3.fromRGB(0, 255, 8),
			BackgroundTransparency = 0.25
		}):Play()
	end

	task.spawn(function()
		legacyLocalPlayerData.fetch()
		object2:WaitUntilReady()
		self.StartingToLaser = false
		local playerbar = instance.playerbar
		local fish = instance.fish
		local _ = playerbar.BackgroundColor3
		local _ = instance.Position
		local v4 = true
		local v5 = false
		local v6 = 1
		tick()
		local modifier = object2:CreateModifier("barSize", "multiply")
		local modifier2 = object2:CreateModifier("resilience", "multiply")
		local modifier3 = object2:CreateModifier("progressLossMultiplier", "add")
		local clone = script.Beam:Clone()
		clone.Parent = fish.icon
		task.spawn(function()
			local flag = false

			local function spawnStar(duration: number, count: number)
				local starImage = self.config.StarImage or "BeamStar"
				local clone2 = script[starImage]:Clone()
				clone2.Rotation = -360
				clone2.Position = UDim2.fromScale(0.5, 0)
				clone2.Parent = clone
				local v7 = self.current.logicTweens:Create(
					clone2,
					TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Rotation = 360,
						Position = UDim2.fromScale(0.5, 1)
					}
				)
				v7.Completed:Once(function()
					clone2:Destroy()
					script.ShineSound.PlaybackSpeed = count / 10 + 2
					fx:PlaySound(script.ShineSound, script)
					object2:AddProgress(self.config.ProgressPerStar)
					object2.fx:SpawnShake(instance, 0.3, 2.5, 0.015, false)
				end)
				v7:Play()
			end

			local function StarBeam()
				if flag then
					return
				end

				flag = true
				task.spawn(function()
					local count = 0

					while flag and object2.active do
						local v7 = count / self.config.StarBeamSpeedFactor
						local v8 = math.clamp(self.config.BaseStarBeamSpeed - v7, 0.1, 1e999)
						spawnStar(v8, count)
						object2:WaitLogic(v8)
						count += 1
					end
				end)
				object2:WaitLogic(self.config.StarBeamDuration)
				flag = false
			end

			while object2.active do
				object2:WaitLogic(random:NextNumber(self.config.MinStarBeamInterval, self.config.MaxStarBeamInterval))

				if not object2.active then
					break
				end

				if flag then
					continue
				end

				flag = true
				task.spawn(function()
					local count = 0

					while flag and object2.active do
						local v7 = count / self.config.StarBeamSpeedFactor
						local v8 = math.clamp(self.config.BaseStarBeamSpeed - v7, 0.1, 1e999)
						spawnStar(v8, count)
						object2:WaitLogic(v8)
						count += 1
					end
				end)
				object2:WaitLogic(self.config.StarBeamDuration)
				flag = false
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function randomZonePosition()
			return 0.1 + random:NextNumber() * 0.8
		end

		local function randomZones()
			local v7 = randomZonePosition() -- equivalent call inferred; original call site unknown
			local count = 0
			local v8

			repeat
				v8 = 0.1 + random:NextNumber() * 0.8
				count += 1
			until math.abs(v7 - v8) >= 0.15 or count > 15

			local count2 = 0
			local v9

			repeat
				v9 = 0.1 + random:NextNumber() * 0.8
				count2 += 1
			until math.abs(v7 - v9) >= 0.15 and math.abs(v8 - v9) >= 0.15 or count2 > 15

			return v7, v8, v9
		end

		local function shootBeam(p: number, instance2)
			v5 = true
			object2:DelayLogic(self.config.BeamLife, function()
				self.current.logicTweens:CreateCallbackAndPlay(TweenInfo.new(self.config.LaserTime), 1, 0, function(p2)
					v6 = p2
				end)
			end)
			task.spawn(function()
				self:Laser(p)
			end)
			object2:DelayLogic(self.config.BeamLife, function()
				if instance2 and instance2.Parent then
					instance2:Destroy()
				end

				if not (self.current and self.current.active) then
					return
				end

				if object2:IsInBar(p, self.config.ZoneWidth) then
					if playerbar:FindFirstChild("Shine") and playerbar.Shine:FindFirstChild("UIGradient") then
						local uIGradient = playerbar.Shine.UIGradient
						uIGradient.Offset = Vector2.new(0, 1)
						TweenService:Create(uIGradient, TweenInfo.new(0.5), {
							Offset = Vector2.new(0, -1)
						}):Play()
					end

					object2:AddProgress(self.config.BeamProgress)
					script.Perfect:Play()
				end
			end)
			object2:DelayLogic(self.config.LaserTime, function()
				v5 = false
			end)
		end

		local function shootFakeBeam(p: number, color: Color3, p2: number, instance2)
			if self.current and self.current.active then
				task.spawn(function()
					self:Laser(p, color)
				end)
				object2:DelayLogic(self.config.BeamLife, function()
					if instance2 and instance2.Parent then
						instance2:Destroy()
					end

					if not (self.current and self.current.active) then
						return
					end

					local isInBar = object2:IsInBar(p2, self.config.ZoneWidth)

					if object2:IsInBar(p, self.config.ZoneWidth) and not isInBar then
						neverWrong = false

						if rhytmicActive then
							rhytmicActive = false
							v3.BackgroundColor3 = Color3.fromRGB(255, 0, 17)
							TweenService:Create(v3, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
								BackgroundTransparency = 1
							}):Play()
						end

						modifier.Value = math.max(self.config.MinControl, modifier.Value - self.config.ControlReduction)

						if modifier.Value < 0 and self.current.active then
							object2:EndMinigame(false)
						end
					end
				end)
			end
		end

		self.reelTrove:Add(object2.OnLogicStep:Connect(function()
			if not (instance.Parent and self.current and object2.active) then
				return
			end

			modifier2.Value = object2.onbar and v5 and 2 or 1

			if v4 and not v5 and tick() - now >= self.config.BeamCooldown then
				v4 = false
				now = tick()

				if random:NextInteger(1, self.config.LaserChance) == 1 then
					self.StartingToLaser = true
					task.spawn(function()
						local integer = random:NextInteger(1, #v)
						local imageColor = v[integer]
						local clone2 = script["BeamWarning" .. integer]:Clone()
						clone2.ImageTransparency = 1
						clone2.Parent = object2.reel

						for _ = 1, self.config.WarningCount do
							if not object2.active then
								break
							end

							script.Warning:Play()
							clone2.ImageColor3 = imageColor
							clone2.ImageTransparency = 0
							object2.logicTweens:Create(clone2, tweenInfo, {
								ImageTransparency = 1
							}):Play()
							object2:WaitLogic(tweenInfo.Time)
						end

						local v8, v9, v10 = randomZones()
						local v11 = {}
						local v12 = 1
						local v13 = { v8, v9, v10 }

						for i = 1, #v do
							if i == integer then
								v11[i] = v[integer]
							else
								while v12 == integer do
									v12 += 1
								end

								v11[i] = v[v12]
								v12 += 1
							end
						end

						local v14 = {}

						for i = 1, #v do
							local v15 = beamZone(object2.reel_bar, v13[i], self.config.ZoneWidth, v11[i])
							local symbol = v15:FindFirstChild("Symbol")

							if symbol then
								symbol.Image = script["BeamWarning" .. i].Image
							end

							v14[i] = v15
						end

						modifier3.Value = self.config.ProgressLossReduction
						object2:WaitLogic(2)
						clone2:Destroy()
						object2:WaitLogic(0.1)

						if self.current and object2.active then
							self.StartingToLaser = false

							for i = 1, #v do
								if i == integer then
									modifier3.Value = 1
									shootBeam(v13[i], v14[i])
								else
									shootFakeBeam(v13[i], v11[i], v13[integer], v14[i])
								end
							end
						else
							self.StartingToLaser = false

							for _, v15 in v14 do
								if v15 and v15.Parent then
									v15:Destroy()
								end
							end
						end
					end)
				end

				object2:DelayLogic(2, function()
					v4 = true
				end)
			end
		end))
	end)
end

setmetatable(Noiseform, module)
return Noiseform