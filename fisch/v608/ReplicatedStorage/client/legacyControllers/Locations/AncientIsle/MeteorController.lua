local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Net = require(ReplicatedStorage.packages.Net)
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local MeteorFireball = require(ReplicatedStorage.client.modules.MeteorFireball)
local remoteEvent = Net:RemoteEvent("Meteor/Spawn")
local remoteEvent2 = Net:RemoteEvent("Meteor/Claim")
local remoteEvent3 = Net:RemoteEvent("Meteor/Disappear")
local MeteorController = {
	LastClaimed = nil
}
local meteor = ReplicatedStorage:WaitForChild("resources"):WaitForChild("models"):WaitForChild("Meteor")
local flashParticles = script.FlashParticles
local v = CFrame.new(0, 250, 250) * CFrame.Angles(0, -1.5707963267948966, 0.3490658503988659)

function MeteorController.Spawn(position: Vector3, p: number, color)
	task.spawn(
		ContentProvider.PreloadAsync,
		ContentProvider,
		{ meteor, flashParticles, ReplicatedStorage.client.modules.MeteorFireball }
	)
	local v2 = CFrame.new(position) * v
	local clone = flashParticles:Clone()
	clone:ScaleTo(10)
	clone:PivotTo(v2)
	clone.Parent = workspace.active

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant.Color = color
			descendant:Emit(1)
		elseif descendant:IsA("Sound") then
			descendant:Play()
		end
	end

	SaneDebris:AddItem(clone, 10)
	task.wait(p - workspace:GetServerTimeNow())

	if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > 2048 then
		return
	end

	local clone2 = meteor:Clone()
	clone2:PivotTo(v2)
	clone2.Root.soar:Play()
	clone2.Parent = workspace.active
	local v3 = p + 2.5 - workspace:GetServerTimeNow()
	TweenService:Create(clone2.PrimaryPart, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(position) * v.Rotation
	}):Play()
	task.wait(v3)
	clone2:Destroy()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "MeteorCC"
	colorCorrectionEffect.Brightness = 0.5
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 227, 188)
	colorCorrectionEffect.Parent = game.Lighting
	local random = Random.new()

	for _ = 1, 10 do
		MeteorFireball.Create(position + random:NextUnitVector() * 30, 10, 2)
		task.wait(0.01)
	end

	for i = 1, 20 do
		task.delay(i * 0.01, function()
			MeteorFireball.Create(position + random:NextUnitVector() * 30, 10, 2)
		end)
	end

	script.ExplodeLarge.Volume = 0.5
	script.ExplodeLarge:Play()
	TweenService:Create(script.ExplodeLarge, TweenInfo.new(5.8, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
	MeteorFireball.Create(position, 64, 3)
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Brightness = 0,
		TintColor = Color3.new(1, 1, 1)
	}):Play()
	task.wait(2)
	colorCorrectionEffect:Destroy()
end

function MeteorController.Claim(lastClaimed: number)
	MeteorController.LastClaimed = lastClaimed

	for _, v2 in CollectionService:GetTagged("MeteorItem") do
		if v2:GetAttribute("ID") == lastClaimed then
			v2:Destroy()
		end
	end
end

function MeteorController.Disappear(p)
	task.wait(p - workspace:GetServerTimeNow())
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)

	for _, folder in CollectionService:GetTagged("MeteorCrater") do
		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter")) then
				continue
			end

			if descendant:IsA("BasePart") then
				descendant.CanCollide = false
			end

			TweenService:Create(descendant, tweenInfo, {
				LocalTransparencyModifier = 1
			}):Play()
		end
	end
end

function MeteorController.Start(_)
	remoteEvent.OnClientEvent:Connect(MeteorController.Spawn)
	remoteEvent2.OnClientEvent:Connect(MeteorController.Claim)
	remoteEvent3.OnClientEvent:Connect(MeteorController.Disappear)
	CollectionService:GetInstanceAddedSignal("MeteorItem"):Connect(function(instance)
		if MeteorController.LastClaimed and instance:GetAttribute("ID") == MeteorController.LastClaimed then
			instance:Destroy()
		end
	end)
	CollectionService:GetInstanceAddedSignal("MeteorCrater"):Connect(function(instance)
		if instance:GetAttribute("_played") or workspace:GetServerTimeNow() - instance:GetAttribute("SpawnedAt") > 10 then
			return
		end

		instance:SetAttribute("_played", true)

		for _, descendant in instance:WaitForChild("Root"):GetDescendants() do
			if descendant:IsA("Sound") then
				descendant:Play()
			elseif descendant:IsA("ParticleEmitter") then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			end
		end
	end)
end

return MeteorController