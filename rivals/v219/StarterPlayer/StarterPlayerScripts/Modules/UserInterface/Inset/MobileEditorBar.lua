local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SettingsController"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local InsetButtonsBar = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("InsetButtonsBar"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local insetBarButtonShareBubble = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("InsetBarButtonShareBubble")
local v = {}
local v2 = {
	{ "Close", "Finish editing", "rbxassetid://108220438104376" },
	{ "Settings", "Edit your settings", "rbxassetid://14641612286" },
	{ "Reset", "Double tap to reset this layout", "rbxassetid://81857929131936" },
	{ "Share", "Share & import this layout", "rbxassetid://13733474711" }
}
local MobileEditorBar = {}
MobileEditorBar.__index = MobileEditorBar

function MobileEditorBar.new(inset)
	local self = setmetatable({}, MobileEditorBar)
	self.Inset = inset
	self.Bar = InsetButtonsBar.new(
		UILibrary.BUTTON_BACKGROUND_TRANSPARENCY,
		UILibrary.BUTTON_BACKGROUND_COLOR,
		UILibrary.BUTTON_ICON_COLOR
	)
	self._last_reset_click = 0
	self._reset_button_hash = 0
	self._interruption_internal = Signal.new()
	self._share_bubble_frame = insetBarButtonShareBubble:Clone()
	self._was_from_settings = false
	self:_Init()
	return self
end

function MobileEditorBar:SetVisible(visible, p, p2)
	local was_from_settings

	if visible then
		was_from_settings = self._was_from_settings or p2
	else
		was_from_settings = false
	end

	self._was_from_settings = was_from_settings
	self.Bar.Buttons.Close.Frame.Visible = not self._was_from_settings
	self.Bar.Frame.Visible = visible
	self.Bar.Frame.Size = p or self.Bar.Frame.Size
	self.Bar:Toggle(true)
	self:_CloseButtonAnimation()
	MobileInputs.EditorLogic:SetEnabled(visible)

	if not visible then
		self._interruption_internal:Fire()
	end
end

function MobileEditorBar:_UpdateShareBubblePosition()
	local v3 = self.Bar.Buttons.Share.Frame.AbsolutePosition.X + self.Bar.Buttons.Share.Frame.AbsoluteSize.X / 2 - self.Bar.Frame.AbsolutePosition.X
	self._share_bubble_frame.Position = UDim2.new(0, v3, 0.99, 0)
end

function MobileEditorBar:_CloseButtonAnimation()
	local close = self.Bar.Buttons.Close

	if not close.Frame:IsDescendantOf(Players) then
		close.Frame.Button.Icon.Size = UDim2.new(0.5, 0, 0.5, 0)
		return
	end

	close.Frame.Button.Icon.Size = UDim2.new(0, 0, 0, 0)
	close.Frame.Button.Icon:TweenSize(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.25, true)
end

function MobileEditorBar:_UpdateProfileButtons()
	local mobileButtonSettings = PlayerDataController:Get("MobileButtonSettings")
	local settingsProfile = PlayerDataController:Get("SettingsProfile")

	for k, _ in pairs(mobileButtonSettings) do
		local visible = settingsProfile == k
		local button = self.Bar.Buttons["Profile" .. k]
		button.Frame.Button.IsSelected.Visible = visible
		button.Frame.Button.Title.TextColor3 = visible and self.Bar:GetBackgroundColor() or self.Bar:GetVisualColor()
		button.Frame.Button.Icon.ImageColor3 = visible and self.Bar:GetBackgroundColor() or self.Bar:GetVisualColor()
	end
end

