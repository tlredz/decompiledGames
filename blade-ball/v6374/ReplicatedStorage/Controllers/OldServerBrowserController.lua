local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalizationService = game:GetService("LocalizationService")
local v = require3(ReplicatedStorage2.Shared.ServerBrowserData)
local v2 = require3(ReplicatedStorage2.Shared.Statable)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.Controllers.NotificationController)
local serversToShow = v.ServersToShow
local v7 = false
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local remoteFunction = v4:RemoteFunction("RefreshServerBrowser")
local remoteFunction2 = v4:RemoteFunction("ServerBrowserTeleport")
local remoteEvent = v4:RemoteEvent("ServerBrowserForceRefresh")
local clones = table.create(serversToShow)
local replicationBuffers = {}

local function setTheme(instance, flag: boolean)
	instance.Image = flag and "rbxassetid://16199707045" or "rbxassetid://15581213596"
	instance.HoverImage = flag and "rbxassetid://16200048922" or "rbxassetid://15581214462"

	for _, label in instance:GetChildren() do
		if not (label:IsA("TextLabel") and label:FindFirstChild("UIStroke")) then
			continue
		end

		local uIStroke = label.UIStroke
		local color

		if flag then
			color = Color3.fromRGB(149, 67, 0)
		else
			color = Color3.fromRGB(21, 56, 169)
		end

		uIStroke.Color = color
	end
end

local OldServerBrowserController = {
	Filter = v2.State(),
	UIServerBrowser = nil,
	_playerCountry = nil
}
v3.new()

function OldServerBrowserController:RefreshList()
	if not self.UIServerBrowser then
		return
	end

	local list = self.UIServerBrowser.MainFrame.List

	if not v7 then
		v7 = true

		for i = 1, serversToShow do
			local clone = list.UIListLayout.Template:Clone()
			clone.Visible = false
			clone.Parent = list
			local v8 = i
			clone.Join.Activated:Connect(function()
				local v9 = replicationBuffers[v8]

				if not v9 then
					return
				end

				local v10, v11 = remoteFunction2:InvokeServer(v9.jobId, v9.placeId)

				if v10 then
					v5:Close("ServerBrowserOld")
				else
					v6:SendNotification(v11)
				end
			end)
			clones[i] = clone
		end
	end

	local v8 = remoteFunction:InvokeServer(self.Filter:Get())
	table.clear(replicationBuffers)

	for k, v9 in clones do
		local v10 = k
		local v11 = v9
		task.spawn(function()
			local v12 = v8[v10]

			if not v12 then
				v11.Visible = false
				return
			end

			local replicationBuffer = v.readReplicationBuffer(v12)

			if not replicationBuffer then
				v11.Visible = false
				return
			end

			replicationBuffers[v10] = replicationBuffer
			v11.Name = replicationBuffer.jobId
			local maxPlayers = replicationBuffer.maxPlayers

			if replicationBuffer.players < maxPlayers then
				v11.Label2.Text = `<stroke color="rgb(32, 78, 163)" joins="round" thickness="2">Players: {replicationBuffer.players}/{maxPlayers} | Region: {replicationBuffer.country}, {replicationBuffer.region}</stroke>`
			else
				v11.Label2.Text = `<stroke color="rgb(32, 78, 163)" joins="round" thickness="2">Players: <font color="rgb(255, 77, 77)">{replicationBuffer.players}/{maxPlayers}</font> | Region: {replicationBuffer.country}, {replicationBuffer.region}</stroke>`
			end

			local v13

			if RunService:IsStudio() then
				v13 = ReplicatedStorage2:GetAttribute("__FAKE_JOB_ID")
			else
				v13 = game.JobId
			end

			if v13 == replicationBuffer.jobId and game.PlaceId == replicationBuffer.placeId then
				v11.Join.Visible = false
				v11.YourServer.Visible = true
			else
				v11.Join.Visible = true
				v11.YourServer.Visible = false
			end

			v11.LayoutOrder = replicationBuffer.country == self._playerCountry and -1 or 1
			v11.Label1.Text = `<stroke color="rgb(17, 49, 110)" joins="round" thickness="2">Server name: {v.getDisplayName(replicationBuffer.country)}</stroke>`
			v11.Visible = true
		end)
	end
end

function OldServerBrowserController:LoadList(p: string?)
	self.Filter:Set(p)
	self:RefreshList()
end

function OldServerBrowserController:Start()
	local serverBrowserOld = playerGui:WaitForChild("ServerBrowserOld")
	self.UIServerBrowser = serverBrowserOld
	local mainFrame = serverBrowserOld.MainFrame
	local topButtons = mainFrame.TopButtons
	local scrollingFrame = topButtons.List.ScrollingFrame
	local success, countryRegionForPlayerAsync = pcall(
		LocalizationService.GetCountryRegionForPlayerAsync,
		LocalizationService,
		localPlayer
	)

	if success then
		self._playerCountry = countryRegionForPlayerAsync
	end

	mainFrame.Close.Activated:Connect(function()
		v5:Close("ServerBrowserOld")
	end)
	v5:OnGuiOpen("ServerBrowserOld", function()
		self:RefreshList()
	end)
	remoteEvent.OnClientEvent:Connect(function()
		if not v5:IsOpen("ServerBrowserOld") then
			return
		end

		self:RefreshList()
	end)
	local clones2 = {}

	for k, continent in v.Continents do
		local clone = scrollingFrame.UIListLayout.Dropdown:Clone()
		clone.Name = k
		clone.Label.Text = continent.DisplayName

		if continent.LayoutOrder then
			clone.LayoutOrder = continent.LayoutOrder
		end

		clone.Parent = scrollingFrame
		table.insert(clones2, clone)
		setTheme(clone, false)

		for _, country in continent.Countries do
			local region = v.Regions[country]

			if not region then
				continue
			end

			local clone2 = clone.List.UIListLayout.Item:Clone()
			clone2.Name = region
			clone2.Label.Text = region
			clone2.Parent = clone.List
			local v8 = country
			clone2.Activated:Connect(function()
				self:LoadList(v8)
			end)
			local v10 = country
			self.Filter:Connect(function(p)
				setTheme(clone2, v10 == p)
			end)
		end

		clone.Activated:Connect(function()
			clone.List.Visible = not clone.List.Visible

			for k2, v9 in clones2 do
				if v9 ~= clone then
					v9.List.Visible = false
				end
			end
		end)
	end

	setTheme(scrollingFrame.All, true)
	scrollingFrame.All.Activated:Connect(function()
		self:LoadList()
	end)
	self.Filter:Connect(function(p)
		setTheme(scrollingFrame.All, p == nil)
	end)
	topButtons.Refresh.Activated:Connect(function()
		self:RefreshList()
	end)
end

return OldServerBrowserController