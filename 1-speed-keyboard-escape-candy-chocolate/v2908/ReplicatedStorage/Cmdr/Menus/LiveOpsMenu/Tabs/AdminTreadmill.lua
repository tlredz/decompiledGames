local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local Lib = require(script.Parent.Parent.Lib)
require(script.Parent.Parent.Types)
return {
	DisplayName = "Admin Treadmill",
	Permission = "cui.liveops.adminTreadmill",
	Order = 25,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v = nil
		local now = 0
		local v2 = -1
		local v3 = nil
		local count = 0
		local flag = false
		local fn
		local v4 = object:AddField(function(object2)
			object2:SetText("Status"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v5 = object:AddButton(function(object2)
			object2:SetButtonText("Start treadmill"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true)
		end)

		local function renderCountdown()
			local v6 = v

			if not v6 then
				return
			end

			local adminAbuseTreadmill = v6.AdminAbuseTreadmill
			local v7 = v6.Timestamp + math.max(0, os.clock() - now)
			local v8

			if adminAbuseTreadmill.UntilTimestamp then
				v8 = Lib.FormatRemaining(adminAbuseTreadmill.UntilTimestamp, v7)
			else
				v8 = adminAbuseTreadmill.Detail
			end

			v4:SetValue((`{adminAbuseTreadmill.Status} | {v8}`))
			v5:SetEnabled(adminAbuseTreadmill.Available and adminAbuseTreadmill.Status == "Inactive")
			local untilTimestamp = adminAbuseTreadmill.UntilTimestamp

			if untilTimestamp and untilTimestamp <= v7 and v3 ~= untilTimestamp then
				v3 = untilTimestamp
				fn()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function render(p)
			v = p
			now = os.clock()
			v2 = -1
			renderCountdown()
		end

		local function act(p)
			if flag or not Lib.ExecuteAction then
				return
			end

			Lib.ExecuteAction:Fire(p):andThen(function(data)
				if flag or not data then
					return
				end

				render(data.Snapshot) -- equivalent call inferred; original call site unknown
				local message = data.Message
				local v7

				if data.Ok then
					v7 = Color3.fromRGB(100, 255, 100)
				else
					v7 = Color3.fromRGB(255, 100, 100)
				end

				NotificationSystem:ShowGeneralNotification(message, v7, 4)

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

		fn = function()
			if flag or not Lib.GetSnapshot then
				return
			end

			count += 1
			local v6 = count
			Lib.GetSnapshot:Fire({}):andThen(function(p)
				if flag or v6 ~= count or not p then
					return
				end

				render(p) -- equivalent call inferred; original call site unknown
			end):catch(function(p)
				if flag or v6 ~= count then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`LiveOps refresh failed: {tostring(p)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		v5:SetButtonCallback(function()
			act({
				System = "AdminAbuseTreadmill",
				Action = "start"
			})
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Force stop treadmill"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
				act({
					System = "AdminAbuseTreadmill",
					Action = "forceStop"
				})
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh treadmill state"):SetYSize(22):SetEnabledPermission("cui.liveops.adminTreadmill"):SetButtonCallback(fn)
		end)
		local v6 = false

		local function queueRefresh()
			if flag or v6 then
				return
			end

			v6 = true
			task.defer(function()
				v6 = false
				fn()
			end)
		end

		local connection = CollectionService:GetInstanceAddedSignal("AdminAbuseTreadmill"):Connect(queueRefresh)
		local connection2 = CollectionService:GetInstanceRemovedSignal("AdminAbuseTreadmill"):Connect(queueRefresh)
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v7 = v

			if flag or not v7 then
				return
			end

			local v8 = math.floor(v7.Timestamp + math.max(0, os.clock() - now))

			if v8 == v2 then
				return
			end

			v2 = v8
			renderCountdown()
		end)
		v4:GetUI().Destroying:Connect(function()
			flag = true
			count += 1
			heartbeatConnection:Disconnect()
			connection:Disconnect()
			connection2:Disconnect()
			v = nil
		end)
		fn()
	end
}