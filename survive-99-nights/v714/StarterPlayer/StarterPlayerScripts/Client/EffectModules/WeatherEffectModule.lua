local createVector = vector.create
local WeatherEffectModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local v = nil
local v2 = nil
WeatherEffectModule.Inside = false
WeatherEffectModule.Clear = {}

function WeatherEffectModule.Clear.Begin() end

function WeatherEffectModule.Clear.End() end

local v3 = {
	"Texture",
	"Color",
	"Transparency",
	"Size",
	"Squash",
	"LightEmission",
	"LightInfluence",
	"Brightness",
	"Orientation",
	"EmissionDirection",
	"Lifetime",
	"Rate",
	"Rotation",
	"RotSpeed",
	"Speed",
	"SpreadAngle",
	"Acceleration",
	"Drag",
	"LockedToPart",
	"TimeScale",
	"VelocityInheritance",
	"ZOffset",
	"Shape",
	"ShapeInOut",
	"ShapeStyle",
	"WindAffectsDrag",
	"Enabled"
}

function WeatherEffectModule.GetWeather()
	return v
end

function GetRainParticles(p)
	if not WeatherEffectModule.Rain.Emitter then
		return
	end

	local children = {}

	for _, child in pairs(WeatherEffectModule.Rain.Emitter:GetChildren()) do
		if string.sub(child.Name, 1, 4) ~= "Rain" then
			continue
		end

		table.insert(children, child)

		if p == "On" then
			child.Enabled = true
		elseif p == "Off" then
			child.Enabled = false
		end
	end

	return children
end

function GetSnowParticles(p)
	if not WeatherEffectModule.Rain.Emitter then
		return
	end

	local children = {}

	for _, child in pairs(WeatherEffectModule.Rain.Emitter:GetChildren()) do
		if string.sub(child.Name, 1, 4) ~= "Snow" then
			continue
		end

		table.insert(children, child)

		if p == "On" then
			child.Enabled = true
		elseif p == "Off" then
			child.Enabled = false
		end
	end

	return children
end

function GetBlizzardParticles(p)
	if not WeatherEffectModule.Blizzard.Emitter then
		return
	end

	local children = {}

	for _, child in pairs(WeatherEffectModule.Blizzard.Emitter:GetChildren()) do
		if string.sub(child.Name, 1, 4) ~= "Snow" then
			continue
		end

		table.insert(children, child)

		if p == "On" then
			child.Enabled = true
		elseif p == "Off" then
			child.Enabled = false
		end
	end

	return children
end

function WeatherEffectModule.LessRain(p)
	if v == "Rain" or v == "Thunderstorm" or v == "Blizzard" then
		if p then
			local function makeLessRainAndSnow()
				WeatherEffectModule.Rain.Emitter.Rain_Thick.Transparency = NumberSequence.new(0.96)
				WeatherEffectModule.Rain.Emitter.Rain_Thin.Transparency = NumberSequence.new(0.96)
				WeatherEffectModule.Rain.Emitter.Rain_TopDown.Transparency = NumberSequence.new(0.96)
				WeatherEffectModule.Rain.Emitter.Snow_Flakes.Transparency = NumberSequence.new(0.88)
				WeatherEffectModule.Rain.Emitter.Snow_Mist.Transparency = NumberSequence.new(0.95)
				WeatherEffectModule.Rain.Emitter.Snow_SmallFlake.Transparency = NumberSequence.new(0.88)
			end

			if v == "Thunderstorm" then
				makeLessRainAndSnow()
				return
			end

			if v ~= "Blizzard" then
				makeLessRainAndSnow()
				return
			end

			WeatherEffectModule.Blizzard.Emitter.ParticleEmitterBlizzard.Transparency = NumberSequence.new(0.8)
			WeatherEffectModule.Blizzard.Emitter.ParticleEmitterBlizzard2.Transparency = NumberSequence.new(0.95)
		elseif v == "Thunderstorm" then
			GetSnowParticles()
			local emitter = WeatherEffectModule.Rain.Emitter

			if not emitter then
				return
			end

			local rainProperties = ReplicatedStorage.Assets.Particles.RainProperties

			for _, v4 in pairs(v3) do
				emitter.Snow_Flakes[v4] = rainProperties.Blizzard_Flakes[v4]
				emitter.Snow_Mist[v4] = rainProperties.Blizzard_Mist[v4]
				emitter.Snow_SmallFlake[v4] = rainProperties.Blizzard_SmallFlake[v4]
			end
		elseif v == "Blizzard" then
			WeatherEffectModule.Blizzard.Emitter.ParticleEmitterBlizzard.Transparency = NumberSequence.new(0.35)
			WeatherEffectModule.Blizzard.Emitter.ParticleEmitterBlizzard2.Transparency = NumberSequence.new(0.85)
		else
			GetSnowParticles()
			local emitter = WeatherEffectModule.Rain.Emitter

			if not emitter then
				return
			end

			local rainProperties = ReplicatedStorage.Assets.Particles.RainProperties

			for _, v4 in pairs(v3) do
				emitter.Snow_Flakes[v4] = rainProperties.Snow_Flakes[v4]
				emitter.Snow_Mist[v4] = rainProperties.Snow_Mist[v4]
				emitter.Snow_SmallFlake[v4] = rainProperties.Snow_SmallFlake[v4]
			end
		end
	end
