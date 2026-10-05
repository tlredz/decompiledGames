local AntiFlingClient = {}
local localPlayer = game.Players.LocalPlayer
require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")

function CharacterAdded(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local preSimulationConnection = nil
	preSimulationConnection = RunService.PreSimulation:Connect(function()
		if not humanoidRootPart then
			preSimulationConnection:Disconnect()
			return
		end

		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity

		if assemblyLinearVelocity.Magnitude > 300 then
			print("anti-fling")
			humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity.Unit * 100
		end
	end)
end

function AntiFlingClient.Init()
	task.spawn(function()
		localPlayer.CharacterAdded:Connect(CharacterAdded)

		if localPlayer.Character then
			CharacterAdded(localPlayer.Character)
		end
	end)
end

return AntiFlingClient