function MobileEditorBar:_Setup()
	for k, list in pairs(v2) do
		self.Bar:CreateButton(k, table.unpack(list))
	end

	local mobileButtonSettings = PlayerDataController:Get("MobileButtonSettings")

	for k, _ in pairs(mobileButtonSettings) do
		local button = self.Bar:CreateButton(#v2 + k, "Profile" .. k, "Switch to layout #" .. k, k)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Size = UDim2.new(0.75, 0, 0.75, 0)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.ZIndex = 0
		frame.Name = "IsSelected"
		frame.BackgroundColor3 = self.Bar:GetVisualColor()
		frame.Parent = button.Frame.Button
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = frame
		local v3 = k
		button.Clicked:Connect(function()
			MobileInputs:SwitchProfile(v3)
		end)
	end

	for k, v3 in pairs(v) do
		local v4 = SettingsLibrary.Info[v3]
		local button = self.Bar:CreateButton(#v2 + #mobileButtonSettings + k, "Settings" .. k, nil, v4.Image)
		local v5 = v3
		button.Clicked:Connect(function()
			SettingsController:ChangeSetting(v5, not PlayerDataController:GetSetting(v5))
		end)
		local count = 0
		local v6 = v3

		local function update_value(p)
			self._interruption_internal:Fire(v6)
			count += 1
			local setting = PlayerDataController:GetSetting(v6)
			button.Frame.Button.Icon.ImageColor3 = setting and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(
				255,
				50,
				50
			)
			local v10

			if p then
				v10 = string.format(
					"%s <font weight=\"900\" color=\"rgb(%s)\">%s</font>",
					v4.DisplayName,
					setting and "100,255,50" or "255,50,50",
					setting and "ON" or "OFF"
				)
			end

			button:PlayBubbleEffect(v10)
		end

		local update_value2 = update_value
		PlayerDataController:GetSettingChangedSignal(v3):Connect(function()
			update_value2(true)
		end)
		update_value(false)
		local v9 = v3
		local v10 = button
		self._interruption_internal:Connect(function(p)
			if p ~= v9 then
				v10:PlayBubbleEffect(nil)
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close_bar()
		self:SetVisible(false)
		self.Inset.MainBar:SetVisible(true, self.Bar.Frame.Size)
	end

	self.Bar.Buttons.Close.Clicked:Connect(function()
		close_bar() -- equivalent call inferred; original call site unknown
	end)
	self.Bar.Buttons.Settings.Clicked:Connect(function()
		close_bar() -- equivalent call inferred; original call site unknown
		Pages.PageSystem:OpenPage("Settings", true)
		Pages.PageSystem:WaitForPage("Settings"):SetPage("Touch")
	end)
	self.Bar.Buttons.Reset.Clicked:Connect(function()
		if tick() > self._last_reset_click + 0.5 then
			self._last_reset_click = tick()
			return
		end

		self._reset_button_hash += 1
		local _reset_button_hash = self._reset_button_hash
		task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 5, function(p)
			if self._reset_button_hash ~= _reset_button_hash then
				return true
			end

			local v4 = 1 - (1 - p / 100) ^ 3
			self.Bar.Buttons.Reset.Frame.Button.Icon.Rotation = -360 * (1 - v4)
		end)
		MobileInputs.EditorLogic:ResetLayout()
	end)
	self.Bar.Buttons.Share.Clicked:Connect(function()
		self._share_bubble_frame.Import.Box.Text = ""
		self._share_bubble_frame.Export.Text = MobileInputs.Buttons:EncryptProfile()
		self._share_bubble_frame.ExportTitle.Text = "Share layout #" .. PlayerDataController:Get("SettingsProfile") .. " by copying this: "
		self._share_bubble_frame.Visible = true
		self._interruption_internal:Fire("Share")
	end)
	self.Bar.Buttons.Share.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateShareBubblePosition()
	end)
	self.Bar.Buttons.Share.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateShareBubblePosition()
	end)
	self._interruption_internal:Connect(function(p)
		if p ~= "Share" then
			self._share_bubble_frame.Visible = false
		end
	end)
	self._share_bubble_frame.Parent = self.Bar.Frame
	self.Bar.Frame.Parent = self.Inset.LeftButtonsFrame
end

function MobileEditorBar:_Init()
	self.Bar.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateShareBubblePosition()
	end)
	self._share_bubble_frame.Close.MouseButton1Click:Connect(function()
		self._share_bubble_frame.Visible = false
	end)
	self._share_bubble_frame.Import.Button.MouseButton1Click:Connect(function()
		MobileInputs.EditorLogic:ImportProfile(self._share_bubble_frame.Import.Box.Text)
	end)
	PlayerDataController:GetDataChangedSignal("MobileButtonSettings"):Connect(function()
		self:_UpdateProfileButtons()
	end)
	PlayerDataController:GetDataChangedSignal("SettingsProfile"):Connect(function()
		self:_UpdateProfileButtons()
	end)
	self:_Setup()
	self:_UpdateProfileButtons()
	self:_UpdateShareBubblePosition()
	self:SetVisible(false)
	ButtonEffect:Add(self._share_bubble_frame.Import.Button, true)
end

return MobileEditorBar