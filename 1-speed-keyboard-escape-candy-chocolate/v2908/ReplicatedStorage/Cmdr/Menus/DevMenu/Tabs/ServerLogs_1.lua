local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local Signal = require(ReplicatedStorage.Utilities.Signal)
require(script.Parent.Parent.Types)
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local v = {}
local v2 = {}
local count = 0
local v3 = Signal.new()
local object = setmetatable({}, {
	__mode = "k"
})
local v4 = {
	"All",
	"Output",
	"Warning",
	"Error"
}
local v5 = {
	MessageOutput = Color3.fromRGB(225, 225, 225),
	MessageInfo = Color3.fromRGB(120, 190, 255),
	MessageWarning = Color3.fromRGB(255, 205, 90),
	MessageError = Color3.fromRGB(255, 105, 105)
}

local function TrimEntries(list)
	while #list > 500 do
		local v6 = table.remove(list, 1)

		if v6 then
			object[v6] = nil
		end
	end
end

local function NormalizeMessage(value: string)
	if #value <= 8000 then
		return value
	end

	return string.sub(value, 1, 8000) .. "\n... [truncated]"
end

local function AddServerEntry(message: string, p, p2: number?)
	count += 1
	local v6 = {
		Id = count,
		Timestamp = math.floor(p2 or os.time()),
		Message = 0,
		MessageType = 0
	}

	if not (#message <= 8000) then
		message = string.sub(message, 1, 8000) .. "\n... [truncated]"
	end

	v6.Message = message
	v6.MessageType = p.Name
	table.insert(v, v6)
	TrimEntries(v)
	return v6
end

local function MergeClientEntries(items)
	local v6 = {}

	for _, v7 in v2 do
		v6[v7.Id] = true
	end

	for _, item in items do
		if v6[item.Id] then
			continue
		end

		v6[item.Id] = true
		table.insert(v2, item)
	end

	table.sort(v2, function(a, b)
		return a.Id < b.Id
	end)
	TrimEntries(v2)
	v3:Fire()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MatchesFilter(p, p2: string)
	if p2 == "All" then
		return true
	elseif p2 == "Output" then
		return p.MessageType == "MessageOutput" or p.MessageType == "MessageInfo"
	elseif p2 == "Warning" then
		return p.MessageType == "MessageWarning"
	end

	return p.MessageType == "MessageError"
end

local function FormatTimestamp(p: number)
	return os.date("!%H:%M:%S", p)
end

local function GetRowHeight(p, formatted: string, p2: number)
	local width = math.max(math.floor(p2 - 22), 40)
	local v7 = object[p]

	if v7 and v7.Width == width then
		return v7.Height
	end

	local height = math.max(
		22,
		math.ceil(TextService:GetTextSize(formatted, 12, Enum.Font.RobotoMono, Vector2.new(width, 100000)).Y) + 8
	)
	object[p] = {
		Width = width,
		Height = height
	}
	return height
end

local function CreateLogRows(list, p: string, p2: string, zIndex: number, p3: number)
	local v6 = { create("UIListLayout")({
			Padding = UDim.new(0, 1),
			SortOrder = Enum.SortOrder.LayoutOrder
		}) }
	local count2 = 0
	local v7 = {}

	for i = #list, 1, -1 do
		local v8 = list[i]

		-- equivalent call inferred; original call site unknown
		if not MatchesFilter(v8, p2) then
			continue
		end

		local v9 = string.lower((`{v8.MessageType} {v8.Message}`))

		if not (p == "" or string.find(v9, p, 1, true)) then
			continue
		end

		count2 += 1

		if #v7 < 120 then
			table.insert(v7, v8)
		end
	end

	local v8 = count2 - #v7
	local count3 = 0

	if v8 > 0 then
		count3 += 1
		table.insert(v6, create("TextLabel")({
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			LayoutOrder = count3,
			Size = UDim2.new(1, -3, 0, 22),
			Text = `{v8} older matching logs hidden for performance`,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			ZIndex = zIndex + 3
		}))
	end

	local count4 = 0

	for i = #v7, 1, -1 do
		local v9 = v7[i]
		count4 += 1
		count3 += 1
		local v10 = string.gsub(v9.MessageType, "^Message", "")
		local timestamp = v9.Timestamp
		local formatted = `[{os.date("!%H:%M:%S", timestamp)}] [{v10}] {v9.Message}`
		local rowHeight = GetRowHeight(v9, formatted, p3)
		local v12 = create("TextLabel")
		local v13 = {
			Name = `Log_{v9.Id}`,
			AutomaticSize = Enum.AutomaticSize.None
		}
		local backgroundColor

		if count4 % 2 == 0 then
			backgroundColor = Color3.fromRGB(28, 28, 28)
		else
			backgroundColor = Color3.fromRGB(23, 23, 23)
		end

		v13.BackgroundColor3 = backgroundColor
		v13.BorderSizePixel = 0
		v13.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json")
		v13.LayoutOrder = count3
		v13.RichText = false
		v13.Size = UDim2.new(1, -3, 0, rowHeight)
		v13.Text = formatted
		v13.TextColor3 = v5[v9.MessageType] or Color3.fromRGB(225, 225, 225)
		v13.TextSize = 12
		v13.TextWrapped = true
		v13.TextXAlignment = Enum.TextXAlignment.Left
		v13.TextYAlignment = Enum.TextYAlignment.Top
		v13.ZIndex = zIndex + 3
		do local _values = table.pack(create("UIPadding")({
	PaddingTop = UDim.new(0, 3),
	PaddingBottom = UDim.new(0, 3),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6)
})); for _k = 1, _values.n do v13[_k] = _values[_k] end end
		table.insert(v6, v12(v13))
	end

	if count2 == 0 then
		table.insert(v6, create("TextLabel")({
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, -8, 0, 30),
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			Text = "No server logs match the current filter.",
			TextColor3 = Color3.fromRGB(135, 135, 135),
			TextSize = 12,
			ZIndex = zIndex + 3
		}))
	end

	return (create("Frame")({
		Name = "ServerLogRows",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -4, 0, 0),
		ZIndex = zIndex + 2,
		v6
	}))
