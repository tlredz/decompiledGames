local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local AdminAbuseEvent = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent)
local _20YearsEvent = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules["20YearsEvent"])
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
		local v3 = not RunService:IsStudio()
		local v4 = ""
		local v5 = "all"
		local v6 = "all"
		local count = 0
		local v7 = nil
		local now = 0
		local v8 = -1
		local v9 = nil
		local flag = false
		local fn
		local fn2
		local fn3
		local v10 = 1
		local v11 = false
		local v12 = nil
		local firstYear = _20YearsEvent.firstYear
		local v13 = false
		local v14 = object:AddField(function(object2)
			object2:SetText("Main slot"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v15 = object:AddField(function(object2)
			object2:SetText("Event slot"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v16 = object:AddField(function(object2)
			object2:SetText("Overlay slot"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v17 = nil
		local v18 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.5)
			v17 = object2.LeftComponents:AddButton(function(object3)
				object3:SetButtonText("Stop main"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
					local v19 = v7

					if not v19 or v19.AdminSlots.main.Status == "Inactive" then
						return
					end

					fn3({
						System = "AdminAbuse",
						Action = "stopModule",
						Module = v19.AdminSlots.main.Status
					})
				end)
			end)
			v18 = object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Stop event"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
					local v19 = v7

					if not v19 or v19.AdminSlots.event.Status == "Inactive" then
						return
					end

					fn3({
						System = "AdminAbuse",
						Action = "stopModule",
						Module = v19.AdminSlots.event.Status
					})
				end)
			end)
		end)
		local v19 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizeAbsolute(22)
			object2.LeftComponents:AddCheckbox(function(object3)
				object3:ShowCheckboxOnly():SetYSize(22):SetValue(v):SetOnChanged(function(p)
					v = p
					v19:SetEnabled(p)
				end)
			end)
			v19 = object2.RightComponents:AddNumberField(function(object3)
				object3:SetText("Duration override (minutes)"):SetNumberFilter(1, 1440):SetValue(v2):SetEnabled(v):SetOnChangedUnfocus(function(p)
					v2 = p
				end)
			end)
		end)
		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.6)
			object2.LeftComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder("search..."):SetValue(""):SetOnChangedRaw(function(value)
					v4 = string.lower(value)

					if v7 then
						fn2(v7)
					end
				end)
			end)
			object2.RightComponents:AddSplit(function(object3)
				object3:SetLeftSizePercent(0.5)
				object3.LeftComponents:AddDropdown(function(object4)
					object4:SetTextVisible(false):SetChoiceList({ "all", "legacy", "framework" }):SetSelected("all"):SetOnChanged(function(p)
						if p == "all" or p == "legacy" or p == "framework" then
							v5 = p

							if v7 then
								fn2(v7)
							end
						end
					end)
				end)
				object3.RightComponents:AddDropdown(function(object4)
					object4:SetTextVisible(false):SetChoiceList({
						"all",
						"event",
						"main",
						"overlay"
					}):SetSelected("all"):SetOnChanged(function(p)
						if p == "all" or p == "event" or p == "main" or p == "overlay" then
							v6 = p

							if v7 then
								fn2(v7)
							end
						end
					end)
				end)
			end)
		end)
		local v20 = object:AddList(function(object2)
			object2:SetSizeY(145)
			object2.Components:AddText(function(object3)
				object3:SetText("Loading events..."):SetYSize(22)
			end)
		end)

		local function RequestSeek(value: number)
			if not (v11 and Lib.SeekAdminAbuseTimeline) then
				return
			end

			local elapsedSeconds = math.clamp(value, 0, v10)
			v12 = elapsedSeconds
			Lib.SeekAdminAbuseTimeline:Fire({
				ElapsedSeconds = elapsedSeconds
			}):andThen(function(p)
				if flag or v12 ~= elapsedSeconds then
					return
				end

				if p == nil or not p.Ok then
					v12 = nil
					warn((`[LiveOpsMenu] Admin Abuse timeline seek failed: {not p and "No response" or p.Message}`))
				end
			end):catch(function(p)
				if flag or v12 ~= elapsedSeconds then
					return
				end

				v12 = nil
				warn((`[LiveOpsMenu] Admin Abuse timeline seek failed: {tostring(p)}`))
			end)
		end

		local v21 = object:AddSlider(function(object2)
			object2:SetText("Main event time (inactive)"):SetEnabledPermission("cui.liveops.adminAbuse.timeline"):SetRange(
				0,
				1
			):SetIncrement(1):SetValue(0):SetEnabled(false):SetOnChanged(RequestSeek)
		end)
		local v22 = nil
		local v23 = nil
		object:AddSplit(function(object2)
			object2:SetRightSizeAbsolute(70)
			v22 = object2.LeftComponents:AddNumberField(function(object3)
				object3:SetText((`Jump to year ({_20YearsEvent.firstYear}-{_20YearsEvent.lastYear})`)):SetNumberFilter(
					_20YearsEvent.firstYear,
					_20YearsEvent.lastYear
				):SetValue(_20YearsEvent.firstYear):SetEnabled(false):SetOnChangedUnfocus(function(p)
					firstYear = p
				end)
			end)
			v23 = object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Jump"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.liveops.adminAbuse.timeline"):SetButtonCallback(function()
					RequestSeek(_20YearsEvent.elapsedSecondsForYear(firstYear))
				end)
			end)
		end)
		object:AddCheckbox(function(object2)
			object2:SetText("Is Global"):SetValue(v3):SetOnChanged(function(p)
				v3 = p
			end)
		end)

		local function RenderTimeline()
			local activeTimeline = AdminAbuseEvent.getActiveTimeline("main")
			local durationSeconds

			if activeTimeline then
				durationSeconds = activeTimeline.durationSeconds
			end

			local v24

			if activeTimeline == nil or activeTimeline.source ~= "framework" or durationSeconds == nil or not (durationSeconds > 0) then
				v24 = false
			else
				v24 = Lib.SeekAdminAbuseTimeline ~= nil
			end

			local v25 = not v24 and 1 or durationSeconds

			if v10 ~= v25 then
				v10 = v25
				v21:SetRange(0, v25)
			end

			if v11 ~= v24 then
				v11 = v24
				v21:SetEnabled(v24)
			end

			if v24 then
				if activeTimeline == nil then
					v24 = false
				else
					v24 = activeTimeline.name == "20YearsEvent"
				end
			end

			if v13 ~= v24 then
				v13 = v24
				v22:SetEnabled(v24)
				v23:SetEnabled(v24)
			end

			if activeTimeline then
				if v12 ~= nil and math.abs(activeTimeline.elapsedSeconds - v12) <= 1 then
					v12 = nil
				end

				local v26 = math.clamp(v12 or activeTimeline.elapsedSeconds, 0, durationSeconds or 1e999)
				local v27

				if durationSeconds then
					v27 = FormatTimelineTime(durationSeconds)
				else
					v27 = "no duration"
				end

				local v28 = not v24 and "" or ` [Year {_20YearsEvent.yearAtElapsedSeconds(v26) or "?"}]`
				v21:SetText((`{activeTimeline.name}{v28} ({FormatTimelineTime(v26)} / {v27})`))

				if v12 == nil then
					v21:SetValue(v26)
				end
			else
				v12 = nil
				v21:SetText("Main event time (inactive)")
				v21:SetValue(0)
			end
		end

		local function RenderCountdowns()
			local v24 = v7

			if not v24 then
				return
			end

			local v25 = v24.Timestamp + math.max(0, os.clock() - now)
			local main = v24.AdminSlots.main
			local event = v24.AdminSlots.event
			local overlay = v24.AdminSlots.overlay
			local status = main.Status
			local v28

			if main.UntilTimestamp then
				v28 = Lib.FormatRemaining(main.UntilTimestamp, v25)
			else
				v28 = main.Detail
			end

			v14:SetValue((`{status} | {v28}`))
			local status2 = event.Status
			local v31

			if event.UntilTimestamp then
				v31 = Lib.FormatRemaining(event.UntilTimestamp, v25)
			else
				v31 = event.Detail
			end

			v15:SetValue((`{status2} | {v31}`))
			local status3 = overlay.Status
			local v34

			if overlay.UntilTimestamp then
				v34 = Lib.FormatRemaining(overlay.UntilTimestamp, v25)
			else
				v34 = overlay.Detail
			end

			v16:SetValue((`{status3} | {v34}`))
			v17:SetEnabled(main.Available and main.Status ~= "Inactive")
			v18:SetEnabled(event.Available and event.Status ~= "Inactive")

			for _, adminSlot in v24.AdminSlots do
				local untilTimestamp = adminSlot.UntilTimestamp

				if not (untilTimestamp and untilTimestamp <= v25 and v9 ~= untilTimestamp) then
					continue
				end

				v9 = untilTimestamp
				fn()
				break
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Render(p)
			v7 = p
			now = os.clock()
			v8 = -1
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
				local v25

				if data.Ok then
					v25 = Color3.fromRGB(100, 255, 100)
				else
					v25 = Color3.fromRGB(255, 100, 100)
				end

				NotificationSystem:ShowGeneralNotification(message, v25, 4)

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
			for _, v24 in v20.Components:GetAll() do
				v24:Destroy()
			end

			local count2 = 0
			local count3 = 0

			for _, adminModule in p.AdminModules do
				if adminModule.Hidden then
					continue
				end

				count2 += 1
				local slot = adminModule.Slot

				if not ((v5 == "all" or adminModule.Source == v5) and (v6 == "all" or adminModule.Slot == v6)) then
					continue
				end

				if not (v4 == "" or string.find(
					string.lower((`{adminModule.DisplayName} {adminModule.Name} {adminModule.Source} {slot}`)),
					v4,
					1,
					true
				)) then
					continue
				end

				count3 += 1
				local adminSlot = p.AdminSlots[adminModule.Slot]
				local v24 = adminSlot.Status == adminModule.Name
				local available = adminSlot.Available

				if available then
					if adminSlot.Status == "Inactive" then
						available = adminModule.LoadError == nil
					else
						available = false
					end
				end

				local v25 = adminModule
				v20.Components:AddBox(function(object2)
					object2:SetBackgroundTransparency(count3 % 2 == 0 and 0.95 or 1)
					object2.Components:AddSplit(function(object3)
						object3:SetRightSizeAbsolute(82)
						object3.LeftComponents:AddText(function(object4)
							local v28 = v25.Source == "framework" and "Framework" or "Legacy"
							local formatted = ` | {v25.Slot}`
							local v29 = v25.LoadError and " | Load failed" or ""
							object4:SetText((`{v25.DisplayName} | {v28}{formatted}{v29}{v24 and " | Active" or ""}`)):SetYSize(22)
						end)
						object3.RightComponents:AddButton(function(object4)
							object4:SetButtonText(v24 and "Stop" or "Launch"):SetYSize(22)
							object4:SetEnabledPermission("cui.liveops.manage")
							object4:SetEnabled(v24 or available)
							object4:DoNeedConfirmation(true)
							object4:SetButtonCallback(function()
								local v28 = fn3
								local v29 = {
									System = "AdminAbuse",
									Action = v24 and "stopModule" or "start",
									Module = v25.Name,
									isGlobal = 0,
									DurationSeconds = 0
								}
								local isGlobal

								if not v24 then
									isGlobal = v3
								end

								v29.isGlobal = isGlobal
								local durationSeconds

								if not (v24 or not v) then
									durationSeconds = v2 * 60
								end

								v29.DurationSeconds = durationSeconds
								v28(v29)
							end)
						end)
					end)
				end)
			end

			if count3 == 0 then
				v20.Components:AddText(function(object2)
					object2:SetText(count2 == 0 and "No LiveOps events are available." or "No events match the search."):SetTextColor(Color3.fromRGB(
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
			local v24 = count
			Lib.GetSnapshot:Fire({}):andThen(function(p)
				if flag or v24 ~= count or not p then
					return
				end

				Render(p) -- equivalent call inferred; original call site unknown
			end):catch(function(p)
				if flag or v24 ~= count then
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
		local v24 = false

		local function QueueRefresh()
			if flag or v24 then
				return
			end

			v24 = true
			task.defer(function()
				v24 = false
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
			local v25 = v7

			if flag or not v25 then
				return
			end

			local v26 = math.floor(v25.Timestamp + math.max(0, os.clock() - now))

			if v26 == v8 then
				return
			end

			v8 = v26
			RenderCountdowns()
		end)
		v14:GetUI().Destroying:Connect(function()
			flag = true
			count += 1
			heartbeatConnection:Disconnect()
			activatedConnection()
			deactivatedConnection()

			if onClientEventConnection then
				onClientEventConnection:Disconnect()
			end

			v7 = nil
			v12 = nil
		end)
		fn()
	end
}