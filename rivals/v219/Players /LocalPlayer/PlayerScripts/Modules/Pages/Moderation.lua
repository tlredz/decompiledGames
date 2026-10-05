local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local ModerationLibrary = require(ReplicatedStorage.Modules.ModerationLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local BanLibrary = require(ReplicatedStorage.Modules.BanLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local DropdownSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("DropdownSlot"))
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RankIcon"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local v = {
	{ "permission_moderation_modpanel_access" },
	{
		"permission_moderation_modpanel_viewbanned_full",
		"permission_moderation_modpanel_viewactions_full",
		"permission_moderation_modpanel_viewdata_limited",
		"permission_moderation_modpanel_viewdata_most",
		"permission_moderation_modpanel_viewdata_full"
	},
	{ "permission_moderation_modpanel_teleport_full" },
	{ "permission_moderation_modpanel_warn_template", "permission_moderation_modpanel_warn_custom" },
	{ "permission_moderation_modpanel_evict_limited", "permission_moderation_modpanel_evict_full" },
	{
		"permission_moderation_modpanel_moderate_limited",
		"permission_moderation_modpanel_moderate_most",
		"permission_moderation_modpanel_moderate_full",
		"permission_moderation_modpanel_unban"
	},
	{ "permission_moderation_modpanel_restrict" },
	{ "permission_moderation_modpanel_removelbs_limited", "permission_moderation_modpanel_investigate_full" },
	{ "permission_moderation_modpanel_pardon_limited", "permission_moderation_modpanel_pardon_full" },
	{ "permission_moderation_modpanel_lock" }
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.PageContainer = self.PageFrame:WaitForChild("Container")
	self.CloseButton = self.PageContainer:WaitForChild("Close")
	self.List = self.PageContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.HeaderFrame = self.Container:WaitForChild("Header")
	self.InfoButton = self.HeaderFrame:WaitForChild("Info")
	self.InfoButtonBubble = self.InfoButton:WaitForChild("Bubble")
	self.InfoButtonBubbleTitle = self.InfoButtonBubble:WaitForChild("Title")
	self.InfoButtonBubbleBackground = self.InfoButtonBubble:WaitForChild("Background")
	self.PowersButton = self.HeaderFrame:WaitForChild("Powers")
	self.PowersButtonBubble = self.PowersButton:WaitForChild("Bubble")
	self.PowersButtonBubbleTitle = self.PowersButtonBubble:WaitForChild("Container"):WaitForChild("Title")
	self.LookupFrame = self.Container:WaitForChild("Lookup")
	self.LookupBox = self.LookupFrame:WaitForChild("Box")
	self.LookupButton = self.LookupFrame:WaitForChild("Button")
	self.LookupDropdownButton = self.LookupFrame:WaitForChild("Dropdown")
	self.DropdownReferenceFrame = self.LookupFrame:WaitForChild("DropdownReference")
	self.InvestigateFrame = self.Container:WaitForChild("Investigate")
	self.InvestigateContainer = self.InvestigateFrame:WaitForChild("Container")
	self.InvestigateWinStreaksFrame = self.InvestigateContainer:WaitForChild("Top100WinStreaks")
	self.InvestigateWinStreaksButton = self.InvestigateWinStreaksFrame:WaitForChild("Button")
	self.InvestigateTrueWinStreaksFrame = self.InvestigateContainer:WaitForChild("Top100TrueWinStreaks")
	self.InvestigateTrueWinStreaksButton = self.InvestigateTrueWinStreaksFrame:WaitForChild("Button")
	self.PlayerFrame = self.Container:WaitForChild("Player")
	self.PlayerWaitingFrame = self.PlayerFrame:WaitForChild("Waiting")
	self.PlayerWaitingDotsFrame = self.PlayerWaitingFrame:WaitForChild("Dots")
	self.PlayerLoadedFrame = self.PlayerFrame:WaitForChild("Loaded")
	self.PlayerLoadedActionsFrame = self.PlayerLoadedFrame:WaitForChild("Actions")
	self.PlayerLoadedInformationFrame = self.PlayerLoadedFrame:WaitForChild("Information")
	self.PlayerLoadedInformationPicture = self.PlayerLoadedInformationFrame:WaitForChild("Picture"):WaitForChild("Picture")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._ban_data = nil
	self._result_data = nil
	self._player_data = nil
	self._player_metadata = nil
	self._is_this_dude_banned = false
	self._ban_data_hash = 0
	self._lookup_disabled = false
	self._player_data_debounce = false
	self._last_rank_icon = nil
	self._dropdown_slot = nil
	self._cached_players = {}
	self:_Init()
	return self
end

function object:SetBanData(ban_data, result_data)
	assert(
		not ban_data or typeof(ban_data) == "table",
		"Argument 1 invalid, expected a table or nil, got " .. tostring(ban_data)
	)
	assert(
		not result_data or typeof(result_data) == "table",
		"Argument 2 invalid, expected a table or nil, got " .. tostring(result_data)
	)
	self._ban_data = ban_data
	self._result_data = result_data
	local player_data

	if self._result_data then
		player_data = self._result_data.RawData or nil
	end

	self._player_data = player_data
	local player_metadata

	if self._result_data then
		player_metadata = self._result_data.Metadata or nil
	end

	self._player_metadata = player_metadata
	self._is_this_dude_banned = nil
	self._ban_data_hash += 1
	self.PlayerLoadedFrame.Visible = self._ban_data ~= nil

	if self._last_rank_icon then
		self._last_rank_icon:Destroy()
		self._last_rank_icon = nil
	end

	if not self._ban_data then
		return
	end

	local _ban_data_hash = self._ban_data_hash
	local isBanned = BanLibrary:IsBanned(self._ban_data)
	local v4 = isBanned and math.max(0, isBanned.EndTime - ServerOsTime:GetRounded())
	local v5 = self._player_data and self._player_data.RedFlags and self._player_data.RedFlags[#self._player_data.RedFlags]
	local v6 = self._player_data and self._player_data.SessionID ~= nil
	local level = self._player_data and self._player_data.Level
	local statisticDuelsWinStreak = self._player_data and self._player_data.StatisticDuelsWinStreak
	local lastKnownControls = self._player_data and self._player_data.LastKnownControls
	local v7 = self._player_data and self._player_data.Seasons and self._player_data.Seasons[SeasonLibrary.CurrentSeason.Name] and self._player_data.Seasons[SeasonLibrary.CurrentSeason.Name].RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]
	local currentELO = v7 and v7.CurrentELO
	local highestELOLeaderboardRanking = v7 and SeasonLibrary:GetHighestELOLeaderboardRanking(
		currentELO,
		self._ban_data.UserID
	)
	local rank = v7 and SeasonLibrary:GetRank(currentELO, self._ban_data.UserID, highestELOLeaderboardRanking)
	local v8 = rank and SeasonLibrary.CurrentSeason.RankProfile.Ranks[rank]
	local v9 = self._ban_data.BanLocked and "🔒" or ""
	local restrictedFromCasualLeaderboards = self._ban_data.Restrictions and self._ban_data.Restrictions.RestrictedFromCasualLeaderboards
	local restrictedFromCompetitiveLeaderboards = self._ban_data.Restrictions and self._ban_data.Restrictions.RestrictedFromCompetitiveLeaderboards
	local count = 0
	local count2 = 0

	for _, v10 in pairs(self._ban_data.BanHistory) do
		if BanLibrary:IsBanLogAWarning(v10) then
			count += 1
		end

		if BanLibrary:IsBanLogABan(v10) then
			count2 += 1
		end
	end

	self._is_this_dude_banned = isBanned ~= nil
	self.PlayerLoadedInformationPicture.Image = string.format(
		CONSTANTS.HEADSHOT_IMAGE,
		(tostring(self._ban_data.UserID))
	)
	self:_SetInformationFrameVisible("ELO", v7)
	self:_SetInformationFrameText(
		"ELO",
		(not currentELO and "N/A" or Utility:PrettyNumber(currentELO) or "N/A") .. " " .. (v8 and v8.DisplayName or "N/A") .. " " .. (highestELOLeaderboardRanking and " #" .. highestELOLeaderboardRanking or "")
	)
	self:_SetInformationFrameVisible("Level", level)
	self:_SetInformationFrameText("Level", level and Utility:PrettyNumber(level) or "")
	self:_SetInformationFrameVisible("WinStreak", statisticDuelsWinStreak and statisticDuelsWinStreak > 0)
	self:_SetInformationFrameText(
		"WinStreak",
		statisticDuelsWinStreak and statisticDuelsWinStreak > 0 and Utility:PrettyNumber(statisticDuelsWinStreak) or ""
	)
	self:_SetInformationFrameVisible("Controls", lastKnownControls)
	self:_SetInformationFrameText("Controls", lastKnownControls or "")
	self:_SetInformationFrameText("Username", "@" .. self._ban_data.Name)
	self:_SetInformationFrameText("DisplayName", "• • •")
	self:_SetInformationFrameText("UserID", "#" .. tostring(self._ban_data.UserID))
	self:_SetInformationFrameText("Online", v6 and "🟢 Online" or "🔴 Offline")
	self:_SetInformationFrameText(
		"Lock",
		self._ban_data.BanLocked and "Locked" or "Not locked",
		self._ban_data.BanLocked and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 50)
	)
	self:_SetInformationFrameText(
		"Status",
		v9 .. (not isBanned and "Not banned" or "Banned [" .. (isBanned.Duration and isBanned.Duration >= BanLibrary.PERMANENT_BAN_DURATION and "Permanent" or Utility:TimeFormat2(v4)) .. "]" or "Not banned"),
		isBanned and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 50)
	)
	self:_SetInformationFrameText(
		"History",
		v9 .. (isBanned and "🚨 " .. isBanned.Reason or not (count2 > 0) and "No ban history" or "Banned " .. count2 .. " time" .. (count2 == 1 and "" or "s") or "No ban history"),
		isBanned and Color3.fromRGB(255, 50, 50) or count2 > 0 and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(
			100,
			255,
			50
		)
	)
	self:_SetInformationFrameText(
		"Flags",
		v9 .. (not v5 and "Not flagged" or tostring(v5.Reason) or "Not flagged"),
		v5 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 50)
	)
	self:_SetInformationFrameText(
		"CasualLBs",
		v9 .. (restrictedFromCasualLeaderboards and "Restricted" or "Not restricted"),
		restrictedFromCasualLeaderboards and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 50)
	)
	self:_SetInformationFrameText(
		"CompLBs",
		v9 .. (restrictedFromCompetitiveLeaderboards and "Restricted" or "Not restricted"),
		restrictedFromCompetitiveLeaderboards and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 50)
	)
	self:_SetInformationFrameText(
		"Warnings",
		v9 .. (not (count > 0) and "No warnings" or count .. " warning" .. (count == 1 and "" or "s") or "No warnings"),
		count > 0 and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(100, 255, 50)
	)

	if v7 then
		self._last_rank_icon = RankIcon.new(currentELO, self._ban_data.UserID)
		self._last_rank_icon:SetParent(self.PlayerRank)
	end

	task.spawn(function()
		local userInfosByUserIdsAsync = UserService:GetUserInfosByUserIdsAsync({ self._ban_data.UserID })

		if _ban_data_hash ~= self._ban_data_hash then
			return
		end

		if userInfosByUserIdsAsync[1] and userInfosByUserIdsAsync[1].DisplayName then
			self:_SetInformationFrameText("DisplayName", userInfosByUserIdsAsync[1].DisplayName)
		end
	end)
	self:_UpdatePermissions()