end

function UpdateRainVisuals(p, p2)
	local emitter = WeatherEffectModule.Rain.Emitter

	if not emitter then
		return
	end

	if p then
		for _, emitter2 in pairs(emitter:GetChildren()) do
			if emitter2:IsA("ParticleEmitter") then
				emitter2.Enabled = false
			end
		end
	elseif p2 == "Snow" then
		GetRainParticles("Off")
		GetSnowParticles("On")
	else
		GetRainParticles("On")
		GetSnowParticles("Off")
	end
end

function HideRain()
	if WeatherEffectModule.Rain and WeatherEffectModule.Rain.Emitter then
		for _, emitter in pairs(WeatherEffectModule.Rain.Emitter:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end
end

function RaycastIndoors()
	if not (localPlayer.Character and localPlayer.Character.PrimaryPart) then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Map.Landmarks }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.IgnoreWater = true
	local position = localPlayer.Character.PrimaryPart.Position
	local raycastResult = workspace:Raycast(position, createVector(0, 75, 0), raycastParams)
	local currentBiome = Client.BiomesClient.GetCurrentBiome()

	if Client.ZoneModule.GetZone(position) ~= "Forest" or raycastResult then
		if not WeatherEffectModule.Inside then
			WeatherEffectModule.Inside = true
			Client.Events.InsideToggle:FireServer(true)
		end

		UpdateRainVisuals(true, currentBiome)
	else
		if WeatherEffectModule.Inside then
			WeatherEffectModule.Inside = false
			Client.Events.InsideToggle:FireServer(false)
		end

		UpdateRainVisuals(false, currentBiome)
	end

	return nil
end

function CheckInside()
	task.spawn(function()
		while v ~= "Clear" do
			RaycastIndoors()
			task.wait(1)
		end
	end)
end

local position = workspace.CurrentCamera.CFrame.Position

function StartRain(p)
	CheckInside()

	if not WeatherEffectModule.Rain.Emitter then
		game.SoundService.Rain:Play()
		local clone = game.ReplicatedStorage.Assets.Particles.RainEmitter:Clone()
		clone.Parent = workspace.Particles
		WeatherEffectModule.Rain.Emitter = clone.RainEmitter
		task.spawn(function()
			while (v == "Rain" or v == "Thunderstorm") and clone.Parent do
				local position2 = workspace.CurrentCamera.CFrame.Position
				local _ = (position2 - position) / 0.5
				position = position2
				local v4 = createVector(0, 0, 0)
				local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local v5 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)

					if v5.Magnitude > 1 then
						v4 = v5.Unit * 100
					end
				end

				if clone and clone:FindFirstChild("RainEmitter") then
					clone.RainEmitter.CFrame = CFrame.new(position2 + createVector(0, 50, 0) + v4) * CFrame.Angles(
						0,
						0,
						1.5707963267948966
					)
				end

				wait(0.5)
			end
		end)
	end

	GetSnowParticles()
	local emitter = WeatherEffectModule.Rain.Emitter

	if not emitter then
		return
	end

	local rainProperties = ReplicatedStorage.Assets.Particles.RainProperties

	if p then
		for _, v4 in pairs(v3) do
			emitter.Snow_Flakes[v4] = rainProperties.Blizzard_Flakes[v4]
			emitter.Snow_Mist[v4] = rainProperties.Blizzard_Mist[v4]
			emitter.Snow_SmallFlake[v4] = rainProperties.Blizzard_SmallFlake[v4]
		end
	else
		for _, v4 in pairs(v3) do
			emitter.Snow_Flakes[v4] = rainProperties.Snow_Flakes[v4]
			emitter.Snow_Mist[v4] = rainProperties.Snow_Mist[v4]
			emitter.Snow_SmallFlake[v4] = rainProperties.Snow_SmallFlake[v4]
			print("made smaller")
		end
	end

	if Client.CampfireEffectModule.PlayerNearFire then
		WeatherEffectModule.LessRain(true)
	end

	RaycastIndoors()
	Client.FireSourceModule.RainWarning(true)
