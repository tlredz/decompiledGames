local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local TweenService = game:GetService("TweenService")
game:GetService("Lighting")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
require(Players.LocalPlayer.PlayerScripts.Modules.VoteBanFrame)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local WeaponSlot = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponSlot)
local MapSlot = require(Players.LocalPlayer.PlayerScripts.Modules.MapSlot)
local voteWeaponTabButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("VoteWeaponTabButton")
local banIcon = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BanIcon")
local Voting = {}
Voting.__index = Voting

function Voting.new(duelInterface)
	local self = setmetatable({}, Voting)
	self.VisibilityChanged = Signal.new()
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Voting")
	self.MapsFrame = self.Frame:WaitForChild("Maps")
	self.MapsCenter = self.MapsFrame:WaitForChild("MapsCenter")
	self.MapsCenterLayout = self.MapsCenter:WaitForChild("Layout")
	self.MapsList = self.MapsFrame:WaitForChild("MapsList")
	self.MapsListContainer = self.MapsList:WaitForChild("Container")
	self.MapsListMaximizedFrame = self.MapsListContainer:WaitForChild("Maximized")
	self.MapsListMaximizedLayout = self.MapsListMaximizedFrame:WaitForChild("Layout")
	self.MapsListMinimizedFrame = self.MapsListContainer:WaitForChild("Minimized")
	self.MapsListMinimizedLayout = self.MapsListMinimizedFrame:WaitForChild("Layout")
	self.MapsListCentererFrame = self.MapsListContainer:WaitForChild("Centerer")
	self.MapsChosenEffectFrame = self.MapsFrame:WaitForChild("ChosenEffect")
	self.MapsArcadeModeFrame = self.MapsFrame:WaitForChild("ArcadeMode")
	self.MapsArcadeModeTitle = self.MapsArcadeModeFrame:WaitForChild("Container"):WaitForChild("Title")
	self.WeaponsFrame = self.Frame:WaitForChild("Weapons")
	self.WeaponsMapFrame = self.WeaponsFrame:WaitForChild("Map")
	self.WeaponsMapContainer = self.WeaponsMapFrame:WaitForChild("Container")
	self.WeaponsMapTitle = self.WeaponsMapContainer:WaitForChild("Title")
	self.WeaponsContainer = self.WeaponsFrame:WaitForChild("Container")
	self.WeaponsTabsFrame = self.WeaponsContainer:WaitForChild("Tabs")
	self.WeaponsList = self.WeaponsContainer:WaitForChild("List")
	self.WeaponsListContainer = self.WeaponsList:WaitForChild("Container")
	self.WeaponsListLayout = self.WeaponsListContainer:WaitForChild("Layout")
	self.RemainingBansFrame = self.Frame:WaitForChild("RemainingBans")
	self.RemainingBansContainer = self.RemainingBansFrame:WaitForChild("Container")
	self.RemainingBansStart = self.RemainingBansFrame:WaitForChild("Start")
	self.RemainingBansFinish = self.RemainingBansFrame:WaitForChild("Finish")
	self._destroyed = false
	self._generate_hash = 0
	self._last_vote_options_type = nil
	self._remaining_ban_icons_generated = false
	self._remaining_ban_icons_generate_hash = 0
	self._remaining_ban_icons = {}
	self._map_slots = {}
	self._map_chosen_slot = nil
	self._map_chosen_hash = 0
	self._weapon_class_selected = nil
	self._weapon_tab_buttons = {}
	self._weapon_slots = {}
	self._weapon_slots_banned = {}
	self._weapon_ban_icons = {}
	self._last_map_chosen_result = nil
	self._ban_sound_debounce = {}
	self:_Init()
	return self
end

function Voting:IsOpen()
	return not self._destroyed and self.Frame.Visible
end

