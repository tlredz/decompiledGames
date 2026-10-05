local BoostpadClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local holdDuration = 1
local v2 = {}
local count = 0
local v3 = {}
local v4 = false
local v5 = nil
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 221, 0))

function InitiateBoostPad(instance)
	v[instance] = 0
	local proximityInteraction = instance:WaitForChild("Primary"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
	local loadingBar = instance:WaitForChild("Model"):WaitForChild("LoadingBar")

	if instance.Name ~= "Winged Boost Pad" then
		holdDuration = proximityInteraction.HoldDuration
	end

	proximityInteraction.PromptButtonHoldBegan:Connect(function()
		if instance:GetAttribute("IsCharging") then
			v[instance] += 1
			local v8 = v[instance]
			loadingBar["1"].Color = Color3.fromRGB(255, 0, 0)
			loadingBar["2"].Color = Color3.fromRGB(255, 0, 0)
			loadingBar["3"].Color = Color3.fromRGB(255, 0, 0)
			loadingBar["4"].Color = Color3.fromRGB(255, 0, 0)
			task.spawn(function()
				loadingBar["1"].Color = Color3.fromRGB(5, 255, 0)
				wait(holdDuration / 3)

				if v8 == v[instance] then
					loadingBar["2"].Color = Color3.fromRGB(5, 255, 0)
					wait(holdDuration / 3)
				end

				if v8 == v[instance] then
					loadingBar["3"].Color = Color3.fromRGB(5, 255, 0)
					wait(holdDuration / 3)
				end

				if v8 == v[instance] then
					loadingBar["4"].Color = Color3.fromRGB(5, 255, 0)
				end
			end)
		end
	end)
	proximityInteraction.PromptButtonHoldEnded:Connect(function()
		v[instance] += 1
		loadingBar["1"].Color = Color3.fromRGB(255, 0, 0)
		loadingBar["2"].Color = Color3.fromRGB(255, 0, 0)
		loadingBar["3"].Color = Color3.fromRGB(255, 0, 0)
		loadingBar["4"].Color = Color3.fromRGB(255, 0, 0)
	end)
end

function AnyWingedPadPlaced()
	for k in pairs(v2) do
		if k:IsDescendantOf(workspace) then
			return true
		end
	end

	return false
end

function ApplyWingedPassive()
	count += 1
	local v6 = count
	Client.WalkspeedController.AddSpeedChange("WingedBoostpad", "Effects", 4)
	Client.WalkspeedController.AddSpeedChange("WingedBoostpad", "Effects", 17, {
		Mode = "Walk"
	})
	Client.Sound.Play("WingedBoostPad")
	Client.Events.WingedBoostpadParticles:FireAllClients(localPlayer.Character, 3)
	task.delay(3, function()
		if v6 == count then
			Client.WalkspeedController.RemoveSpeedChange("WingedBoostpad")
		end
	end)
end

function WeldWingedParticles(parent, p)
	local clone = game.ReplicatedStorage.Assets.Particles.SnowBiome[p]:Clone()
	clone.Anchored = false
	clone.Massless = true
	clone.CFrame = parent.HumanoidRootPart.CFrame
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = parent.HumanoidRootPart
	weldConstraint.Parent = clone
	clone.Parent = parent
	return clone
end

function EmitWingedStart(p)
	local folder = WeldWingedParticles(p, "WingedBoostPadStart")
	folder.Name = "WingedBoostPadBurst"

	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
		end
	end

	task.delay(3, function()
		folder:Destroy()
	end)
end

function EnableWingedParticles(instance, childName)
	if instance:FindFirstChild(childName) then
		return
	end

	local folder = WeldWingedParticles(instance, childName)

	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = true
	end
end

function DisableWingedParticles(instance)
	if not instance then
		return
	end

	for _, childName in pairs({ "WingedBoostPadAura", "WingedBoostPadStart" }) do
		local child = instance:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end
end

function StartWingedAura(instance, duration, p)
	if not (instance and instance:FindFirstChild("HumanoidRootPart")) then
		return
	end

	if p then
		if not instance:FindFirstChild("WingedBoostPadStart") then
			Client.Utility.SpawnParticles("WingedBoostPadBigBoost", instance:GetPivot())
		end

		EnableWingedParticles(instance, "WingedBoostPadStart")
	else
		EmitWingedStart(instance)
	end

	EnableWingedParticles(instance, "WingedBoostPadAura")
	local v6 = time() + duration

	if not v3[instance] or v3[instance] < v6 then
		v3[instance] = v6
		task.delay(duration, function()
			if v3[instance] == v6 then
				v3[instance] = nil
				DisableWingedParticles(instance)
			end
		end)
	end
end

function EmitBoostPadUsed(parent)
	local humanoidRootPart = parent and parent:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clone = game.ReplicatedStorage.Assets.Particles.BoostPadUsed:Clone()
	clone.Anchored = false
	clone.Massless = true
	clone.CFrame = humanoidRootPart.CFrame
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = humanoidRootPart
	weldConstraint.Parent = clone
	clone.Parent = parent
	Client.Utility.RunParticles(clone, {
		Color = colorSequence
	})
	task.delay(3, function()
		clone:Destroy()
	end)
end

function BoostpadClient.Init()
	task.spawn(function()
		local mainFire = workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire")
		local position = mainFire:GetPivot().Position
		local outerTouchZone = mainFire:WaitForChild("OuterTouchZone")

		while true do
			task.wait(0.25)
			local humanoidRootPart = Client.PlayerHandler.HumanoidRootPart

			if not humanoidRootPart then
				continue
			end

			local v6 = (humanoidRootPart.Position - position).Magnitude <= outerTouchZone.Size.X / 2

			if humanoidRootPart == v5 and v4 and not v6 and (mainFire:GetAttribute("FuelRemaining") or 0) > 0 and AnyWingedPadPlaced() then
				ApplyWingedPassive()
			end

			v5 = humanoidRootPart
			v4 = v6
		end
	end)
end

Client.Utility.ForAllTagged("Boostpad", function(p)
	if p.Name == "Winged Boost Pad" then
		v2[p] = true
	end

	InitiateBoostPad(p)
end, function(p)
	v2[p] = nil
end)
Client.Events.SpeedPlayer:Connect(function(p, _, _, p2)
	if p ~= "WingedBoostpadUse" or not localPlayer.Character then
		return
	end

	if not localPlayer.Character:FindFirstChild("WingedBoostPadStart") then
		Client.Sound.Play("Boosted", {
			Volume = 0.4,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.35
			}
		})
		Client.CamShake.ShakeOnce(1.3, 20, 0.1, 0.4)
		Client.Sound.Play("WingedBoostPad", {
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head
			}
		})
	end

	Client.Events.WingedBoostpadParticles:FireAllClients(localPlayer.Character, p2, true)
end)
Client.Events.WingedBoostpadParticles:Connect(function(_, p, p2, p3)
	StartWingedAura(p, p2, p3)
end)
Client.Events.BoostpadUsedParticles:Connect(function(_, p)
	EmitBoostPadUsed(p)
end)
return BoostpadClient