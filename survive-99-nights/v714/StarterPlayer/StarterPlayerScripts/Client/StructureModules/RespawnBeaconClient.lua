local createVector = vector.create
local RespawnBeaconClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.AnimateRespawnAtBeacon:Connect(function(instance, p)
	local flag = false
	localPlayer.CharacterAdded:Once(function()
		flag = true
	end)
	local respawnCF = instance:WaitForChild("RespawnCF")
	local serverTimeNow = workspace:GetServerTimeNow()

	if p < serverTimeNow then
		return
	end

	local v = p - serverTimeNow

	if v > 4 then
		v -= 1.5
		task.wait(1)
	end

	task.spawn(function()
		local respawnChargeUp = instance:WaitForChild("Main"):WaitForChild("RespawnChargeUp")
		local v2 = p - workspace:GetServerTimeNow()

		if v2 > 0 then
			respawnChargeUp.PlaybackSpeed = respawnChargeUp.TimeLength / v2
			respawnChargeUp:Play()
		end
	end)

	if not localPlayer.Character then
		task.spawn(function()
			localPlayer.CharacterAdded:Wait()

			for _, emitter in pairs(respawnCF.OnRespawned:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
				end
			end
		end)
	end

	if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
		return
	end

	local cFrame = workspace.CurrentCamera.CFrame
	local v2 = respawnCF.CFrame * CFrame.new(0, 0, -14) * CFrame.Angles(0, 3.141592653589793, 0) + createVector(0, 5, 0)
	local cFrame2 = respawnCF.CFrame
	local cframe = CFrame.lookAt(v2.Position, cFrame2.Position)

	local function tweenCamera(p2)
		if flag then
			return true
		end

		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera.CFrame = cFrame:Lerp(cframe, p2)
	end

	Client.TweenModule.new(tweenCamera, v, "Quad", "InOut"):Play()
	task.spawn(function()
		task.wait(v)
		instance:WaitForChild("Main"):WaitForChild("RespawnNoise"):Play()
	end)
end)

function RespawnBeaconClient.PlayGemAddedParticles(instance)
	local respawnCF = instance:WaitForChild("RespawnCF")
	task.spawn(function()
		for _, emitter in pairs(respawnCF.RedGemAddedParticles:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
			end
		end
	end)
end

function RespawnBeaconClient.OpenRespawnBeaconMenu(instance)
	local rechargeCost = instance:GetAttribute("RechargeCost") or 1

	if instance:GetAttribute("Charged") then
		return
	end

	Client.GemActivateClient.OpenMenu(instance, rechargeCost)
end

function RespawnBeaconAdded(instance)
	local function update()
		local charged = instance:GetAttribute("Charged")
		task.spawn(function()
			local offLight = instance:WaitForChild("OffLight")
			offLight.Color = charged and Color3.fromRGB(31, 20, 20) or Color3.fromRGB(255, 89, 89)
			local offLight_2 = instance:WaitForChild("OffLight")
			offLight_2.Material = charged and Enum.Material.SmoothPlastic or Enum.Material.Neon
			local pointLight = instance:WaitForChild("OffLight"):WaitForChild("PointLight")
			pointLight.Enabled = not charged
			local onLight = instance:WaitForChild("OnLight")
			onLight.Color = charged and Color3.fromRGB(75, 151, 75) or Color3.fromRGB(22, 44, 22)
			local onLight_2 = instance:WaitForChild("OnLight")
			onLight_2.Material = charged and Enum.Material.Neon or Enum.Material.SmoothPlastic
			local pointLight_2 = instance:WaitForChild("OnLight"):WaitForChild("PointLight")
			pointLight_2.Enabled = charged
			local cylinders = instance:WaitForChild("Cylinders")
			cylinders.Color = charged and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(86, 36, 36)
			local cylinders_2 = instance:WaitForChild("Cylinders")
			cylinders_2.Material = charged and Enum.Material.Neon or Enum.Material.Plaster
			local innerLights = instance:WaitForChild("Inner Lights")
			innerLights.Color = charged and Color3.fromRGB(18, 238, 212) or Color3.fromRGB(32, 43, 42)
			local innerLights_2 = instance:WaitForChild("Inner Lights")
			innerLights_2.Material = charged and Enum.Material.Neon or Enum.Material.SmoothPlastic

			if charged == true then
				instance:WaitForChild("Main"):WaitForChild("MachineHum"):Play()
				local proximityInteraction = instance:WaitForChild("Main"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
				proximityInteraction.Enabled = false
			else
				instance:WaitForChild("Main"):WaitForChild("MachineHum"):Stop()
				local proximityInteraction_2 = instance:WaitForChild("Main"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
				proximityInteraction_2.Enabled = true
			end
		end)
	end

	instance:GetAttributeChangedSignal("Charged"):Connect(update)
	local charged = instance:GetAttribute("Charged")
	task.spawn(function()
		local offLight = instance:WaitForChild("OffLight")
		offLight.Color = charged and Color3.fromRGB(31, 20, 20) or Color3.fromRGB(255, 89, 89)
		local offLight_2 = instance:WaitForChild("OffLight")
		offLight_2.Material = charged and Enum.Material.SmoothPlastic or Enum.Material.Neon
		local pointLight = instance:WaitForChild("OffLight"):WaitForChild("PointLight")
		pointLight.Enabled = not charged
		local onLight = instance:WaitForChild("OnLight")
		onLight.Color = charged and Color3.fromRGB(75, 151, 75) or Color3.fromRGB(22, 44, 22)
		local onLight_2 = instance:WaitForChild("OnLight")
		onLight_2.Material = charged and Enum.Material.Neon or Enum.Material.SmoothPlastic
		local pointLight_2 = instance:WaitForChild("OnLight"):WaitForChild("PointLight")
		pointLight_2.Enabled = charged
		local cylinders = instance:WaitForChild("Cylinders")
		cylinders.Color = charged and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(86, 36, 36)
		local cylinders_2 = instance:WaitForChild("Cylinders")
		cylinders_2.Material = charged and Enum.Material.Neon or Enum.Material.Plaster
		local innerLights = instance:WaitForChild("Inner Lights")
		innerLights.Color = charged and Color3.fromRGB(18, 238, 212) or Color3.fromRGB(32, 43, 42)
		local innerLights_2 = instance:WaitForChild("Inner Lights")
		innerLights_2.Material = charged and Enum.Material.Neon or Enum.Material.SmoothPlastic

		if charged == true then
			instance:WaitForChild("Main"):WaitForChild("MachineHum"):Play()
			local proximityInteraction = instance:WaitForChild("Main"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
			proximityInteraction.Enabled = false
		else
			instance:WaitForChild("Main"):WaitForChild("MachineHum"):Stop()
			local proximityInteraction_2 = instance:WaitForChild("Main"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
			proximityInteraction_2.Enabled = true
		end
	end)
end

function RespawnBeaconClient.Init()
	Client.Utility.ForAllTagged("RespawnBeacon", RespawnBeaconAdded)
end

return RespawnBeaconClient