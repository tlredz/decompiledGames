local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local v = Component.new({
	Tag = "EmployeeOnlyDoor"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local jobName = self.Instance:GetAttribute("JobName")

	if jobName == nil then
		jobName = self.Instance.Name
	end

	self.requiredJob = jobName
	local jobBag = PlayerBagUtil.WaitForInstanceFromBag(Players.LocalPlayer, "Job")

	if jobBag == nil then
		warn((`[EmployeeOnlyDoor] No Job bag found for {Players.LocalPlayer.Name}`))
		return
	end

	self.jobBag = jobBag
	local jobName2 = jobBag:WaitForChild("JobName")
	self.jobNameValue = jobName2
	self._Janitor:Add(jobBag:GetPropertyChangedSignal("Value"):Connect(function()
		self:UpdateCollision()
	end))
	self._Janitor:Add(jobName2:GetPropertyChangedSignal("Value"):Connect(function()
		self:UpdateCollision()
	end))
	self:UpdateCollision()
end

function v:UpdateCollision()
	self.Instance.CanCollide = self.jobBag.Value ~= true or self.jobNameValue.Value ~= self.requiredJob
end

function v:Stop()
	self._Janitor:Destroy()
end

return v