end

function StopRain()
	game.SoundService.Blizzard:Stop()
	game.SoundService.Rain:Stop()
	WeatherEffectModule.Rain.Emitter:Destroy()
	WeatherEffectModule.Rain.Emitter = nil
	Client.FireSourceModule.RainWarning(false)
end

function StartBlizzard()
	CheckInside()

	if not WeatherEffectModule.Blizzard.Emitter then
		game.SoundService.Blizzard:Play()
		local clone = game.ReplicatedStorage.Assets.Particles.BlizzardEmitter:Clone()
		clone.Parent = workspace.Particles
		WeatherEffectModule.Blizzard.Emitter = clone.BlizzardEmitter
		task.spawn(function()
			while v == "Blizzard" and clone.Parent do
				clone.BlizzardEmitter.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position + createVector(
					0,
					50,
					0
				)) * CFrame.Angles(0, 0, 1.5707963267948966)
				wait(0.5)
			end
		end)
	end

	WeatherEffectModule.Blizzard.Emitter.ParticleEmitterBlizzard.Transparency = NumberSequence.new(0.35)
	Client.FireSourceModule.RainWarning(true)
end

function StopBlizzard()
	game.SoundService.Blizzard:Stop()
	game.SoundService.Rain:Stop()
	WeatherEffectModule.Blizzard.Emitter:Destroy()
	WeatherEffectModule.Blizzard.Emitter = nil
	Client.FireSourceModule.RainWarning(false)
end

WeatherEffectModule.Blizzard = {}

function WeatherEffectModule.Blizzard.Begin()
	Client.PopUpUI.AddPopUp("a blizzard has started")
	StartBlizzard()
end

function WeatherEffectModule.Blizzard.End()
	StopBlizzard()
end

WeatherEffectModule.Rain = {}

function WeatherEffectModule.Rain.Begin()
	Client.PopUpUI.AddPopUp("it has started to rain")
	StartRain()
end

function WeatherEffectModule.Rain.End()
	StopRain()
end

WeatherEffectModule.Thunderstorm = {}

function WeatherEffectModule.Thunderstorm.Begin()
	StartRain(true)
	Client.PopUpUI.AddPopUp("it has started to rain and thunder")
	Client.Sound.Play("Thunder")
end

function WeatherEffectModule.Thunderstorm.End()
	StopRain()
end

function SetWeather(p)
	if v and v == p then
		return
	end

	if v and WeatherEffectModule[v] and WeatherEffectModule[v].End then
		WeatherEffectModule[v].End()
	end

	v = p

	if v and WeatherEffectModule[v] and WeatherEffectModule[v].Begin then
		WeatherEffectModule[v].Begin()
	end
end

