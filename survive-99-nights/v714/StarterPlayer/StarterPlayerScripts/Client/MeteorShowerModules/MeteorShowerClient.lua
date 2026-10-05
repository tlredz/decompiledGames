local createVector = vector.create
local MeteorShowerClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local clones = {}
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService2 = game:GetService("TweenService")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)

function ExplosionAtPoint(position)
	local clone = ReplicatedStorage.Assets.Particles.UFOSmokeParticle:Clone()
	clone.Position = position
	Client.Sound.Play("MeteorImpactEvent", {
		Duplicate = true,
		Volume = Random.new():NextNumber(0.1, 0.45)
	})
	task.spawn(function()
		Client.CamShake.ShakeOnce(3.3, 20, 0.1, 0.4)
	end)
	task.spawn(function()
		if not clone then
			return
		end

		clone.Parent = workspace.Particles
		TweenService2:Create(clone.BillboardGui, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(200, 0, 200, 0)
		}):Play()
		TweenService2:Create(
			clone.BillboardGui.ImageLabel,
			TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				ImageTransparency = 1
			}
		):Play()
		task.spawn(function()
			wait(0.75)

			if clone then
				clone:Destroy()
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Tween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	tween:Destroy()
end

function FlyMeteorToPosition(p, duration)
	local clone = ReplicatedStorage.Assets.MeteorShower.AmbientMeteor:Clone()
	table.insert(clones, clone)
	local primaryPart = clone.PrimaryPart
	primaryPart.Position = p + createVector(2000, -0, 1500) + createVector(0, 200, 0)
	primaryPart.SoftTrail.Brightness = 0
	primaryPart.SoftTrail.Enabled = true
	primaryPart.HardTrail.Brightness = 0
	primaryPart.HardTrail.Enabled = true
	primaryPart.CenterAtt.AmbientFlare.Brightness = 0
	primaryPart.CenterAtt.AmbientFlare.Enabled = true
	task.wait(2)

	if not (clone and clone.PrimaryPart and clone.PrimaryPart:FindFirstChild("SoftTrail")) then
		return
	end

	Client.TweenModule.new(function(p2)
		local v = 200 * (1 - p2)
		primaryPart.Position = p + createVector(1, -0, 0.75) * (1 - p2) * 2000 + Vector3.new(0, v, 0)
	end, duration, "Linear"):Play()
	Tween(primaryPart.SoftTrail, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0), {
		Brightness = 5
	}) -- equivalent call inferred; original call site unknown
	Tween(primaryPart.HardTrail, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0), {
		Brightness = 5
	}) -- equivalent call inferred; original call site unknown
	Tween(
		primaryPart.CenterAtt.AmbientFlare,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0),
		{
			Brightness = 5
		}
	) -- equivalent call inferred; original call site unknown
	clone.Parent = workspace.Particles
	task.wait(duration)

	if primaryPart and primaryPart.Parent then
		primaryPart.SoftTrail.Enabled = false
		primaryPart.HardTrail.Enabled = false
		primaryPart.CenterAtt.AmbientFlare.Enabled = false
		task.delay(10, function()
			clone:Destroy()
		end)
	end
end

Client.Events.MeteorLanding:Connect(function(p, p2)
	local v = p2 - workspace:GetServerTimeNow()

	if v > 0 then
		FlyMeteorToPosition(p, v)
		ExplosionAtPoint(p)
	end
end)
Client.Events.StartMeteorShower:Connect(function()
	MeteorShowerClient.ToggleMeteors(true)
end)
Client.Events.StopMeteorShower:Connect(function()
	Client.PopUpUI.AddPopUp("meteors have crashed all over the map", "orange")
	MeteorShowerClient.ToggleMeteors(false)
end)
local flag = false
local clones2 = {}

function RandomNumber(p: number, p2: number)
	return math.random(p * 1000, p2 * 1000) / 1000
end

function MeteorShowerClient.ObsidironExplosionVisuals(player)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = player.Character.HumanoidRootPart
		local children = ReplicatedStorage.Assets.MeteorShower.ObsidironExplosion.Main:GetChildren()
		local v = {}

		if player == localPlayer then
			Client.Sound.Play("Shockwave", {
				Volume = 0.55,
				Replicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.4
				}
			})
		end

		for _, emitter in pairs(children) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			table.insert(v, clone)
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(clone:GetAttribute("EmitCount") or 3)
		end
	end
