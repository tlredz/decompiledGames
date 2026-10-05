local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function _G.MobileMouseUpdate(object)
	local currentCamera = workspace.CurrentCamera

	if _G.MobileShiftlock == false then
		_G.MobileMouse = object:GetMouse().Hit
	else
		_G.MobileMouse = CFrame.new(
			currentCamera.CFrame.Position,
			currentCamera.CFrame.Position + currentCamera.CFrame.LookVector
		) * CFrame.new(0, 35, -500)
	end
end

function _G.IsReady(instance)
	local v = true

	if not _G.CheckAlive_Character(instance) then
		v = false
		return false
	end

	if instance:FindFirstChild("Stun") and instance:FindFirstChild("Stun").Value > 0 then
		v = false
	end

	return instance:FindFirstChild("Humanoid").Sit ~= true and v
end

function _G.CheckAlive_Player(player)
	if player and player.Parent and player.Character and player.Character.Parent and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Parent and player.Character:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

function _G.CheckAlive_Character(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

function _G.ClearBV(instance)
	local humanoidRootPart = _G.CheckAlive_Character(instance) and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		for _, child in ipairs(humanoidRootPart:GetChildren()) do
			if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition")) then
				continue
			end

			child:Destroy()
		end
	end
end

function _G.CheckBV(instance)
	local v = false

	if not _G.CheckAlive_Character(instance) then
		v = true
		return true
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and (humanoidRootPart:FindFirstChildWhichIsA("BodyVelocity") or humanoidRootPart:FindFirstChildWhichIsA("BodyGyro") or humanoidRootPart:FindFirstChildWhichIsA("BodyPosition")) then
		return true
	end

	return v
end

function _G.IsEquip(childName)
	if _G.CheckAlive_Character(localPlayer.Character) and localPlayer.Character:FindFirstChild(childName) then
		return localPlayer.Character:FindFirstChild(childName)
	end

	return false
end