function Voting:PlayMapChosenEffect(last_map_chosen_result)
	local uDim = UDim2.new(0, 0, 0, 0)
	local uDim2 = UDim2.new(0.5, 0, 3, 0)

	for _, _map_slot in pairs(self._map_slots) do
		if _map_slot.Name ~= last_map_chosen_result.Name then
			continue
		end

		local v = _map_slot.Frame.AbsolutePosition + _map_slot.Frame.AbsoluteSize * 0.5 - self.MapsChosenEffectFrame.AbsolutePosition
		uDim2 = UDim2.new(0, v.X, 0, v.Y)
		uDim = UDim2.new(0, _map_slot.Frame.AbsoluteSize.X, 0, _map_slot.Frame.AbsoluteSize.Y)
	end

	self:_ClearMaps()
	self:_ClearMapChosenEffect()
	self._last_map_chosen_result = last_map_chosen_result
	self._map_chosen_hash += 1
	local _map_chosen_hash = self._map_chosen_hash
	self._map_chosen_slot = MapSlot.new(last_map_chosen_result.Name, true)
	self._map_chosen_slot.Frame.SizeConstraint = Enum.SizeConstraint.RelativeXY
	self._map_chosen_slot.Frame.Size = uDim
	self._map_chosen_slot.Frame.Position = uDim2
	self._map_chosen_slot:SetParent(self.MapsChosenEffectFrame)
	self._map_chosen_slot.Frame:TweenSizeAndPosition(
		UDim2.new(1, 0, 1, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		"Out",
		"Quint",
		0.75,
		true
	)
	self.WeaponsMapTitle.Text = "Map: " .. last_map_chosen_result.Name
	self.DuelInterface:CreateSound("rbxassetid://103035811146294", 1, 1, script, true, 5)
	wait(1.25)

	if _map_chosen_hash ~= self._map_chosen_hash then
		return
	end

	self._map_chosen_slot.Frame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quint", 0.75, true)
	wait(0.75)

	if _map_chosen_hash ~= self._map_chosen_hash then
		return
	end

	self._map_chosen_slot:Destroy()
	self._map_chosen_slot = nil
end

function Voting:Generate()
	self._generate_hash += 1
	local visible = self.DuelInterface.ClientDuel:Get("VoteOptions") and not self.DuelInterface:IsPageOpen()
	self.Frame.Visible = visible
	self.VisibilityChanged:Fire()

	if visible then
		if not GamepadService.GamepadCursorEnabled and ControlsController.CurrentControls == "Gamepad" then
			GamepadService:EnableGamepadCursor(self.Frame)
		end

		task.spawn(function()
			local voteOptionsType = self.DuelInterface.ClientDuel:Get("VoteOptionsType")

			if self._last_vote_options_type ~= voteOptionsType then
				self._last_vote_options_type = voteOptionsType
				self._remaining_ban_icons_generated = false
				self._remaining_ban_icons_generate_hash += 0
			end

			if voteOptionsType == "Maps" then
				self:_ClearWeapons()
				self:_GenerateMaps()
			elseif voteOptionsType == "Weapons" then
				self:_ClearMaps()
				self:_GenerateWeapons()
			end
		end)
	else
		GamepadService:DisableGamepadCursor()
		self._remaining_ban_icons_generated = false
		self._remaining_ban_icons_generate_hash += 0
		self:_ClearMaps()
		self:_ClearWeapons()
	end
end

function Voting:Destroy()
	self._destroyed = true
	self.VisibilityChanged:Destroy()
	self:_ClearMaps()
	self:_ClearMapChosenEffect()
	self:_ClearWeapons()
end

function Voting:_PlayBanSound(p2, ...)
	if self._ban_sound_debounce[p2] then
		return
	end

	self._ban_sound_debounce[p2] = true
	task.defer(function(...)
		self._ban_sound_debounce[p2] = nil
		self.DuelInterface:CreateSound(p2, ...)
	end, ...)
end

function Voting:_ClearMapChosenEffect()
	self._map_chosen_hash += 1

	if self._map_chosen_slot then
		self._map_chosen_slot:Destroy()
		self._map_chosen_slot = nil
	end
end

function Voting:_SetWeaponClassSelected(weapon_class_selected)
	self._weapon_class_selected = weapon_class_selected
	self:_UpdateWeapons()
end

function Voting:_UpdateWeapons()
	for k, _ in pairs(ItemLibrary.Classes) do
		local v = k == self._weapon_class_selected
		local _weapon_tab_button = self._weapon_tab_buttons[k]
		_weapon_tab_button.Title.TextColor3 = v and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
		_weapon_tab_button.Title.Icon.ImageColor3 = v and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
		_weapon_tab_button.Background.ImageColor3 = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
		_weapon_tab_button.Background.ImageTransparency = v and 0 or 0.25
		_weapon_tab_button.Background.UIGradient.Enabled = not v
	end

	for k, _weapon_slot in pairs(self._weapon_slots) do
		_weapon_slot.Frame.Visible = ItemLibrary.Items[k].Class == self._weapon_class_selected
	end
end

function Voting:_GenerateRemainingBans()
	for _, _weapon_ban_icon in pairs(self._weapon_ban_icons) do
		_weapon_ban_icon:Destroy()
	end

	self._weapon_ban_icons = {}
	local voteOptions = self.DuelInterface.ClientDuel:Get("VoteOptions")
	local voteOptionsType = self.DuelInterface.ClientDuel:Get("VoteOptionsType")
	local v

	if voteOptionsType == "Weapons" then
		v = self.DuelInterface.ClientDuel:Get("MaxWeaponBansPerTeam")
	else
		v = self.DuelInterface.ClientDuel:Get("MaxMapBansPerTeam")
	end

	local v2 = v or 0
	local voteBansRemaining = self.DuelInterface.ClientDuel:Get("VoteBansRemaining") or {}
	local flag = false

	if not self._remaining_ban_icons_generated then
		for _, _remaining_ban_icon in pairs(self._remaining_ban_icons) do
			for _, v3 in pairs(_remaining_ban_icon) do
				v3:Destroy()
			end
		end

		self._remaining_ban_icons = {}
		self._remaining_ban_icons_generated = true
		self._remaining_ban_icons_generate_hash += 1
		local _remaining_ban_icons_generate_hash = self._remaining_ban_icons_generate_hash
		local v3 = {}

		for _, dueler in pairs(self.DuelInterface.ClientDuel.Duelers) do
			local teamID = dueler:Get("TeamID")

			if teamID then
				v3[teamID] = true
			end
		end

		local dueler = self.DuelInterface.ClientDuel:GetDueler(Players.LocalPlayer)
		local layoutOrder = 1

		for k in pairs(v3) do
			if dueler then
				local _ = k == dueler:Get("TeamID")
			end

			local teamColor = DuelLibrary:GetTeamColor(k)

			for _ = 1, v2 - (voteBansRemaining[k] or 0) do
				local v5 = 1 - (layoutOrder - 1) * 0.1
				local clone = banIcon:Clone()
				clone.ImageColor3 = Utility:DarkenColor(teamColor, v5 * 0.5)
				clone.Icon.ImageColor3 = Utility:DarkenColor(teamColor, v5)
				clone.LayoutOrder = layoutOrder
				clone.ZIndex = -layoutOrder
				self._remaining_ban_icons[k] = self._remaining_ban_icons[k] or {}
				table.insert(self._remaining_ban_icons[k], clone)
				task.delay((layoutOrder - 1) * 0.25 + 0.125, function()
					if _remaining_ban_icons_generate_hash ~= self._remaining_ban_icons_generate_hash then
						return
					end

					clone.UIScale.Scale = 0.25
					clone.Parent = self.RemainingBansContainer
					TweenService:Create(
						clone.UIScale,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Scale = 1
						}
					):Play()
					self.DuelInterface:CreateSound(
						"rbxassetid://92837039207579",
						1.25,
						layoutOrder * 0.075 + 0.75,
						script,
						true,
						5
					)
				end)
				layoutOrder += 1
				flag = true
			end
		end

		self.RemainingBansContainer.Position = self.RemainingBansStart.Position
		self.RemainingBansContainer:TweenPosition(self.RemainingBansContainer.Position, "Out", "Linear", 0, true)
		self.RemainingBansContainer.Size = self.RemainingBansStart.Size
		self.RemainingBansContainer:TweenSize(self.RemainingBansContainer.Size, "Out", "Linear", 0, true)
		task.spawn(function()
			local _remaining_ban_icons_generate_hash2 = self._remaining_ban_icons_generate_hash
			wait(1)

			if self._remaining_ban_icons_generate_hash ~= _remaining_ban_icons_generate_hash2 then
				return
			end

			if self.RemainingBansContainer:IsDescendantOf(Players) then
				self.RemainingBansContainer:TweenPosition(
					self.RemainingBansFinish.Position,
					"InOut",
					"Quint",
					0.5,
					true
				)
				self.RemainingBansContainer:TweenSize(self.RemainingBansFinish.Size, "InOut", "Quint", 0.5, true)
			else
				self.RemainingBansContainer.Position = self.RemainingBansFinish.Position
				self.RemainingBansContainer.Size = self.RemainingBansFinish.Size
			end
		end)
		self:_SetWeaponClassSelected("Primary")
	end

	for k, _remaining_ban_icon in pairs(self._remaining_ban_icons) do
		local v3 = v2 - (voteBansRemaining[k] or 0)

		for k2, v4 in pairs(_remaining_ban_icon) do
			v4.Visible = k2 <= v3
		end
	end

	if voteOptionsType == "Weapons" then
		local v3 = {}

		for _, voteOption in pairs(voteOptions) do
			local isBanned = voteOption.IsBanned

			if not isBanned then
				continue
			end

			local teamColor = DuelLibrary:GetTeamColor(isBanned)
			local item = ItemLibrary.Items[voteOption.Name]
			v3[item.Class] = (v3[item.Class] or 0) + 1
			local layoutOrder = v3[item.Class]
			local clone = banIcon:Clone()
			clone.ImageColor3 = Utility:DarkenColor(teamColor, 0.5)
			clone.Icon.ImageColor3 = Utility:DarkenColor(teamColor, 1)
			clone.LayoutOrder = layoutOrder
			clone.ZIndex = -layoutOrder
			clone.Parent = self._weapon_tab_buttons[item.Class].Bans
			table.insert(self._weapon_ban_icons, clone)
			clone.Weapon.Icon.Image = ItemLibrary.ViewModels[voteOption.Name].ImageCentered or item.Image
			clone.Weapon.ZIndex = 10
			clone.Weapon.Visible = true
		end
	end

	if flag then
		wait(1.25)
	end
