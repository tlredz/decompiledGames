local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.utils.assets)
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local MeteorFireball = require(ReplicatedStorage.client.modules.MeteorFireball)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local remoteEvent = Net:RemoteEvent("PassiveVfx/MeteorShower/PlaySting")
local MeteorShower = {}
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing")
local random = Random.new()

function MeteorShower.CreateMeteorModel(p, _)
	local child = ReplicatedStorage.resources.replicated.instances.general:FindFirstChild(p.MeteorModelName)

	if not child then
		warn((`Failed to find model for meteor {p.MeteorModelName}!`))
		return nil
	end

	local clone = child:Clone()
	clone:ScaleTo(clone:GetScale() * (p.ModelScale or 1))

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.CastShadow = false
		part.Anchored = true
	end

	return clone
end

function MeteorShower.PlaySound(childName: string?, p, p2)
	if not (childName and p) then
		return
	end

	local child = fishing:FindFirstChild(childName)

	if not child then
		return
	end

	fx:PlaySound(child, p, Random.new():NextNumber(0.75, 1.25), "FishingSound", p2)
end

function MeteorShower.LoadMeteors(_, maid, _, data, data2)
	local flag = false
	maid:Add(function()
		flag = true
	end)

	for i = 1, data.MeteorCount do
		local v = i
		task.delay((i - 1) * data.MeteorInterval, function()
			local folder = MeteorShower.CreateMeteorModel(data, data2)

			if not folder or flag then
				return
			end

			local unitVector = random:NextUnitVector()

			if unitVector.Y < 0 then
				unitVector *= createVector(1, -1, 1)
			end

			local v2 = (unitVector + createVector(0, 0.25, 0)) * 128
			local cframe = CFrame.lookAt(data2.Center.Position + v2, data2.Center.Position)
			local v3 = CFrame.new(data2.Center.Position) * cframe.Rotation
			local primaryPart = folder.PrimaryPart
			primaryPart.Anchored = true

			if data.PivotOffset then
				primaryPart.PivotOffset *= CFrame.new(data.PivotOffset.Position * (data.ModelScale or 1)) * data.PivotOffset.Rotation
			end

			if v == data.MeteorCount then
				folder:ScaleTo(folder:GetScale() * 3)
			end

			folder:PivotTo(cframe)
			folder.Name = data2.Owner.Name
			folder.Parent = workspace.active.debrisfx
			MeteorShower.PlaySound(data.StartSoundName, primaryPart, data2.Owner)

			if flag then
				folder:Destroy()
				return
			end

			SaneDebris:AddItem(folder, data.FallAnimTime + 5)
			local total = 0

			while true do
				local v4 = RunService.RenderStepped:Wait()

				if not (folder.Parent and primaryPart.Parent) then
					break
				end

				total += v4
				primaryPart:PivotTo(cframe:Lerp(v3, total / data.FallAnimTime))

				if data.FallAnimTime <= total then
					break
				end
			end

			for i2, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
					descendant.LocalTransparencyModifier = 1
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
					descendant.Enabled = false
				end
			end

			for i2, child in primaryPart.ExplosionEffects:GetChildren() do
				if not (child.Name ~= "ImpactParticle" or data2.Owner == localPlayer) then
					continue
				end

				if v == data.MeteorCount then
					child.Lifetime = NumberRange.new(child.Name == "Core" and 2 or child.Name == "ImpactParticle" and 0.5 or 3)
					child:Emit(child.Rate * (child.Name:match("^Rays_") and 5 or 1))
				elseif child.Name ~= "ImpactParticle" then
					child:Emit(child.Rate)
				end
			end

			MeteorShower.PlaySound(data.EndSoundName, data2.Root)
		end)
	end

	local v = data2.Owner == localPlayer

	if v then
		TweenService:Create(script.Sting, TweenInfo.new(1.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			PlaybackSpeed = 0.5,
			Volume = 0.5
		}):Play()
		task.delay(1, function()
			TweenService:Create(script.Sting, TweenInfo.new(3, Enum.EasingStyle.Linear), {
				Volume = 0
			}):Play()
		end)
	end

	task.delay(0.5, function()
		local WAIT_INTERVAL = 0.1
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "MeteorCC"

		if v and not SettingsController:GetSettingValue("photosensitiveMode") then
			colorCorrectionEffect.Parent = game.Lighting
		end

		local tween = TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(data.MeteorCount * 0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{
				Brightness = 1,
				TintColor = Color3.fromRGB(211, 167, 255)
			}
		)
		tween:Play()
		local random2 = Random.new()

		for _ = 1, data.MeteorCount - 1 do
			MeteorFireball.Create(data2.Center.Position + random2:NextUnitVector() * createVector(1, 0, 1) * 5, 8, 2)
			task.wait(WAIT_INTERVAL)
		end

		for i = 1, 5 do
			task.delay(i * 0.01, function()
				MeteorFireball.Create(data2.Center.Position + random2:NextUnitVector() * 5, 4, 2)
			end)
		end

		if v then
			script.ExplodeLarge.Volume = 0.5
			script.ExplodeLarge:Play()
			TweenService:Create(script.ExplodeLarge, TweenInfo.new(5.8, Enum.EasingStyle.Linear), {
				Volume = 0
			}):Play()
		end

		MeteorFireball.Create(data2.Center.Position, 24, 3)
		tween:Cancel()

		if not SettingsController:GetSettingValue("photosensitiveMode") then
			colorCorrectionEffect.Brightness = 0
			colorCorrectionEffect.Saturation = -1.1
			colorCorrectionEffect.Contrast = -100
			colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
			task.wait(WAIT_INTERVAL)
			colorCorrectionEffect.Contrast = 100
			task.wait(WAIT_INTERVAL)
			colorCorrectionEffect.Contrast = 0
			colorCorrectionEffect.Saturation = 0
			colorCorrectionEffect.Brightness = 1
			colorCorrectionEffect.TintColor = Color3.fromRGB(211, 167, 255)
		end

		TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Brightness = 0,
			TintColor = Color3.new(1, 1, 1)
		}):Play()
		task.wait(2)
		colorCorrectionEffect:Destroy()
	end)
end

remoteEvent.OnClientEvent:Connect(function()
	script.Sting.Volume = 0.2
	script.Sting.PlaybackSpeed = 1
	script.Sting:Play()
end)
return MeteorShower