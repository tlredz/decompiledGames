local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
require(ReplicatedStorage.CUI)
local DevPanelAnalytics = require(ReplicatedStorage._FRAMEWORK.Features.Admins.DevPanelAnalytics)
local MessagingLogConsole = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.MessagingLogConsole)
require(script.Parent.Parent.Types)
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local rbxassetfontsfamiliesRobotoMonojson = Font.new("rbxasset://fonts/families/RobotoMono.json")
local v = {
	sent = Color3.fromRGB(105, 195, 255),
	received = Color3.fromRGB(125, 235, 155)
}

local function clearComponents(object)
	for _, v2 in object:GetAll() do
		v2:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addReadOnlyField(components, p: string, p2: string)
	components:AddField(function(object)
		object:SetText(p):SetValue(p2):SetEnabled(false)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatSnapshotTime(timestamp: number)
	local localTime = DateTime.fromUnixTimestamp(timestamp):ToLocalTime()
	return string.format("%02d:%02d:%02d", localTime.Hour, localTime.Minute, localTime.Second)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatLogTime(timestampMillis: number)
	local localTime = DateTime.fromUnixTimestampMillis(timestampMillis):ToLocalTime()
	return string.format(
		"%02d:%02d:%02d.%03d",
		localTime.Hour,
		localTime.Minute,
		localTime.Second,
		localTime.Millisecond
	)
end

local function countSubscriptions(p)
	local count = 0

	for _, handler in p.handlers do
		if handler.isSubscribed then
			count += 1
		end
	end

	return count, #p.handlers - count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function matchesLogFilter(p, value: string)
	return value == "All" or string.lower(value) == p.direction
end

local function getLogRowHeight(p, formatted: string, p2: number, p3)
	local width = math.max(math.floor(p2 - 22), 40)
	local v3 = p3[p.id]

	if v3 and v3.width == width then
		return v3.height
	end

	local height = math.max(
		24,
		math.ceil(TextService:GetTextSize(formatted, 12, Enum.Font.RobotoMono, Vector2.new(width, 100000)).Y) + 8
	)
	p3[p.id] = {
		width = width,
		height = height
	}
	return height
end

local function createMessagingLogRows(list, p: string, value: string, zIndex: number, p2: number, p3)
	local v2 = { create("UIListLayout")({
			Padding = UDim.new(0, 1),
			SortOrder = Enum.SortOrder.LayoutOrder
		}) }
	local count = 0
	local v3 = {}

	for i = #list, 1, -1 do
		local v4 = list[i]

		if not matchesLogFilter(v4, value) then
			continue
		end

		local v5 = string.lower((`{v4.direction} {v4.topic} {v4.payload}`))

		if not (p == "" or string.find(v5, p, 1, true)) then
			continue
		end

		count += 1

		if #v3 < 120 then
			table.insert(v3, v4)
		end
	end

	local count2 = 0
	local v4 = count - #v3

	if v4 > 0 then
		count2 += 1
		table.insert(v2, create("TextLabel")({
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0,
			FontFace = rbxassetfontsfamiliesRobotoMonojson,
			LayoutOrder = count2,
			Size = UDim2.new(1, -3, 0, 22),
			Text = `{v4} older matching messages hidden for performance`,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			ZIndex = zIndex + 3
		}))
	end

	local count3 = 0

	for i = #v3, 1, -1 do
		local v5 = v3[i]
		count3 += 1
		count2 += 1
		local v6 = v5.direction == "sent" and "SENT" or "RECV"
		local formatted = `[{formatLogTime(v5.timestampMillis)}] [{v6}] [{v5.topic}] ({v5.payloadBytes} B)\n{v5.payload}`
		local logRowHeight = getLogRowHeight(v5, formatted, p2, p3)
		local v7 = create("TextLabel")
		local v8 = {
			Name = `MessagingLog_{v5.id}`,
			AutomaticSize = Enum.AutomaticSize.None
		}
		local backgroundColor

		if count3 % 2 == 0 then
			backgroundColor = Color3.fromRGB(28, 28, 28)
		else
			backgroundColor = Color3.fromRGB(23, 23, 23)
		end

		v8.BackgroundColor3 = backgroundColor
		v8.BorderSizePixel = 0
		v8.FontFace = rbxassetfontsfamiliesRobotoMonojson
		v8.LayoutOrder = count2
		v8.RichText = false
		v8.Size = UDim2.new(1, -3, 0, logRowHeight)
		v8.Text = formatted
		v8.TextColor3 = v[v5.direction]
		v8.TextSize = 12
		v8.TextWrapped = true
		v8.TextXAlignment = Enum.TextXAlignment.Left
		v8.TextYAlignment = Enum.TextYAlignment.Top
		v8.ZIndex = zIndex + 3
		do local _values = table.pack(create("UIPadding")({
	PaddingTop = UDim.new(0, 3),
	PaddingBottom = UDim.new(0, 3),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6)
})); for _k = 1, _values.n do v8[_k] = _values[_k] end end
		table.insert(v2, v7(v8))
	end

	if count == 0 then
		table.insert(v2, create("TextLabel")({
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, -8, 0, 44),
			FontFace = rbxassetfontsfamiliesRobotoMonojson,
			Text = "Waiting for MessagingService activity...",
			TextColor3 = Color3.fromRGB(135, 135, 135),
			TextSize = 12,
			TextWrapped = true,
			ZIndex = zIndex + 3
		}))
	end

	return (create("Frame")({
		Name = "MessagingLogRows",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -4, 0, 0),
		ZIndex = zIndex + 2,
		v2
	}))
