local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
_G.LeaderboardEnabled = {}
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local clientGameModules = ReplicatedStorage2.ClientGameModules
local _ = ReplicatedStorage2.Common
local packages = ReplicatedStorage2.Packages
require3(packages.Net)
require3(packages.Replion)
require3(clientGameModules.GuiHandler)
require3(script.Types)
require3(packages.Promise)
local v = require3(ReplicatedStorage2.ServerInfo)
local localPlayer = nil
local v2 = {}
local v3 = {}
local LeaderboardController = {
	Init = function(self)
		for _, moduleScript in script.Components:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local v4 = require3(moduleScript)
			v2[moduleScript.Name] = v4
		end
	end,
	GetWrappedChildSingle = function(_, p: string, p2: string)
		if v3[p][p2] then
			return v3[p][p2][1]
		end
	end,
	GetWrappedChild = function(_, p: string, p2: string, p3)
		if v3[p][p2] then
			return table.find(v3[p][p2], p3)
		end
	end,
	AddToTree = function(self, p: string, p2: string, p3)
		if not v3[p] then
			v3[p] = {}
		end

		if not v3[p][p2] then
			v3[p][p2] = {}
		end

		table.insert(v3[p][p2], p3)
	end
}

function LeaderboardController:BuildChildren(folder)
	for _, guiObject in folder:GetDescendants() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local type = guiObject:GetAttribute("Type")

		if not type then
			continue
		end

		local v4 = v2[type]

		if v4 then
			local v5 = v4:Init(guiObject)
			LeaderboardController:AddToTree(folder.Name, type, v5)
		else
			print((`could not find component for {type}`))
		end
	end
end

function LeaderboardController.Start(_)
	localPlayer = Players.LocalPlayer
	task.delay(5, function()
		if v.isDuelMatchServer() then
			return
		end

		local tagged = CollectionService:GetTagged("Leaderboard")

		for _, v4 in tagged do
			LeaderboardController:BuildChildren(v4)
		end
	end)
end

return LeaderboardController