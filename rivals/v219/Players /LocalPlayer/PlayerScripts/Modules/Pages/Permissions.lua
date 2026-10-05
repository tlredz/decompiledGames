local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local DropdownSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("DropdownSlot"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local permissionsPlayersCard = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PermissionsPlayersCard")
local permissionsPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PermissionsPlayerSlot")
local permissionsRoleLabel = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PermissionsRoleLabel")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.PageContainer = self.PageFrame:WaitForChild("Container")
	self.CloseButton = self.PageContainer:WaitForChild("Close")
	self.WaitingFrame = self.PageContainer:WaitForChild("Waiting")
	self.WaitingDotsFrame = self.WaitingFrame:WaitForChild("Dots")
	self.List = self.PageContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.InfoButton = self.Container:WaitForChild("Header"):WaitForChild("Info")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._permissions_datas = {}
	self._add_role_dropdown_slot = nil
	self._players_cards = {}
	self._player_slots = {}
	self._generate_hash = 0
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	self:_ClearNewPlayerBox()
	self:_CloseAddRoleDropdown()
	task.spawn(self._FetchPermissionsDatas, self)
end

function object:Close(...)
	self:_CloseAddRoleDropdown()
	Page.Close(self, ...)
end

function object:_CloseAddRoleDropdown()
	if self._add_role_dropdown_slot then
		self._add_role_dropdown_slot:Destroy()
		self._add_role_dropdown_slot = nil
	end
end

function object:_ClearNewPlayerBox()
	for _, _players_card in pairs(self._players_cards) do
		_players_card.Container.PermissionsNewPlayerSlot.Container.Lookup.Box.Text = ""
	end
end

function object._GetHighestValueTeam(_, items)
	local v = -1e999
	local v2 = nil

	for _, item in pairs(items) do
		local teamName = PermissionsLibrary.Roles[item].TeamName
		local teamValue = PermissionsLibrary.Teams[teamName].TeamValue

		if not (v < teamValue) then
			continue
		end

		v2 = teamName
		v = teamValue
	end

	return v2
end

function object:_GetManageableRoles(list)
	local manageableRoles = PermissionsLibrary:GetManageableRoles(PlayerDataController:Get("PermissionsRoles"))

	if list then
		for i = #manageableRoles, 1, -1 do
			if table.find(list, manageableRoles[i]) then
				table.remove(manageableRoles, i)
			end
		end
	end

	table.sort(manageableRoles, function(a, b)
		local teamValue = PermissionsLibrary.Teams[PermissionsLibrary.Roles[a].TeamName].TeamValue
		local teamValue2 = PermissionsLibrary.Teams[PermissionsLibrary.Roles[b].TeamName].TeamValue

		if teamValue ~= teamValue2 then
			return teamValue2 < teamValue
		end

		local roleValue = PermissionsLibrary.Roles[a].RoleValue
		local roleValue2 = PermissionsLibrary.Roles[b].RoleValue

		if roleValue == roleValue2 then
			return Utility:StringLessThan(
				PermissionsLibrary.Roles[a].DisplayName,
				PermissionsLibrary.Roles[b].DisplayName
			)
		end

		return roleValue2 < roleValue
	end)
	local displayNames = {}

	for k, manageableRole in pairs(manageableRoles) do
		displayNames[k] = PermissionsLibrary.Roles[manageableRole].DisplayName
	end

	return displayNames
end

function object:_RoleManagement(p, p2)
	if not (p and p2) then
		return
	end

	self:_SetWaitingFrameVisible(true)
	local success, result = pcall(function()
		return ReplicatedStorage.Remotes.Permissions.RoleManagement:InvokeServer(p, p2)
	end)

	if not success then
		warn("Failed to manage role, error:", result)
	end

	self:_SetWaitingFrameVisible(false)
end

function object:_GetNewUserID(p2)
	return (tonumber((string.sub(
		self._players_cards[p2].Container.PermissionsNewPlayerSlot.Container.Lookup.Box.Text,
		2
	))))
end

function object:_AddRoleDropdown(p, p2, p3)
	self:_CloseAddRoleDropdown()
	self._add_role_dropdown_slot = DropdownSlot.new(p, self:_GetManageableRoles(p3))
	self._add_role_dropdown_slot.Selected:Connect(function(p4)
		local permissionsRoleNameFromDisplayName = PermissionsLibrary:GetPermissionsRoleNameFromDisplayName(p4)
		self:_RoleManagement(tonumber(p2) or self:_GetNewUserID(p2), permissionsRoleNameFromDisplayName)
	end)
end

function object:_Generate()
	self:_CloseAddRoleDropdown()
	self:_ClearNewPlayerBox()

	for _, _player_slot in pairs(self._player_slots) do
		_player_slot:Destroy()
	end

	self._player_slots = {}
	self._generate_hash += 1
	local _generate_hash = self._generate_hash

	local function get_highest_team_name(roles)
		local v = -1e999
		local v2 = nil

		for _, item in pairs(roles) do
			local teamName = PermissionsLibrary.Roles[item].TeamName
			local teamValue = PermissionsLibrary.Teams[teamName].TeamValue

			if not (v < teamValue) then
				continue
			end

			v2 = teamName
			v = teamValue
		end

		return v2
	end

	local function get_highest_role_name(roles)
		local roleValue = -1e999
		local v = nil

		for _, item in pairs(roles) do
			local role = PermissionsLibrary.Roles[item]

			if not (roleValue < role.RoleValue) then
				continue
			end

			roleValue = role.RoleValue
			v = item
		end

		return v
	end

	local v = {}
	local v2 = {}

	for k, v3 in pairs(not self._permissions_datas and {} or self._permissions_datas.Players or {}) do
		local v4 = tonumber(k)
		table.insert(v, {
			v4,
			get_highest_team_name(v3.Roles),
			get_highest_role_name(v3.Roles),
			v3
		})
		table.insert(v2, v4)
	end

	local userInfos = ComplianceController:GetUserInfos(v2)

	if self._generate_hash ~= _generate_hash then
		return
	end

	table.sort(v, function(a, b)
		local v3 = not a[2] and -1 or PermissionsLibrary.Teams[a[2]].TeamValue or -1
		local v4 = not b[2] and -1 or PermissionsLibrary.Teams[b[2]].TeamValue or -1

		if v3 ~= v4 then
			return v4 < v3
		end

		local v5 = not a[3] and -1 or PermissionsLibrary.Roles[a[3]].RoleValue or -1
		local v6 = not b[3] and -1 or PermissionsLibrary.Roles[b[3]].RoleValue or -1

		if v5 == v6 then
			return (a[4].AddedTimestamp or 1e999) < (b[4].AddedTimestamp or 1e999)
		end

		return v6 < v5
	end)

	for _, list in pairs(v) do
		local v3, v4, _, v5 = table.unpack(list)

		if #v5.Roles == 0 then
			continue
		end

		local userInfo = userInfos[tostring(v3)]
		local text = not (userInfo and userInfo.DisplayName) and "• • •" or userInfo.DisplayName or "• • •"
		local text2 = userInfo and userInfo.Username and "@" .. userInfo.Username or "• • •"
		local clone = permissionsPlayerSlot:Clone()
		clone.Container.DisplayName.Text = text
		clone.Container.Username.Text = text2
		clone.Container.UserId.Text = "#" .. v3
		clone.Container.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, v3)
		clone.Parent = self._players_cards[v4].Container
		table.insert(self._player_slots, clone)
		ButtonEffect:Add(clone.Container.Roles.Add, true)
		local v8 = v5
		local v10 = v3
		clone.Container.Roles.Add.MouseButton1Click:Connect(function()
			if #self:_GetManageableRoles(v8.Roles) == 0 then
				Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
			else
				self:_AddRoleDropdown(clone.Container.Roles.Add.DropdownContainer, v10, v8.Roles)
			end
		end)

		for _, role in pairs(v5.Roles) do
			local role2 = PermissionsLibrary.Roles[role]
			local clone2 = permissionsRoleLabel:Clone()
			clone2.Display.Title.Text = role2.DisplayName
			clone2.Background.ImageColor3 = role2.Color or Color3.fromRGB(255, 255, 255)
			clone2.LayoutOrder = -(PermissionsLibrary.Teams[role2.TeamName].TeamValue * 10000 + role2.RoleValue)
			clone2.Parent = clone.Container.Roles
			ButtonEffect:Add(clone2, true)
			local v11 = role
			local v12 = v3
			clone2.MouseButton1Click:Connect(function()
				if PermissionsLibrary:CanManageRole(v11, PlayerDataController:Get("PermissionsRoles")) then
					self:_RoleManagement(v12, v11)
				else
					Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
				end
			end)
			local title = clone2.Display.Title

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				clone2.Size = UDim2.new(0.1, title.TextBounds.X, 0.1, 0)
			end

			title:GetPropertyChangedSignal("TextBounds"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
		end

		local layout = clone.Container.Roles.Layout
		-- equivalent calls inferred from this helper; original call sites unknown
		local v11 = clone

		local function update()
			v11.Size = UDim2.new(0.24, 0, 0.085, layout.AbsoluteContentSize.Y)
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end
end

function object:_SetWaitingFrameVisible(visible)
	self.WaitingFrame.Visible = visible

	if self.WaitingFrame then
		self.WaitingDotsFrame:AddTag("UILoadingDots")
	else
		self.WaitingDotsFrame:RemoveTag("UILoadingDots")
	end
end

function object:_SetPermissionsDatas(options)
	self._permissions_datas = options or {}
	self:_Generate()
end

function object:_FetchPermissionsDatas()
	self:_CloseAddRoleDropdown()
	self:_ClearNewPlayerBox()
	self:_SetWaitingFrameVisible(true)
	local success, result = pcall(function()
		return ReplicatedStorage.Remotes.Permissions.FetchPermissions:InvokeServer()
	end)

	if success then
		if not result then
			warn("Fetching permissions returned nothing!")
		end
	else
		warn("Failed to fetch permissions, error:", result)
	end

	self:_SetPermissionsDatas(success and result)
	self:_SetWaitingFrameVisible(false)
end

function object:_UpdateLayouts()
	self.CloseButton.Position = UDim2.new(0.975, 0, 0.0225, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Position = UDim2.new(0.5, 9, 0, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Size = UDim2.new(0.85, 0, 0, self.PageFrame.AbsoluteSize.Y * 0.75)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function object:_VerifyOpen()
	if not PermissionsLibrary:CanViewPermissionsPage(PlayerDataController:Get("PermissionsRoles")) then
		task.defer(function()
			self.Closed:Fire()
		end)
	end
end

function object:_Setup()
	for k, team in pairs(PermissionsLibrary.Teams) do
		local clone = permissionsPlayersCard:Clone()
		clone.Container.Header.Title.Text = team.DisplayName
		clone.Container.Header.Background.ImageColor3 = team.Color
		clone.Container.Header.Icon.Image = team.Icon
		clone.LayoutOrder = -team.TeamValue
		clone.Parent = self.Container
		self._players_cards[k] = clone
		local layout = clone.Container.Layout

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			clone.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
		local v3 = k
		local v4 = clone

		local function update_headshot()
			local _GetNewUserID = self:_GetNewUserID(v3)
			v4.Container.PermissionsNewPlayerSlot.Container.Headshot.ImageColor3 = Color3.fromRGB(255, 255, 255)
			v4.Container.PermissionsNewPlayerSlot.Container.Headshot.ImageTransparency = _GetNewUserID and 0 or 0.75
			v4.Container.PermissionsNewPlayerSlot.Container.Headshot.Image = not _GetNewUserID and "rbxassetid://93178222051105" or string.format(
				CONSTANTS.HEADSHOT_IMAGE,
				_GetNewUserID
			)
		end

		clone.Container.PermissionsNewPlayerSlot.Container.Lookup.Box.FocusLost:Connect(update_headshot)
		update_headshot()
		local v5 = clone
		local update_headshot2 = update_headshot
		clone.Container.PermissionsNewPlayerSlot.Container.Lookup.Box:GetPropertyChangedSignal("Text"):Connect(function()
			if not v5.Container.PermissionsNewPlayerSlot.Container.Lookup.Box:IsFocused() then
				update_headshot2()
			end
		end)
		local v6 = k
		local v7 = clone
		clone.Container.PermissionsNewPlayerSlot.Container.Roles.Add.MouseButton1Click:Connect(function()
			if self:_GetNewUserID(v6) and #self:_GetManageableRoles() ~= 0 then
				self:_AddRoleDropdown(v7.Container.PermissionsNewPlayerSlot.Container.Roles.Add.DropdownContainer, v6)
			else
				Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
			end
		end)
		ButtonEffect:Add(clone.Container.PermissionsNewPlayerSlot.Container.Roles.Add, true)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.PageFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.InfoButton.MouseButton1Click:Connect(function()
		self.PromptSystem:Open("ViewPermissionsRoles")
	end)
	PlayerDataController:GetDataChangedSignal("PermissionsRoles"):Connect(function()
		self:_VerifyOpen()
	end)
	ReplicatedStorage.Remotes.Permissions.UpdatePermissions.OnClientEvent:Connect(function(p)
		self:_SetPermissionsDatas(p)
	end)
	self:_Setup()
	self:_Generate()
	self:_UpdateLayouts()
	self:_VerifyOpen()
	ButtonEffect:Add(self.InfoButton)
	ButtonEffect:Add(self.CloseButton)
end

return object._new()