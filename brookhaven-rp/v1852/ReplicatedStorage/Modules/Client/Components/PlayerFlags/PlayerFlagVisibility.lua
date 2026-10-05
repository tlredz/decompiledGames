local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local v = Component.new({
	Tag = "PlayerFlagVisibility",
	Ancestors = { workspace, StarterGui, Players }
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Update()
	local playerFlagHides = self.Instance:GetAttribute("PlayerFlagHides") == true
	local v2 = PlayerFlag.IsEnabled(self.flagName) ~= playerFlagHides
	local instance = self.Instance
	local parent

	if v2 then
		parent = self.initialParent
	else
		parent = StarterGui
	end

	instance.Parent = parent
end

function v:Start()
	local playerFlag = self.Instance:GetAttribute("PlayerFlag")
	assert(typeof(playerFlag) == "string", "PlayerFlagVisibility requires a PlayerFlag string attribute")
	self.flagName = playerFlag
	self.initialParent = self.Instance.Parent
	self:Update()
	self._Janitor:AddPromise(ReplicatedDataController.GetSessionReplicaPromise():andThen(function(object2)
		self._Janitor:Add(object2:OnSet({ "PlayerFlags", playerFlag }, function()
			self:Update()
		end), "Disconnect")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v