end

Client.Events.ObsidironShockwave:Connect(function(p)
	MeteorShowerClient.ObsidironExplosionVisuals(p)
end)

function CreateMeteor()
	task.spawn(function()
		local X, Z

		if localPlayer.Character and localPlayer.Character.PrimaryPart then
			X = localPlayer.Character.PrimaryPart.Position.X
			Z = localPlayer.Character.PrimaryPart.Position.Z
		else
			X = 0
			Z = 0
		end

		local vector2 = Vector3.new(X, 0, Z)
		local v = RandomNumber(20, 25)
		local v2 = RandomNumber(2000, 2500)
		local clone = ReplicatedStorage.Assets.MeteorShower.AmbientMeteor:Clone()
		table.insert(clones2, clone)
		local primaryPart = clone.PrimaryPart
		clone:ScaleTo(Random.new():NextNumber(1, 2))
		primaryPart.Position = Vector3.new(RandomNumber(-100, 100), RandomNumber(60, 120), RandomNumber(-250, 250)) + createVector(
			0,
			150,
			0
		) + vector2
		primaryPart.SoftTrail.Brightness = 0
		primaryPart.SoftTrail.Enabled = true
		primaryPart.HardTrail.Brightness = 0
		primaryPart.HardTrail.Enabled = true
		primaryPart.CenterAtt.AmbientFlare.Brightness = 0
		primaryPart.CenterAtt.AmbientFlare.Enabled = true
		primaryPart.Position += CFrame.lookAlong(primaryPart.Position, createVector(-1, -0.1, -0.75)).LookVector * (v2 * -0.5)
		task.wait(2)

		if not (clone and clone.PrimaryPart and clone.PrimaryPart:FindFirstChild("SoftTrail")) then
			return
		end

		Tween(primaryPart, TweenInfo.new(v, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {
			Position = primaryPart.Position + CFrame.lookAlong(primaryPart.Position, createVector(-1, -0.1, -0.75)).LookVector * v2
		}) -- equivalent call inferred; original call site unknown
		Tween(primaryPart.SoftTrail, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0), {
			Brightness = 5
		}) -- equivalent call inferred; original call site unknown
		Tween(primaryPart.HardTrail, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0), {
			Brightness = 5
		}) -- equivalent call inferred; original call site unknown
		Tween(
			primaryPart.CenterAtt.AmbientFlare,
			TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0),
			{
				Brightness = 5
			}
		) -- equivalent call inferred; original call site unknown
		clone.Parent = workspace.Particles
		task.wait(v)

		if primaryPart and primaryPart.Parent then
			primaryPart.SoftTrail.Enabled = false
			primaryPart.HardTrail.Enabled = false
			primaryPart.CenterAtt.AmbientFlare.Enabled = false
		end

		task.wait(10)

		if clone then
			clone:Destroy()
		end
	end)
end

local flag2 = true
local count = 0

function MeteorShowerClient.ToggleMeteors(p)
	if p then
		if flag then
			return
		end

		count += 1
		local v = count
		flag = true

		if flag2 then
			flag2 = false
			local children = ReplicatedStorage.Assets.MeteorShower.ObsidironExplosion.Main:GetChildren()
			local textures = { "rbxassetid://16877842776", "rbxassetid://15580440964", "rbxassetid://15580440964" }

			for _, v2 in pairs(children) do
				table.insert(textures, v2.Texture)
			end

			UtilityAlec.preload(textures)
		end

		task.spawn(function()
			while flag do
				wait(Random.new():NextNumber(1, 1.3))
				CreateMeteor()
			end
		end)
		task.spawn(function()
			wait(8)

			if v == count then
				Client.PopUpUI.AddPopUp("the sky is on fire", "orange")
				Client.Sound.Play("MeteorShower")
				Client.ColorCorrectionLightingClient.SetMeteors(true)
			end
		end)
	else
		count += 1
		flag = false
		ReplicatedStorage.Core.Sounds.MeteorShower:Stop()

		for _, v in pairs(clones2) do
			v:Destroy()
		end

		Client.ColorCorrectionLightingClient.SetMeteors(false)
	end
end

function MeteorShowerClient.Init() end

return MeteorShowerClient