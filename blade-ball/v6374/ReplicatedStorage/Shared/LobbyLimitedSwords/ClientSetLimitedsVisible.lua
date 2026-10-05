local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Shared.LimitedSwordEvent)
local v3 = require3(ReplicatedStorage2.Shared.LimitedSwordPacksData)
local limitedSwordsStands = ReplicatedStorage2.Misc.LimitedSwordsStands
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)

if not ReplicatedStorage2:FindFirstChild("LimitedSwords") then
	local folder = Instance.new("Folder")
	folder.Name = "LimitedSwords"
	folder.Parent = ReplicatedStorage2
end

local function getStartDate(p)
	return p.FFlagStartTime and v4:GetKey(p.FFlagStartTime) or p.RootFFlagStartTime and v4:GetKey(p.RootFFlagStartTime) or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEndDate(p)
	return p.FFlagEndTime and v4:GetKey(p.FFlagEndTime) or p.RootFFlagEndTime and v4:GetKey(p.RootFFlagEndTime) or 0
end

return function(parent)
	workspace:WaitForChild("Spawn", 1000000)

	local function shouldBeVisible(p, p2, p3)
		return p2 <= p and p < p3
	end

	for childName, event in v2.Events do
		local child = parent:FindFirstChild(childName)
		local v5

		if child then
			v5 = true
		else
			child = limitedSwordsStands:FindFirstChild(childName)

			if not child then
				continue
			end

			v5 = false
		end

		local v6 = childName
		local duration = event.Duration
		local timerLabel = child.TimerBGUI.TimerLabel
		v.Thread.Every(1, function()
			local now = os.time()
			local v9 = nil
			local key = nil
			task.spawn(function()
				if v6 == "SwordPacks" then
					for k, v10 in v3 do
						local key2 = v10.FFlagStartTime and v4:GetKey(v10.FFlagStartTime) or not v10.RootFFlagStartTime and 0 or v4:GetKey(v10.RootFFlagStartTime) or 0
						local endDate = getEndDate(v10) -- equivalent call inferred; original call site unknown
						local v11 = now
						local v12

						if key2 <= v11 then
							v12 = v11 < endDate
						else
							v12 = false
						end

						if not v12 then
							continue
						end

						if v9 then
							key2 = math.min(v9, key2)
						end

						v9 = key2

						if key then
							endDate = math.max(key, endDate)
						end

						key = endDate
					end
				elseif v6 == v2.Active then
					key = v4:GetKey("LimitedSwordTimerOverride")

					if key == 0 or typeof(key) ~= "number" then
						key = nil
					end
				end
			end)
			local v10 = key or duration.Max

			if v10 < now and child then
				child.Parent = limitedSwordsStands
			elseif child.Parent ~= parent then
				child.Parent = parent
			end

			local v11

			if (v9 or duration.Min) <= now then
				v11 = now < v10
			else
				v11 = false
			end

			if v11 ~= v5 then
				local v12 = child
				local parent2

				if v11 then
					parent2 = parent
				else
					parent2 = limitedSwordsStands
				end

				v12.Parent = parent2
				v5 = v11
			end

			if v5 then
				local v12 = math.max(0, v10 - now)
				timerLabel.Text = v.ValueConvertor:FormatTimeWithDaysFull(v12)
			end
		end)
	end
end