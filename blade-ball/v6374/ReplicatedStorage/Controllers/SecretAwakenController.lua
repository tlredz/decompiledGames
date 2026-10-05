local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local clientGameModules = ReplicatedStorage2.ClientGameModules
local common = ReplicatedStorage2.Common
local packages = ReplicatedStorage2.Packages
require3(packages.Net)
local v = require3(packages.Replion)
require3(clientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.Statable)
require3(script.Types)
require3(common.Utils)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v2 = nil
local secretUpgrade = nil
local v3 = {}
local v4 = {}
local SecretAwakenController = {
	Init = function(self)
		for _, moduleScript in script.Components:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local v5 = require3(moduleScript)
			v3[moduleScript.Name] = v5
		end
	end,
	GetWrappedChildSingle = function(_, p: string)
		if v4[p] then
			return v4[p][1]
		end
	end,
	AddToTree = function(self, p: string, p2)
		if not v4[p] then
			v4[p] = {}
		end

		table.insert(v4[p], p2)
	end
}

function SecretAwakenController:BuildChildren()
	for _, guiObject in secretUpgrade:GetDescendants() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local type = guiObject:GetAttribute("Type")

		if not type then
			continue
		end

		local v5 = v3[type]

		if v5 then
			SecretAwakenController:AddToTree(type, (v5:Init(guiObject, v2)))
		else
			print((`could not find component for {type}`))
		end
	end
end

function SecretAwakenController.Start(_)
	localPlayer = Players.LocalPlayer
	playerGui = localPlayer:WaitForChild("PlayerGui")
	secretUpgrade = playerGui:WaitForChild("SecretUpgrade")
	v2 = v.Client:WaitReplion("Data")
	SecretAwakenController:BuildChildren()
end

return SecretAwakenController