end

function object:Open(...)
	Page.Open(self, ...)
	task.spawn(function()
		self._cached_players = ReplicatedStorage.Remotes.Moderator.RequestCachedPlayers:InvokeServer() or self._cached_players
	end)
end

function object:_SetActionButtonVisible(childName, visible)
	local waitForChild = self.PlayerLoadedActionsFrame:WaitForChild(childName)
	waitForChild.Visible = visible
end

function object:_SetInformationFrameText(childName, text, p2)
	local value = self.PlayerLoadedInformationFrame:WaitForChild(childName):WaitForChild("Value")
	value.Text = text
	local value_2 = self.PlayerLoadedInformationFrame:WaitForChild(childName):WaitForChild("Value")
	value_2.TextColor3 = p2 or Color3.fromRGB(255, 255, 255)
end

function object:_SetInformationFrameVisible(childName, visible)
	local waitForChild = self.PlayerLoadedInformationFrame:WaitForChild(childName)
	waitForChild.Visible = visible
end

function object:_UpdatePowersButtonBubble()
	local permissionsRoles = PlayerDataController:Get("PermissionsRoles")
	local text = ""

	for k, v3 in pairs(v) do
		if k > 1 then
			text ..= [[


]]
		end

		for k2, v4 in pairs(v3) do
			if k2 > 1 then
				text ..= "\n"
			end

			text ..= string.format(
				"%s %s",
				PermissionsLibrary:HasPermission(v4, permissionsRoles) and "✅" or "🟥",
				PermissionsLibrary.Permissions[v4].Description
			)
		end
	end

	self.PowersButtonBubbleTitle.Text = text
