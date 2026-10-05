local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local world = ReplicatedStorage:WaitForChild("world")
local AstraeusSerenade = {
	Morph = function(p, data, object)
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
		task.spawn(function()
			local random = object:GetRandom(5)
			local _ = data.playerbar
			local fish = data.fish
			local _ = data.Position
			local clone = script.Beam:Clone()
			clone.Parent = fish.icon
			local clone2 = script.Star:Clone()

			if object.rodName == "Astraeus Serenade" then
				clone2.Parent = data.playerbar
			end

			object:WaitUntilReady()
			object.OnFishEnterBar:Connect(function()
				clone2.ImageTransparency = 0
			end)
			object.OnFishExitBar:Connect(function()
				clone2.ImageTransparency = 0.5
			end)

			if random:NextNumber(0, 100) < p.config.InstantCompletionChance then
				object:AddProgress(100)
				clone2.ImageColor3 = Color3.fromRGB(216, 197, 91)
				TweenService:Create(clone2, TweenInfo.new(3), {
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			end

			local flag = false
			TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local v = world.weather.meteorological.Value == "Starfall"

			local function StarBeam()
				if flag then
					return
				end

				flag = true
				local count = 0

				local function spawnStar(duration: number)
					local clone3 = script.BeamStar:Clone()
					clone3.Rotation = -360
					clone3.Position = UDim2.fromScale(0.5, 0)
					clone3.Parent = clone
					local v2 = object.logicTweens:Create(
						clone3,
						TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Rotation = 360,
							Position = UDim2.fromScale(0.5, 1)
						}
					)
					v2.Completed:Once(function()
						clone3:Destroy()
						script.ShineSound.PlaybackSpeed = count / 10 + 2
						fx:PlaySound(script.ShineSound, script)
						object:AddProgress(p.config.ProgressPerStar)
						object.fx:SpawnShake(data, 0.3, 2.5, 0.015, false)
					end)
					v2:Play()
				end

				task.spawn(function()
					while flag and object.active do
						local v2 = count / (v and p.config.StarBeamSpeedFactor_Starfall or p.config.StarBeamSpeedFactor_Default)
						local v3 = math.clamp(p.config.BaseStarBeamSpeed - v2, p.config.MinStarBeamSpeed, 1e999)
						spawnStar(v3)
						object:WaitLogic(v3)
						count += 1
					end
				end)
				object:WaitLogic(p.config.StarBeamDuration)
				flag = false
			end

			local v2 = true

			while object.active do
				if not (v2 and p.config.AlwaysImmediate) then
					object:WaitLogic(random:NextNumber(p.config.MinStarBeamInterval, p.config.MaxStarBeamInterval))
				end

				v2 = false

				if not object.active then
					break
				end

				StarBeam()
			end
		end)
	end
}
setmetatable(AstraeusSerenade, module)
return AstraeusSerenade