end

local function CreateConsole(data)
	local baseZIndex = data.BaseZIndex
	local source = Vide.source(false)
	local v6 = { create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder
		}) }
	local v7 = nil
	local v8 = nil

	for k, text in v4 do
		local v10 = text
		table.insert(v6, create("TextButton")({
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			LayoutOrder = k,
			Size = UDim2.new(1, 0, 0, 22),
			Text = text,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			ZIndex = baseZIndex + 12,
			MouseButton1Click = function()
				source(false)

				if v7 then
					v7.Text = `{v10}  ▾`
				end

				data.OnFilterChanged(v10)
			end
		}))
	end

	return (create("Frame")({
		Name = "ServerConsole",
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.fromScale(1, 1),
		ZIndex = baseZIndex + 1,
		create("TextBox")({
			Name = "Search",
			BackgroundColor3 = Color3.fromRGB(31, 31, 31),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			ClearTextOnFocus = false,
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			PlaceholderText = "search server logs...",
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -96, 0, 24),
			Text = "",
			TextColor3 = Color3.fromRGB(230, 230, 230),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = baseZIndex + 3,
			create("UIPadding")({
				PaddingLeft = UDim.new(0, 7),
				PaddingRight = UDim.new(0, 7)
			}),
			Vide.action(function(instance)
				local textChangedConnection = instance:GetPropertyChangedSignal("Text"):Connect(function()
					data.OnSearchChanged(string.lower(instance.Text))
				end)
				Vide.cleanup(textChangedConnection)
			end)
		}),
		create("TextButton")({
			Name = "Filter",
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			Position = UDim2.new(1, -88, 0, 4),
			Size = UDim2.fromOffset(84, 24),
			Text = "All  ▾",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			ZIndex = baseZIndex + 3,
			MouseButton1Click = function()
				source(not source())
			end,
			Vide.action(function(p)
				v7 = p
			end)
		}),
		create("Frame")({
			Name = "FilterDropdown",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			Position = UDim2.new(1, -88, 0, 29),
			Size = UDim2.fromOffset(84, #v4 * 22),
			Visible = source,
			ZIndex = baseZIndex + 11,
			v6
		}),
		create("ScrollingFrame")({
			Name = "Rows",
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			CanvasSize = UDim2.new(),
			Position = UDim2.fromOffset(4, 32),
			ScrollBarImageColor3 = Color3.fromRGB(95, 95, 95),
			ScrollBarThickness = 7,
			Size = UDim2.new(1, -8, 1, -64),
			ZIndex = baseZIndex + 2,
			Vide.action(function(p)
				data.OnRowsMounted(p)
			end)
		}),
		create("TextButton")({
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			Position = UDim2.new(0, 4, 1, -28),
			Size = UDim2.new(0.34, -4, 0, 24),
			Text = "Refresh history",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			ZIndex = baseZIndex + 3,
			MouseButton1Click = data.OnRefresh
		}),
		create("TextButton")({
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			Position = UDim2.new(0.34, 2, 1, -28),
			Size = UDim2.new(0.33, -4, 0, 24),
			Text = "Clear local",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			ZIndex = baseZIndex + 3,
			MouseButton1Click = data.OnClear
		}),
		create("TextButton")({
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
			Position = UDim2.new(0.67, 0, 1, -28),
			Size = UDim2.new(0.33, -4, 0, 24),
			Text = "Follow: ON",
			TextColor3 = Color3.fromRGB(140, 230, 140),
			TextSize = 12,
			ZIndex = baseZIndex + 3,
			MouseButton1Click = function()
				if v8 then
					data.OnToggleAutoScroll(v8)
				end
			end,
			Vide.action(function(p)
				v8 = p
			end)
		})
	}))
end

