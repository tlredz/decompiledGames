local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local MatchmakingCountdown = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("MatchmakingCountdown"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Teleporting"))
require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("PlayerList"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local playerInteractionGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PlayerInteractionGui")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.LocalFighter = nil
	self._connections = {}
	self._changed_connections = {}
	self._bbg = playerInteractionGui:Clone()
	self._highlight = nil
	self._next_whitelist = 0
	self._whitelist = {}
	self._disabled_until = 0
	self._hash = 0
	self:_Init()
	return self
end

function class:_SetAdornee(p2)
	self._bbg.Adornee = p2 or nil
	local _bbg = self._bbg
	local parent

	if p2 then
		parent = Players.LocalPlayer.PlayerGui
	end

	_bbg.Parent = parent
end

function class:_GetWhitelist()
	if tick() > self._next_whitelist then
		self._next_whitelist = tick() + 3
		self._whitelist = FighterController:GetFighterModels()
	end

	return self._whitelist
end

function class:_ClearChangedConnections()
	for _, _changed_connection in pairs(self._changed_connections) do
		_changed_connection:Disconnect()
	end

	self._changed_connections = {}
end

function class:_Verify()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}

	if self._highlight then
		self._highlight:Destroy()
		self._highlight = nil
	end

	self:_SetAdornee(nil)
	self:_ClearChangedConnections()
	self._hash += 1
	local _hash = self._hash

	if not self.LocalFighter or self.LocalFighter:Get("IsInDuel") or self.LocalFighter:Get("IsInShootingRange") or self.LocalFighter.Entity and self.LocalFighter.Entity:Get("IsGrabbingSnowball") or tick() < self._disabled_until then
		return
	end

	if Pages.PageSystem.CurrentPage or SpectateController.CurrentDuelSubject or MobileInputs.EditorEnabled or Teleporting.Enabled or MatchmakingCountdown:IsVisible() or GuiService.MenuIsOpen then
		return
	end

	self._highlight = Instance.new("Highlight")
	self._highlight.Name = "PlayerInteraction"
	self._highlight.FillColor = Color3.fromRGB(255, 255, 255)
	self._highlight.Parent = Players.LocalPlayer.PlayerGui

	local function get_hovered_player_object()
		local mouseLocation = UILibrary:GetMouseLocation()
		local screenPointToRay = workspace.CurrentCamera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y, 0)
		local characterModel = Utility:GetCharacterModel(Utility:Raycast(
			screenPointToRay.Origin,
			screenPointToRay.Origin + screenPointToRay.Direction * 100,
			100,
			self:_GetWhitelist(),
			Enum.RaycastFilterType.Include
		).Instance)
		local playerFromCharacter = characterModel and Players:GetPlayerFromCharacter(characterModel)

		if characterModel and characterModel:FindFirstChild("HumanoidRootPart") and (workspace.CurrentCamera.CFrame.Position - characterModel.HumanoidRootPart.Position).Magnitude < 5 then
			return
		else
			return playerFromCharacter, characterModel
		end
	end

	local v = nil
	local v2 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_visuals()
		if self._hash ~= _hash then
			return
		end

		local v3 = tick() - v2 < 0.25
		self._highlight.FillTransparency = v3 and 0.5 or 0.75
		self._highlight.OutlineTransparency = v3 and 0 or 0.5
		self._bbg.Container.Title.Text = v3 and "Tap again to view profile" or "Double tap to view profile"
	end

	update_visuals() -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function set_start_click(now)
		v2 = now
		update_visuals() -- equivalent call inferred; original call site unknown
		task.delay(0.25, function()
			if self._hash ~= _hash then
				return
			end

			local v3 = tick() - v2 < 0.25
			self._highlight.FillTransparency = v3 and 0.5 or 0.75
			self._highlight.OutlineTransparency = v3 and 0 or 0.5
			self._bbg.Container.Title.Text = v3 and "Tap again to view profile" or "Double tap to view profile"
		end)
	end

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonX then
			if tick() - v2 > 0.25 then
				v = nil
			end

			set_start_click(tick()) -- equivalent call inferred; original call site unknown

			if input.UserInputType == Enum.UserInputType.Touch then
				self:_ClearChangedConnections()
				table.insert(self._changed_connections, input:GetPropertyChangedSignal("Position"):Connect(function()
					local _, adornee = get_hovered_player_object()
					self._highlight.Adornee = adornee
					self:_SetAdornee(adornee and adornee:FindFirstChild("HumanoidRootPart"))
				end))
				table.insert(
					self._changed_connections,
					input:GetPropertyChangedSignal("UserInputState"):Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							self:_ClearChangedConnections()
						end
					end)
				)
			end
		end
	end))
	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonX then
			if tick() - v2 > 0.25 then
				return
			end

			local v3 = get_hovered_player_object()

			if not v3 then
				return
			end

			if v == v3 then
				Pages.PageSystem:OpenPage("ViewProfile")
				Pages.PageSystem:WaitForPage("ViewProfile"):Fetch(v3)
			else
				v = v3
			end
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mouse_moved()
		local _, adornee = get_hovered_player_object()
		self._highlight.Adornee = adornee
		self:_SetAdornee(adornee and adornee:FindFirstChild("HumanoidRootPart"))
	end

	table.insert(self._connections, workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(mouse_moved))
	table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			mouse_moved() -- equivalent call inferred; original call site unknown
		end
	end))
end

function class:_HookLocalFighter()
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_Verify()
	end)
	self.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_Verify()
	end)

	local function entity_added(object2)
		object2:GetDataChangedSignal("IsGrabbingSnowball"):Connect(function()
			self._disabled_until = tick() + 2
			task.delay(2, self._Verify, self)
			self:_Verify()
		end)
		self:_Verify()
	end

	self.LocalFighter.EntityAdded:Connect(entity_added)

	if self.LocalFighter.Entity then
		task.defer(entity_added, self.LocalFighter.Entity)
	end

	self:_Verify()
end

function class:_Setup()
	self._bbg.Name = "PlayerInteraction"
	self._bbg.Parent = Players.LocalPlayer.PlayerGui
end

function class:_Init()
	Pages.PageSystem.PageOpened:Connect(function()
		self:_Verify()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_Verify()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_Verify()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_Verify()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_Verify()
	end)
	MatchmakingCountdown.VisibilityChanged:Connect(function()
		self:_Verify()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_Verify()
	end)
	self:_Setup()
	task.defer(self._Verify, self)
	task.spawn(self._HookLocalFighter, self)
end

return class._new()