end

function Voting:_ClearWeapons()
	for _, _weapon_slot in pairs(self._weapon_slots) do
		_weapon_slot:Destroy()
	end

	self._weapon_slots = {}
	self._weapon_slots_banned = {}
	self.WeaponsFrame.Visible = false
end

function Voting:_GenerateWeapons()
	self.WeaponsFrame.Visible = true
	local _generate_hash = self._generate_hash
	self:_GenerateRemainingBans()

	if _generate_hash ~= self._generate_hash then
		return
	end

	local voteOptions = self.DuelInterface.ClientDuel:Get("VoteOptions")
	local dueler = self.DuelInterface.ClientDuel:GetDueler(Players.LocalPlayer)

	for k, voteOption in pairs(voteOptions) do
		local name = voteOption.Name

		if self._weapon_slots[name] then
			continue
		end

		local v = WeaponSlot.new(name)
		v.Frame.LayoutOrder = k
		v.Frame.Parent = self.WeaponsListContainer

		if dueler then
			local name2 = name
			v.Frame.Button.MouseButton1Click:Connect(function()
				ReplicatedStorage.Remotes.Duels.Vote:FireServer(name2)
			end)
		else
			v:DisableButton()
		end

		v.PlayBanFrameSound:Connect(function(...)
			self:_PlayBanSound(...)
		end)
		self._weapon_slots[name] = v
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 0.25
		uIScale.Parent = v.Frame
		TweenService:Create(
			uIScale,
			TweenInfo.new(math.sqrt(k) * 0.1 + 0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Scale = 1
			}
		):Play()
	end

	for _, voteOption in pairs(voteOptions) do
		local name = voteOption.Name
		local _weapon_slot = self._weapon_slots[name]

		if not _weapon_slot or not voteOption.IsBanned or self._weapon_slots_banned[name] then
			continue
		end

		self._weapon_slots_banned[name] = true
		_weapon_slot:ToggleBanned(0, voteOption.IsBanned)
	end

	self:_UpdateWeapons()