local serverEvent = AdminRemote.RegisterServerEvent("AdminMenu_Logging_Push", "cui.dev.serverLogs", function(_, p)
	if type(p) ~= "table" then
		return
	end

	MergeClientEntries({ p })
end)
local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_Logging_GetHistory",
	"cui.dev.serverLogs",
	false,
	function()
		return {
			Entries = table.clone(v)
		}
	end
)

if RunService:IsServer() then
	local success, logHistory = pcall(LogService.GetLogHistory, LogService)

	if success and type(logHistory) == "table" then
		for _, v6 in logHistory do
			if not (type(v6) == "table" and type(v6.message) == "string" and typeof(v6.messageType) == "EnumItem") then
				continue
			end

			AddServerEntry(v6.message, v6.messageType, tonumber(v6.timestamp))
		end
	end

	LogService.MessageOut:Connect(function(p, p2)
		local addServerEntry = AddServerEntry(p, p2)

		if serverEvent then
			pcall(serverEvent.FireAll, serverEvent, addServerEntry)
		end
	end)
end

return {
	DisplayName = "Server Logs",
	Permission = "cui.dev.serverLogs",
	Order = 40,
	Setup = function(object2, p)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v6 = ""
		local v7 = "All"
		local v8 = true
		local v9 = nil
		local v10 = nil
		local v11 = false
		local thread = nil
		local v12 = false
		local flag = false
		local UI = object2:AddList(function(object3)
			object3:SetSizeY(360)
		end):GetUI()
		UI.Content.Visible = false
		UI.ScrollBG.Visible = false

		local function CanRender()
			return object2.ContentFrame.Visible and p.Window:IsVisible() and not p.Window:IsMinimized()
		end

		local function fn()
			if not v9 then
				return
			end

			if v10 then
				v10()
			end

			for _, child in v9:GetChildren() do
				if child.Name == "ServerLogRows" then
					child:Destroy()
				end
			end

			v10 = Vide.mount(function()
				return (CreateLogRows(v2, v6, v7, v9.ZIndex, math.max(v9.AbsoluteSize.X, 300)))
			end, v9)

			if v8 then
				task.defer(function()
					if v9 and v9.Parent then
						v9.CanvasPosition = Vector2.new(0, (math.max(v9.AbsoluteCanvasSize.Y, 0)))
					end
				end)
			end
		end

		local function fn2()
			if flag or v11 or not object2.ContentFrame.Visible or not p.Window:IsVisible() or p.Window:IsMinimized() then
				return
			end

			v11 = true
			thread = task.delay(0.08, function()
				thread = nil
				v11 = false

				if flag or not object2.ContentFrame.Visible or not p.Window:IsVisible() or p.Window:IsMinimized() then
					return
				end

				fn()
			end)
		end

		local function Refresh()
			if flag or v12 or not clientEvent then
				return
			end

			v12 = true
			clientEvent:Fire({}):andThen(function(p2)
				v12 = false

				if flag then
					return
				end

				if p2 then
					MergeClientEntries(p2.Entries)
				end
			end):catch(function(p2)
				v12 = false

				if flag then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`Failed to load server logs: {tostring(p2)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		local v13 = Vide.mount(function()
			return (CreateConsole({
				BaseZIndex = UI.ZIndex,
				OnRowsMounted = function(p2)
					v9 = p2
					fn2()
				end,
				OnSearchChanged = function(p2)
					v6 = p2
					fn2()
				end,
				OnFilterChanged = function(p2)
					v7 = p2
					fn2()
				end,
				OnToggleAutoScroll = function(p2)
					v8 = not v8
					p2.Text = v8 and "Follow: ON" or "Follow: OFF"
					local textColor

					if v8 then
						textColor = Color3.fromRGB(140, 230, 140)
					else
						textColor = Color3.fromRGB(200, 200, 200)
					end

					p2.TextColor3 = textColor

					if v8 then
						fn2()
					end
				end,
				OnRefresh = Refresh,
				OnClear = function()
					table.clear(v2)
					table.clear(object)
					v3:Fire()
				end
			}))
		end, UI)
		local connection = v3:Connect(fn2)
		local visibleChangedConnection = object2.ContentFrame:GetPropertyChangedSignal("Visible"):Connect(fn2)
		local UI2 = p.Window.UI
		local visibleChangedConnection2 = UI2:GetPropertyChangedSignal("Visible"):Connect(fn2)
		local visibleChangedConnection3 = UI2.Content:GetPropertyChangedSignal("Visible"):Connect(fn2)
		UI.Destroying:Connect(function()
			flag = true

			if thread then
				task.cancel(thread)
				thread = nil
			end

			v11 = false
			connection:Disconnect()
			visibleChangedConnection:Disconnect()
			visibleChangedConnection2:Disconnect()
			visibleChangedConnection3:Disconnect()

			if v10 then
				v10()
			end

			if v13 then
				v13()
			end

			v10 = nil
			v13 = nil
			v9 = nil
		end)
		Refresh()
	end
}