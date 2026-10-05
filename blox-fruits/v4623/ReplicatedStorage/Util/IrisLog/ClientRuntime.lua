local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local HotkeyCombo = require(script.Parent.HotkeyCombo)
require(script.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidTextOverflowMode(p)
	return p == "clip" or p == "fit" or p == "wrap"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasControlCharacters(value: string)
	return string.find(value, "%c") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function encodedWithinLimit(p, p2: number)
	local success, result = pcall(function()
		return HttpService:JSONEncode(p)
	end)
	return success and #result <= p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sanitizeFloatingHotkeyCombo(p)
	return HotkeyCombo.sanitize(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function floatingHotkeySignature(p)
	return HotkeyCombo.signature(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isGeneratedRemoteName(value)
	if typeof(value) == "string" then
		return string.match(value, "^%{%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x%}$") ~= nil or string.match(
			value,
			"^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
		) ~= nil
	end

	return false
end

return {
	install = function(self, data)
		local Formatter = require(data.Script.ReactComponents.Formatter)
		local ReactComponents = require(data.Script.ReactComponents)
		local LogNameColors = require(data.Script.LogNameColors)
		local TabDisplay = require(data.Script.TabDisplay)
		local vector = Vector2.new(ReactComponents.Theme.TabBarHeight, ReactComponents.Theme.TabBarHeight)
		local serverStates = {}
		local replicatedHandles = {}
		local object = setmetatable({}, {
			__mode = "k"
		})
		local v3 = os.time() - workspace:GetServerTimeNow()
		local v4 = nil
		local v5 = nil
		local object2 = setmetatable({}, {
			__mode = "k"
		})
		local object3 = setmetatable({}, {
			__mode = "k"
		})
		local flag = false
		local flag2 = false
		local lines = nil
		local v6 = nil
		local windowPositionPx = nil
		local windowSizePx = nil
		local count = 0
		local visible = false
		local lockedDown2 = true
		local v11 = 0
		local count2 = 0
		local toasts = {}
		local count3 = 0
		local v13 = true
		local ignoreToastAlerts = false
		local showHiddenLogs2 = false
		local textOverflowMode = "clip"
		local minimalTables = false
		local v17 = nil
		local v18 = {}
		local v19 = {}
		local namesByName = {}
		local namesByName2 = {}
		local v20 = {}
		local v21 = {}
		local v22 = {}
		local flag3 = false
		local v23 = nil
		local count4 = 0
		local count5 = 0
		local flag4 = false
		local v24 = 0
		local v25 = false
		local v26 = 0

		local function fn() end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function currentLineSource()
			if v26 > 0 then
				return "server"
			end

			return "client"
		end

		local function markLineSource(p, p2: string)
			object[p] = p2
			return p
		end

		local function bumpLogVersion()
			count4 += 1
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function invalidateVisibleLogs()
			v23 = nil
			count4 += 1
		end

		function self._onCategoryChanged()
			invalidateVisibleLogs() -- equivalent call inferred; original call site unknown
			fn()
		end

		local function minimizedWindowPosition()
			local currentCamera = workspace.CurrentCamera
			local viewportSize

			if currentCamera then
				viewportSize = currentCamera.ViewportSize
			else
				viewportSize = Vector2.new(1280, 720)
			end

			return Vector2.new(math.max(0, viewportSize.X - vector.X), (math.max(0, viewportSize.Y - vector.Y)))
		end

		local function preferencesRemote()
			local preferences = data.Script:FindFirstChild("Preferences")

			if preferences and preferences:IsA("RemoteEvent") then
				return preferences
			end

			return nil
		end

		local function settingsExchangeRemote()
			local settingsExchange = data.Script:FindFirstChild("SettingsExchange")

			if settingsExchange and settingsExchange:IsA("RemoteFunction") then
				return settingsExchange
			end

			return nil
		end

		local function ensurePinnedPreferenceNames()
			if v17 then
				return v17
			end

			local result = {}

			for _, v27 in data.SortedLogArray do
				if v27.Pinned then
					result[v27.Name] = true
				end
			end

			v17 = result
			return result
		end

		local function applyPinnedPreferences()
			if not v17 then
				return false
			end

			local v27 = false

			for _, v28 in data.SortedLogArray do
				local pinned = v17[v28.Name] == true

				if v28.Pinned == pinned then
					continue
				end

				v28.Pinned = pinned
				v27 = true
			end

			return v27
		end

		local function applyLogNameColorPreference(state2)
			local nameColorKey = v20[state2.Name]

			if not LogNameColors.isValidKey(nameColorKey) then
				nameColorKey = nil
			end

			local colorForKey = LogNameColors.colorForKey(nameColorKey)

			if state2.NameColorKey == nameColorKey and state2.NameColor == colorForKey then
				return false
			end

			state2.NameColorKey = nameColorKey
			state2.NameColor = colorForKey
			return true
		end

		local function applyAllLogNameColorPreferences()
			local v27 = false

			for _, v28 in data.SortedLogArray do
				local nameColorKey = v20[v28.Name]

				if not LogNameColors.isValidKey(nameColorKey) then
					nameColorKey = nil
				end

				local colorForKey = LogNameColors.colorForKey(nameColorKey)
				local v30

				if v28.NameColorKey == nameColorKey and v28.NameColor == colorForKey then
					v30 = false
				else
					v28.NameColorKey = nameColorKey
					v28.NameColor = colorForKey
					v30 = true
				end

				v27 = v30 or v27
			end

			return v27
		end

		local function visibleLogCanUsePreference(p)
			return p ~= nil and typeof(p.Name) == "string" and #p.Name <= 120
		end

		local function logHasCustomNameColor(p)
			return p ~= nil and p.NameColor ~= nil
		end

		local function logHasCategory(p)
			if p == nil then
				return false
			end

			local category = p.Category

			if typeof(category) ~= "string" and p.IrisLogSettings ~= nil then
				category = p.IrisLogSettings.Category
			end

			return typeof(category) == "string" and category ~= ""
		end

		local function logCanBeShown(data2)
			if data2 == nil or data2.IsPopup == true then
				return false
			end

			if data2.IrisLogSettings.Hidden == true then
				local v27

				if data2 == nil then
					v27 = false
				else
					local category = data2.Category

					if typeof(category) ~= "string" and data2.IrisLogSettings ~= nil then
						category = data2.IrisLogSettings.Category
					end

					if typeof(category) == "string" then
						v27 = category ~= ""
					else
						v27 = false
					end
				end

				if v27 then
					return showHiddenLogs2
				end
			end

			local v27 = showHiddenLogs2

			if v27 then
				return v27
			end

			if data2.Pinned == true then
				return true
			else
				return data2 ~= nil and data2.NameColor ~= nil or data2.IrisLogSettings.Hidden ~= true
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function logDropdownRank(data2)
			if data2.Pinned then
				return 1
			end

			local v27

			if data2 == nil then
				v27 = false
			else
				v27 = data2.NameColor ~= nil
			end

			if v27 then
				return 2
			end

			if data2.IrisLogSettings.Hidden == true then
				return 4
			end

			return 3
		end

		local function collectTabNames(state2)
			local count6 = 0
			local names = {}

			for _, tab in state2.Tabs do
				if typeof(tab.Name) ~= "string" or #tab.Name > 80 then
					continue
				end

				local name = tab.Name

				if string.find(name, "%c") ~= nil then
					continue
				end

				count6 += 1

				if count6 > 40 then
					break
				else
					table.insert(names, tab.Name)
				end
			end

			return names
		end

		local function isSafeTabPreferenceName(value)
			if typeof(value) == "string" and #value <= 80 then
				local controlCharacters = hasControlCharacters(value) -- equivalent call inferred; original call site unknown
				return not controlCharacters
			else
				return false
			end
		end

		local function findTabIndexByName(p, value)
			local v27

			if typeof(value) == "string" and #value <= 80 then
				local controlCharacters = hasControlCharacters(value) -- equivalent call inferred; original call site unknown
				v27 = not controlCharacters
			else
				v27 = false
			end

			if not v27 then
				return nil
			end

			for k, tab in p.Tabs do
				if tab.Name == value then
					return k
				end
			end

			return nil
		end

		local function findTabIndex(p, p2)
			if not p2 then
				return nil
			end

			for k, tab in p.Tabs do
				if tab == p2 then
					return k
				end
			end

			return nil
		end

		local function selectedTabNameForIndex(p, p2: number)
			local tab = p.Tabs[p2]

			if not tab then
				return nil
			end

			local name = tab.Name
			local v27

			if typeof(name) == "string" and #name <= 80 then
				local controlCharacters = hasControlCharacters(name) -- equivalent call inferred; original call site unknown
				v27 = not controlCharacters
			else
				v27 = false
			end

			if v27 then
				return tab.Name
			end

			return nil
		end

		local function collectSelectedTabPreferences(namesByName3)
			local count6 = 0
			local result = {}

			for k, item in namesByName3 do
				if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil) then
					continue
				end

				local v27

				if typeof(item) == "string" and #item <= 80 then
					local controlCharacters = hasControlCharacters(item) -- equivalent call inferred; original call site unknown
					v27 = not controlCharacters
				else
					v27 = false
				end

				if not v27 then
					continue
				end

				count6 += 1

				if count6 > 100 then
					break
				else
					result[k] = item
				end
			end

			if encodedWithinLimit(result, 1536) then
				return result
			end

			return {}
		end

		local function applyTabOrder(state2)
			local v27 = v19[state2.Name]

			if not v27 then
				return false
			end

			local v28 = {}

			for _, tab in state2.Tabs do
				if typeof(tab.Name) == "string" and v28[tab.Name] == nil then
					v28[tab.Name] = tab
				end
			end

			local v29 = state2.Tabs[object2[state2] or 0] or state2.CURRENT_TAB
			local v30 = {}

			for k, state in v21 do
				if k == state2.Name then
					table.insert(v30, {
						State = state,
						Tab = state2.Tabs[state.SelectedTabIndex or object3[state2] or 0],
						Floating = true
					})
				end
			end

			for k, state in v22 do
				if k == state2.Name then
					table.insert(v30, {
						State = state,
						Tab = state2.Tabs[state.SelectedTabIndex or 0],
						Floating = false
					})
				end
			end

			local v31 = {}

			for _, v32 in v27 do
				local v33 = v28[v32]

				if not v33 then
					continue
				end

				table.insert(v31, v33)
				v28[v32] = nil
			end

			for _, tab in state2.Tabs do
				if v28[tab.Name] ~= tab then
					continue
				end

				table.insert(v31, tab)
				v28[tab.Name] = nil
			end

			if #v31 ~= #state2.Tabs then
				return false
			end

			local v32 = false

			for k, v34 in v31 do
				if state2.Tabs[k] == v34 then
					continue
				end

				v32 = true
				break
			end

			if not v32 then
				return false
			end

			table.clear(state2.Tabs)

			for _, v34 in v31 do
				table.insert(state2.Tabs, v34)
			end

			local v34

			if v29 then
				for k, tab in state2.Tabs do
					if tab ~= v29 then
						continue
					end

					v34 = k
					break
				end
			end

			if v34 then
				object2[state2] = v34
				state2.CURRENT_TAB = state2.Tabs[v34]
			end

			for _, v35 in v30 do
				local tab = v35.Tab
				local selectedTabIndex

				if tab then
					for k, tab2 in state2.Tabs do
						if tab2 ~= tab then
							continue
						end

						selectedTabIndex = k
						break
					end
				else
					local k = nil
					selectedTabIndex = k
				end

				if not selectedTabIndex then
					continue
				end

				v35.State.SelectedTabIndex = selectedTabIndex

				if v35.Floating then
					object3[state2] = selectedTabIndex
				end
			end

			return true
		end

		local function applyAllTabOrderPreferences()
			local v27 = false

			for _, v28 in data.SortedLogArray do
				v27 = applyTabOrder(v28) or v27
			end

			return v27
		end

		local function collectPreferences()
			local count6 = 0
			local pinnedLogs = {}

			for _, v28 in data.SortedLogArray do
				if not v28.Pinned then
					continue
				end

				count6 += 1

				if count6 > 100 then
					break
				else
					pinnedLogs[v28.Name] = true
				end
			end

			local count7 = 0
			local v28 = {}

			for k, v29 in v18 do
				local v30 = sanitizeFloatingHotkeyCombo(v29) -- equivalent call inferred; original call site unknown

				if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil and v30 ~= nil) then
					continue
				end

				count7 += 1

				if count7 > 80 then
					break
				else
					v28[k] = v30
				end
			end

			local floatingHotkeys = not encodedWithinLimit(v28, 1536) and {} or v28
			local count8 = 0
			local v30 = {}

			for k, v32 in v19 do
				if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil and typeof(v32) == "table") then
					continue
				end

				local v33 = {}
				local v34 = {}

				for _, v35 in v32 do
					if typeof(v35) ~= "string" or #v35 > 80 or string.find(v35, "%c") ~= nil or v33[v35] then
						continue
					end

					v33[v35] = true
					table.insert(v34, v35)

					if #v34 >= 40 then
						break
					end
				end

				if not (#v34 > 0) then
					continue
				end

				count8 += 1

				if count8 > 80 then
					break
				else
					v30[k] = v34
				end
			end

			local tabOrders = not encodedWithinLimit(v30, 2048) and {} or v30
			local selectedTabs = collectSelectedTabPreferences(namesByName)
			local floatingSelectedTabs = collectSelectedTabPreferences(namesByName2)
			local count9 = 0
			local v35 = {}

			for k, v36 in v20 do
				if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil and LogNameColors.isValidKey(v36)) then
					continue
				end

				count9 += 1

				if count9 > 100 then
					break
				else
					v35[k] = v36
				end
			end

			local logNameColors = not encodedWithinLimit(v35, 1536) and {} or v35
			return {
				TextOverflowMode = textOverflowMode,
				MinimalTables = minimalTables,
				IgnoreToastAlerts = ignoreToastAlerts,
				ShowHiddenLogs = showHiddenLogs2,
				PinnedLogs = pinnedLogs,
				FloatingHotkeys = floatingHotkeys,
				TabOrders = tabOrders,
				SelectedTabs = selectedTabs,
				FloatingSelectedTabs = floatingSelectedTabs,
				LogNameColors = logNameColors
			}
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function queuePreferenceSync()
			if flag3 then
				return
			end

			flag3 = true
			task.defer(function()
				flag3 = false
				local preferences = data.Script:FindFirstChild("Preferences")

				if not (preferences and preferences:IsA("RemoteEvent")) then
					preferences = nil
				end

				if not preferences then
					return
				end

				local v27 = collectPreferences()
				local success, result = pcall(function()
					return HttpService:JSONEncode(v27)
				end)

				if not success or #result > 8192 then
					return
				end

				preferences:FireServer(v27)
			end)
		end

		local function applyPreferences(data2)
			if typeof(data2) ~= "table" then
				return
			end

			if isValidTextOverflowMode(data2.TextOverflowMode) then
				textOverflowMode = data2.TextOverflowMode
			end

			minimalTables = data2.MinimalTables == true
			ignoreToastAlerts = data2.IgnoreToastAlerts == true
			local showHiddenLogs = data2.ShowHiddenLogs == true
			local v27 = showHiddenLogs2 ~= showHiddenLogs
			showHiddenLogs2 = showHiddenLogs
			local v28 = {}
			local pinnedLogs = data2.PinnedLogs

			if typeof(pinnedLogs) == "table" then
				local count6 = 0

				for k, pinnedLog in pinnedLogs do
					if not (pinnedLog == true and typeof(k) == "string") then
						continue
					end

					count6 += 1

					if count6 > 100 then
						break
					else
						v28[k] = true
					end
				end
			end

			v17 = v28
			local v29 = applyPinnedPreferences()
			local v30 = {}
			local v31 = {}
			local floatingHotkeys = data2.FloatingHotkeys

			if typeof(floatingHotkeys) == "table" then
				local count6 = 0

				for k, floatingHotkey in floatingHotkeys do
					local v33 = sanitizeFloatingHotkeyCombo(floatingHotkey) -- equivalent call inferred; original call site unknown
					local v34

					if v33 then
						v34 = HotkeyCombo.signature(v33)
					end

					if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil and v33 ~= nil) then
						continue
					end

					if v34 == nil or v31[v34] then
						continue
					end

					count6 += 1

					if count6 > 80 then
						break
					else
						v30[k] = v33
						v31[v34] = true
					end
				end
			end

			v18 = v30

			for k in v21 do
				if v18[k] == nil then
					v21[k] = nil
				end
			end

			local v32 = {}
			local tabOrders = data2.TabOrders

			if typeof(tabOrders) == "table" then
				local count6 = 0

				for k, tabOrder in tabOrders do
					if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil and typeof(tabOrder) == "table") then
						continue
					end

					local v34 = {}
					local v35 = {}

					for _, v36 in tabOrder do
						if typeof(v36) ~= "string" or not (#v36 <= 80) or string.find(v36, "%c") ~= nil or v34[v36] then
							continue
						end

						v34[v36] = true
						table.insert(v35, v36)

						if #v35 >= 40 then
							break
						end
					end

					if not (#v35 > 0) then
						continue
					end

					count6 += 1

					if count6 > 80 then
						break
					else
						v32[k] = v35
					end
				end
			end

			v19 = v32
			local v33 = false

			for _, v34 in data.SortedLogArray do
				v33 = applyTabOrder(v34) or v33
			end

			local function readSelectedTabs(items)
				local result = {}

				if typeof(items) ~= "table" then
					return result
				end

				local count6 = 0

				for k, item in items do
					if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil) then
						continue
					end

					local v34

					if typeof(item) == "string" and #item <= 80 then
						local controlCharacters = hasControlCharacters(item) -- equivalent call inferred; original call site unknown
						v34 = not controlCharacters
					else
						v34 = false
					end

					if not v34 then
						continue
					end

					count6 += 1

					if count6 > 100 then
						break
					else
						result[k] = item
					end
				end

				if encodedWithinLimit(result, 1536) then
					return result
				end

				return {}
			end

			namesByName = readSelectedTabs(data2.SelectedTabs)
			namesByName2 = readSelectedTabs(data2.FloatingSelectedTabs)

			for _, v34 in data.SortedLogArray do
				local v35 = namesByName[v34.Name]
				local v36

				if typeof(v35) == "string" and #v35 <= 80 then
					local controlCharacters = hasControlCharacters(v35) -- equivalent call inferred; original call site unknown
					v36 = not controlCharacters
				else
					v36 = false
				end

				local v37

				if v36 then
					for k, tab in v34.Tabs do
						if tab.Name ~= v35 then
							continue
						end

						v37 = k
						break
					end
				else
					local k = nil
					v37 = k
				end

				if v37 then
					object2[v34] = v37
					v34.CURRENT_TAB = v34.Tabs[v37]
				end

				local v38 = namesByName2[v34.Name]
				local v39

				if typeof(v38) == "string" and #v38 <= 80 then
					local controlCharacters = hasControlCharacters(v38) -- equivalent call inferred; original call site unknown
					v39 = not controlCharacters
				else
					v39 = false
				end

				local v40

				if v39 then
					for k, tab in v34.Tabs do
						if tab.Name ~= v38 then
							continue
						end

						v40 = k
						break
					end
				else
					local k = nil
					v40 = k
				end

				if v40 then
					object3[v34] = v40
				end
			end

			for k, v34 in v21 do
				local irisLog = data.IrisLogs[k]

				if not irisLog then
					continue
				end

				local v35 = namesByName2[irisLog.Name]
				local v36

				if typeof(v35) == "string" and #v35 <= 80 then
					local controlCharacters = hasControlCharacters(v35) -- equivalent call inferred; original call site unknown
					v36 = not controlCharacters
				else
					v36 = false
				end

				local v37

				if v36 then
					for k2, tab in irisLog.Tabs do
						if tab.Name ~= v35 then
							continue
						end

						v37 = k2
						break
					end
				else
					local k2 = nil
					v37 = k2
				end

				v34.SelectedTabIndex = v37 or v34.SelectedTabIndex
			end

			local logNameColors = {}
			local logNameColors2 = data2.LogNameColors

			if typeof(logNameColors2) == "table" then
				local count6 = 0

				for k, logNameColor in logNameColors2 do
					if not (typeof(k) == "string" and #k <= 120 and string.find(k, "%c") == nil and LogNameColors.isValidKey(logNameColor)) then
						continue
					end

					count6 += 1

					if count6 > 100 then
						break
					else
						logNameColors[k] = logNameColor
					end
				end
			end

			v20 = logNameColors
			local v34 = false

			for _, v35 in data.SortedLogArray do
				local nameColorKey = v20[v35.Name]

				if not LogNameColors.isValidKey(nameColorKey) then
					nameColorKey = nil
				end

				local colorForKey = LogNameColors.colorForKey(nameColorKey)
				local v37

				if v35.NameColorKey == nameColorKey and v35.NameColor == colorForKey then
					v37 = false
				else
					v35.NameColorKey = nameColorKey
					v35.NameColor = colorForKey
					v37 = true
				end

				v34 = v37 or v34
			end

			if v29 or v27 or v34 then
				v23 = nil
			end

			count4 += 1

			if v33 then
				count4 += 1
			end

			fn()
		end

		local function mergeNewSeverity(p, newSeverity: string?)
			if not newSeverity then
				return
			end

			if newSeverity == "error" or p.NewSeverity ~= "error" then
				p.NewSeverity = newSeverity
			end
		end

		local function markUnread(state2, ...)
			if state2.Visible or v21[state2.Name] ~= nil or v22[state2.Name] ~= nil then
				return
			end

			state2.New += 1
			local lineSeverity = data.DetectLineSeverity(...)

			if lineSeverity and (lineSeverity == "error" or state2.NewSeverity ~= "error") then
				state2.NewSeverity = lineSeverity
			end

			count4 += 1
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getViewportSize()
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				return currentCamera.ViewportSize
			end

			return (Vector2.new(1280, 720))
		end

		local function defaultWindowBounds()
			local viewportSize = getViewportSize() -- equivalent call inferred; original call site unknown

			if viewportSize.Y <= 1 then
				viewportSize = Vector2.new(1280, 720)
			end

			return
				Vector2.new(viewportSize.X * 0.25, viewportSize.Y * 0.05),
				Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.9)
		end

		local function defaultFloatingWindowBounds(name: string)
			local viewportSize = getViewportSize() -- equivalent call inferred; original call site unknown

			if viewportSize.Y <= 1 then
				viewportSize = Vector2.new(1280, 720)
			end

			local vector2 = Vector2.new(math.max(360, viewportSize.X * 0.38), (math.max(240, viewportSize.Y * 0.42)))
			local vector3 = Vector2.new(math.min(vector2.X, viewportSize.X), (math.min(vector2.Y, viewportSize.Y)))
			local total = 0

			for i = 1, #name do
				total += string.byte(name, i)
			end

			local vector4 = Vector2.new(total % 7 * 24, total % 5 * 22)
			local v27 = Vector2.new(viewportSize.X * 0.08, viewportSize.Y * 0.12) + vector4
			return
				Vector2.new(
					math.clamp(v27.X, 0, (math.max(0, viewportSize.X - vector3.X))),
					(math.clamp(v27.Y, 0, (math.max(0, viewportSize.Y - vector3.Y))))
				),
				vector3
		end

		local function defaultPopupWindowBounds(value: string)
			local viewportSize = getViewportSize() -- equivalent call inferred; original call site unknown

			if viewportSize.Y <= 1 then
				viewportSize = Vector2.new(1280, 720)
			end

			local vector2 = Vector2.new(math.max(460, viewportSize.X * 0.46), (math.max(300, viewportSize.Y * 0.58)))
			local vector3 = Vector2.new(math.min(vector2.X, viewportSize.X), (math.min(vector2.Y, viewportSize.Y)))
			local total = 0

			for i = 1, #value do
				total += string.byte(value, i)
			end

			local vector4 = Vector2.new(total % 5 * 22, total % 4 * 20)
			local v27 = Vector2.new((viewportSize.X - vector3.X) * 0.5, (viewportSize.Y - vector3.Y) * 0.5) + vector4
			return
				Vector2.new(
					math.clamp(v27.X, 0, (math.max(0, viewportSize.X - vector3.X))),
					(math.clamp(v27.Y, 0, (math.max(0, viewportSize.Y - vector3.Y))))
				),
				vector3
		end

		local function ensureWindowBounds()
			if not (windowPositionPx and windowSizePx) then
				windowPositionPx, windowSizePx = defaultWindowBounds()
			end
		end

		local function getVisibleLogs()
			if v23 then
				return v23
			end

			table.sort(data.SortedLogArray, function(a, b)
				local v27 = logDropdownRank(a) -- equivalent call inferred; original call site unknown
				local v28 = logDropdownRank(b) -- equivalent call inferred; original call site unknown

				if v27 == v28 then
					return a.Name < b.Name
				end

				return v27 < v28
			end)
			local result = {}

			for _, v27 in data.SortedLogArray do
				local v28

				if v27 == nil or v27.IsPopup == true then
					v28 = false
				else
					local v29

					if v27.IrisLogSettings.Hidden == true then
						local v30

						if v27 == nil then
							v30 = false
						else
							local category = v27.Category

							if typeof(category) ~= "string" and v27.IrisLogSettings ~= nil then
								category = v27.IrisLogSettings.Category
							end

							if typeof(category) == "string" then
								v30 = category ~= ""
							else
								v30 = false
							end
						end

						if v30 then
							v28 = showHiddenLogs2
						else
							v28 = showHiddenLogs2

							if not v28 then
								if v27.Pinned == true then
									v28 = true
								else
									if v27 == nil then
										v29 = false
									else
										v29 = v27.NameColor ~= nil
									end

									v28 = v29 or v27.IrisLogSettings.Hidden ~= true
								end
							end
						end
					else
						v28 = showHiddenLogs2

						if not v28 then
							if v27.Pinned == true then
								v28 = true
							else
								if v27 == nil then
									v29 = false
								else
									v29 = v27.NameColor ~= nil
								end

								v28 = v29 or v27.IrisLogSettings.Hidden ~= true
							end
						end
					end
				end

				if v28 then
					table.insert(result, v27)
				end
			end

			v23 = result
			return result
		end

		local function getSelectedTabIndex(state2)
			local v27 = object2[state2]

			if not v27 then
				local v28 = namesByName[state2.Name]
				local v29

				if typeof(v28) == "string" and #v28 <= 80 then
					local controlCharacters = hasControlCharacters(v28) -- equivalent call inferred; original call site unknown
					v29 = not controlCharacters
				else
					v29 = false
				end

				if v29 then
					for k, tab in state2.Tabs do
						if tab.Name ~= v28 then
							continue
						end

						v27 = k
						break
					end
				else
					v27 = nil
				end
			end

			if not v27 and state2.CURRENT_TAB then
				for k, tab in state2.Tabs do
					if tab ~= state2.CURRENT_TAB then
						continue
					end

					v27 = k
					break
				end
			end

			if not v27 and state2.Tabs[1] and #state2.Tabs[1].Lines == 0 then
				for i = 2, #state2.Tabs do
					if not (#state2.Tabs[i].Lines > 0) then
						continue
					end

					v27 = i
					break
				end
			end

			local selectedTabIndex = TabDisplay.resolveSelectedTabIndex(state2.Tabs, v27)
			object2[state2] = selectedTabIndex
			state2.CURRENT_TAB = state2.Tabs[selectedTabIndex]
			return selectedTabIndex
		end

		local function getFloatingSelectedTabIndex(p, p2)
			local selectedTabIndex = p2.SelectedTabIndex or object3[p]

			if not selectedTabIndex then
				local v27 = namesByName2[p.Name]
				local v28

				if typeof(v27) == "string" and #v27 <= 80 then
					local controlCharacters = hasControlCharacters(v27) -- equivalent call inferred; original call site unknown
					v28 = not controlCharacters
				else
					v28 = false
				end

				if v28 then
					for k, tab in p.Tabs do
						if tab.Name ~= v27 then
							continue
						end

						selectedTabIndex = k
						break
					end
				else
					selectedTabIndex = nil
				end
			end

			if not selectedTabIndex and p.Tabs[1] and #p.Tabs[1].Lines == 0 then
				for i = 2, #p.Tabs do
					if not (#p.Tabs[i].Lines > 0) then
						continue
					end

					selectedTabIndex = i
					break
				end
			end

			local selectedTabIndex2 = TabDisplay.resolveSelectedTabIndex(p.Tabs, selectedTabIndex)
			p2.SelectedTabIndex = selectedTabIndex2
			object3[p] = selectedTabIndex2
			return selectedTabIndex2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTabLineStartToBottom(p, p2: number?)
			local tab = p.Tabs[p2 or getSelectedTabIndex(p)]

			if tab then
				tab.LINE_RENDER_START = math.max(0, #tab.Lines - data.LineRenderLimit)
			end
		end

		local function getFloatingWindowEntries()
			local result = {}

			for k, v27 in v21 do
				local irisLog = data.IrisLogs[k]

				if irisLog then
					table.insert(result, {
						Log = irisLog,
						SelectedTabIndex = getFloatingSelectedTabIndex(irisLog, v27),
						LockedDown = v27.LockedDown,
						PositionPx = v27.PositionPx,
						SizePx = v27.SizePx,
						ResetToken = v27.ResetToken,
						Minimized = v27.Minimized
					})
				else
					v21[k] = nil
				end
			end

			table.sort(result, function(a, b)
				return tostring(a.Log.Name) < tostring(b.Log.Name)
			end)
			return result
		end

		local function getPopupSelectedTabIndex(p, p2)
			local selectedTabIndex = p2.SelectedTabIndex

			if not selectedTabIndex and p.Tabs[1] and #p.Tabs[1].Lines == 0 then
				for i = 2, #p.Tabs do
					if not (#p.Tabs[i].Lines > 0) then
						continue
					end

					selectedTabIndex = i
					break
				end
			end

			local selectedTabIndex2 = TabDisplay.resolveSelectedTabIndex(p.Tabs, selectedTabIndex)
			p2.SelectedTabIndex = selectedTabIndex2
			return selectedTabIndex2
		end

		local function getPopupWindowEntries()
			local result = {}

			for k, v27 in v22 do
				local irisLog = data.IrisLogs[k]

				if irisLog then
					local popupSelectedTabIndex = getPopupSelectedTabIndex(irisLog, v27)
					table.insert(result, {
						Log = irisLog,
						Title = v27.Title,
						SelectedTabIndex = popupSelectedTabIndex,
						LockedDown = v27.LockedDown,
						PositionPx = v27.PositionPx,
						SizePx = v27.SizePx,
						ResetToken = v27.ResetToken
					})
				else
					v22[k] = nil
				end
			end

			table.sort(result, function(a, b)
				return tostring(a.Title) < tostring(b.Title)
			end)
			return result
		end

		local function openFloatingLog(object4)
			local v27 = v21[object4.Name]

			if not v27 then
				local positionPx, sizePx = defaultFloatingWindowBounds(object4.Name)
				v27 = {
					PositionPx = positionPx,
					SizePx = sizePx,
					ResetToken = 0,
					Minimized = false,
					SelectedTabIndex = nil,
					LockedDown = true
				}
				v21[object4.Name] = v27
			end

			v27.LockedDown = true
			setTabLineStartToBottom(object4, getFloatingSelectedTabIndex(object4, v27)) -- equivalent call inferred; original call site unknown
			object4:MarkAsRead()
			fn()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function toggleFloatingLog(floatingLogForKeyCode)
			if not v21[floatingLogForKeyCode.Name] then
				openFloatingLog(floatingLogForKeyCode)
				return
			end

			v21[floatingLogForKeyCode.Name] = nil
			fn()
		end

		local function getSelectedLog()
			local v27 = v5
			local v28

			if v27 == nil or v27.IsPopup == true then
				v28 = false
			else
				local v29

				if v27.IrisLogSettings.Hidden == true then
					local v30

					if v27 == nil then
						v30 = false
					else
						local category = v27.Category

						if typeof(category) ~= "string" and v27.IrisLogSettings ~= nil then
							category = v27.IrisLogSettings.Category
						end

						if typeof(category) == "string" then
							v30 = category ~= ""
						else
							v30 = false
						end
					end

					if v30 then
						v28 = showHiddenLogs2
					else
						v28 = showHiddenLogs2

						if not v28 then
							if v27.Pinned == true then
								v28 = true
							else
								if v27 == nil then
									v29 = false
								else
									v29 = v27.NameColor ~= nil
								end

								v28 = v29 or v27.IrisLogSettings.Hidden ~= true
							end
						end
					end
				else
					v28 = showHiddenLogs2

					if not v28 then
						if v27.Pinned == true then
							v28 = true
						else
							if v27 == nil then
								v29 = false
							else
								v29 = v27.NameColor ~= nil
							end

							v28 = v29 or v27.IrisLogSettings.Hidden ~= true
						end
					end
				end
			end

			if v28 then
				return v5
			end

			for _, v29 in data.SortedLogArray do
				if not v29.Visible then
					continue
				end

				local v30

				if v29 == nil or v29.IsPopup == true then
					v30 = false
				else
					local v31

					if v29.IrisLogSettings.Hidden == true then
						local v32

						if v29 == nil then
							v32 = false
						else
							local category = v29.Category

							if typeof(category) ~= "string" and v29.IrisLogSettings ~= nil then
								category = v29.IrisLogSettings.Category
							end

							if typeof(category) == "string" then
								v32 = category ~= ""
							else
								v32 = false
							end
						end

						if v32 then
							v30 = showHiddenLogs2
						else
							v30 = showHiddenLogs2

							if not v30 then
								if v29.Pinned == true then
									v30 = true
								else
									if v29 == nil then
										v31 = false
									else
										v31 = v29.NameColor ~= nil
									end

									v30 = v31 or v29.IrisLogSettings.Hidden ~= true
								end
							end
						end
					else
						v30 = showHiddenLogs2

						if not v30 then
							if v29.Pinned == true then
								v30 = true
							else
								if v29 == nil then
									v31 = false
								else
									v31 = v29.NameColor ~= nil
								end

								v30 = v31 or v29.IrisLogSettings.Hidden ~= true
							end
						end
					end
				end

				if not v30 then
					continue
				end

				v5 = v29
				return v29
			end

			v5 = getVisibleLogs()[1]
			return v5
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateCurrentLinePointers(p)
			if p then
				local tab = p.Tabs[getSelectedTabIndex(p)]
				v6 = p
				lines = tab and tab.Lines or p.Lines

				if tab and not tab.LINE_RENDER_START then
					tab.LINE_RENDER_START = math.max(0, #lines - data.LineRenderLimit)
				end
			else
				v6 = nil
				lines = nil
			end
		end

		local function fireControl(list, ...)
			local v27 = list[2]

			if typeof(v27) == "function" then
				task.spawn(v27, ...)
				return
			end

			local generatedRemoteName = isGeneratedRemoteName(v27) -- equivalent call inferred; original call site unknown

			if not generatedRemoteName or typeof(list[1]) ~= "string" then
				return
			end

			local remoteEvent = data.Script:FindFirstChild(v27)

			if remoteEvent and remoteEvent:IsA("RemoteEvent") then
				remoteEvent:FireServer(list[1], ...)
			end
		end

		local context = {
			ServerStates = serverStates,
			ReplicatedHandles = replicatedHandles,
			OnControl = fireControl
		}
		local new = self.new
		local destroy = self.Destroy

		function self.new(p: string, p2, p3)
			local irisLog = data.IrisLogs[p]
			local v28 = irisLog and irisLog.IrisLogSettings.Hidden == true
			local v29 = new(p, p2, p3)
			local hidden = v29.IrisLogSettings.Hidden == true
			local v30 = false

			if v17 then
				local pinned = v17[v29.Name] == true

				if v29.Pinned ~= pinned then
					v29.Pinned = pinned
					v30 = true
				end
			end

			local v31 = applyTabOrder(v29)
			local v32 = namesByName[v29.Name]
			local v33

			if typeof(v32) == "string" and #v32 <= 80 then
				local controlCharacters = hasControlCharacters(v32) -- equivalent call inferred; original call site unknown
				v33 = not controlCharacters
			else
				v33 = false
			end

			local v34

			if v33 then
				for k, tab in v29.Tabs do
					if tab.Name ~= v32 then
						continue
					end

					v34 = k
					break
				end
			end

			if v34 then
				object2[v29] = v34
				v29.CURRENT_TAB = v29.Tabs[v34]
			end

			local v35 = namesByName2[v29.Name]
			local v36

			if typeof(v35) == "string" and #v35 <= 80 then
				local controlCharacters = hasControlCharacters(v35) -- equivalent call inferred; original call site unknown
				v36 = not controlCharacters
			else
				v36 = false
			end

			local v37

			if v36 then
				for k, tab in v29.Tabs do
					if tab.Name ~= v35 then
						continue
					end

					v37 = k
					break
				end
			end

			if v37 then
				object3[v29] = v37
			end

			local nameColorKey = v20[v29.Name]

			if not LogNameColors.isValidKey(nameColorKey) then
				nameColorKey = nil
			end

			local colorForKey = LogNameColors.colorForKey(nameColorKey)
			local v39

			if v29.NameColorKey == nameColorKey and v29.NameColor == colorForKey then
				v39 = false
			else
				v29.NameColorKey = nameColorKey
				v29.NameColor = colorForKey
				v39 = true
			end

			if irisLog and v28 == hidden and not (v30 or v39) then
				if v31 then
					count4 += 1
				end
			else
				invalidateVisibleLogs() -- equivalent call inferred; original call site unknown
			end

			return v29
		end

		function self:Destroy()
			v22[self.Name] = nil
			v21[self.Name] = nil
			object2[self] = nil
			object3[self] = nil

			if v5 == self then
				v5 = nil
			end

			if v6 == self then
				v6 = nil
				lines = nil
			end

			destroy(self)
			invalidateVisibleLogs() -- equivalent call inferred; original call site unknown
			fn(true)
		end

		self.destroy = self.Destroy

		local function clearLog(p)
			for i = #p.Lines, 1, -1 do
				if not Formatter.containsStay(p.Lines[i]) then
					table.remove(p.Lines, i)
				end
			end

			fn(true)
		end

		local function clearTabLines(p, p2: string, p3: string?)
			local v28 = nil

			for _, tab in p.Tabs do
				if tab.Name ~= p2 then
					continue
				end

				v28 = tab
				break
			end

			if not v28 then
				return
			end

			for i = #v28.Lines, 1, -1 do
				local line = v28.Lines[i]

				if Formatter.containsStay(line) or not (p3 == nil or object[line] == p3) then
					continue
				end

				table.remove(v28.Lines, i)
			end

			fn(true)
		end

		local function createReactRoot()
			if v4 then
				return
			end

			local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 100)

			if not playerGui then
				return
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "IrisLogReactGui"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 100
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.Parent = playerGui
			v4 = ReactRoblox.createRoot(screenGui)
		end

		local function dismissToast(id: number)
			for i = #toasts, 1, -1 do
				if toasts[i].Id ~= id then
					continue
				end

				table.remove(toasts, i)
				break
			end

			count3 += 1
			fn()
		end

		local function pushToast(log, ...)
			count2 += 1
			table.insert(toasts, {
				Id = count2,
				Log = log,
				Line = { ... }
			})

			while #toasts > 5 do
				table.remove(toasts, 1)
			end

			count3 += 1
			createReactRoot()
			fn()
		end

		local function addToast(p, ...)
			if ignoreToastAlerts then
				return
			end

			pushToast(p, ...)
		end

		local function addSystemToast(...)
			pushToast(nil, ...)
		end

		local function handleSelectLog(object4)
			object4:Show()
		end

		local function handleTogglePin(p, pinned: boolean)
			p.Pinned = pinned
			invalidateVisibleLogs() -- equivalent call inferred; original call site unknown
			local pinnedPreferenceNames = ensurePinnedPreferenceNames()

			if pinned then
				pinnedPreferenceNames[p.Name] = true
			else
				pinnedPreferenceNames[p.Name] = nil
			end

			queuePreferenceSync() -- equivalent call inferred; original call site unknown
			fn()
		end

		local function handleLogNameColorChanged(state2, p: string?)
			local v28

			if state2 == nil or typeof(state2.Name) ~= "string" then
				v28 = false
			else
				v28 = #state2.Name <= 120
			end

			if not v28 or p ~= nil and not LogNameColors.isValidKey(p) or v20[state2.Name] == p then
				return
			end

			if p then
				v20[state2.Name] = p
			else
				v20[state2.Name] = nil
			end

			local nameColorKey = v20[state2.Name]

			if not LogNameColors.isValidKey(nameColorKey) then
				nameColorKey = nil
			end

			local colorForKey = LogNameColors.colorForKey(nameColorKey)
			local flag5

			if state2.NameColorKey == nameColorKey and state2.NameColor == colorForKey then
				flag5 = false
			else
				state2.NameColorKey = nameColorKey
				state2.NameColor = colorForKey
				flag5 = true
			end

			if flag5 then
				invalidateVisibleLogs() -- equivalent call inferred; original call site unknown
			end

			queuePreferenceSync() -- equivalent call inferred; original call site unknown
			fn()
		end

		local function handleFloatingHotkeyChanged(p, p2)
			local v28

			if p == nil or typeof(p.Name) ~= "string" then
				v28 = false
			else
				v28 = #p.Name <= 120
			end

			if not v28 then
				return
			end

			local v29 = sanitizeFloatingHotkeyCombo(p2) -- equivalent call inferred; original call site unknown

			if p2 ~= nil and not v29 then
				return
			end

			if v29 then
				local v30 = floatingHotkeySignature(v29) -- equivalent call inferred; original call site unknown

				for k, v31 in v18 do
					if not (k ~= p.Name and HotkeyCombo.signature(v31) == v30) then
						continue
					end

					v18[k] = nil
					v21[k] = nil
				end

				v18[p.Name] = v29
			else
				v18[p.Name] = nil
				v21[p.Name] = nil
			end

			queuePreferenceSync() -- equivalent call inferred; original call site unknown
			fn()
		end

		local function handleFloatingWindowChanged(p, positionPx: Vector2, sizePx: Vector2)
			local v28 = v21[p.Name]

			if not v28 then
				return
			end

			v28.PositionPx = positionPx
			v28.SizePx = sizePx
		end

		local function handlePopupWindowChanged(p, positionPx: Vector2, sizePx: Vector2)
			local v28 = v22[p.Name]

			if not v28 then
				return
			end

			v28.PositionPx = positionPx
			v28.SizePx = sizePx
		end

		local function handleFloatingMinimizedChanged(p, minimized: boolean)
			local v28 = v21[p.Name]

			if not v28 then
				return
			end

			v28.Minimized = minimized

			if minimized then
				local viewportSize = getViewportSize() -- equivalent call inferred; original call site unknown
				v28.PositionPx = Vector2.new(
					math.max(0, viewportSize.X - vector.X),
					(math.max(0, viewportSize.Y - vector.Y))
				)
			end

			fn()
		end

		local function handleClose()
			visible = false
			fn()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function handleResetWindow()
			windowPositionPx, windowSizePx = defaultWindowBounds()
			count += 1
			fn()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function handleWindowChanged(point: Vector2, point2: Vector2)
			windowPositionPx = point
			windowSizePx = point2
		end

		local function handlePopupClose(instance)
			local v28 = v22[instance.Name]

			if v28 and v28.CloseRemote and v28.CloseRemote.Parent then
				pcall(function()
					v28.CloseRemote:FireServer()
				end)
			end

			instance:Destroy()
		end

		local function handleSelectTab(value: number)
			if not v5 then
				return
			end

			local v28 = math.clamp(value, 1, (math.max(1, #v5.Tabs)))
			object2[v5] = v28
			v5.CURRENT_TAB = v5.Tabs[v28]
			local tab = v5.Tabs[v28]
			local name

			if tab then
				local name2 = tab.Name
				local v29

				if typeof(name2) == "string" and #name2 <= 80 then
					local controlCharacters = hasControlCharacters(name2) -- equivalent call inferred; original call site unknown
					v29 = not controlCharacters
				else
					v29 = false
				end

				if v29 then
					name = tab.Name
				end
			end

			if name then
				namesByName[v5.Name] = name
				queuePreferenceSync() -- equivalent call inferred; original call site unknown
			end

			updateCurrentLinePointers(v5) -- equivalent call inferred; original call site unknown
			lockedDown2 = true
			fn()
		end

		local function handleFloatingSelectTab(p, value: number)
			local v28 = v21[p.Name]

			if not v28 then
				return
			end

			local selectedTabIndex = math.clamp(value, 1, (math.max(1, #p.Tabs)))
			v28.SelectedTabIndex = selectedTabIndex
			object3[p] = selectedTabIndex
			local tab = p.Tabs[selectedTabIndex]
			local name

			if tab then
				local name2 = tab.Name
				local v30

				if typeof(name2) == "string" and #name2 <= 80 then
					local controlCharacters = hasControlCharacters(name2) -- equivalent call inferred; original call site unknown
					v30 = not controlCharacters
				else
					v30 = false
				end

				if v30 then
					name = tab.Name
				end
			end

			if name then
				namesByName2[p.Name] = name
				queuePreferenceSync() -- equivalent call inferred; original call site unknown
			end

			v28.LockedDown = true
			setTabLineStartToBottom(p, selectedTabIndex) -- equivalent call inferred; original call site unknown
			fn()
		end

		local function handlePopupSelectTab(p, value: number)
			local v28 = v22[p.Name]

			if not v28 then
				return
			end

			local selectedTabIndex = math.clamp(value, 1, (math.max(1, #p.Tabs)))
			v28.SelectedTabIndex = selectedTabIndex
			v28.LockedDown = true
			setTabLineStartToBottom(p, selectedTabIndex) -- equivalent call inferred; original call site unknown
			fn()
		end

		local function handleReorderTabs(state2, p: number, p2: number)
			if p == p2 or p < 1 or p2 < 1 or #state2.Tabs < p or #state2.Tabs < p2 then
				return
			end

			local tab = state2.Tabs[getSelectedTabIndex(state2)]
			local v28 = {}

			for k, state in v21 do
				if k == state2.Name then
					table.insert(v28, {
						State = state,
						Tab = state2.Tabs[getFloatingSelectedTabIndex(state2, state)],
						Floating = true
					})
				end
			end

			for k, state in v22 do
				if k == state2.Name then
					table.insert(v28, {
						State = state,
						Tab = state2.Tabs[getPopupSelectedTabIndex(state2, state)],
						Floating = false
					})
				end
			end

			local v29 = table.remove(state2.Tabs, p)
			table.insert(state2.Tabs, p2, v29)
			local v30

			if tab then
				for k, tab2 in state2.Tabs do
					if tab2 ~= tab then
						continue
					end

					v30 = k
					break
				end
			end

			if v30 then
				object2[state2] = v30
				state2.CURRENT_TAB = state2.Tabs[v30]
			end

			for _, v31 in v28 do
				local tab2 = v31.Tab
				local selectedTabIndex

				if tab2 then
					for k, tab3 in state2.Tabs do
						if tab3 ~= tab2 then
							continue
						end

						selectedTabIndex = k
						break
					end
				else
					local k = nil
					selectedTabIndex = k
				end

				if not selectedTabIndex then
					continue
				end

				v31.State.SelectedTabIndex = selectedTabIndex

				if v31.Floating then
					object3[state2] = selectedTabIndex
				end
			end

			if state2.IsPopup ~= true then
				v19[state2.Name] = collectTabNames(state2)
				queuePreferenceSync() -- equivalent call inferred; original call site unknown
			end

			count4 += 1
			fn()
		end

		local function handleLockedDownChanged(flag5: boolean)
			if lockedDown2 == flag5 then
				return
			end

			lockedDown2 = flag5

			if flag5 and v6 then
				setTabLineStartToBottom(v6, getSelectedTabIndex(v6)) -- equivalent call inferred; original call site unknown
			end

			fn()
		end

		local function handleFloatingLockedDownChanged(p, lockedDown: boolean)
			local v28 = v21[p.Name]

			if not (v28 and v28.LockedDown ~= lockedDown) then
				return
			end

			v28.LockedDown = lockedDown

			if lockedDown then
				setTabLineStartToBottom(p, getFloatingSelectedTabIndex(p, v28)) -- equivalent call inferred; original call site unknown
			end

			fn()
		end

		local function handlePopupLockedDownChanged(p, lockedDown: boolean)
			local v28 = v22[p.Name]

			if not (v28 and v28.LockedDown ~= lockedDown) then
				return
			end

			v28.LockedDown = lockedDown

			if lockedDown then
				setTabLineStartToBottom(p, getPopupSelectedTabIndex(p, v28)) -- equivalent call inferred; original call site unknown
			end

			fn()
		end

		local function handleToastActivated(p)
			visible = true

			if p.Log then
				p.Log:Show()
			end

			dismissToast(p.Id)
		end

		local function handleTextOverflowModeChanged(p: string)
			if not isValidTextOverflowMode(p) then
				return
			end

			textOverflowMode = p
			queuePreferenceSync() -- equivalent call inferred; original call site unknown
			fn(true)
		end

		local function handleMinimalTablesChanged(flag5: boolean)
			minimalTables = flag5
			queuePreferenceSync() -- equivalent call inferred; original call site unknown
			fn(true)
		end

		local function handleIgnoreToastAlertsChanged(flag5: boolean)
			ignoreToastAlerts = flag5

			if flag5 then
				table.clear(toasts)
				count3 += 1
			end

			queuePreferenceSync() -- equivalent call inferred; original call site unknown
			fn()
		end

		local function handleShowHiddenLogsChanged(flag5: boolean)
			showHiddenLogs2 = flag5
			local v28 = v5
			local v29

			if v28 == nil or v28.IsPopup == true then
				v29 = false
			else
				local v30

				if v28.IrisLogSettings.Hidden == true then
					local v31

					if v28 == nil then
						v31 = false
					else
						local category = v28.Category

						if typeof(category) ~= "string" and v28.IrisLogSettings ~= nil then
							category = v28.IrisLogSettings.Category
						end

						if typeof(category) == "string" then
							v31 = category ~= ""
						else
							v31 = false
						end
					end

					if v31 then
						v29 = showHiddenLogs2
					else
						v29 = showHiddenLogs2

						if not v29 then
							if v28.Pinned == true then
								v29 = true
							else
								if v28 == nil then
									v30 = false
								else
									v30 = v28.NameColor ~= nil
								end

								v29 = v30 or v28.IrisLogSettings.Hidden ~= true
							end
						end
					end
				else
					v29 = showHiddenLogs2

					if not v29 then
						if v28.Pinned == true then
							v29 = true
						else
							if v28 == nil then
								v30 = false
							else
								v30 = v28.NameColor ~= nil
							end

							v29 = v30 or v28.IrisLogSettings.Hidden ~= true
						end
					end
				end
			end

			if not v29 then
				v5 = nil
			end

			invalidateVisibleLogs() -- equivalent call inferred; original call site unknown
			queuePreferenceSync() -- equivalent call inferred; original call site unknown
			fn()
		end

		local function handleExportSettings()
			local settingsExchange = data.Script:FindFirstChild("SettingsExchange")

			if not (settingsExchange and settingsExchange:IsA("RemoteFunction")) then
				settingsExchange = nil
			end

			if not settingsExchange then
				addSystemToast("IrisLog settings export is unavailable.")
				return false, nil
			end

			local success, result = pcall(function()
				return settingsExchange:InvokeServer("Export", (collectPreferences()))
			end)

			if not success then
				addSystemToast("IrisLog settings export failed.")
				return false, nil
			end

			if result == nil then
				return false, nil
			end

			if typeof(result) == "table" and result.Success == true and typeof(result.Value) == "string" then
				addSystemToast("IrisLog settings exported.")
				return true, result.Value
			end

			addSystemToast((typeof(result) ~= "table" or typeof(result.Error) ~= "string") and "IrisLog settings export failed." or result.Error)
			return false, nil
		end

		local function handleImportSettings(value: string)
			local v28 = string.gsub(value, "%s+", "")

			if v28 == "" then
				addSystemToast("Paste an IrisLog settings export first.")
				return false
			end

			local settingsExchange = data.Script:FindFirstChild("SettingsExchange")

			if not (settingsExchange and settingsExchange:IsA("RemoteFunction")) then
				settingsExchange = nil
			end

			if not settingsExchange then
				addSystemToast("IrisLog settings import is unavailable.")
				return false
			end

			local success, result = pcall(function()
				return settingsExchange:InvokeServer("Import", v28)
			end)

			if not success then
				addSystemToast("IrisLog settings import failed.")
				return false
			end

			if result == nil then
				return false
			end

			if typeof(result) == "table" and result.Success == true and typeof(result.Preferences) == "table" then
				applyPreferences(result.Preferences)
				addSystemToast("IrisLog settings imported.")
				return true
			else
				addSystemToast((typeof(result) ~= "table" or typeof(result.Error) ~= "string") and "IrisLog settings import failed." or result.Error)
				return false
			end
		end

		local function renderReact()
			if not v4 then
				return
			end

			local floatingWindowEntries = getFloatingWindowEntries()
			local popupWindowEntries = getPopupWindowEntries()

			if not visible and #toasts == 0 and #floatingWindowEntries == 0 and #popupWindowEntries == 0 and v13 then
				return
			end

			if not (windowPositionPx and windowSizePx) then
				local v28, v29 = defaultWindowBounds()
				handleWindowChanged(v28, v29) -- equivalent call inferred; original call site unknown
			end

			local visibleLogs = getVisibleLogs()
			local selectedLog = getSelectedLog()
			local selectedTabIndex2 = 1

			if selectedLog then
				selectedTabIndex2 = getSelectedTabIndex(selectedLog)
				local tab = selectedLog.Tabs[selectedTabIndex2]
				updateCurrentLinePointers(selectedLog) -- equivalent call inferred; original call site unknown

				if tab then
					if lockedDown2 then
						tab.LINE_RENDER_START = math.max(0, #tab.Lines - data.LineRenderLimit)
					elseif not tab.LINE_RENDER_START then
						tab.LINE_RENDER_START = math.max(0, #tab.Lines - data.LineRenderLimit)
					end
				end
			else
				v6 = nil
				lines = nil
			end

			for _, floatingWindowEntry in floatingWindowEntries do
				local log = floatingWindowEntry.Log
				local selectedTabIndex = floatingWindowEntry.SelectedTabIndex
				local tab = log.Tabs[selectedTabIndex]

				if not tab then
					continue
				end

				if floatingWindowEntry.LockedDown then
					tab.LINE_RENDER_START = math.max(0, #tab.Lines - data.LineRenderLimit)
				elseif not tab.LINE_RENDER_START then
					tab.LINE_RENDER_START = math.max(0, #tab.Lines - data.LineRenderLimit)
				end
			end

			for _, popupWindowEntry in popupWindowEntries do
				local log = popupWindowEntry.Log
				local selectedTabIndex = popupWindowEntry.SelectedTabIndex
				local tab = log.Tabs[selectedTabIndex]

				if not tab then
					continue
				end

				if popupWindowEntry.LockedDown then
					tab.LINE_RENDER_START = math.max(0, #tab.Lines - data.LineRenderLimit)
				elseif not tab.LINE_RENDER_START then
					tab.LINE_RENDER_START = math.max(0, #tab.Lines - data.LineRenderLimit)
				end
			end

			local v29 = v4
			local createElement = React.createElement
			local root = ReactComponents.Root
			local v30 = {
				Visible = visible,
				Logs = visibleLogs,
				LogVersion = count4,
				SelectedLog = selectedLog,
				SelectedTabIndex = selectedTabIndex2,
				LineRenderLimit = data.LineRenderLimit,
				LockedDown = lockedDown2,
				RenderVersion = count5,
				WindowPositionPx = windowPositionPx,
				WindowSizePx = windowSizePx,
				WindowResetToken = count,
				FloatingWindows = floatingWindowEntries,
				PopupWindows = popupWindowEntries,
				Context = context,
				Toasts = toasts,
				ToastVersion = count3,
				OnSelectLog = handleSelectLog,
				OnTogglePin = handleTogglePin,
				OnClear = clearLog,
				OnClose = handleClose,
				OnResetWindow = handleResetWindow,
				OnWindowChanged = handleWindowChanged,
				OnFloatingWindowChanged = handleFloatingWindowChanged,
				OnPopupWindowChanged = handlePopupWindowChanged,
				OnFloatingMinimizedChanged = handleFloatingMinimizedChanged,
				OnSelectTab = handleSelectTab,
				OnFloatingSelectTab = handleFloatingSelectTab,
				OnPopupSelectTab = handlePopupSelectTab,
				OnReorderTabs = handleReorderTabs,
				OnLockedDownChanged = handleLockedDownChanged,
				OnFloatingLockedDownChanged = handleFloatingLockedDownChanged,
				OnPopupLockedDownChanged = handlePopupLockedDownChanged,
				OnPopupClose = handlePopupClose,
				OnToastActivated = handleToastActivated,
				OnToastDismissed = dismissToast,
				TextOverflowMode = textOverflowMode,
				OnTextOverflowModeChanged = handleTextOverflowModeChanged,
				MinimalTables = minimalTables,
				OnMinimalTablesChanged = handleMinimalTablesChanged,
				IgnoreToastAlerts = ignoreToastAlerts,
				OnIgnoreToastAlertsChanged = handleIgnoreToastAlertsChanged,
				ShowHiddenLogs = showHiddenLogs2,
				OnShowHiddenLogsChanged = handleShowHiddenLogsChanged,
				OnExportSettings = handleExportSettings,
				OnImportSettings = handleImportSettings,
				OnLogNameColorChanged = handleLogNameColorChanged
			}
			local floatingHotkeyNames

			if selectedLog then
				floatingHotkeyNames = v18[selectedLog.Name]
			end

			v30.FloatingHotkeyNames = floatingHotkeyNames
			v30.OnFloatingHotkeyChanged = handleFloatingHotkeyChanged
			v29:render(createElement(root, v30))
			local v32 = not visible

			if v32 then
				if #toasts == 0 and #floatingWindowEntries == 0 then
					v32 = #popupWindowEntries == 0
				else
					v32 = false
				end
			end

			v13 = v32
		end

		fn = function(flag5: boolean?)
			if flag5 then
				flag4 = true
			end

			if v24 > 0 then
				v25 = true
				return
			end

			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false

				if flag4 then
					count5 += 1
					flag4 = false
				end

				renderReact()
			end)
		end

		function self._onReplicatedHandleUpdated(_, p: string, kind: string, p3)
			replicatedHandles[p] = {
				Kind = kind,
				Value = p3
			}
			fn(true)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function withReplicatedLines(fn2)
			v26 += 1
			local v28, v29 = xpcall(fn2, debug.traceback)
			v26 -= 1

			if not v28 then
				error(v29, 0)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function withRenderSuspended(fn2)
			v24 += 1
			local v28, v29 = xpcall(fn2, debug.traceback)
			v24 -= 1

			if v24 == 0 and v25 then
				v25 = false
				fn()
			end

			if not v28 then
				error(v29, 0)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function toggleMenu()
			visible = not visible

			if visible then
				createReactRoot()
				local selectedLog = getSelectedLog()

				if selectedLog then
					selectedLog:Show()
				end
			end

			fn()
		end

		local function resetWindow()
			handleResetWindow() -- equivalent call inferred; original call site unknown
		end

		local function isMainLogToggleKey(p)
			if p == Enum.KeyCode.F8 then
				return true
			end

			local v28 = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
			return p == Enum.KeyCode.P and v28
		end

		local function floatingHotkeyComboIsPressed(items, p)
			local v28 = false

			for _, item in items do
				local keyCodeFromName = HotkeyCombo.keyCodeFromName(item)

				if keyCodeFromName == nil then
					return false
				end

				if keyCodeFromName == p then
					v28 = true
				elseif not UserInputService:IsKeyDown(keyCodeFromName) then
					return false
				end
			end

			return v28
		end

		local function getFloatingLogForKeyCode(keyCode)
			local v28 = 0
			local v29 = nil

			for k, v30 in v18 do
				if not (v28 < #v30 and floatingHotkeyComboIsPressed(v30, keyCode)) then
					continue
				end

				v29 = data.IrisLogs[k]
				v28 = #v30
			end

			return v29
		end

		local function connectShortcuts()
			if flag2 or data.BuildInfo.IS_PUBLISHED and v11 < 2 then
				return
			end

			flag2 = true
			TextChatService.SendingMessage:Connect(function(p)
				if p.Text == "/log" or p.Text:upper() == "/F8" then
					toggleMenu() -- equivalent call inferred; original call site unknown
				end
			end)
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then
					return
				end

				local focusedTextBox = UserInputService:GetFocusedTextBox()

				if input.KeyCode == Enum.KeyCode.Unknown or (gameProcessed or focusedTextBox) then
					return
				end

				local keyCode = input.KeyCode
				local v28

				if keyCode == Enum.KeyCode.F8 then
					v28 = true
				else
					v28 = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)

					if keyCode ~= Enum.KeyCode.P then
						v28 = false
					end
				end

				if v28 then
					toggleMenu() -- equivalent call inferred; original call site unknown
				else
					local floatingLogForKeyCode = getFloatingLogForKeyCode(input.KeyCode)

					if floatingLogForKeyCode then
						toggleFloatingLog(floatingLogForKeyCode) -- equivalent call inferred; original call site unknown
					elseif input.KeyCode == Enum.KeyCode.F7 then
						local v29, v30 = defaultWindowBounds()
						handleWindowChanged(v29, v30) -- equivalent call inferred; original call site unknown
						count += 1
						fn()
					end
				end
			end)
		end

		local function fn2()
			createReactRoot()
			connectShortcuts()
			fn()
		end

		function self.Button(_, p: string, p2)
			return {
				p,
				p2,
				"</btn>",
				p
			}
		end

		function self.AuthorityButton(_, _, p: string, callback)
			return {
				p,
				callback,
				"</btn>",
				p
			}
		end

		function self:AppendHeader(...)
			table.insert(self.HeaderLines, { ... })
			fn(true)
		end

		function self:AppendToTab(p: string, ...)
			local lines2 = self:EnsureTab(p).Lines
			local v28 = { ... }
			local v29 = currentLineSource() -- equivalent call inferred; original call site unknown
			object[v28] = v29
			table.insert(lines2, v28)
			applyTabOrder(self)
			fn(true)
		end

		function self.ServerState(_, p: string)
			return { nil, p, "</srvst>" }
		end

		function self.AuthorityCheckbox(_, _, p: string, callback, flag5: boolean?)
			return {
				p,
				callback,
				"</chk>",
				p,
				flag5
			}
		end

		function self.AuthorityComboBox(_, _, p: string, p2, callback)
			return {
				p,
				callback,
				"</cmbo>",
				p,
				p2
			}
		end

		function self.AuthorityInstanceChildrenComboBox(_, _, p: string, p2, callback)
			return {
				p,
				callback,
				"</combochild>",
				p,
				p2
			}
		end

		function self.Checkbox(_, p: string, callback, flag5: boolean?)
			return {
				p,
				callback,
				"</chk>",
				p,
				flag5
			}
		end

		function self.ToastAlert(p, ...)
			addToast(p, ...)
		end

		self.Toast = self.ToastAlert

		function self:AppendWithTime(...)
			self.LastAppend = tick()
			markUnread(self, ...)
			local line = self.Lines[#self.Lines]

			if data.CompareLine({ data.ClientContextText, ... }, line) then
				data.IncrementNumRepeatsForLine(line)
			else
				local lines2 = self.Lines
				local v28 = { os.date("%H:%M:%S", os.time()), ... }
				local v29 = currentLineSource() -- equivalent call inferred; original call site unknown
				object[v28] = v29
				table.insert(lines2, v28)

				if #self.Lines > data.ClientLinesSaved then
					table.remove(self.Lines, 1)
				end
			end

			fn(true)
		end

		function self:RawAppend(...)
			self.LastAppend = tick()
			markUnread(self, ...)
			local lines2 = self.Lines
			local v28 = { ... }
			local v29 = currentLineSource() -- equivalent call inferred; original call site unknown
			object[v28] = v29
			table.insert(lines2, v28)
			fn(true)
		end

		function self:Append(...)
			self:AppendWithTime(data.LogContextText, ...)
		end

		function self.ClearTab(p, p2: string)
			clearTabLines(p, p2, "client")
		end

		function self:AppendAndStudioWarn(...)
			local RunService = game:GetService("RunService")

			if RunService:IsStudio() then
				warn(`[{debug.info(2, "s")}]:`, ...)
			end

			self:AppendWithTime(data.LogContextText, ...)
		end

		function self:MarkAsRead()
			if self.New == 0 and self.NewSeverity == nil then
				return
			end

			self.New = 0
			self.NewSeverity = nil
			count4 += 1
			fn()
		end

		self.Print = self.Append

		function self.Thread(p, p2, p3)
			p.Threads[p2] = { p3, tick() }
		end

		function self:Show()
			for _, v28 in data.SortedLogArray do
				v28:Hide()
			end

			self.Visible = true
			v5 = self
			self:MarkAsRead()
			updateCurrentLinePointers(self) -- equivalent call inferred; original call site unknown
			lockedDown2 = true
			fn()
		end

		function self:Hide()
			self.Visible = false
		end

		data.Script.UpdateState.OnClientEvent:Connect(function(p, p2)
			serverStates[p] = p2
			fn(true)
		end)
		data.Script.RemoteEvent.OnClientEvent:Connect(function(p, ...)
			local v28 = self.new(p)
			local v29 = { ... }
			local v30 = v29[1]

			if typeof(v30) == "number" then
				local line = v28.Lines[#v28.Lines]

				if data.CompareLine({ data.ServerContextText, unpack(v29, 2) }, line) then
					data.IncrementNumRepeatsForLine(line)
					fn(true)
				else
					local function fn3()
						v28:RawAppend(os.date("%H:%M:%S", v30 + v3), unpack(v29, 2))
					end

					withReplicatedLines(fn3) -- equivalent call inferred; original call site unknown
				end
			else
				v26 += 1
				local v31, v32 = xpcall(function()
					v28:RawAppend(unpack(v29))
				end, debug.traceback)
				v26 -= 1

				if not v31 then
					error(v32, 0)
				end
			end
		end)
		data.Script.event.OnClientEvent:Connect(function(p, ...)
			if p == "Preferences" then
				applyPreferences(...)
			elseif p == "Popup" then
				local v28 = select("#", ...)
				local v29, v30, remoteEvent = ...

				if typeof(v29) ~= "string" then
					return
				end

				local v31

				if typeof(v30) == "string" and typeof(remoteEvent) == "Instance" and remoteEvent:IsA("RemoteEvent") then
					v31 = 4
				else
					v30 = v29
					remoteEvent = nil
					v31 = 2
				end

				fn2()
				local v32 = self.new(v29)
				v32.DisplayName = v30
				v32.IsPopup = true
				v32.Visible = false
				v32.New = 0
				v32.NewSeverity = nil
				invalidateVisibleLogs() -- equivalent call inferred; original call site unknown
				local v33 = v22[v29]

				if v33 then
					v33.Title = v30
					v33.CloseRemote = remoteEvent or v33.CloseRemote
					v33.LockedDown = true
				else
					local positionPx, sizePx = defaultPopupWindowBounds(v29)
					v33 = {
						Title = v30,
						CloseRemote = remoteEvent,
						PositionPx = positionPx,
						SizePx = sizePx,
						ResetToken = 0,
						SelectedTabIndex = nil,
						LockedDown = true
					}
					v22[v29] = v33
				end

				local v34 = {}

				for i = v31, v28 do
					v34[i - v31 + 1] = select(i, ...)
				end

				if #v34 > 0 then
					if typeof(v34[1]) == "number" then
						v34[1] = os.date("%H:%M:%S", v34[1] + v3)
					end

					v32.LastAppend = tick()
					local lines2 = v32.Lines
					object[v34] = "server"
					table.insert(lines2, v34)
					setTabLineStartToBottom(v32, getPopupSelectedTabIndex(v32, v33)) -- equivalent call inferred; original call site unknown
				end

				fn(true)
			elseif p == "ReceiveBulk" then
				local v28, v29, v30, v31 = ...
				local v32 = self.new(v28, nil, v31)

				local function fn3()
					local function fn4()
						for _, v33 in v30 do
							if v33.Name == "Log" then
								for _, list in v33.Lines do
									list[1] = os.date("%H:%M:%S", list[1] + v3)
									v32:RawAppend(unpack(list))
								end
							else
								for _, list in v33.Lines do
									v32:AppendToTab(v33.Name, unpack(list))
								end
							end
						end

						if v29 then
							for _, list in v29 do
								v32:AppendHeader(unpack(list))
							end
						end
					end

					withReplicatedLines(fn4) -- equivalent call inferred; original call site unknown
					applyTabOrder(v32)
				end

				withRenderSuspended(fn3) -- equivalent call inferred; original call site unknown
			elseif p == "AppendHeader" then
				local v28 = { ... }
				local v29 = v28[1]
				local v30 = self.new(v29)
				v26 += 1
				local v31, v32 = xpcall(function()
					v30:AppendHeader(unpack(v28, 2))
				end, debug.traceback)
				v26 -= 1

				if not v31 then
					error(v32, 0)
				end
			elseif p == "AppendToTab" then
				local v28 = { ... }
				local v29 = v28[1]
				local v30 = v28[2]
				local v31 = self.new(v29)
				v26 += 1
				local v32, v33 = xpcall(function()
					v31:AppendToTab(v30, unpack(v28, 3))
				end, debug.traceback)
				v26 -= 1

				if not v32 then
					error(v33, 0)
				end
			elseif p == "ClearTab" then
				local v28, v29 = ...

				if typeof(v28) ~= "string" or typeof(v29) ~= "string" then
					return
				end

				clearTabLines(self.new(v28), v29, "server")
			elseif p == "DestroyLog" then
				local v28 = ...

				if typeof(v28) ~= "string" then
					return
				end

				local irisLog = data.IrisLogs[v28]

				if irisLog then
					irisLog:Destroy()
				end
			elseif p == "UpdateReplicatedObject" then
				local v28, v29, kind, v31 = ...

				if typeof(v28) ~= "string" or typeof(v29) ~= "string" or kind ~= "object" and kind ~= "inline-log" then
					return
				end

				self.new(v28)
				replicatedHandles[v29] = {
					Kind = kind,
					Value = v31
				}
				fn(true)
			elseif p == "ToastAlert" then
				local v28 = ...
				addToast(self.new(v28), select(2, ...))
			elseif p == "SetCategory" then
				local v28, v29 = ...

				if typeof(v28) ~= "string" then
					return
				end

				local v30 = self.new(v28)

				if typeof(v29) ~= "string" then
					v29 = nil
				end

				v30:SetCategory(v29)
			elseif p == "EnableLogs" then
				v11 = ...
				task.spawn(function()
					local irisLogModules = game.Players.LocalPlayer:WaitForChild("PlayerGui", 100):WaitForChild(
						"IrisLogModules",
						9999
					)

					if irisLogModules then
						for _, child in irisLogModules:GetChildren() do
							local v28 = child
							task.spawn(function()
								local module = require(v28)

								repeat
									task.wait()
								until data.IrisLogs[v28.Name]

								module.Client(data.IrisLogs[v28.Name])
							end)
						end

						irisLogModules.ChildAdded:Connect(function(child)
							local module = require(child)

							repeat
								task.wait()
							until data.IrisLogs[child.Name]

							module.Client(data.IrisLogs[child.Name])
						end)
					end
				end)
				fn2()
			end
		end)
	end
}