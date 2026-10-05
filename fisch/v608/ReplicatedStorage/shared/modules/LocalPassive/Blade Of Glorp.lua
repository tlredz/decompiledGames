local BladeOfGlorp = {}
local ContentProvider = game:GetService("ContentProvider")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
ReplicatedStorage:WaitForChild("world")
local tweenInfo = TweenInfo.new(0.3)

function BladeOfGlorp.Laser(data)
	if not (data.reel and data.current.active) then
		return
	end

	local laserSound = script.LaserSound
	local playerbar = data.reel.playerbar
	local clone = script.Laser:Clone()
	clone.Size = UDim2.new(0, data.config.LaserSize, 50, 0)
	clone.Parent = playerbar
	laserSound.PlaybackSpeed = Random.new():NextNumber(0.95, 1.1)
	laserSound:Play()
	data.current.fx:SpawnShake(data.reel, 0.5, 3, 0.01, true)
	task.spawn(function()
		local glow = clone.Glow

		while clone.Parent do
			local color = Color3.fromRGB(221, 255, 171)

			if playerbar.BackgroundTransparency > 0 then
				color = Color3.fromRGB(72, 40, 34)
			end

			glow.BackgroundColor3 = color
			clone.BackgroundColor3 = color
			task.wait()
		end
	end)
	data.current:DelayLogic(data.config.BeamLife, function()
		data.current.logicTweens:CreateAndPlay(clone, TweenInfo.new(data.config.BeamLife), {
			Size = UDim2.new(0, 0, 50, 0)
		})
		local glow = clone.Glow
		local v = data.current.logicTweens:CreateAndPlay(glow, TweenInfo.new(3), {
			BackgroundTransparency = 1
		})
		v.Completed:Once(function()
			clone:Destroy()
		end)
		v:Play()
	end)
end

function BladeOfGlorp:Morph(instance, object)
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
	object.OnMinigameEnd:Once(function()
		if self.StartingToLaser then
			self.StartingToLaser = false
			object:AddCleanupDelay(1)
			script.SparedSound:Play()
			local clone = script.Spared:Clone()
			clone.Parent = self.current.reel
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				TextTransparency = 1
			}):Play()
		end
	end)
	task.spawn(function()
		legacyLocalPlayerData.fetch()
		object:WaitUntilReady()
		local random = object:GetRandom(5)
		self.StartingToLaser = false
		local playerbar = instance.playerbar
		local backgroundColor3 = playerbar.BackgroundColor3
		local _ = instance.Position
		local lastTime = tick()
		local modifier = object:CreateModifier("barSize", "multiply")
		local modifier2 = object:CreateModifier("resilience", "multiply")
		local localPlayer = game.Players.LocalPlayer
		local children = {}
		local flag = false
		local v = 1
		local v2 = true

		for _, child in workspace:WaitForChild("Pets"):GetChildren() do
			if child.Name == tostring(localPlayer.UserId) then
				table.insert(children, child)
			end
		end

		local function shootBeam()
			flag = true
			self.current:DelayLogic(self.config.BeamLife, function()
				self.current.logicTweens:CreateCallbackAndPlay(TweenInfo.new(self.config.LaserTime), 1, 0, function(p)
					v = p
				end)
			end)
			task.spawn(function()
				for _, v3 in children do
					local laser = v3:FindFirstChild("Laser")

					if not laser then
						continue
					end

					local v4 = laser
					self.current:DelayLogic(self.config.BeamLife, function()
						v4.Transparency = 0
						self.current.logicTweens:CreateAndPlay(v4, TweenInfo.new(self.config.BeamLife), {
							Transparency = 1
						})
					end)
				end
			end)
			modifier.Value = 0.3333333333333333
			self.current.logicTweens:CreateAndPlay(playerbar, TweenInfo.new(self.config.LaserTime), {
				BackgroundColor3 = backgroundColor3
			})
			self.current.logicTweens:CreateAndPlay(modifier, TweenInfo.new(self.config.LaserTime), {
				Value = 1
			})
			task.spawn(self.Laser, self)
			self.current:DelayLogic(self.config.BeamLife * 2, function()
				if object.onbar then
					if playerbar:FindFirstChild("Shine") and playerbar.Shine:FindFirstChild("UIGradient") then
						local uIGradient = playerbar.Shine.UIGradient
						uIGradient.Offset = Vector2.new(0, 1)
						self.current.logicTweens:CreateAndPlay(uIGradient, TweenInfo.new(0.5), {
							Offset = Vector2.new(0, -1)
						}):Play()
					end

					object:AddProgress(10)
					script.Perfect:Play()
				end
			end)
			self.current:DelayLogic(self.config.LaserTime, function()
				flag = false
			end)
		end

		self.reelTrove:Add(self.current.OnLogicStep:Connect(function()
			if not (instance.Parent and self.current and self.current.active) then
				return
			end

			modifier2.Value = object.onbar and flag and 2 or 1

			if flag then
				object:AddProgress((object.onbar and 0.25 or -0.25) * v)
				local hit = script.Hit

				if not object.onbar then
					hit = script.Damage
				end

				if tick() - lastTime >= (object.onbar and 0.075 or 0.15) then
					lastTime = tick()
					hit.Volume = math.clamp((object.onbar and 0.75 or 2) * v, 0.1, 2)
					hit:Play()
				end
			end

			if v2 and not flag then
				v2 = false

				if random:NextInteger(1, self.config.LaserChance) == 1 then
					self.StartingToLaser = true
					local clone = script.BeamWarning:Clone()
					clone.ImageTransparency = 1
					clone.Parent = self.current.reel
					task.spawn(function()
						for _ = 1, self.config.WarningCount do
							if not self.current.active then
								break
							end

							script.Warning:Play()
							clone.ImageTransparency = 0
							self.current.logicTweens:CreateAndPlay(clone, tweenInfo, {
								ImageTransparency = 1
							})
							self.current:WaitLogic(tweenInfo.Time)
						end

						clone:Destroy()
						self.current:WaitLogic(0.1)

						if not self.current.active then
							return
						end

						self.StartingToLaser = false
						shootBeam()
					end)
				end

				self.current:DelayLogic(2, function()
					v2 = true
				end)
			end
		end))
	end)
end

setmetatable(BladeOfGlorp, module)
return BladeOfGlorp