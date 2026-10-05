local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local RunService = game:GetService("RunService")
local v2 = nil

if require3(ReplicatedStorage2.ServerInfo).isTestGame() then
	v2 = v:GetGamepadConnected(Enum.UserInputType[RunService:IsStudio() and "Gamepad2" or "Gamepad1"]) and "Console" or v2
end

return v2 or ""