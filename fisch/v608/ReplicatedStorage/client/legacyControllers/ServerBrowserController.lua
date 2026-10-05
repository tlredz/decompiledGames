local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local ServerBrowserData = require(ReplicatedStorage.shared.data.ServerBrowserData)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local safezone = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone")
local serverBrowser = safezone:WaitForChild("topbar"):WaitForChild("ServerBrowser")
local serverbrowser = safezone:WaitForChild("serverbrowser")
local search = serverbrowser:WaitForChild("Search")

if not search:IsA("TextBox") then
	search = search:FindFirstChildWhichIsA("TextBox")
end

local servers = serverbrowser:WaitForChild("servers")
local scroll = servers:WaitForChild("scroll")
local template = scroll:WaitForChild("template")
local close = serverbrowser:WaitForChild("Close")
local joinrandomserver = servers:WaitForChild("joinrandomserver")
local order = servers:WaitForChild("order")
local regionsort = servers:WaitForChild("regionsort")
local refresh = servers:WaitForChild("refresh")
local remoteFunction = Net:RemoteFunction("ServerBrowser/GetServerList")
local remoteFunction2 = Net:RemoteFunction("ServerBrowser/TeleportToServer")
Net:RemoteFunction("ServerBrowser/TeleportToRandom")
Net:RemoteFunction("ServerBrowser/GetCurrentServer")
local remoteEvent = Net:RemoteEvent("ServerBrowser/ServerListUpdated")
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(p: string)
	anno_localthought:Fire(p)
end

local v = {
	Virginia = Color3.fromRGB(72, 133, 237),
	Washington = Color3.fromRGB(72, 133, 237),
	California = Color3.fromRGB(52, 168, 235),
	Oregon = Color3.fromRGB(52, 168, 235),
	England = Color3.fromRGB(244, 194, 13),
	Hesse = Color3.fromRGB(244, 194, 13),
	["North Holland"] = Color3.fromRGB(244, 194, 13),
	["São Paulo"] = Color3.fromRGB(60, 186, 84),
	["Sao Paulo"] = Color3.fromRGB(60, 186, 84),
	Tokyo = Color3.fromRGB(219, 68, 55),
	Singapore = Color3.fromRGB(219, 68, 55),
	Maharashtra = Color3.fromRGB(219, 68, 55),
	["New South Wales"] = Color3.fromRGB(123, 80, 196),
	["N/A"] = Color3.fromRGB(149, 165, 166),
	Unknown = Color3.fromRGB(149, 165, 166)
}
local v2 = {}
v2[1] = "All"
local v3 = 1
local v4 = true
local v5 = Trove.new()
local v6 = {}
local v7 = {}
local v8 = nil
local flag = false
local count = 0
local ServerBrowserController = {}
template.Visible = false
serverbrowser.Visible = false