end

return {
	DisplayName = "Messaging Analytics",
	Permission = "cui.dev.analytics.messaging",
	Order = 50,
	Setup = function(object, p)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v2 = nil
		local v3 = ""
		local flag = false
		local sequence = -1
		local v4 = {}
		local v5 = {}
		local v6 = {}
		local v7 = ""
		local v8 = "All"
		local v9 = true
		local v10 = nil
		local v11 = nil
		local thread = nil
		local v12 = false

		local function fn() end

		local v13 = object:AddField(function(object2)
			object2:SetText("Live stream"):SetValue("Paused"):SetEnabled(false)
		end)
		local v14 = object:AddTab(function(object2)
			object2:SetTabs({ "Live Traffic", "Metrics & Topics" })
		end)
		local componentCtn = v14:GetComponentCtn("Live Traffic")
		local componentCtn2 = v14:GetComponentCtn("Metrics & Topics")
		local UI = componentCtn:AddList(function(object2)
			object2:SetSizeY(380)
		end):GetUI()
		local content = UI:FindFirstChild("Content")

		if content and content:IsA("GuiObject") then
			content.Visible = false
		end

		local scrollBG = UI:FindFirstChild("ScrollBG")

		if scrollBG and scrollBG:IsA("GuiObject") then
			scrollBG.Visible = false
		end

		componentCtn2:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search messaging topics..."):SetValue(""):SetOnChangedRaw(function(value)
				v3 = string.lower(value)
				fn()
			end)
		end)
		local v15 = componentCtn2:AddList(function(object2)
			object2:SetSizeY(330)
		end)

		fn = function()
			local scroll = v15:GetScroll()

			for _, v16 in v15.Components:GetAll() do
				v16:Destroy()
			end

			local v16 = v2
			local messaging

			if v16 then
				messaging = v16.messaging
			else
				messaging = nil
			end

			if not (v16 and messaging) then
				v15.Components:AddText(function(object2)
					object2:SetText("Open this panel to begin streaming MessagingService diagnostics."):SetTextColor(Color3.fromRGB(
						150,
						150,
						150
					)):SetAutoResize(true)
				end)
				return
			end

			local count = 0

			for _, handler in messaging.handlers do
				if handler.isSubscribed then
					count += 1
				end
			end

			local v17 = #messaging.handlers - count
			local v18 = messaging.failedSendAttempts + messaging.failedSubscriptionsAttempts == 0 and v17 == 0 and "Healthy" or "Needs attention"
			v15.Components:AddTitle(function(object2)
				object2:SetTitle("Health overview")
			end)
			v15.Components:AddSplit(function(p2)
				p2.LeftComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Status: {v18}`)):SetEnabled(false)
				end)
				p2.RightComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Handlers: {count}/{#messaging.handlers} live`)):SetEnabled(false)
				end)
			end)
			v15.Components:AddTitle(function(object2)
				object2:SetTitle("Traffic")
			end)
			v15.Components:AddSplit(function(p2)
				p2.LeftComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Sent/min: {messaging.messageSentLastMinute}`)):SetEnabled(false)
				end)
				p2.RightComponents:AddField(function(object2)
					object2:SetTextVisible(false):SetValue((`Received/min: {messaging.messageReceivedLastMinute}`)):SetEnabled(false)
				end)
			end)
			addReadOnlyField(
				v15.Components,
				"Lifetime traffic",
				`{messaging.messageSent} sent / {messaging.messageReceived} received`
			) -- equivalent call inferred; original call site unknown
			addReadOnlyField(
				v15.Components,
				"Retries & filtering",
				`{messaging.failedSendAttempts} send retries, {messaging.failedSubscriptionsAttempts} subscription retries, {messaging.duplicateFound} duplicates blocked`
			) -- equivalent call inferred; original call site unknown
			v15.Components:AddTitle(function(object2)
				object2:SetTitle((`Topic handlers ({#messaging.handlers})`))
			end)
			local count2 = 0

			for _, handler in messaging.handlers do
				local v21 = handler.isSubscribed and "subscribed" or "not subscribed"
				local v22 = string.lower((`{handler.topic} {v21} {handler.subscriberCount} listeners`))

				if not (v3 == "" or string.find(v22, v3, 1, true)) then
					continue
				end

				count2 += 1
				local v23 = handler
				v15.Components:AddExpandable(function(object2)
					object2:SetText((`{v23.isSubscribed and "[LIVE]" or "[IDLE]"} {v23.topic}`))
					addReadOnlyField(object2.Components, "Topic", v23.topic) -- equivalent call inferred; original call site unknown
					addReadOnlyField(
						object2.Components,
						"Subscription",
						v23.isSubscribed and "Subscribed and receiving" or "Handler exists but is not subscribed"
					) -- equivalent call inferred; original call site unknown
					addReadOnlyField(object2.Components, "Local subscribers", tostring(v23.subscriberCount)) -- equivalent call inferred; original call site unknown
					object2:BindOnExpanded(function(p2, p3)
						if p3 then
							v4[v23.topic] = p2
						end
					end)

					if v4[v23.topic] then
						object2:SetExpanded(true, false, true)
					end
				end)
			end

			if count2 == 0 then
				v15.Components:AddText(function(object2)
					object2:SetText("No messaging topics match this search."):SetTextColor(Color3.fromRGB(150, 150, 150)):SetYSize(22)
				end)
			end

			v15:SetScroll(scroll)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function canRenderLogs()
			return p.isVisible() and v14:GetOpenTabName() == "Live Traffic"
		end

		local function fn2()
			local v16 = v10

			if not v16 then
				return
			end

			if v11 then
				v11()
			end

			for _, child in v16:GetChildren() do
				if child.Name == "MessagingLogRows" then
					child:Destroy()
				end
			end

			v11 = Vide.mount(function()
				return (createMessagingLogRows(v5, v7, v8, v16.ZIndex, math.max(v16.AbsoluteSize.X, 300), v6))
			end, v16)

			if v9 then
				task.defer(function()
					if not flag and v16.Parent then
						v16.CanvasPosition = Vector2.new(0, (math.max(v16.AbsoluteCanvasSize.Y, 0)))
					end
				end)
			end
		end

		local function fn3()
			if flag or v12 or not p.isVisible() or v14:GetOpenTabName() ~= "Live Traffic" then
				return
			end

			v12 = true
			thread = task.delay(0.06, function()
				thread = nil
				v12 = false

				if not flag and canRenderLogs() then
					fn2()
				end
			end)
		end

		local v16 = Vide.mount(function()
			return MessagingLogConsole({
				baseZIndex = UI.ZIndex,
				onRowsMounted = function(p2)
					v10 = p2
					fn3()
				end,
				onSearchChanged = function(p2)
					v7 = p2
					fn3()
				end,
				onDirectionChanged = function(p2)
					v8 = p2
					fn3()
				end,
				onToggleFollow = function(p2)
					v9 = not v9
					p2.Text = v9 and "Follow: ON" or "Follow: OFF"
					local textColor

					if v9 then
						textColor = Color3.fromRGB(140, 230, 140)
					else
						textColor = Color3.fromRGB(200, 200, 200)
					end

					p2.TextColor3 = textColor

					if v9 then
						fn3()
					end
				end,
				onClear = function()
					table.clear(v5)
					table.clear(v6)
					fn3()
				end
			})
		end, UI)
		componentCtn2:AddButton(function(object2)
			object2:SetButtonText("Refresh messaging snapshot"):SetYSize(22):SetEnabledPermission("cui.dev.analytics.messaging"):SetButtonCallback(function()
				v13:SetValue("Refreshing...")
				DevPanelAnalytics.refreshPanel("messaging")
			end)
		end)
		local connection = DevPanelAnalytics.connectToPanel("messaging", function(data)
			if flag or data.panel ~= "messaging" then
				return
			end

			if data.ok then
				if data.sequence <= sequence then
					return
				end

				sequence = data.sequence
				v2 = data
				v13:SetValue((`Live - updated {formatSnapshotTime(data.timestamp)} - every {DevPanelAnalytics.getUpdateIntervalSeconds()}s`))
				fn()
			else
				v13:SetValue("Stream error")
				NotificationSystem:ShowGeneralNotification(
					`Messaging analytics failed: {data.errorMessage}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end
		end)
		local connection2 = DevPanelAnalytics.connectToMessagingLog(function(p2)
			if flag then
				return
			end

			table.insert(v5, p2)

			while #v5 > 500 do
				local v17 = table.remove(v5, 1)

				if v17 then
					v6[v17.id] = nil
				end
			end

			fn3()
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateListening(visible: boolean)
			if flag then
				return
			end

			v13:SetValue(visible and "Connecting..." or "Paused")
			DevPanelAnalytics.setPanelListening("messaging", visible)

			if visible then
				fn3()
			end
		end

		local visibilityChangedConnection = p.visibilityChanged:Connect(updateListening)
		local onTabOpenedConnection = v14.OnTabOpened:Connect(function(p2)
			if p2 == "Live Traffic" then
				fn3()
			end
		end)
		v13:GetUI().Destroying:Connect(function()
			flag = true
			DevPanelAnalytics.setPanelListening("messaging", false)

			if thread then
				task.cancel(thread)
				thread = nil
			end

			v12 = false
			connection:Disconnect()
			connection2:Disconnect()
			visibilityChangedConnection:Disconnect()
			onTabOpenedConnection:Disconnect()

			if v11 then
				v11()
			end

			if v16 then
				v16()
			end

			v11 = nil
			v16 = nil
			v10 = nil
		end)
		fn()
		updateListening(p.isVisible()) -- equivalent call inferred; original call site unknown
	end
}