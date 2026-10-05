local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Selection = game:GetService("Selection")
local v = pcall(function()
	return Selection:Get()
end)
return {
	resolveContainer = function()
		if v then
			return CoreGui
		end

		local localPlayer = RunService:IsClient() and Players.LocalPlayer

		if localPlayer then
			return localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 5)
		end

		return nil
	end
}