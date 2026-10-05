local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Common.Utils)

local function UseNewServerBrowser()
	local fFlag = v.FFlag.GetFFlag("NewServerBrowserEnabled")

	if fFlag ~= nil then
		return fFlag == true
	end

	if not RunService:IsClient() then
		return false
	end

	local localPlayer = Players.LocalPlayer
	return localPlayer ~= nil and localPlayer:GetAttribute("NewServerBrowserAB") == true
end

return UseNewServerBrowser