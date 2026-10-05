local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local ServerInfo = require(ReplicatedStorage.ServerInfo)

if ServerInfo.isDuelLobbyServer() or ServerInfo.isDungeonsLobbyServer() then
	return
end

local spinnyy = workspace:WaitForChild("Spawn", 1000000):WaitForChild("Spinnyy")
task.wait(2)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(dt)
	spinnyy.CFrame *= CFrame.Angles(0, 0.2 * dt, 0)
end)