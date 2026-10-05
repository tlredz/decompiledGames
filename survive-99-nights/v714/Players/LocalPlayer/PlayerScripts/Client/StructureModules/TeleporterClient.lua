local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local TeleporterClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local holdDuration = 4
local cFramesByInstance = {}
local v2 = {}

function SpinIt(instance)
	task.spawn(function()
		if not v2[instance] then
			local spinner = instance.Model:FindFirstChild("Spinner")

			if not spinner then
				return
			end

			local charge = instance.PrimaryPart.Charge
			charge:Play()
			v2[instance] = true
			local v3 = v[instance]
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0.2
			TweenService:Create(numberValue, TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Value = 0.03
			}):Play()
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Value = 0.3
			TweenService:Create(numberValue2, TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Value = 25.1
			}):Play()

			while v3 == v[instance] and instance.Parent do
				spinner:PivotTo(spinner:GetPivot() * CFrame.Angles(0, math.rad(numberValue2.Value), 0))
				wait(numberValue.Value)
			end

			charge:Stop()
			v2[instance] = false
		end
	end)
end

function InitiateTeleporter(instance)
	v[instance] = 0
	local proximityInteraction = instance:WaitForChild("Primary"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
	holdDuration = proximityInteraction.HoldDuration

	if not cFramesByInstance then
		cFramesByInstance[instance] = instance.Model.Spinner.CFrame
	end

	proximityInteraction.PromptButtonHoldBegan:Connect(function()
		if instance:GetAttribute("IsCharging") then
			v[instance] += 1
			local _ = v[instance]
			SpinIt(instance)
		else
			proximityInteraction.Enabled = false
			wait(2.5)
			proximityInteraction.Enabled = true
		end
	end)
	proximityInteraction.PromptButtonHoldEnded:Connect(function()
		v[instance] += 1
	end)
end

Client.Events.TeleportParticles:Connect(function(instance)
	if instance and instance:FindFirstChild("HumanoidRootPart") and instance.HumanoidRootPart:FindFirstChild("RootAttachment") then
		local teleportBefore = ReplicatedStorage.Assets.Particles.TeleportBefore
		local clone = teleportBefore.ParticleEmitter:Clone()
		clone.Parent = instance.HumanoidRootPart
		local clone2 = teleportBefore.Attachment.Gas:Clone()
		local clone3 = teleportBefore.Attachment.Ground:Clone()
		clone2.Parent = instance.HumanoidRootPart.RootAttachment
		clone3.Parent = instance.HumanoidRootPart.RootAttachment
		clone:Emit(clone:GetAttribute("EmitCount"))
		clone2:Emit(clone2:GetAttribute("EmitCount"))
		clone3:Emit(clone3:GetAttribute("EmitCount"))
		Client.Sound.Play("Boosted", {
			Volume = 0.4,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.3
			}
		})
		local clones = {}
		task.spawn(function()
			wait(0.75)

			if instance and instance.HumanoidRootPart and instance.HumanoidRootPart:FindFirstChild("RootAttachment") then
				local children = ReplicatedStorage.Assets.Particles.TeleportBefore:GetChildren()

				for _, v3 in pairs(children) do
					local clone4 = v3:Clone()
					clone4.Parent = instance.HumanoidRootPart
					table.insert(clones, clone4)
				end

				for _, particleEmitter in pairs(clones) do
					if not particleEmitter:IsA("ParticleEmitter") then
						particleEmitter = particleEmitter:FindFirstChildWhichIsA("ParticleEmitter")
					end

					if particleEmitter then
						particleEmitter:Emit(particleEmitter:GetAttribute("EmitCount"))
					end
				end
			end

			wait(9)

			if clone then
				clone:Destroy()
			end

			if clone2 then
				clone2:Destroy()
			end

			if clone3 then
				clone3:Destroy()
			end

			for _, v3 in pairs(clones) do
				v3:Destroy()
			end
		end)
	end
end)
local teleporterIcons = {}
local v3 = nil

function GetOtherTeleporters(p)
	local tagged = CollectionService:GetTagged("Teleporter")
	local result = {}

	for _, v4 in pairs(tagged) do
		if v4:IsDescendantOf(workspace) and v4 ~= p then
			table.insert(result, v4)
		end
	end

	return result
end

Client.Events.MapClosed:Connect(function(p)
	if v3 and not p then
		Client.Events.ChooseTeleporterCancelled:FireServer(v3)
	end

	for _, v4 in pairs(teleporterIcons) do
		v4:Destroy()
	end

	v3 = nil
end)

function OpenTeleporter(p, p2)
	for _, v4 in pairs(teleporterIcons) do
		v4:Destroy()
	end

	v3 = p
	local v4 = GetOtherTeleporters(p)

	if not (#v4 >= 2) then
		return v4[1] or nil
	end

	for _, v5 in pairs(v4) do
		local pivot = v5:GetPivot()

		if not pivot then
			continue
		end

		local X = pivot.X
		local Z = pivot.Z
		local teleporterIcon = Client.MapDrawClient.MakeTeleporterIcon(X, Z)

		if not teleporterIcon then
			continue
		end

		table.insert(teleporterIcons, teleporterIcon)
		local v6 = v5
		local v7 = teleporterIcon
		teleporterIcon.Activated:Connect(function()
			if v6.Parent == nil then
				v7:Destroy()
				return
			end

			if localPlayer.Character and localPlayer.Character:HasTag("CarryingEasterBunnyEgg") then
				Client.PopUpUI.AddPopUp("you can't teleport right now", "easterbunny")
				return
			end

			Client.Events.ChooseTeleporter:FireServer(v6, p2)
			v3 = nil
			Client.MapDrawClient.CloseMap()
		end)
	end

	Client.MapDrawClient.OpenMap()
end

Client.Events.ChooseTeleporter:Connect(function(p, p2)
	if localPlayer.Character and localPlayer.Character:HasTag("CarryingEasterBunnyEgg") then
		Client.PopUpUI.AddPopUp("you can't teleport right now", "easterbunny")
	else
		OpenTeleporter(p, p2)
	end
end)
Client.Events.CloseTeleporter:Connect(function()
	Client.MapDrawClient.CloseMap()
end)

function TeleporterClient.Init()
	task.spawn(function() end)
end

Client.Utility.ForAllTagged("Teleporter", InitiateTeleporter)
return TeleporterClient