local function getGroundPosition(position2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(position2, createVector(0, -1000, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position, raycastResult
	end

	return nil
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getValue(magnitude)
	return 0.1 + 3.4 * ((120 - magnitude) / 120)
end

local random = Random.new()

function FlyAway(folder, p)
	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Anchored == false) then
			continue
		end

		part.CFrame *= CFrame.Angles(
			random:NextNumber(0, 6.283185307179586),
			random:NextNumber(0, 6.283185307179586),
			random:NextNumber(0, 6.283185307179586)
		)
		local mass = part.Mass
		local v4 = part.Position - p
		part:ApplyImpulse((Vector3.new(
			mass * 28 * 0.76472449133173 * math.sign(v4.X),
			mass * 70 * 0.76472449133173,
			mass * 28 * 0.76472449133173 * math.sign(v4.Z)
		)))
	end
end

function WeatherEffectModule.LightningStrike(position2, p, p2, instance)
	local clone = ReplicatedStorage.Assets.Particles.CloudTemplate:Clone()

	if p2 then
		position2 += createVector(-1.5, 0, 5)
	end

	clone:PivotTo(CFrame.new(position2))
	clone.Parent = workspace
	clone.LightningWarning.Thunder:Play()
	local cloud1 = clone.Cloud1
	local cloud2 = clone.Cloud2
	local lightningWarning = clone.LightningWarning
	local lightningStrike = clone.LightningStrike
	local circle = clone.Circle
	local random2 = Random.new()
	TweenService:Create(cloud1, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Transparency = 0.2,
		Position = cloud1.Position + createVector(7, 0, 0)
	}):Play()
	TweenService:Create(cloud2, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Transparency = 0.2,
		Position = cloud2.Position - createVector(7, 0, 0)
	}):Play()
	local v4 = true
	task.spawn(function()
		wait(p)
		v4 = false
	end)
	wait(1)

	while v4 and v == "Thunderstorm" do
		local clone2 = lightningWarning:Clone()
		clone2.PointLight.Enabled = true
		clone2.CFrame *= CFrame.Angles(
			random2:NextNumber(0, 6.283185307179586),
			random2:NextNumber(0, 6.283185307179586),
			random2:NextNumber(0, 6.283185307179586)
		)
		clone2.Size = createVector(13, 13, 13)
		clone2.Transparency = 0.5
		clone2.Parent = lightningWarning.Parent
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = createVector(1, 1, 1)
		}):Play()
		task.spawn(function()
			wait(0.4)
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			wait(0.15)

			if clone2 and clone2:FindFirstChild("PointLight") then
				clone2.PointLight.Enabled = false
			end
		end)

		if p <= 0 then
			break
		end

		if v ~= "Thunderstorm" then
			continue
		end

		local v6 = math.min(p, 0.5)
		v6 -= task.wait(v6)
	end

	if v == "Thunderstorm" then
		for _, child in pairs(clone.LightningPhysical:GetChildren()) do
			if p2 and child.Position.Y < 15 then
				continue
			end

			child.Transparency = 0.35
			child.PointLight.Enabled = true
			local v5 = child
			task.spawn(function()
				TweenService:Create(v5, TweenInfo.new(1.95, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
				wait(2)
				v5:Destroy()
			end)
		end

		clone.LightningWarning.Lightning:Play()

		if instance and instance:FindFirstChild("Primary") then
			instance.Primary.HitSound:Play()
		end

		local groundPosition, v5 = getGroundPosition(position2)

		if groundPosition and not p2 then
			lightningStrike.Position = groundPosition
			circle.Position = groundPosition
		end

		if v5 and not p2 then
			clone.FlyingParts:PivotTo(CFrame.new(groundPosition) * CFrame.new(0, 0.05, 0))

			for _, child in pairs(clone.FlyingParts:GetChildren()) do
				child.Color = v5.Instance.Color
				child.Transparency = 0
				child.Anchored = false
			end

			FlyAway(clone.FlyingParts, groundPosition)
		end

		if not p2 then
			circle.Transparency = 0.85
			TweenService:Create(circle, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = createVector(0, 0, 0)
			}):Play()
		end

		if localPlayer.Character and localPlayer.Character.PrimaryPart and localPlayer.Character:FindFirstChild("Left Leg") then
			local magnitude = (localPlayer.Character.PrimaryPart.Position - groundPosition).Magnitude

			if (magnitude <= circle.Size.X / 2 or (localPlayer.Character["Left Leg"].Position - groundPosition).Magnitude <= circle.Size.X / 2) and not p2 then
				Client.Events.CheckLightningDamage:FireServer()
			end

			if magnitude < 120 then
				local exposureCompensation = getValue(magnitude)

				if not p2 then
					Client.CamShake.ShakeOnce(5 * exposureCompensation, 5 * exposureCompensation, 0.08, 0.25)
				end

				if game.Lighting.ExposureCompensation < exposureCompensation then
					if v2 then
						v2:Pause()
					end

					game.Lighting.ExposureCompensation = exposureCompensation
					v2 = TweenService:Create(game.Lighting, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
						ExposureCompensation = 0
					})
					v2:Play()
				end
			end
		end
	end

	task.spawn(function()
		wait(1)
		TweenService:Create(cloud1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Transparency = 1
		}):Play()
		TweenService:Create(cloud2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Transparency = 1
		}):Play()
		wait(3)
		clone:Destroy()
	end)
end

Client.Events.CreateLightning:Connect(function(p, p2, p3, p4)
	WeatherEffectModule.LightningStrike(p, p2, p3, p4)
end)

function WeatherEffectModule.Init()
	task.spawn(function()
		workspace:GetAttributeChangedSignal("Weather"):Connect(function()
			local weather = workspace:GetAttribute("Weather")
			SetWeather(weather)
		end)

		if workspace:GetAttribute("Weather") then
			SetWeather(workspace:GetAttribute("Weather"))
		end
	end)
end

return WeatherEffectModule