local HudNavigation = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("HudNavigation"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local serverBrowser = playerGui:WaitForChild("ServerBrowser")
local serverBrowserShade = playerGui:WaitForChild("ServerBrowserShade")
local panel = serverBrowser.Panel
local ServerBrowserView = require(game.ReplicatedStorage.ChickenOrHero.Presentation:WaitForChild("ServerBrowserView"))
ServerBrowserView.apply(serverBrowser)
local absoluteSizeChangedConnection = serverBrowser:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	ServerBrowserView.layout(serverBrowser)
end)
ServerBrowserView.layout(serverBrowser)
serverBrowser.Open.Text = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled and "SERVERS · B" or "SERVERS"
local serverBrowserEvent = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("ServerBrowserEvent")
local v = false
local v2 = false
local v3 = false
local now = -1e999
local count = 0
local clones = {}
local connections = {}
local flag = true
local selectedObject = nil
local v4 = false
local code = "ALL"
local v5 = 1
local v6 = 1
local v7 = {}
local v8 = nil
local v9 = {
	rows = 0
}
v9.rows = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ping()
	local success, result = pcall(function()
		return localPlayer:GetNetworkPing() * 1000
	end)
	return success and result == result and result > 0 and math.floor(result + 0.5) or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePing()
	if not (flag and v and serverBrowser.Enabled and panel.Visible) then
		return
	end

	local v10 = ping() -- equivalent call inferred; original call site unknown
	panel.Connection.Text = not v10 and "YOUR CONNECTION  ·  measuring…" or "YOUR CONNECTION  ·  " .. v10 .. " ms" or "YOUR CONNECTION  ·  measuring…"

	if v8 and v8.Parent then
		v8.Ping.Text = v10 and v10 .. " ms · you" or "Measuring…"
	end
end

local function clearRows()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)

	for _, v10 in clones do
		v10:Destroy()
	end

	table.clear(clones)
	v8 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function status(value)
	panel.Status.Text = value or "Switch servers between matches."
end

local render

