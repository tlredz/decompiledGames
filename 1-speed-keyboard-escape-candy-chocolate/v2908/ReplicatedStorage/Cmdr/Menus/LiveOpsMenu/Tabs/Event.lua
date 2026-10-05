local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local Lib = require(script.Parent.Parent.Lib)
require(script.Parent.Parent.Types)
return {
	DisplayName = "Event",
	Permission = "cui.liveops.event",
	Order = 0,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v = 10
		local v2 = nil
		local now = 0
		local v3 = -1
		local v4 = nil
		local count = 0
		local flag = false
		local v5 = object:AddField(function(object2)
			object2:SetText("Event storm"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v6 = object:AddField(function(object2)
			object2:SetText("Details"):SetValue(""):SetEnabled(false)
		end)
		object:AddNumberField(function(object2)
			object2:SetText("Duration (minutes)"):SetNumberFilter(1, 1440):SetValue(v):SetOnChangedUnfocus(function(p)
				v = p
			end)
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Render(p)
			v2 = p
			now = os.clock()
			v3 = -1
			v5:SetValue(p.EventCoins.Status)
			v6:SetValue(p.EventCoins.Detail)
		end

		local function fn()
			if flag or not Lib.GetSnapshot then
				return
			end

			count += 1
			local v7 = count
			Lib.GetSnapshot:Fire({}):andThen(function(p)
				if flag or v7 ~= count or not p then
					return
				end

				Render(p) -- equivalent call inferred; original call site unknown
			end):catch(function(p)
				if flag or v7 ~= count then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`LiveOps refresh failed: {tostring(p)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		local function Act(p)
			if flag or not Lib.ExecuteAction then
				return
			end

			Lib.ExecuteAction:Fire(p):andThen(function(data)
				if flag or not data then
					return
				end

				Render(data.Snapshot) -- equivalent call inferred; original call site unknown
				local message = data.Message
				local v8

				if data.Ok then
					v8 = Color3.fromRGB(100, 255, 100)
				else
					v8 = Color3.fromRGB(255, 100, 100)
				end

				NotificationSystem:ShowGeneralNotification(message, v8, 4)

				if data.Ok then
					task.delay(0.5, fn)
				end
			end):catch(function(p2)
				if flag then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`LiveOps action failed: {tostring(p2)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Start storm"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):SetButtonCallback(function()
					Act({
						System = "EventCoins",
						Action = "start",
						DurationSeconds = v * 60
					})
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Stop override"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):SetButtonCallback(function()
					Act({
						System = "EventCoins",
						Action = "stop"
					})
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh event state"):SetYSize(22):SetEnabledPermission("cui.liveops.event"):SetButtonCallback(fn)
		end)
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v7 = v2

			if flag or not v7 then
				return
			end

			local v8 = v7.Timestamp + math.max(0, os.clock() - now)
			local v9 = math.floor(v8)

			if v9 == v3 then
				return
			end

			v3 = v9
			local untilTimestamp = v7.EventCoins.UntilTimestamp
			local v11

			if untilTimestamp then
				v11 = Lib.FormatRemaining(untilTimestamp, v8)
			else
				v11 = v7.EventCoins.Detail
			end

			v6:SetValue(v11)

			if untilTimestamp and untilTimestamp <= v8 and v4 ~= untilTimestamp then
				v4 = untilTimestamp
				fn()
			end
		end)
		v5:GetUI().Destroying:Connect(function()
			flag = true
			count += 1
			heartbeatConnection:Disconnect()
			v2 = nil
		end)
		fn()
	end
}