end

function object:_UpdatePermissions()
	local permissionsRoles = PlayerDataController:Get("PermissionsRoles")
	local banLocked = self._ban_data and self._ban_data.BanLocked

	for _, v2 in pairs({
		"Status",
		"CasualLBs",
		"CompLBs",
		"Flags",
		"History"
	}) do
		self:_SetInformationFrameVisible(v2, ModerationLibrary:CanViewBanStatusAndLogs(permissionsRoles))
	end

	self.InvestigateFrame.Visible = ModerationLibrary:CanUseInvestigativeCommands(permissionsRoles)
	self:_SetActionButtonVisible("ViewLogs", ModerationLibrary:CanViewBanStatusAndLogs(permissionsRoles))
	self:_SetActionButtonVisible("ViewData", ModerationLibrary:CanViewData(permissionsRoles))
	self:_SetActionButtonVisible("ViewActions", ModerationLibrary:CanViewActionHistory(permissionsRoles))
	self:_SetActionButtonVisible("Lock", ModerationLibrary:CanManageBanLocks(permissionsRoles))
	self:_SetActionButtonVisible("Kick", not banLocked and ModerationLibrary:CanEvict(permissionsRoles))
	local v3 = not banLocked

	if v3 then
		if self._is_this_dude_banned then
			v3 = ModerationLibrary:CanUnban(permissionsRoles)
		else
			v3 = ModerationLibrary:CanBan(permissionsRoles)
		end
	end

	self:_SetActionButtonVisible("Moderate", v3)
	self:_SetActionButtonVisible(
		"Wipe",
		not banLocked and ModerationLibrary:CanRemoveFromLeaderboards(permissionsRoles)
	)
	self:_SetActionButtonVisible(
		"Pardon",
		not banLocked and ModerationLibrary:CanPardon(permissionsRoles) and self._player_data and self._player_data.RedFlags and self._player_data.RedFlags[#self._player_data.RedFlags]
	)
	self:_SetActionButtonVisible("Restrict", not banLocked and ModerationLibrary:CanRestrict(permissionsRoles))
	self:_SetActionButtonVisible("Warn", not banLocked and ModerationLibrary:CanWarnCustom(permissionsRoles))
	self:_UpdatePowersButtonBubble()
end

function object:_UpdateLayouts()
	self.InfoButtonBubbleBackground.Size = UDim2.new(0.0375, self.InfoButtonBubbleTitle.TextBounds.X, 1, 0)
	self.CloseButton.Position = UDim2.new(0.9, 0, 0.0225, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Position = UDim2.new(0.5, 9, 0, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Size = UDim2.new(0.7, 0, 0, self.PageFrame.AbsoluteSize.Y * 0.75)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function object:_PlayersLookupDropdown()
	if self._dropdown_slot then
		self._dropdown_slot:Cancel()
		self._dropdown_slot = nil
	end

	local table2 = Utility:CloneTable(self._cached_players)

	for _, v2 in pairs(Players:GetPlayers()) do
		local v3 = string.upper(v2.DisplayName) .. " (@" .. string.upper(v2.Name) .. ")"

		if not table.find(table2, v3) then
			table.insert(table2, v3)
		end
	end

	table.sort(table2, function(a, b)
		return Utility:StringLessThan(a, b)
	end)
	self._dropdown_slot = DropdownSlot.new(self.DropdownReferenceFrame, table2)
	self._dropdown_slot.Selected:Connect(function(value)
		self._dropdown_slot = nil

		if not value then
			return
		end

		self.LookupBox.Text = string.sub(value, string.find(value, "@") + 1, #value - 1)
		task.defer(self._FetchBanData, self)
	end)
end

function object:_FetchPlayerData()
	if self._player_data_debounce then
		return
	end

	self._player_data_debounce = true
	local success, result = pcall(function()
		return ReplicatedStorage.Remotes.Moderator.RequestPlayerData:InvokeServer(self._ban_data.Name)
	end)
	self._player_data_debounce = false

	if not success then
		self.PromptSystem:Open(
			"ErrorMessage",
			"Whoops!",
			"Something went wrong while fetching their data, error:",
			(tostring(result))
		)
	elseif result then
		self.PromptSystem:Open("ViewPlayerData", self._ban_data.Name, result)
	else
		self.PromptSystem:Open("ErrorMessage", "Whoops!", "This player has never played RIVALS before!")
	end
end

function object:_RawFetchBanData(list)
	if self._lookup_disabled then
		return
	end

	self:SetBanData(nil)

	if not list or #list == 0 then
		return
	end

	self._lookup_disabled = true
	self.PlayerWaitingFrame.Visible = true
	self.PlayerWaitingDotsFrame:AddTag("UILoadingDots")
	self:SetBanData(table.unpack(ReplicatedStorage.Remotes.Moderator.RequestPlayer:InvokeServer(list) or {}))
	self._lookup_disabled = false
	self.PlayerWaitingFrame.Visible = false
	self.PlayerWaitingDotsFrame:RemoveTag("UILoadingDots")
end

function object:_FetchBanData()
	self:_RawFetchBanData(self.LookupBox.Text)
end

function object:_SetupActionButton(childName, onMouseButton1Click)
	local button = self.PlayerLoadedActionsFrame:WaitForChild(childName):WaitForChild("Button")
	local title = button:WaitForChild("Title")
	local description = button:WaitForChild("Description")
	local icon = button:WaitForChild("Icon")
	local background = button:WaitForChild("Background")
	local uIGradient = background:WaitForChild("UIGradient")
	local imageColor3 = background.ImageColor3

	local function enter()
		background.ImageColor3 = Color3.fromRGB(255, 255, 255)
		background.ImageTransparency = 0
		background.Size = UDim2.new(0.725, 0, 1, 0)
		title.TextColor3 = Color3.fromRGB(0, 0, 0)
		description.TextColor3 = Color3.fromRGB(0, 0, 0)
		icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
		uIGradient.Enabled = false
	end

	button.MouseEnter:Connect(enter)

	local function leave()
		background.ImageColor3 = imageColor3
		background.ImageTransparency = 0.5
		background.Size = UDim2.new(1, 0, 1, 0)
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		description.TextColor3 = Color3.fromRGB(255, 255, 255)
		icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		uIGradient.Enabled = true
	end

	button.MouseLeave:Connect(leave)
	leave()
	button.MouseButton1Click:Connect(onMouseButton1Click)
	ButtonEffect:Add(button, true)
end

function object:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.PageFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.InfoButtonBubbleTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.InvestigateWinStreaksButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.Moderator.CheckTop100Streaks:FireServer()
	end)
	self.InvestigateTrueWinStreaksButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.Moderator.CheckTop100TrueStreaks:FireServer()
	end)
	self.LookupButton.MouseButton1Click:Connect(function()
		self:_FetchBanData()
	end)
	self.LookupDropdownButton.MouseButton1Click:Connect(function()
		self:_PlayersLookupDropdown()
	end)
	self.InfoButton.MouseButton1Click:Connect(function()
		self.InfoButtonBubble.Visible = not self.InfoButtonBubble.Visible
	end)
	self.PowersButton.MouseButton1Click:Connect(function()
		self.PowersButtonBubble.Visible = not self.PowersButtonBubble.Visible
	end)
	self:_SetupActionButton("Moderate", function()
		if self._is_this_dude_banned then
			self.PromptSystem:Open("Unban", self._ban_data)
		else
			self.PromptSystem:Open("Ban", self._ban_data)
		end
	end)
	self:_SetupActionButton("ViewLogs", function()
		self.PromptSystem:Open("InspectBanLogs", self._ban_data)
	end)
	self:_SetupActionButton("Join", function()
		ReplicatedStorage.Remotes.Moderator.Join:FireServer(self._ban_data.Name)
	end)
	self:_SetupActionButton("Kick", function()
		self.PromptSystem:Open("Kick", self._ban_data)
	end)
	self:_SetupActionButton("ViewData", function()
		if self._result_data then
			self.PromptSystem:Open("ViewPlayerData", self._ban_data.Name, self._result_data)
		else
			self:_FetchPlayerData()
		end
	end)
	self:_SetupActionButton("Pardon", function()
		self.PromptSystem:Open("Pardon", self._ban_data)
	end)
	self:_SetupActionButton("Lock", function()
		ReplicatedStorage.Remotes.Moderator.LockBans:FireServer(self._ban_data.Name)
	end)
	self:_SetupActionButton("ViewActions", function()
		self.PromptSystem:Open("InspectActionLogs", self._ban_data)
	end)
	self:_SetupActionButton("Wipe", function()
		ReplicatedStorage.Remotes.Moderator.RemoveFromLeaderboards:FireServer(self._ban_data.Name)
	end)
	self:_SetupActionButton("Restrict", function()
		self.PromptSystem:Open("Restrict", self._ban_data)
	end)
	self:_SetupActionButton("Warn", function()
		self.PromptSystem:Open("Warn", self._ban_data)
	end)
	PlayerDataController:GetDataChangedSignal("PermissionsRoles"):Connect(function()
		self:_UpdatePermissions()
	end)
	ReplicatedStorage.Remotes.Moderator.UpdateBanData.OnClientEvent:Connect(function(p)
		self:SetBanData(p, self._result_data)
	end)
	self:_UpdateLayouts()
	self:_UpdatePermissions()
	self:SetBanData(nil)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.InvestigateWinStreaksButton)
	ButtonEffect:Add(self.InvestigateTrueWinStreaksButton)
	ButtonEffect:Add(self.LookupButton)
	ButtonEffect:Add(self.LookupDropdownButton)
	ButtonEffect:Add(self.InfoButton)
	ButtonEffect:Add(self.PowersButton)
end

return object._new()