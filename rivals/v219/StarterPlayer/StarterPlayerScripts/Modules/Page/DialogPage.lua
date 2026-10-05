local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local dialogButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DialogButton")
local dialogPage = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DialogPage")
local pages = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("Pages")
local object = setmetatable({}, Page)
object.__index = object

function object.new(name)
	local clone = dialogPage:Clone()
	clone.Name = name
	clone.Parent = pages
	local self = setmetatable(Page.new(name), object)
	self.Container = self.PageFrame:WaitForChild("Container")
	self.Background = self.Container:WaitForChild("Background")
	self.Arrow = self.Background:WaitForChild("Arrow")
	self.Message = self.Container:WaitForChild("Message")
	self.Picture = self.Container:WaitForChild("Picture")
	self.ButtonsFrame = self.Container:WaitForChild("Buttons")
	self.HidePartyDisplay = true
	self._close_callback = nil
	self._dialog_buttons = {}
	self._layout_order = 0
	self._buttons_hash = 0
	self._play_dialog_hash = 0
	self._picture_original_size = self.Picture.Size
	self._dialog_actions = {}
	self:_Init()
	return self
end

function object:PlayDialog(data)
	self._play_dialog_hash += 1
	local _ = self._play_dialog_hash

	if data.Message then
		self:_Message(data.Message.Picture, data.Message.Text, data.Message.SoundID)
	else
		self:_Clear()
	end

	if data.Buttons then
		for _, button in pairs(data.Buttons) do
			local _GetButtonAction = self:_GetButtonAction(button.NextDialog, button.DialogActionKey)
			local color = button.IsCloseButton and Color3.fromRGB(255, 50, 50)
			self:_CreateButton(button.Text, _GetButtonAction, color, data.ButtonAppearDelay)
		end
	end

	if data.DelayedContinue then
		task.spawn(function()
			local _play_dialog_hash = self._play_dialog_hash
			wait(data.DelayedContinue.Delay)

			if _play_dialog_hash ~= self._play_dialog_hash then
				return
			end

			self:_GetButtonAction(data.DelayedContinue.NextDialog)()
		end)
	end
end

function object:HookDialogActionKey(p2, p3)
	self._dialog_actions[p2] = p3
end

function object:Open(...)
	Page.Open(self, ...)
	self:_Clear()
end

function object:Close(...)
	self:_Clear()
	Page.Close(self, ...)
end

function object:_FetchDialog(p, ...)
	local _is_open_hash = self._is_open_hash
	local success, result = pcall(p.InvokeServer, p, ...)

	if _is_open_hash ~= self._is_open_hash then
		return
	end

	if not success then
		warn("Failed to fetch dialog, error:", result)
	end

	if success and result then
		self:PlayDialog(result)
	else
		self:CloseRequest()
	end
end

function object:_GetButtonAction(p, p2)
	return function()
		if p then
			self:PlayDialog(p)
		else
			self:CloseRequest()
		end

		if p2 then
			if self._dialog_actions[p2] then
				self._dialog_actions[p2]()
			else
				ReplicatedStorage.Remotes.Misc.DialogAction:FireServer(p2)
			end
		end
	end
end

function object:_CreateButton(text, onMouseButton1Click, p, value)
	self._layout_order += 1
	local v = p or Color3.fromRGB(84, 212, 42)
	local v2 = value or 0
	local clone = dialogButton:Clone()
	clone.Button.BackgroundColor3 = v
	clone.Button.Container.Arrow.ImageColor3 = v
	clone.Button.Container.Title.Text = text
	clone.LayoutOrder = self._layout_order
	clone.Parent = self.ButtonsFrame
	table.insert(self._dialog_buttons, clone)
	local button = clone.Button
	local container = button.Container
	local title = container.Title

	local function update()
		clone.Size = UDim2.new(0, (title.TextBounds.X + container.AbsoluteSize.X) / button.Size.X.Scale, 1, 0)
		title.Position = UDim2.new(1, -clone.AbsoluteSize.X / 2 * button.Size.X.Scale, 0.5, 0)
	end

	container:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	button:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	title:GetPropertyChangedSignal("TextBounds"):Connect(update)
	update()
	button.MouseButton1Click:Connect(onMouseButton1Click)
	ButtonEffect:Add(button)
	task.spawn(function()
		local _buttons_hash = self._buttons_hash
		button.Visible = false
		wait(0.1 * (self._layout_order - 1) + v2)

		if _buttons_hash ~= self._buttons_hash then
			return
		end

		button.Visible = true
		button.Position = UDim2.new(0.75, 0, 0.5, 0)
		button:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.5, true)
	end)
end

function object:_ClearButtons()
	for _, _dialog_button in pairs(self._dialog_buttons) do
		_dialog_button:Destroy()
	end

	self._dialog_buttons = {}
	self._layout_order = 0
	self._buttons_hash += 1
end

function object:_Message(value, value2, p)
	self:_ClearButtons()
	local image = value or ""
	local text = value2 or ""
	self.Message.Text = text
	self.Picture.Image = image
	self.Background.Visible = text ~= "" or image ~= ""
	self.Arrow.Visible = image ~= ""

	if self.Picture:IsDescendantOf(Players) then
		self.Picture.Size = UDim2.new(
			self._picture_original_size.X.Scale * 0.8,
			0,
			self._picture_original_size.Y.Scale * 1.2,
			0
		)
		self.Picture:TweenSize(self._picture_original_size, "Out", "Back", 0.5, true)
	else
		self.Picture.Size = self._picture_original_size
	end

	if p then
		Utility:CreateSound(p, 1, 1, script, true, 10)
	end
end

function object:_Clear()
	self:_Message(nil, nil, nil)
end

function object:_Setup()
	function self._close_callback()
		self:CloseRequest()
	end
end

function object:_Init()
	self:_Setup()
	self:_Clear()
end

return object