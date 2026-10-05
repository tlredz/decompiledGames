local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local DevPanelAnalytics = require(ReplicatedStorage._FRAMEWORK.Features.Admins.DevPanelAnalytics)
require(script.Parent.Parent.Types)

local function clearComponents(object)
	for _, v in object:GetAll() do
		v:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addReadOnlyField(components, p: string, p2: string)
	components:AddField(function(object)
		object:SetText(p):SetValue(p2):SetEnabled(false)
	end)
end

local function formatData(p)
	local success, result = pcall(HttpService.JSONEncode, HttpService, p)

	if success then
		return result
	end

	return (`<unencodable: {tostring(result)}>`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatSnapshotTime(timestamp: number)
	local localTime = DateTime.fromUnixTimestamp(timestamp):ToLocalTime()
	return string.format("%02d:%02d:%02d", localTime.Hour, localTime.Minute, localTime.Second)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTimestamp(lastChange: number)
	if lastChange < 0 then
		return "Never"
	end

	local localTime = DateTime.fromUnixTimestampMillis(lastChange):ToLocalTime()
	return string.format(
		"%02d/%02d %02d:%02d:%02d.%03d",
		localTime.Day,
		localTime.Month,
		localTime.Hour,
		localTime.Minute,
		localTime.Second,
		localTime.Millisecond
	)
end

local function formatAge(lastChange: number)
	if lastChange < 0 then
		return "never updated"
	end

	local v = math.max(0, (math.floor((DateTime.now().UnixTimestampMillis - lastChange) / 1000)))

	if v < 60 then
		return (`{v}s ago`)
	end

	if v < 3600 then
		return (`{math.floor(v / 60)}m ago`)
	end

	if v < 86400 then
		return (`{math.floor(v / 3600)}h ago`)
	end

	return (`{math.floor(v / 86400)}d ago`)
end

local function summarizeWrites(writes)
	if #writes == 0 then
		return "No tracked writes"
	end

	local count = 0
	local total = 0
	local count2 = 0

	for _, v in writes do
		if v.status == "Started" then
			count2 += 1
		elseif v.status == "Rejected" then
			count += 1
		end

		total += v.retryAmount
	end

	return (`{#writes} shards • {count2} active • {count} failed • {total} retries`)
end

local function hasStateIssue(p)
	if not p.messageValid then
		return true
	end

	for _, write in p.writes do
		if write.status == "Rejected" or write.retryAmount > 0 then
			return true
		end
	end

	return false
end

return {
	DisplayName = "Global State",
	Permission = "cui.dev.analytics.globalState",
	Order = 51,
	Setup = function(object, p)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v = nil
		local v2 = ""
		local flag = false
		local sequence = -1
		local v3 = {}

		local function fn() end

		local v4 = object:AddField(function(object2)
			object2:SetText("Live stream"):SetValue("Paused"):SetEnabled(false)
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search state keys, values, or shards..."):SetValue(""):SetOnChangedRaw(function(value)
				v2 = string.lower(value)
				fn()
			end)
		end)
		local v5 = object:AddList(function(object2)
			object2:SetSizeY(420)
		end)

		fn = function()
			local scroll = v5:GetScroll()

			for _, v6 in v5.Components:GetAll() do
				v6:Destroy()
			end

			local v6 = v
			local globalState

			if v6 then
				globalState = v6.globalState
			else
				globalState = nil
			end

			if not (v6 and globalState) then
				v5.Components:AddText(function(object2)
					object2:SetText("Open this tab to begin streaming GlobalStateManager diagnostics."):SetTextColor(Color3.fromRGB(
						150,
						150,
						150
					)):SetAutoResize(true)
				end)
				return
			end

			local count = 0
			local total = 0

			for _, state in globalState.states do
				local flag2

				if state.messageValid then
					local flag3 = true

					for _, write in state.writes do
						if not (write.status == "Rejected" or write.retryAmount > 0) then
							continue
						end

						flag2 = true
						flag3 = false
						break
					end

					if flag3 then
						flag2 = false
					end
				else
					flag2 = true
				end

				if flag2 then
					count += 1
				end

				total += state.subscriberCount
			end

			v5.Components:AddTitle(function(object2)
				object2:SetTitle("Manager health")
			end)
			v5.Components:AddSplit(function(p2)
				p2.LeftComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Cached: {globalState.cachedStateCount} states`)):SetEnabled(false)
				end)
				p2.RightComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Issues: {count}`)):SetEnabled(false)
				end)
			end)
			v5.Components:AddSplit(function(p2)
				p2.LeftComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Reads: {globalState.ongoingReadCount}`)):SetEnabled(false)
				end)
				p2.RightComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Writes: {globalState.trackedWriteCount}`)):SetEnabled(false)
				end)
			end)
			addReadOnlyField(
				v5.Components,
				"Local shard",
				`{globalState.serverShardKey} of {globalState.shardCount} • TTL {math.floor(globalState.stateExpirationSeconds / 86400)} days`
			) -- equivalent call inferred; original call site unknown
			addReadOnlyField(
				v5.Components,
				"Cache & listeners",
				`{globalState.cachedStoreCount} MemoryStore handles • {total} state subscribers`
			) -- equivalent call inferred; original call site unknown
			v5.Components:AddTitle(function(object2)
				object2:SetTitle((`Cached states ({globalState.cachedStateCount})`))
			end)
			local count2 = 0

			for _, state in globalState.states do
				local data = state.data
				local success, result = pcall(HttpService.JSONEncode, HttpService, data)

				if not success then
					result = `<unencodable: {tostring(result)}>`
				end

				local v9 = summarizeWrites(state.writes)
				local v10 = string.lower((`{state.key} {result} {v9}`))

				if not (v2 == "" or string.find(v10, v2, 1, true)) then
					continue
				end

				count2 += 1
				local v11

				if state.messageValid then
					local flag2 = true

					for _, write in state.writes do
						if not (write.status == "Rejected" or write.retryAmount > 0) then
							continue
						end

						v11 = true
						flag2 = false
						break
					end

					if flag2 then
						v11 = false
					end
				else
					v11 = true
				end

				local v13 = state
				local v14 = v9
				local v15 = result
				v5.Components:AddExpandable(function(object2)
					object2:SetText((`{v11 and "[WARN]" or "[OK]"} {v13.key} • {formatAge(v13.lastChange)}`))
					object2.Components:AddBox(function(p2)
						local components3 = p2.Components
						local v16 = formatTimestamp(v13.lastChange) -- equivalent call inferred; original call site unknown
						addReadOnlyField(components3, "Last change", v16) -- equivalent call inferred; original call site unknown
						addReadOnlyField(p2.Components, "Subscribers", tostring(v13.subscriberCount)) -- equivalent call inferred; original call site unknown
						addReadOnlyField(
							p2.Components,
							"Messaging payload",
							v13.messageValid and "Valid" or `Invalid: {v13.messageValidationError}`
						) -- equivalent call inferred; original call site unknown
						addReadOnlyField(p2.Components, "Shard summary", v14) -- equivalent call inferred; original call site unknown

						for k, write in v13.writes do
							local v23 = not (write.retryAmount > 0) and "" or ` • {write.retryAmount} retries`
							addReadOnlyField(p2.Components, `Shard {write.shardKey}`, `{write.status}{v23}`) -- equivalent call inferred; original call site unknown
						end

						p2.Components:AddTitle(function(object3)
							object3:SetTitle("Cached JSON value")
						end)
						p2.Components:AddText(function(object3)
							object3:SetText(v15):SetAutoResize(true):SetTextSize(12)
						end)
					end)
					object2:BindOnExpanded(function(p2, p3)
						if p3 then
							v3[v13.key] = p2
						end
					end)

					if v3[v13.key] then
						object2:SetExpanded(true, false, true)
					end
				end)
			end

			if count2 == 0 then
				v5.Components:AddText(function(object2)
					object2:SetText("No cached global states match this search."):SetTextColor(Color3.fromRGB(
						150,
						150,
						150
					)):SetYSize(22)
				end)
			end

			v5:SetScroll(scroll)
		end

		local connection = DevPanelAnalytics.connectToPanel("globalState", function(data)
			if flag or data.panel ~= "globalState" then
				return
			end

			if data.ok then
				if data.sequence <= sequence then
					return
				end

				sequence = data.sequence
				v = data
				v4:SetValue((`Live • updated {formatSnapshotTime(data.timestamp)} • every {DevPanelAnalytics.getUpdateIntervalSeconds()}s`))
				fn()
			else
				v4:SetValue("Stream error")
				NotificationSystem:ShowGeneralNotification(
					`Global state analytics failed: {data.errorMessage}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateListening(visible: boolean)
			if flag then
				return
			end

			v4:SetValue(visible and "Connecting..." or "Paused")
			DevPanelAnalytics.setPanelListening("globalState", visible)
		end

		local visibilityChangedConnection = p.visibilityChanged:Connect(updateListening)
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh global state snapshot"):SetYSize(22):SetEnabledPermission("cui.dev.analytics.globalState"):SetButtonCallback(function()
				v4:SetValue("Refreshing...")
				DevPanelAnalytics.refreshPanel("globalState")
			end)
		end)
		v4:GetUI().Destroying:Connect(function()
			flag = true
			DevPanelAnalytics.setPanelListening("globalState", false)
			connection:Disconnect()
			visibilityChangedConnection:Disconnect()
		end)
		fn()
		updateListening(p.isVisible()) -- equivalent call inferred; original call site unknown
	end
}