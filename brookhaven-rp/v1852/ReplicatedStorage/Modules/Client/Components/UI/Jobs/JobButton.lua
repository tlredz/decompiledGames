local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local v = Component.new({
	Tag = "JobButton"
})
local JobUtil = require(ReplicatedStorage.Modules.Shared.Game.JobUtil)
local flag = false

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local name = self.Instance.Name
	local jobNameFromId = JobUtil.getJobNameFromId(name)
	self._Janitor:Add(self.Instance.MouseButton1Click:connect(function()
		if flag then
			return
		end

		TelemetryController.SendClientInteraction("filterClick", {
			filter = self.Instance.Parent:GetAttribute("CurrentFilter"),
			itemType = "Jobs",
			name = self.Instance.Name
		})
		flag = true

		if PlayerBagUtil.GetPlayerBagInstance(Players.LocalPlayer, "Job"):FindFirstChild("JobName").Value == jobNameFromId then
			Remotes.fireServer("QuitJob", jobNameFromId)
		else
			Remotes.fireServer("GiveJobUIMenu", jobNameFromId)
		end

		task.wait(0.3)
		flag = false
	end))
	self._Janitor:Add(Remotes.connect("JobMainUIOpen", function(p2: string)
		if p2 == jobNameFromId then
			self.Instance:AddTag("Checked")
		else
			self.Instance:RemoveTag("Checked")
		end
	end))
	self._Janitor:Add(Remotes.connect("JobMainUIClose", function()
		self.Instance:RemoveTag("Checked")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v