local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.MainFrame = UILibrary:GetTo("MainFrame")
	self:_Init()
	return self
end

function class:_UpdateSize()
	local setting = PlayerDataController:GetSetting("Padded HUD")
	local v = not Pages.PageSystem.CurrentPage

	if v then
		if setting == "Always On" then
			v = true
		elseif setting == "Using Controller" then
			v = ControlsController.CurrentControls == "Gamepad"
		else
			v = false
		end
	end

	local uDim = v and UDim2.new(0.9, 0, 0.9, 0) or UDim2.new(1, 0, 1, 0)

	if self.MainFrame:IsDescendantOf(Players) then
		self.MainFrame:TweenSize(uDim, "Out", "Quint", 0.25, true)
	else
		self.MainFrame.Size = uDim
	end
end

function class:_Update()
	local visible = not (FighterController.LocalFighter and FighterController.LocalFighter:Get("IsHiddenByCutscene") or PlayerDataController:GetSetting("Hide HUD"))
	local visible2 = SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject:Get("Status") == "Voting"
	local v3 = not GuiService.MenuIsOpen
	self.MainFrame.BottomStack.Visible = visible
	self.MainFrame.Notifications.Visible = visible
	local duelInterfaces = self.MainFrame.DuelInterfaces

	if visible or visible2 then
		visible2 = v3
	end

	duelInterfaces.Visible = visible2
	self.MainFrame.EliminatedEffect.Visible = visible
	self.MainFrame.FighterInterfaces.Visible = visible and v3
	self.MainFrame.Lobby.Visible = visible
end

function class:_HookLocalFighter()
	FighterController:WaitForLocalFighter():GetDataChangedSignal("IsHiddenByCutscene"):Connect(function()
		self:_Update()
	end)
	task.defer(self._Update, self)
end

function class:_Init()
	PlayerDataController:GetSettingChangedSignal("Hide HUD"):Connect(function()
		self:_Update()
	end)
	PlayerDataController:GetSettingChangedSignal("Padded HUD"):Connect(function()
		self:_UpdateSize()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_Update()
	end)
	SpectateController.DuelSubjectStatusChanged:Connect(function()
		self:_Update()
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateSize()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateSize()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_Update()
	end)
	self:_Update()
	self:_UpdateSize()
	task.defer(self._HookLocalFighter, self)
end

return class._new()