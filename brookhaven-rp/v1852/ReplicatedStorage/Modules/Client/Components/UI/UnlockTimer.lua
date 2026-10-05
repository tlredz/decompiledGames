local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TimeUtil = require(ReplicatedStorage.Modules.Shared.Utils.TimeUtil)
local v = Component.new({
	Tag = "UnlockTimer"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local textLabel = self.Instance:WaitForChild("BillboardGui"):WaitForChild("TextLabel")
	self._thread = task.spawn(function()
		while true do
			textLabel.Text = self:GetText()
			task.wait(1)
		end
	end)
	self._Janitor:Add(function()
		task.cancel(self._thread)
	end)
end

function v:GetText()
	local unixTime = self.Instance:GetAttribute("UnixTime")
	local unlockedText = self.Instance:GetAttribute("UnlockedText")
	local lockedText = self.Instance:GetAttribute("LockedText")
	local textOverride = self.Instance:GetAttribute("TextOverride")
	local serverTimeNow = workspace:GetServerTimeNow()

	if textOverride then
		return textOverride
	end

	if unixTime <= serverTimeNow then
		return unlockedText
	end

	local formatRelativeTime, v2 = TimeUtil.formatRelativeTime(unixTime - serverTimeNow)

	if v2 > 0 then
		local formatRelativeTime2 = TimeUtil.formatRelativeTime(v2)
		return lockedText .. " " .. formatRelativeTime:upper() .. " " .. formatRelativeTime2:upper()
	else
		return lockedText .. " " .. formatRelativeTime:upper()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v