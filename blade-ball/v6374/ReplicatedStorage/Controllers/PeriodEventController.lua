local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.PeriodEvent.Events)
local v2 = require3(ReplicatedStorage2.Packages.Observers)
local v3 = require3(ReplicatedStorage2.ServerInfo)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Packages.Trove)
return {
	Start = function(_)
		local priorityEvent = v.GetPriorityEvent()
		v2.observeTag("PeriodEventNPC", function(instance)
			local maid = v5.new()
			local v6 = (v3.isDevPlaceGame() or v3.isTestGame()) and "TestPeriodEventEndTimestamp" or "PeriodEventEndTimestamp"

			local function updateTheRisingNPC()
				local fFlag = v4.FFlag.GetFFlag(v6, priorityEvent.EndTime)
				instance:SetAttribute("EndTime", fFlag)

				if priorityEvent.Id == "SerpentBreakout" then
					instance:SetAttribute("WindowName", "SerpentBreakout")
				end

				local hitbox = instance:FindFirstChild("Hitbox")
				local rankedLabel = hitbox and hitbox:FindFirstChild("RankedLabel", true)

				if rankedLabel then
					rankedLabel:SetAttribute("EndTime", fFlag)
				end
			end

			task.defer(updateTheRisingNPC)
			maid:Add(v4.FFlag.OnChange(updateTheRisingNPC))
			return function()
				maid:Destroy()
			end
		end)
		v2.observeTag("PeriodEventTimer", function(p)
			local function updateTheRisingNPC()
				local serverTimeNow = workspace:GetServerTimeNow()
				local fFlag = v4.FFlag.GetFFlag("InPeriodEvent", 7200)
				local v6 = math.floor(serverTimeNow / fFlag + 1) * fFlag

				if workspace:GetAttribute("InPeriodEvent") then
					p.Text = "NOW"
					return
				end

				local v7 = v6 - serverTimeNow

				if fFlag - 3 < v7 then
					p.Text = ""
				else
					p.Text = `Next event in: {v4.ValueConvertor:FormatTimeWithDaysFull(v6 - serverTimeNow)}`
				end
			end

			local connection = v4.Thread.Every(1, updateTheRisingNPC)
			return function()
				connection:Disconnect()
				connection = nil
			end
		end)
	end
}