-- equivalent calls inferred from this helper; original call sites unknown
local function formatUptime(startTime: number)
	local v9 = os.time() - startTime
	local v10 = v9 < 0 and 0 or v9
	local v11 = math.floor(v10 / 3600)
	local v12 = math.floor(v10 % 3600 / 60)

	if v11 > 0 then
		return (`{v11}h {v12}m`)
	end

	return (`{v12}m`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearEntries()
	for _, v9 in v6 do
		v9:Destroy()
	end

	table.clear(v6)
end

local function updateEntryUI(instance, data)
	local regionicon = instance:FindFirstChild("regionicon")
	local playercount = instance:FindFirstChild("playercount")
	local serverregion = instance:FindFirstChild("serverregion")
	local region = data.region or "Unknown"
	local playerCount = data.playerCount or 0
	local maxPlayers = data.maxPlayers or 0
	local startTime = data.startTime or 0
	local v9 = formatUptime(startTime) -- equivalent call inferred; original call site unknown

	if regionicon then
		regionicon.BackgroundColor3 = v[region] or v.Unknown
	end

	if playercount then
		playercount.Text = `{playerCount}/{maxPlayers} players`
	end

	if serverregion then
		serverregion.Text = `{region} · {v9}`
	end

	instance:SetAttribute("Region", region)
	instance:SetAttribute("PlayerCount", playerCount)
end

local function createServerEntry(p)
	local clone = template:Clone()
	clone.Visible = true
	clone.Name = p.jobId
	local servername = clone:FindFirstChild("servername")
	local join = clone:FindFirstChild("join")
	local serverName = ServerBrowserData.generateServerName(p.jobId or "")
	servername.Text = serverName
	clone:SetAttribute("ServerName", serverName)
	local v9 = p.jobId == game.JobId
	clone:SetAttribute("IsCurrentServer", v9)

	if v9 then
		join.Text = "Current"
		join.AutoButtonColor = false
		join.border.Color = Color3.fromRGB(139, 139, 139)
		join.TextColor3 = Color3.fromRGB(139, 139, 139)
		join.BackgroundColor3 = Color3.fromRGB(49, 49, 49)
	end

	local v10 = false
	v5:Connect(join.Activated, function()
		if v9 or v10 then
			return
		end

		v10 = true
		join.Text = "Joining..."
		join.AutoButtonColor = false
		local v11, v12 = remoteFunction2:InvokeServer(p.placeId, p.jobId)

		if not v11 then
			notify(v12 or "Failed to join server") -- equivalent call inferred; original call site unknown
		end

		join.Text = "Join"
		join.AutoButtonColor = true
		v10 = false
	end)
	updateEntryUI(clone, p)
	clone.Parent = scroll
	return clone
end

local function buildRegionFilterOptions()
	local v9 = {}

	for _, v10 in v7 do
		for _, v11 in v10 do
			v9[v11.region or "Unknown"] = true
		end
	end

	v2 = { "All" }

	for k in v9 do
		table.insert(v2, k)
	end

	if v3 > #v2 then
		v3 = 1
	end
end

local function flattenServers(p: string?)
	local result = {}

	if p then
		local v9 = v7[p]

		if v9 then
			for _, v10 in v9 do
				result[v10.jobId] = v10
			end

			return result
		end
	else
		for _, v9 in v7 do
			for _, v10 in v9 do
				result[v10.jobId] = v10
			end
		end
	end

	return result
end

local function syncEntries(p: string?)
	if v7 and next(v7) ~= nil then
		local v9 = flattenServers(p)

		for k, v10 in v6 do
			if v9[k] then
				continue
			end

			v10:Destroy()
			v6[k] = nil
		end

		for k, v10 in v9 do
			local v11 = v6[k]

			if v11 then
				updateEntryUI(v11, v10)
			else
				v6[k] = createServerEntry(v10)
			end
		end
	else
		clearEntries() -- equivalent call inferred; original call site unknown
	end
end

local function applyFilterAndSort()
	local v9 = v2[v3] or "All"
	local text = string.lower(search.Text)
	local v10 = {}

	for _, v11 in v6 do
		local region = v11:GetAttribute("Region") or "Unknown"
		local v12 = v9 == "All" or region == v9
		local v13

		if text == "" then
			v13 = true
		else
			local serverName = string.lower(v11:GetAttribute("ServerName") or "")
			local v14 = string.lower(region)
			v13 = string.find(serverName, text, 1, true) ~= nil or string.find(v14, text, 1, true) ~= nil
		end

		if v12 and v13 then
			v11.Visible = true
			table.insert(v10, v11)
		else
			v11.Visible = false
		end
	end

	table.sort(v10, function(a, b)
		local playerCount = a:GetAttribute("PlayerCount") or 0
		local playerCount2 = b:GetAttribute("PlayerCount") or 0

		if v4 then
			return playerCount < playerCount2
		end

		return playerCount2 < playerCount
	end)

	for k, v11 in v10 do
		if v11:GetAttribute("IsCurrentServer") then
			v11.LayoutOrder = -1
		else
			v11.LayoutOrder = k
		end
	end
end

local function fetchServerList()
	count += 1
	local v9 = count
	local success, result = pcall(function()
		return remoteFunction:InvokeServer()
	end)

	if v9 ~= count then
		return
	end

	if not (success and result) then
		warn((`[ServerBrowser]: failed to fetch server list: {result}`))
		return
	end

	v7 = result
	buildRegionFilterOptions()
	syncEntries(v8)
	applyFilterAndSort()
end

local function getAllServersFlat()
	local result = {}

	for _, v9 in v7 do
		for _, v10 in v9 do
			table.insert(result, v10)
		end
	end

	return result
end

local function findRandomServer()
	local allServersFlat = getAllServersFlat()
	local v9 = {}

	for _, v10 in allServersFlat do
		if v10.jobId ~= game.JobId and v10.playerCount < (v10.maxPlayers or 0) then
			table.insert(v9, v10)
		end
	end

	if #v9 == 0 then
		return nil
	end

	return v9[math.random(1, #v9)]
end

function ServerBrowserController:Open(p: string?)
	if flag then
		return
	end

	flag = true
	v8 = p
	serverbrowser.Visible = true

	if v7 and next(v7) then
		syncEntries(v8)
		applyFilterAndSort()
	end

	task.spawn(fetchServerList)
end

function ServerBrowserController:Close()
	if not flag then
		return
	end

	flag = false
	count += 1
	serverbrowser.Visible = false
	clearEntries() -- equivalent call inferred; original call site unknown
end

function ServerBrowserController:Toggle(p: string?)
	if flag then
		self:Close()
	else
		self:Open(p)
	end
end

function ServerBrowserController:Refresh()
	task.spawn(fetchServerList)
end

function ServerBrowserController.IsOpen(_)
	return flag
end

function ServerBrowserController:Start()
	if not FischUtils.IsTradePlaza() then
		serverBrowser.Visible = false
		return
	end

	v5:Connect(serverBrowser.Activated, function()
		self:Toggle()
	end)
	v5:Connect(close.Activated, function()
		self:Close()
	end)
	v5:Connect(refresh.Activated, function()
		self:Refresh()
	end)
	v5:Connect(search:GetPropertyChangedSignal("Text"), function()
		applyFilterAndSort()
	end)
	order.Text = v4 and "Player Count ▲" or "Player Count ▼"
	regionsort.Text = `Region: {v2[v3]}`
	v5:Connect(order.Activated, function()
		v4 = not v4
		order.Text = v4 and "Player Count ▲" or "Player Count ▼"
		applyFilterAndSort()
	end)
	v5:Connect(regionsort.Activated, function()
		v3 = v3 % #v2 + 1
		regionsort.Text = `Region: {v2[v3]}`
		applyFilterAndSort()
	end)
	v5:Connect(joinrandomserver.Activated, function()
		local randomServer = findRandomServer()

		if not randomServer then
			notify("No servers available.") -- equivalent call inferred; original call site unknown
			return
		end

		joinrandomserver.Text = "Joining..."
		joinrandomserver.AutoButtonColor = false
		local v9, v10 = remoteFunction2:InvokeServer(randomServer.placeId, randomServer.jobId)

		if not v9 then
			notify(v10 or "Failed to join server.") -- equivalent call inferred; original call site unknown
		end

		joinrandomserver.Text = "Join Random Server"
		joinrandomserver.AutoButtonColor = true
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		v7 = p
		buildRegionFilterOptions()
		regionsort.Text = `Region: {v2[v3]}`

		if not flag then
			return
		end

		syncEntries(v8)
		applyFilterAndSort()
	end)
end

return ServerBrowserController