render = function()
	local selectedObject2 = GuiService.SelectedObject

	if selectedObject2 and selectedObject2:IsDescendantOf(panel.List) then
		GuiService.SelectedObject = panel.Close
	end

	clearRows()
	local v10 = {}

	for _, v11 in v9.rows or {} do
		local v12 = not v11.location and "UNKNOWN" or v11.location.countryCode or "UNKNOWN"

		if not ((v11.current or v11.updatedAt and os.time() - v11.updatedAt <= 60) and (code == "ALL" or code == v12)) then
			continue
		end

		table.insert(v10, v11)
	end

	table.sort(v10, function(a, b)
		if a.current ~= b.current then
			return a.current == true
		end

		if a.full ~= b.full then
			return not a.full
		end

		if v4 and a.averagePing ~= b.averagePing then
			return (a.averagePing or 1e999) < (b.averagePing or 1e999)
		end

		if a.players == b.players then
			return a.id < b.id
		end

		return a.players > b.players
	end)
	panel.Empty.Visible = #v10 == 0
	panel.Empty.Text = code == "ALL" and "No servers to show yet.\nTry refreshing in a moment." or "No available servers in this country.\nChoose ALL or refresh."
	panel.Count.Text = string.format("%d %s", #v10, #v10 == 1 and "SERVER" or "SERVERS")
	v6 = math.max(1, (math.ceil(#v10 / 50)))
	v5 = math.clamp(v5, 1, v6)
	panel.PageLabel.Text = ("PAGE %d / %d"):format(v5, v6)

	for _, v11 in {
		{ panel.PreviousPage, v5 > 1 },
		{ panel.NextPage, v5 < v6 }
	} do
		v11[1].Active = v11[2]
		v11[1].Selectable = v11[2]
		v11[1].AutoButtonColor = v11[2]
		v11[1].TextTransparency = v11[2] and 0 or 0.55
	end

	for i = (v5 - 1) * 50 + 1, math.min(v5 * 50, #v10) do
		local v11 = v10[i]
		local clone = serverBrowser.Templates.ServerRow:Clone()
		clone.Name = "Server_" .. i
		clone.LayoutOrder = i
		clone.Visible = true
		local location = v11.location
		clone.Title.Text = (v11.current and "YOUR SERVER · " or "") .. (not location and "Region unknown" or location.country or "Region unknown")
		clone.Details.Text = ("%d / %d players  ·  %s"):format(v11.players, v11.capacity, v11.phase)
		local subdivision = location and location.subdivision
		local region = clone.Region
		local region2

		if location then
			if not subdivision or subdivision == "" or not subdivision then
				subdivision = location.country
			end

			region2 = subdivision .. " · approx."

			if not region2 then
				region2 = v11.region or "Location unavailable"
			end
		else
			region2 = v11.region or "Location unavailable"
		end

		region.Text = region2
		clone.Ping.Text = not v11.averagePing and "Ping unavailable" or v11.averagePing .. " ms avg" or "Ping unavailable"

		if v11.current then
			v8 = clone
		end

		clone.Join.Text = v11.current and "HERE" or v11.full and "FULL" or "JOIN"
		clone.Join.Active = not (v2 or v11.current or v11.full or v9.studio)
		clone.Join.Selectable = clone.Join.Active
		clone.Join.AutoButtonColor = clone.Join.Active
		clone.Join.BackgroundTransparency = clone.Join.Active and 0.08 or 0.7
		clone.Join.TextTransparency = clone.Join.Active and 0 or 0.45
		ServerBrowserView.styleRow(clone, v11)
		table.insert(connections, clone.Join.Activated:Connect(function()
			if not clone.Join.Active or v2 then
				return
			end

			v2 = true
			panel.Status.Text = "Preparing to switch servers…"
			serverBrowserEvent:FireServer("Join", v11.id)
			render()
			task.delay(55, function()
				if flag and v2 and localPlayer:GetAttribute("ServerBrowserTransferring") ~= true then
					v2 = false
					panel.Status.Text = "No transfer started. Please try again."
					render()
				end
			end)
		end))
		clone.Parent = panel.List
		table.insert(clones, clone)
	end

	if flag and v and serverBrowser.Enabled then
		if not panel.Visible then
			return
		end

		local v11 = ping() -- equivalent call inferred; original call site unknown
		panel.Connection.Text = not v11 and "YOUR CONNECTION  ·  measuring…" or "YOUR CONNECTION  ·  " .. v11 .. " ms" or "YOUR CONNECTION  ·  measuring…"

		if v8 and v8.Parent then
			v8.Ping.Text = v11 and v11 .. " ms · you" or "Measuring…"
		end
	end
end

local function renderCountries()
	local selectedObject2 = GuiService.SelectedObject
	local name = selectedObject2 and selectedObject2:IsDescendantOf(panel.Countries) and selectedObject2.Name

	for _, v10 in v7 do
		v10:Destroy()
	end

	table.clear(v7)
	local countries = {}

	for _, v10 in v9.rows or {} do
		local location = v10.location
		countries[not location and "UNKNOWN" or location.countryCode or "UNKNOWN"] = location and location.country or "Unknown region"
	end

	local v10 = {
		{
			code = "ALL",
			name = "ALL COUNTRIES"
		}
	}

	for k, name2 in countries do
		table.insert(v10, {
			code = k,
			name = name2
		})
	end

	table.sort(v10, function(a, b)
		if a.code == "ALL" then
			return b.code ~= "ALL"
		end

		return b.code ~= "ALL" and a.name < b.name
	end)

	if code ~= "ALL" and not countries[code] then
		code = "ALL"
	end

	for k, v11 in v10 do
		local textButton = Instance.new("TextButton")
		textButton.Name = "Country_" .. v11.code
		textButton.Text = v11.name
		textButton.LayoutOrder = k
		textButton.BorderSizePixel = 0
		textButton.Parent = panel.Countries
		ServerBrowserView.styleCountry(textButton, code == v11.code)

		if name == textButton.Name then
			GuiService.SelectedObject = textButton
		end

		local v12 = v11
		textButton.Activated:Connect(function()
			code = v12.code
			v5 = 1

			for k2, v14 in v7 do
				ServerBrowserView.styleCountry(v14, v14 == textButton)
			end

			panel.List.CanvasPosition = Vector2.zero
			render()
		end)
		table.insert(v7, textButton)
	end

	ServerBrowserView.layout(serverBrowser)
end

local function request()
	if v3 or os.clock() - now < 2 then
		return
	end

	v3 = true
	now = os.clock()
	count += 1
	local v10 = count
	panel.Refresh.Text = "…"

	if #clones == 0 then
		panel.Empty.Text = "Looking for servers…"
	end

	serverBrowserEvent:FireServer("List")
	task.delay(10, function()
		if flag and v3 and count == v10 then
			v3 = false
			panel.Refresh.Text = "REFRESH"

			if not v2 then
				panel.Status.Text = "The server list is taking longer than usual. Try refreshing."
			end
		end
	end)
end

local function permitted()
	return workspace:GetAttribute("ServerBrowserAvailable") == true and localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("InMatch") ~= true and (localPlayer:GetAttribute("GameRole") or "Lobby") == "Lobby" and localPlayer:GetAttribute("TutorialSession") ~= true and localPlayer:GetAttribute("TutorialRouting") ~= true and localPlayer:GetAttribute("ScreenPresentationActive") ~= true and localPlayer:GetAttribute("AdminRefreshActive") ~= true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setOpen(serverBrowserOpen)
	if serverBrowserOpen and not permitted() then
		return
	end

	if serverBrowserOpen then
		HudNavigation.opening("Servers")
	end

	if v == serverBrowserOpen then
		return
	end

	v = serverBrowserOpen
	localPlayer:SetAttribute("ServerBrowserOpen", serverBrowserOpen)
	panel.Visible = serverBrowserOpen
	serverBrowserShade.Enabled = serverBrowserOpen

	if serverBrowserOpen then
		selectedObject = GuiService.SelectedObject
		serverBrowserShade.Shade.BackgroundTransparency = 1
		TweenService:Create(serverBrowserShade.Shade, TweenInfo.new(0.15), {
			BackgroundTransparency = 0.4
		}):Play()
		ServerBrowserView.layout(serverBrowser)
		updatePing() -- equivalent call inferred; original call site unknown
		request()

		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = panel.Close
		end
	else
		local selectedObject2 = GuiService.SelectedObject

		if selectedObject2 and selectedObject2:IsDescendantOf(serverBrowser) then
			GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
		end
	end
end

local function availability()
	serverBrowser.Open.Visible = false
	HudNavigation.setAvailable("Servers", (permitted()))

	if not permitted() then
		setOpen(false) -- equivalent call inferred; original call site unknown
	end
end

HudNavigation.register("Servers", function()
	setOpen(not v)
end)
HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "Servers" then
		setOpen(false) -- equivalent call inferred; original call site unknown
	end
end)
serverBrowser.Open.Activated:Connect(function()
	setOpen(not v)
end)
panel.Close.Activated:Connect(function()
	if v == false then
		return
	end

	v = false
	localPlayer:SetAttribute("ServerBrowserOpen", false)
	panel.Visible = false
	serverBrowserShade.Enabled = false
	local selectedObject2 = GuiService.SelectedObject

	if selectedObject2 and selectedObject2:IsDescendantOf(serverBrowser) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end)
panel.Refresh.Activated:Connect(request)

local function changePage(p)
	local v10 = math.clamp(v5 + p, 1, v6)

	if v10 == v5 then
		return
	end

	v5 = v10
	panel.List.CanvasPosition = Vector2.zero
	render()
end

panel.PreviousPage.Activated:Connect(function()
	local v10 = math.clamp(v5 + -1, 1, v6)

	if v10 == v5 then
		return
	end

	v5 = v10
	panel.List.CanvasPosition = Vector2.zero
	render()
end)
panel.NextPage.Activated:Connect(function()
	local v10 = math.clamp(v5 + 1, 1, v6)

	if v10 == v5 then
		return
	end

	v5 = v10
	panel.List.CanvasPosition = Vector2.zero
	render()
end)
panel.Sort.Activated:Connect(function()
	v5 = 1
	panel.List.CanvasPosition = Vector2.zero
	v4 = not v4
	panel.Sort.Text = v4 and "SORT: AVG PING" or "SORT: PLAYERS"
	render()
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if UserInputService:GetFocusedTextBox() then
		return
	end

	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		setOpen(not v)
	elseif v and (input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Escape) then
		setOpen(false) -- equivalent call inferred; original call site unknown
	end
end)
serverBrowserEvent.OnClientEvent:Connect(function(p, data)
	if type(data) ~= "table" then
		return
	end

	if p == "List" then
		v3 = false
		count += 1
		panel.Refresh.Text = "REFRESH"
		v9 = data
		renderCountries()
		render()

		if not v2 then
			local notice = data.notice or data.joinReason
			status(notice) -- equivalent call inferred; original call site unknown
		end
	elseif p == "Joining" then
		v2 = true
		status(data.message) -- equivalent call inferred; original call site unknown
		render()
	elseif p == "JoinResult" then
		v2 = false
		status(data.message) -- equivalent call inferred; original call site unknown
		render()
	elseif p == "Error" then
		v3 = false
		panel.Refresh.Text = "REFRESH"

		if not v2 then
			status(data.message) -- equivalent call inferred; original call site unknown
		end
	end
end)

for _, v10 in {
	"ClientReady",
	"InMatch",
	"GameRole",
	"TutorialSession",
	"TutorialRouting",
	"ScreenPresentationActive",
	"AdminRefreshActive"
} do
	localPlayer:GetAttributeChangedSignal(v10):Connect(availability)
end

workspace:GetAttributeChangedSignal("ServerBrowserAvailable"):Connect(availability)
panel.Visible = false
serverBrowserShade.Enabled = false
localPlayer:SetAttribute("ServerBrowserOpen", false)
serverBrowser.Open.Visible = false
HudNavigation.setAvailable("Servers", (permitted()))

if not permitted() and v ~= false then
	v = false
	localPlayer:SetAttribute("ServerBrowserOpen", false)
	panel.Visible = false
	serverBrowserShade.Enabled = false
	local selectedObject2 = GuiService.SelectedObject

	if selectedObject2 and selectedObject2:IsDescendantOf(serverBrowser) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

task.spawn(function()
	local count2 = 0

	while flag do
		task.wait(1)
		count2 += 1

		if not v then
			continue
		end

		updatePing() -- equivalent call inferred; original call site unknown

		if not (count2 >= 16) then
			continue
		end

		request()
		count2 = 0
	end
end)
script.Destroying:Connect(function()
	absoluteSizeChangedConnection:Disconnect()
	flag = false
	localPlayer:SetAttribute("ServerBrowserOpen", false)
	serverBrowserShade.Enabled = false
	clearRows()
end)