end

function Voting:_ClearMaps()
	for _, _map_slot in pairs(self._map_slots) do
		_map_slot:Destroy()
	end

	self._map_slots = {}
	self.MapsCenter.Visible = false
	self.MapsList.Visible = false
end

function Voting:_GenerateMaps()
	if self._map_chosen_slot then
		return
	end

	local voteSelectionMode = self.DuelInterface.ClientDuel:Get("VoteSelectionMode")
	local voteOptions = self.DuelInterface.ClientDuel:Get("VoteOptions")
	local visible = #voteOptions <= 6
	self.MapsList.Visible = not visible
	self.MapsCenter.Visible = visible
	self.MapsCenterLayout.FillDirectionMaxCells = #voteOptions == 4 and 2 or 0
	local _generate_hash = self._generate_hash
	self:_GenerateRemainingBans()

	if _generate_hash ~= self._generate_hash then
		return
	end

	local v2 = {}

	if not visible and #voteOptions > 3 then
		local random = Random.new(self.DuelInterface.ClientDuel:Get("DuelSeed"))
		local voteOptions2 = {}

		for _, voteOption in pairs(voteOptions) do
			if voteOption.Name ~= "Random" then
				table.insert(voteOptions2, voteOption)
			end
		end

		for _ = 1, 3 do
			v2[table.remove(voteOptions2, random:NextInteger(1, #voteOptions2))] = true
		end
	end

	local dueler = self.DuelInterface.ClientDuel:GetDueler(Players.LocalPlayer)
	local total = 0

	for k, voteOption in pairs(voteOptions) do
		total += voteOption.Votes

		if self._map_slots[voteOption.Name] then
			continue
		end

		local mapsCenter

		if visible then
			mapsCenter = self.MapsCenter
		elseif v2[voteOption] then
			mapsCenter = self.MapsListMaximizedFrame
		else
			mapsCenter = self.MapsListMinimizedFrame
		end

		local v3 = MapSlot.new(voteOption.Name, not dueler)
		v3.Frame.LayoutOrder = k
		v3:SetParent(mapsCenter)
		self._map_slots[voteOption.Name] = v3
		v3.CreateSound:Connect(function(...)
			self:_PlayBanSound(...)
		end)

		if dueler then
			local v4 = voteOption
			v3.Frame.Button.MouseButton1Click:Connect(function()
				ReplicatedStorage.Remotes.Duels.Vote:FireServer(v4.Name)
			end)
		end

		if mapsCenter == self.MapsListMaximizedFrame then
			continue
		end

		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 0.25
		uIScale.Parent = v3.Frame
		TweenService:Create(
			uIScale,
			TweenInfo.new(math.sqrt(k) * 0.1 + 0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Scale = 1
			}
		):Play()
	end

	local v3 = {}
	local teamIDsByUserId = {}
	local v4 = nil

	for _, dueler2 in pairs(self.DuelInterface.ClientDuel.Duelers) do
		local lastVote = dueler2:Get("LastVote")

		if lastVote then
			v3[lastVote] = v3[lastVote] or {}
			table.insert(v3[lastVote], dueler2.Player.UserId)
		end

		if dueler2.Player == Players.LocalPlayer then
			v4 = lastVote
		end

		teamIDsByUserId[tostring(dueler2.Player.UserId)] = dueler2:Get("TeamID")
	end

	for _, voteOption in pairs(voteOptions) do
		local _map_slot = self._map_slots[voteOption.Name]

		if not _map_slot then
			continue
		end

		if voteOption.IsBanned then
			_map_slot.VoteBanFrame:Play(voteOption.IsBanned, true)
		else
			_map_slot:UpdateVotes(
				voteOption.Votes,
				total,
				v3[voteOption.Name],
				teamIDsByUserId,
				voteOption.Name == v4,
				voteSelectionMode
			)
		end
	end
end

function Voting:_UpdateLists()
	self.MapsList.CanvasSize = UDim2.new(
		0,
		0,
		0,
		self.MapsListMinimizedFrame.AbsolutePosition.Y + self.MapsListMinimizedLayout.AbsoluteContentSize.Y - self.MapsListContainer.AbsolutePosition.Y + 10
	)
	self.MapsList.ClipsDescendants = self.MapsList.CanvasPosition.Y > 5
	self.WeaponsList.CanvasSize = UDim2.new(0, 0, 0, self.WeaponsListLayout.AbsoluteContentSize.Y)
	self.WeaponsList.ClipsDescendants = self.WeaponsList.CanvasPosition.Y > 5
	self.WeaponsTabsFrame.Visible = self.WeaponsListLayout.AbsoluteContentSize.Y > 0
	self.WeaponsMapFrame.Visible = self._last_map_chosen_result and self.WeaponsTabsFrame.Visible
	self.MapsListMaximizedFrame.Visible = self.MapsListMaximizedLayout.AbsoluteContentSize.Y > 0
	self.MapsListMinimizedFrame.Visible = self.MapsListMinimizedLayout.AbsoluteContentSize.Y > 0
	self.MapsListCentererFrame.Size = UDim2.new(
		0,
		0,
		0,
		math.max(0, self.MapsList.AbsoluteWindowSize.Y - self.MapsList.CanvasSize.Y.Offset) / 2
	)
end

function Voting:_Setup()
	for k, class in pairs(ItemLibrary.Classes) do
		local clone = voteWeaponTabButton:Clone()
		clone.Title.Text = k
		clone.Title.Icon.Image = class.ImageDiagonalLeft
		clone.LayoutOrder = class.Slot
		clone.Parent = self.WeaponsTabsFrame
		self._weapon_tab_buttons[k] = clone
		local v = k
		clone.MouseButton1Click:Connect(function()
			self:_SetWeaponClassSelected(v)
		end)
		ButtonEffect:Add(clone)
		local title = clone.Title
		-- equivalent calls inferred from this helper; original call sites unknown
		local icon = title.Icon

		local function update()
			icon.Position = UDim2.new(0.5, -title.TextBounds.X / 2, 0.5, 0)
		end

		title:GetPropertyChangedSignal("TextBounds"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	local arcadeMode = self.DuelInterface.ClientDuel:Get("ArcadeMode")
	self.MapsArcadeModeTitle.Text = not arcadeMode and "" or "Gamemode: " .. DuelLibrary.ArcadeModes[arcadeMode].DisplayName or ""
	self.MapsArcadeModeFrame.Visible = arcadeMode
end

function Voting:_Init()
	self.MapsList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_UpdateLists()
	end)
	self.MapsList:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		self:_UpdateLists()
	end)
	self.MapsList:GetPropertyChangedSignal("CanvasSize"):Connect(function()
		self:_UpdateLists()
	end)
	self.WeaponsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLists()
	end)
	self.WeaponsList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_UpdateLists()
	end)
	self.MapsListMaximizedLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLists()
	end)
	self.MapsListMinimizedLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLists()
	end)
	self.MapsListContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateLists()
	end)
	self.MapsListMinimizedFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		task.defer(self._UpdateLists, self)
	end)
	self:_Setup()
	self:_UpdateLists()
end

return Voting