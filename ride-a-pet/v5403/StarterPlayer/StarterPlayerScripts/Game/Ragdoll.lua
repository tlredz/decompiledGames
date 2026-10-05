local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/Ragdoll", 1e999).OnClientEvent:Connect(function(flag: boolean, assemblyLinearVelocity: Vector3?)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	if flag then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") and typeof(assemblyLinearVelocity) == "Vector3" then
			humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
		end
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)