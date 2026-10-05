local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local settingTabSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SettingTabSlot")
local v = {
	{ "Video", "rbxassetid://111628467664626" },
	{ "Audio", "rbxassetid://77374671054355" },
	{ "Game", "rbxassetid://76006565289299" },
	{ "Crosshair", "rbxassetid://132790955082325" },
	{ "Hotkeys", "rbxassetid://74762673547084" },
	{ "Touch", "rbxassetid://123856214444472" },
	{ "Account", string.format(CONSTANTS.HEADSHOT_IMAGE, Players.LocalPlayer.UserId) }
}
local Tabs = {}
Tabs.__index = Tabs

function Tabs.new(page)
	local self = setmetatable({}, Tabs)
	self.Clicked = Signal.new()
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Tabs")
	self.Background = self.Frame:WaitForChild("Background")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._tab_frames = {}
	self:_Init()
	return self
end

function Tabs:SetPage(p2)
	for k, _tab_frame in pairs(self._tab_frames) do
		local visible = p2 == k
		local title = _tab_frame.Button.Title
		local textColor

		if visible then
			textColor = Color3.fromRGB(0, 0, 0)
		else
			textColor = Color3.fromRGB(255, 255, 255)
		end

		title.TextColor3 = textColor
		local uIStroke = _tab_frame.Button.Title.UIStroke
		local color

		if visible then
			color = Color3.fromRGB(255, 255, 255)
		else
			color = Color3.fromRGB(0, 0, 0)
		end

		uIStroke.Color = color
		_tab_frame.Button.Title.UIStroke.Transparency = visible and 0 or 0.75
		_tab_frame.Button.Background.Visible = visible
	end
end

function Tabs:_UpdateControls()
	self._tab_frames.Touch.Visible = ControlsController.CurrentControls == "Touch"
	self._tab_frames.Hotkeys.Visible = not self._tab_frames.Touch.Visible
end

function Tabs:_Setup()
	for k, list in pairs(v) do
		local text, image = table.unpack(list)
		local clone = settingTabSlot:Clone()
		clone.Button.Title.Text = text
		clone.Button.Icon.Image = image
		clone.LayoutOrder = k
		clone.Parent = self.Container
		self._tab_frames[text] = clone
		clone.Button.MouseButton1Click:Connect(function()
			self.Clicked:Fire(text)
		end)
		ButtonEffect:Add(clone.Button)

		if text ~= "Account" then
			continue
		end

		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = clone.Button.Icon
	end
end

function Tabs:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Background.Size = UDim2.new(0, self.Layout.AbsoluteContentSize.X, 1.25, 0)
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateControls()
	end)
	self:_Setup()
	self:_UpdateControls()
end

return Tabs