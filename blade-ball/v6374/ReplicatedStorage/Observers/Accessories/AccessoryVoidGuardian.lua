local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("AccessoryVoidGuardian", function(instance)
	local folder = instance:FindFirstAncestorWhichIsA("Folder")
	local seed = folder and folder:GetAttribute("Seed") or 0
	local side = instance:GetAttribute("Side") or 1
	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		instance.C0 = CFrame.Angles(0, (workspace:GetServerTimeNow() + seed) * 2 % 6.283185307179586, 0) * CFrame.new(
			2 * side,
			2,
			2 * side
		)
	end)
	return function()
		postSimulationConnection:Disconnect()
	end
end, { workspace })