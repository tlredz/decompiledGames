local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "CountdownTimer"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local timerLabel = self.Instance:WaitForChild("Container"):WaitForChild("TimerLabel")
	local arriveDays = timerLabel:WaitForChild("ArriveDays")
	local arriveHours = timerLabel:WaitForChild("ArriveHours")
	local dashDashDash = timerLabel:FindFirstChild("DashDashDash")
	local arrivesIn = timerLabel:WaitForChild("ArrivesIn")
	local targetTimestamp = self.Instance:GetAttribute("TargetTimestamp")
	local soonThresholdSeconds = self.Instance:GetAttribute("SoonThresholdSeconds") or 0
	local soonText = self.Instance:GetAttribute("SoonText") or "ARRIVES SOON!"
	local updateIntervalSeconds = self.Instance:GetAttribute("UpdateIntervalSeconds") or 1800
	local flag = true
	self._Janitor:Add(function()
		flag = false
	end)
	task.spawn(function()
		while flag do
			local v2 = targetTimestamp - DateTime.now().UnixTimestamp

			if soonThresholdSeconds > 0 and v2 <= soonThresholdSeconds then
				arriveHours.Visible = false
				arriveDays.Visible = false

				if dashDashDash ~= nil then
					dashDashDash.Visible = false
				end

				arrivesIn.Text = soonText
				arrivesIn.Position = UDim2.fromScale(0.5, 0.5)
				break
			else
				local v3 = math.floor(v2 / 86400)
				local v4 = math.ceil(v2 % 86400 / 3600)
				arriveDays.Text = (v3 < 10 and v3 > 0 and "0" or "") .. tostring(v3) .. " DAYS"
				arriveHours.Text = (v4 < 10 and "0" or "") .. tostring(v4) .. " HOURS"
				task.wait(updateIntervalSeconds)
			end
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v