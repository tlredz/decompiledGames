local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local StormyLightningController = require(ReplicatedStorage.client.legacyControllers.StormyLightningController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local ThundermaulPassive = {}
ThundermaulPassive.__index = ThundermaulPassive
local world = ReplicatedStorage:WaitForChild("world")

function ThundermaulPassive:Morph(p2, object)
	self.random = object:GetRandom(8)
	self.lastStrike = Workspace:GetServerTimeNow()
	object:Preload({ script.initialStrike, ReplicatedStorage.resources.vfx.LightningExplosion })
	task.spawn(function()
		object:WaitUntilReady()

		if not object.cast_power then
			return
		end

		local bobber = object.rod and object.rod:FindFirstChild("bobber")

		if bobber and bobber:IsA("BasePart") then
			local cast_power = object.cast_power
			local v = cast_power >= 96
			local boltThickness = 0.5 + cast_power / 100 * 1.5
			local position = bobber.Position

			if v then
				if object.stats.ForcedProgressSpeed <= -50 then
					object:AddProgress(self.config.ForcedProgressSpeedMaxBonus)
				else
					object:AddProgress(self.config.InitialProgressBonus_PerfectCast)
				end

				fx:PlaySound(script.initialStrike, p2, true)
				object.fx:SpawnShake(object.reel_bar, 0.15, 1, 0.01, false)
			else
				object:AddProgress(cast_power / 100 * self.config.InitialProgressBonus)
			end

			StormyLightningController:Strike(position, {
				SkipStrikingLock = true,
				BoltColor = Color3.fromRGB(255, 255, 100),
				BoltThickness = boltThickness,
				BranchChance = 0.3 + cast_power / 100 * 0.4,
				ShakeIntensity = 1,
				ShakeDuration = 0.2,
				NoPostFire = true,
				NotWeather = true
			})
		end
	end)
end

function ThundermaulPassive:SpawnBoltVFX(parent, p2)
	local strikeWidth = self.config.StrikeWidth or 0.1
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ThundermaulBolt"
	imageLabel.Size = UDim2.fromScale(strikeWidth, 1.2)
	imageLabel.Position = UDim2.fromScale(p2 - strikeWidth / 2, -0.1)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://15826927544"
	imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 150)
	imageLabel.ImageTransparency = 0
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.ZIndex = 8
	imageLabel.Parent = parent
	TweenService:Create(imageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}):Play()
	task.delay(0.55, function()
		if imageLabel.Parent then
			imageLabel:Destroy()
		end
	end)
end

function ThundermaulPassive:SpawnPhysicalBolt()
	local bobber = self.current and self.current.rod and self.current.rod:FindFirstChild("bobber")

	if not (bobber and bobber:IsA("BasePart")) then
		return
	end

	local v = math.random() * 3.141592653589793 * 2
	local v2 = math.random() * 5
	local v3 = bobber.Position + Vector3.new(math.cos(v) * v2, 0, math.sin(v) * v2)
	task.spawn(function()
		StormyLightningController:Strike(v3, {
			SkipStrikingLock = true,
			BoltThickness = 0.4,
			BoltColor = Color3.fromRGB(255, 255, 100),
			NoPostFire = true,
			ShakeIntensity = 0.6,
			ShakeDuration = 0.15,
			NotWeather = true
		})
	end)
end

function ThundermaulPassive:TickLogic_Rod(_)
	local serverTimeNow = Workspace:GetServerTimeNow()
	local strikeInterval = self.config.StrikeInterval

	if serverTimeNow < self.lastStrike + strikeInterval then
		return
	end

	local current = self.current

	if not (current and current.active) then
		return
	end

	self.lastStrike = serverTimeNow
	local number = self.random:NextNumber(0.05, 0.95)
	self:SpawnBoltVFX(current.reel_bar, number)
	self:SpawnPhysicalBolt()
	local value = world.weather.Value
	local v = value ~= "Rain" and value ~= "Stormy" and 1 or self.config.RainyMultiplier
	current:AddProgress(self.config.ProgressPerStrike * v)
	TweenService:Create(
		current.reel_progress.bar,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
		{
			BackgroundColor3 = Color3.fromRGB(255, 255, 100)
		}
	):Play()
	current.fx:SpawnShake(current.reel_bar, 0.05, 1, 0.01, false)
end

setmetatable(ThundermaulPassive, module)
return ThundermaulPassive