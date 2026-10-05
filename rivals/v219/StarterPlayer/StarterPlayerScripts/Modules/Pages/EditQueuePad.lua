local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SettingsInfo = require(ReplicatedStorage.Modules.SettingsInfo)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local settings = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Settings")
local v = {
	{
		"QueueName",
		"Dropdown",
		"Gamemode",
		"rbxassetid://77802568386086",
		"Changes the gameplay, map pool, & more"
	},
	{
		"MapPool",
		"Dropdown",
		"Map Pool",
		"rbxassetid://83261934303870",
		"Change how the map pool is determined"
	},
	{
		"MapPoolGamemode",
		"Dropdown",
		"By Gamemode",
		"rbxassetid://14641612286",
		"You probably don't need to edit this"
	},
	{
		"MapPoolSpecific",
		"Dropdown",
		"Specific Map",
		"rbxassetid://14641612286",
		"Choose the specific map you want"
	},
	{
		"InfinitePlayersPerTeam",
		"Toggle",
		"Infinite Players",
		"rbxassetid://16782323002",
		"The private server owner has to manually start this duel"
	},
	{
		"PlayersPerTeam",
		"Slider",
		"Players Per Team",
		"rbxassetid://105821004981978",
		"Turn on Infinite Players if you have a big party"
	},
	{
		"UnlimitedTime",
		"Toggle",
		"Unlimited Time",
		"rbxassetid://18195730712",
		"The timer won't end while playing this duel"
	},
	{
		"CanSelfQueue",
		"Toggle",
		"Play Solo",
		"rbxassetid://17738769051",
		"Allows you to play this duel by yourself"
	},
	{
		"DisableOOB",
		"Toggle",
		"Out of Bounds",
		"rbxassetid://89987125943326",
		"Go out of bounds in any map"
	}
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.HeaderFrame = self.Container:WaitForChild("Header")
	self.HeaderTitle = self.HeaderFrame:WaitForChild("Title")
	self._client_queue_pad = nil
	self._setting_objects = {}
	self._connections = {}
	self:_Init()
	return self
end

function object:SetQueuePad(client_queue_pad)
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self._client_queue_pad = client_queue_pad

	if not self._client_queue_pad then
		return
	end

	self.HeaderTitle.Text = client_queue_pad:Get("Model").Name

	for _, _setting_object in pairs(self._setting_objects) do
		_setting_object.RegenerateSettingsInfo()
	end

	local function update()
		for k, _setting_object in pairs(self._setting_objects) do
			local defaultValue = self._client_queue_pad:Get(k)

			if defaultValue == nil then
				defaultValue = _setting_object.SettingObject.SettingsInfo.DefaultValue
			end

			_setting_object.SettingObject:SetValue(defaultValue, true, true)
		end
	end

	table.insert(self._connections, self._client_queue_pad.Activity:Connect(update))
	update()
end

function object:Close(...)
	self:SetQueuePad(nil)
	Page.Close(self, ...)
end

function object:_GetSettingsInfoValueParams(p2)
	if p2 == "InfinitePlayersPerTeam" or p2 == "UnlimitedTime" or p2 == "CanSelfQueue" or p2 == "DisableOOB" then
		return false, nil
	end

	if p2 == "PlayersPerTeam" then
		local queueName = self._client_queue_pad and self._client_queue_pad:Get("QueueName")
		local matchmakingQueueInfoFromQueueName = queueName and self._client_queue_pad:GetMatchmakingQueueInfoFromQueueName(queueName)
		return
			matchmakingQueueInfoFromQueueName and matchmakingQueueInfoFromQueueName.PlayersPerTeam or 1,
			1,
			self._client_queue_pad and self._client_queue_pad:GetMaxPlayersPerTeam() or 1,
			1
	elseif p2 == "QueueName" then
		local v2 = not self._client_queue_pad and { "???" } or self._client_queue_pad:GetDuelLogics(Players.LocalPlayer) or { "???" }
		local originalQueueName = self._client_queue_pad and self._client_queue_pad:Get("OriginalQueueName")
		local v3 = originalQueueName and DuelLibrary.MatchmakingQueues[originalQueueName]
		local titleName = v3 and (v3.TitleName or v3.DisplayName)

		if not (titleName and table.find(v2, titleName) and titleName) then
			titleName = v2[1]
		end

		return titleName, v2
	else
		if p2 == "MapPool" then
			return "By Gamemode", { "Unrestricted", "By Gamemode", "Specific Map" }
		end

		if p2 == "MapPoolGamemode" then
			local v2 = not self._client_queue_pad and { "???" } or self._client_queue_pad:GetMapPools(Players.LocalPlayer) or { "???" }
			local queueName = self._client_queue_pad and self._client_queue_pad:Get("QueueName")
			local matchmakingQueueInfoFromQueueName = queueName and self._client_queue_pad:GetMatchmakingQueueInfoFromQueueName(queueName)
			return
				matchmakingQueueInfoFromQueueName and matchmakingQueueInfoFromQueueName.DisplayName and table.find(
					v2,
					matchmakingQueueInfoFromQueueName.DisplayName
				) and matchmakingQueueInfoFromQueueName.DisplayName or v2[1],
				v2
		elseif p2 == "MapPoolSpecific" then
			local sortedMapNames = self._client_queue_pad and self._client_queue_pad:GetSortedMapNames() or { "???" }
			return sortedMapNames[1], sortedMapNames
		else
			assert(false, p2)
		end
	end
end

function object:_Setup()
	for k, list in pairs(v) do
		local v2, v3, v4, v5, v6 = table.unpack(list)
		local module = require(settings[v3])

		local function regenerate_settings_info()
			return SettingsInfo.new("", "", v4, v5, v6, v3, self:_GetSettingsInfoValueParams(v2))
		end

		local settingObject = module.new(regenerate_settings_info())
		settingObject.SettingFrame.LayoutOrder = k
		settingObject.SettingFrame.Parent = self.Container
		local v13 = v2
		settingObject.Replicate:Connect(function()
			if self._client_queue_pad then
				ReplicatedStorage.Remotes.PrivateServer.EditQueuePad:FireServer(
					self._client_queue_pad:Get("ObjectID"),
					v13,
					settingObject.Value
				)
			end
		end)
		local settingObject2 = settingObject
		local regenerate_settings_info2 = regenerate_settings_info
		self._setting_objects[v2] = {
			SettingObject = settingObject,
			RegenerateSettingsInfo = function()
				settingObject2:SetSettingsInfo(regenerate_settings_info2())
			end
		}
	end

	self._setting_objects.MapPool.SettingObject:Scale(0.95)
	self._setting_objects.MapPoolGamemode.SettingObject:Scale(0.9)
	self._setting_objects.MapPoolSpecific.SettingObject:Scale(0.9)
	self._setting_objects.InfinitePlayersPerTeam.SettingObject:Scale(0.95)
	self._setting_objects.PlayersPerTeam.SettingObject:Scale(0.9)

	local function update_dependencies()
		self._setting_objects.PlayersPerTeam.SettingObject.SettingFrame.Visible = not self._setting_objects.InfinitePlayersPerTeam.SettingObject.Value
		self._setting_objects.MapPoolGamemode.SettingObject.SettingFrame.Visible = self._setting_objects.MapPool.SettingObject.Value == "By Gamemode"
		self._setting_objects.MapPoolSpecific.SettingObject.SettingFrame.Visible = self._setting_objects.MapPool.SettingObject.Value == "Specific Map"
	end

	self._setting_objects.InfinitePlayersPerTeam.SettingObject.Changed:Connect(update_dependencies)
	self._setting_objects.MapPool.SettingObject.Changed:Connect(update_dependencies)
	update_dependencies()
	self._setting_objects.QueueName.SettingObject.Changed:Connect(function()
		self._setting_objects.PlayersPerTeam.RegenerateSettingsInfo()
		self._setting_objects.MapPoolGamemode.RegenerateSettingsInfo()
	end)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
		self.List.Active = self.Layout.AbsoluteContentSize.Y >= self.List.AbsoluteSize.Y
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()