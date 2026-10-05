local NightSkipMachineClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local v = 0
local v2 = 0
local flag = false
Client.Events.AnimateNightSkipMachine:Connect(function(_) end)

function ResetNightSkipMachine(instance)
	flag = false
	task.spawn(function()
		local machineHum = instance:WaitForChild("Main"):WaitForChild("MachineHum")
		local boom1 = instance:WaitForChild("Main"):WaitForChild("Boom1")
		local electricShock = instance:WaitForChild("Main"):WaitForChild("ParticleAttachment"):WaitForChild("ElectricShock")
		local proximityInteraction = instance:WaitForChild("Main"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
		proximityInteraction.Enabled = true
		v = 0.12
		v2 = 0.1
		instance.Main.PointLight.Enabled = false
		electricShock:Emit(20)
		machineHum:Stop()
		boom1:Play()
	end)
end

function StartSpinningHands(instance)
	task.spawn(function()
		if flag then
			return
		end

		flag = true

		while flag do
			local v3 = RunService.RenderStepped:Wait()
			local hands = instance:FindFirstChild("Hands")

			if not hands then
				continue
			end

			local handSmall = hands:FindFirstChild("HandSmall")
			local handLarge = hands:FindFirstChild("HandLarge")

			if not (handSmall and handLarge) then
				continue
			end

			handSmall:PivotTo(handSmall:GetPivot() * CFrame.Angles(v2 * v3, 0, 0))
			handLarge:PivotTo(handLarge:GetPivot() * CFrame.Angles(v * v3, 0, 0))
		end
	end)
end

function NightSkipMachineClient.OpenActivationMenu(instance)
	local useCost = instance:GetAttribute("UseCost") or 1

	if instance:GetAttribute("Charged") then
		return
	end

	Client.GemActivateClient.OpenMenu(instance, useCost)
end

function TemporalAccelerometerAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local function update()
		local charged = instance:GetAttribute("Charged")
		local active = instance:GetAttribute("Active")
		instance.Main.PointLight.Enabled = charged or active
		local proximityInteraction = instance:WaitForChild("Main"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
		proximityInteraction.Enabled = not (charged or active)
		local machineHum = instance:WaitForChild("Main"):WaitForChild("MachineHum")
		local boom1 = instance:WaitForChild("Main"):WaitForChild("Boom1")
		machineHum.PlaybackSpeed = active and 2 or 1
		machineHum.Volume = active and 0.3 or 0.1

		if (charged or active) and not flag then
			StartSpinningHands(instance)
			machineHum:Play()
			boom1:Play()
		elseif flag and not (charged or active) then
			ResetNightSkipMachine(instance)
		end

		if active then
			v = 12
			v2 = 1
		elseif charged then
			v = 0.12
			v2 = 0.1
		else
			v = 0
			v2 = 0
		end
	end

	instance:GetAttributeChangedSignal("Charged"):Connect(update)
	instance:GetAttributeChangedSignal("Active"):Connect(update)
	update()
end

function NightSkipMachineClient.Init()
	Client.Utility.ForAllTagged("NightSkipMachine", TemporalAccelerometerAdded)
end

return NightSkipMachineClient