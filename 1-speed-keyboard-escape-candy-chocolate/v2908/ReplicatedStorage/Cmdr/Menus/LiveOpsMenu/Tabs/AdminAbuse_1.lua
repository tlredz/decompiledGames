local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local AdminAbuseEvent = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent)
local Lib = require(script.Parent.Parent.Lib)
require(script.Parent.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatTimelineTime(p: number)
	local v = math.max(0, (math.floor(p)))
	return string.format("%02d:%02d", math.floor(v / 60), v % 60)
end

return {
	DisplayName = "Admin Abuse",
	Permission = "cui.liveops.adminAbuse",
	Order = 20,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v = false
		local v2 = 10
		local v3 = ""
		local v4 = "all"
		local v5 = "all"
		local count = 0
		local v6 = nil
		local now = 0
		local v7 = -1
		local v8 = nil
		local flag = false
		local fn
		local fn2
		local fn3
		local v9 = 1
		local v10 = false
		local v11 = nil
		local v12 = object:AddField(function(object2)
			object2:SetText("Main slot"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v13 = object:AddField(function(object2)
			object2:SetText("Event slot"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v14 = nil
		local v15 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.5)
			v14 = object2.LeftComponents:AddButton(function(object3)
				object3:SetButtonText("Stop main"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
					local v16 = v6

					if not v16 or v16.AdminSlots.main.Status == "Inactive" then
						return
					end

					fn3({
						System = "AdminAbuse",
						Action = "stopModule",
						Module = v16.AdminSlots.main.Status
					})
				end)
			end)
			v15 = object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Stop event"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
					local v16 = v6

					if not v16 or v16.AdminSlots.event.Status == "Inactive" then
						return
					end

					fn3({
						System = "AdminAbuse",
						Action = "stopModule",
						Module = v16.AdminSlots.event.Status
					})
				end)
			end)
		end)
		local v16 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizeAbsolute(22)
			object2.LeftComponents:AddCheckbox(function(object3)
				object3:ShowCheckboxOnly():SetYSize(22):SetValue(v):SetOnChanged(function(p)
					v = p
					v16:SetEnabled(p)
				end)
			end)
			v16 = object2.RightComponents:AddNumberField(function(object3)
				object3:SetText("Duration override (minutes)"):SetNumberFilter(1, 1440):SetValue(v2):SetEnabled(v):SetOnChangedUnfocus(function(p)
					v2 = p
				end)
			end)
		end)
		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.6)
			object2.LeftComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder("search..."):SetValue(""):SetOnChangedRaw(function(value)
					v3 = string.lower(value)

					if v6 then
						fn2(v6)
					end
				end)
			end)
			object2.RightComponents:AddSplit(function(object3)
				object3:SetLeftSizePercent(0.5)
				object3.LeftComponents:AddDropdown(function(object4)
					object4:SetTextVisible(false):SetChoiceList({ "all", "legacy", "framework" }):SetSelected("all"):SetOnChanged(function(p)
						if p == "all" or p == "legacy" or p == "framework" then
							v4 = p

							if v6 then
								fn2(v6)
							end
						end
					end)
				end)
				object3.RightComponents:AddDropdown(function(object4)
					object4:SetTextVisible(false):SetChoiceList({ "all", "event", "main" }):SetSelected("all"):SetOnChanged(function(p)
						if p == "all" or p == "event" or p == "main" then
							v5 = p

							if v6 then
								fn2(v6)
							end
						end
					end)
				end)
			end)
		end)
		local v17 = object:AddList(function(object2)
			object2:SetSizeY(145)
			object2.Components:AddText(function(object3)
				object3:SetText("Loading events..."):SetYSize(22)
			end)
		end)
		local v18 = object:AddSlider(function(object2)
			object2:SetText(RunService:IsStudio() and "Main event time (inactive)" or "Main event time (Studio only)"):SetEnabledPermission("cui.liveops.adminAbuse.timeline"):SetRange(
				0,
				1
			):SetIncrement(1):SetValue(0):SetEnabled(false):SetOnChanged(function(value)
				if not (RunService:IsStudio() and v10 and Lib.SeekAdminAbuseTimeline) then
					return
				end

				local elapsedSeconds = math.clamp(value, 0, v9)
				v11 = elapsedSeconds
				Lib.SeekAdminAbuseTimeline:Fire({
					ElapsedSeconds = elapsedSeconds
				}):andThen(function(p)
					if flag or v11 ~= elapsedSeconds then
						return
					end

					if p == nil or not p.Ok then
						v11 = nil
						warn((`[LiveOpsMenu] Admin Abuse timeline seek failed: {not p and "No response" or p.Message}`))
					end
				end):catch(function(p)
					if flag or v11 ~= elapsedSeconds then
						return
					end

					v11 = nil
					warn((`[LiveOpsMenu] Admin Abuse timeline seek failed: {tostring(p)}`))
				end)
			end)
		end)

		local function RenderTimeline()
			local activeTimeline = AdminAbuseEvent.getActiveTimeline("main")
			local durationSeconds

			if activeTimeline then
				durationSeconds = activeTimeline.durationSeconds
			end

			local isStudio = RunService:IsStudio()

			if isStudio then
				if activeTimeline == nil or activeTimeline.source ~= "framework" or durationSeconds == nil or not (durationSeconds > 0) then
					isStudio = false
				else
					isStudio = Lib.SeekAdminAbuseTimeline ~= nil
				end
			end

			local v19 = not isStudio and 1 or durationSeconds

			if v9 ~= v19 then
				v9 = v19
				v18:SetRange(0, v19)
			end

			if v10 ~= isStudio then
				v10 = isStudio
				v18:SetEnabled(isStudio)
			end

			if activeTimeline then
				if v11 ~= nil and math.abs(activeTimeline.elapsedSeconds - v11) <= 1 then
					v11 = nil
				end

				local v20 = math.clamp(v11 or activeTimeline.elapsedSeconds, 0, durationSeconds or 1e999)
				local v21

				if durationSeconds then
					v21 = FormatTimelineTime(durationSeconds)
				else
					v21 = "no duration"
				end

				v18:SetText((`{activeTimeline.name} ({FormatTimelineTime(v20)} / {v21})`))

				if v11 == nil then
					v18:SetValue(v20)
				end
			else
				v11 = nil
				v18:SetText(RunService:IsStudio() and "Main event time (inactive)" or "Main event time (Studio only)")
				v18:SetValue(0)
			end
		end

		local function RenderCountdowns()
			local v19 = v6

			if not v19 then
				return
			end

			local v20 = v19.Timestamp + math.max(0, os.clock() - now)
			local main = v19.AdminSlots.main
			local event = v19.AdminSlots.event
			local status = main.Status
			local v23

			if main.UntilTimestamp then
				v23 = Lib.FormatRemaining(main.UntilTimestamp, v20)
			else
				v23 = main.Detail
			end

			v12:SetValue((`{status} | {v23}`))
			local status2 = event.Status
			local v26

			if event.UntilTimestamp then
				v26 = Lib.FormatRemaining(event.UntilTimestamp, v20)
			else
				v26 = event.Detail
			end

			v13:SetValue((`{status2} | {v26}`))
			v14:SetEnabled(main.Available and main.Status ~= "Inactive")
			v15:SetEnabled(event.Available and event.Status ~= "Inactive")

			for _, adminSlot in v19.AdminSlots do
				local untilTimestamp = adminSlot.UntilTimestamp

				if not (untilTimestamp and untilTimestamp <= v20 and v8 ~= untilTimestamp) then
					continue
				end

				v8 = untilTimestamp
				fn()
				break
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Render(p)
			v6 = p
			now = os.clock()
			v7 = -1
			RenderCountdowns()
			fn2(p)
		end

		fn3 = function(p)
			if flag or not Lib.ExecuteAction then
				return
			end

			Lib.ExecuteAction:Fire(p):andThen(function(data)
				if flag or not data then
					return
				end

				Render(data.Snapshot) -- equivalent call inferred; original call site unknown
				local message = data.Message
				local v20

				if data.Ok then
					v20 = Color3.fromRGB(100, 255, 100)
				else
					v20 = Color3.fromRGB(255, 100, 100)
				end

				NotificationSystem:ShowGeneralNotification(message, v20, 4)

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

		fn2 = function(p)
			for _, v19 in v17.Components:GetAll() do
				v19:Destroy()
			end

			local count2 = 0

			for _, adminModule in p.AdminModules do
				local slot = adminModule.Slot

				if not ((v4 == "all" or adminModule.Source == v4) and (v5 == "all" or adminModule.Slot == v5)) then
					continue
				end

				if not (v3 == "" or string.find(
					string.lower((`{adminModule.DisplayName} {adminModule.Name} {adminModule.Source} {slot}`)),
					v3,
					1,
					true
				)) then
					continue
				end

				count2 += 1
				local adminSlot = p.AdminSlots[adminModule.Slot]
				local v19 = adminSlot.Status == adminModule.Name
				local available = adminSlot.Available

				if available then
					if adminSlot.Status == "Inactive" then
						available = adminModule.LoadError == nil
					else
						available = false
					end
				end

				local v20 = adminModule
				v17.Components:AddBox(function(object2)
					object2:SetBackgroundTransparency(count2 % 2 == 0 and 0.95 or 1)
					object2.Components:AddSplit(function(object3)
						object3:SetRightSizeAbsolute(82)
						object3.LeftComponents:AddText(function(object4)
							local v23 = v20.Source == "framework" and "Framework" or "Legacy"
							local formatted = ` | {v20.Slot}`
							local v24 = v20.Hidden and " | Hidden" or ""
							local v25 = v20.LoadError and " | Load failed" or ""
							object4:SetText((`{v20.DisplayName} | {v23}{formatted}{v24}{v25}{v19 and " | Active" or ""}`)):SetYSize(22)
						end)
						object3.RightComponents:AddButton(function(object4)
							object4:SetButtonText(v19 and "Stop" or "Launch"):SetYSize(22)
							object4:SetEnabledPermission("cui.liveops.manage")
							object4:SetEnabled(v19 or available)
							object4:DoNeedConfirmation(true)
							object4:SetButtonCallback(function()
								local v23 = fn3
								local v24 = {
									System = "AdminAbuse",
									Action = v19 and "stopModule" or "start",
									Module = v20.Name,
									DurationSeconds = 0
								}
								local durationSeconds

								if not (v19 or not v) then
									durationSeconds = v2 * 60
								end

								v24.DurationSeconds = durationSeconds
								v23(v24)
							end)
						end)
					end)
				end)
			end

			if count2 == 0 then
				v17.Components:AddText(function(object2)
					object2:SetText(#p.AdminModules == 0 and "No LiveOps events are available." or "No events match the search."):SetTextColor(Color3.fromRGB(
						150,
						150,
						150
					)):SetYSize(22)
				end)
			end
		end

		fn = function()
			if flag or not Lib.GetSnapshot then
				return
			end

			count += 1
			local v19 = count
			Lib.GetSnapshot:Fire({}):andThen(function(p)
				if flag or v19 ~= count or not p then
					return
				end

				Render(p) -- equivalent call inferred; original call site unknown
			end):catch(function(p)
				if flag or v19 ~= count then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`LiveOps refresh failed: {tostring(p)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		object:AddButton(function(object2)
			object2:SetButtonText("EMERGENCY STOP ALL"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):SetButtonColor(Color3.fromRGB(
				190,
				45,
				45
			)):DoNeedConfirmation(true):SetButtonCallback(function()
				fn3({
					System = "AdminAbuse",
					Action = "stopAll"
				})
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh Admin Abuse state"):SetYSize(22):SetEnabledPermission("cui.liveops.adminAbuse"):SetButtonCallback(fn)
		end)
		local v19 = false

		local function QueueRefresh()
			if flag or v19 then
				return
			end

			v19 = true
			task.defer(function()
				v19 = false
				fn()
			end)
		end

		local activatedConnection = AdminAbuseEvent.remotes.Activated:connect(QueueRefresh)
		local deactivatedConnection = AdminAbuseEvent.remotes.Deactivated:connect(QueueRefresh)
		local onClientEventConnection = nil
		task.spawn(function()
			local adminAbuseSync = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes"):WaitForChild("AdminAbuseSync")

			if adminAbuseSync and adminAbuseSync:IsA("RemoteEvent") then
				onClientEventConnection = adminAbuseSync.OnClientEvent:Connect(QueueRefresh)
			end
		end)
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			RenderTimeline()
			local v20 = v6

			if flag or not v20 then
				return
			end

			local v21 = math.floor(v20.Timestamp + math.max(0, os.clock() - now))

			if v21 == v7 then
				return
			end

			v7 = v21
			RenderCountdowns()
		end)
		v12:GetUI().Destroying:Connect(function()
			flag = true
			count += 1
			heartbeatConnection:Disconnect()
			activatedConnection()
			deactivatedConnection()

			if onClientEventConnection then
				onClientEventConnection:Disconnect()
			end

			v6 = nil
			v11 = nil
		end)
		fn()
	end
}