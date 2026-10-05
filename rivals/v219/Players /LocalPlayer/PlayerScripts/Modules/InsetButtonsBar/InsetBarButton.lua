local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local insetBarButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("InsetBarButton")
local InsetBarButton = {}
InsetBarButton.__index = InsetBarButton

function InsetBarButton.new(name, display_name, visual, visual_position, visual_size, visual_color, is_mirrored)
	local self = setmetatable({}, InsetBarButton)
	self.Clicked = Signal.new()
	self.Entered = Signal.new()
	self.Name = name
	self.Frame = insetBarButton:Clone()
	self._display_name = display_name
	self._visual = visual
	self._visual_position = visual_position
	self._visual_size = visual_size
	self._visual_color = visual_color
	self._is_mirrored = is_mirrored
	self._bubble_effect_hash = 0
	self._bubble_effect_playing = false
	self._original_icon_size = nil
	self:_Init()
	return self
end

function InsetBarButton:SetMirrored(is_mirrored)
	if is_mirrored == self._is_mirrored then
		return
	end

	self._is_mirrored = is_mirrored
	self:_UpdateMirrored()
end

function InsetBarButton:Enter()
	if self._bubble_effect_playing then
		return
	end

	self.Frame.Button.OnHover.Visible = true
	self.Entered:Fire()
end

function InsetBarButton:Leave()
	if self._bubble_effect_playing then
		return
	end

	self.Frame.Button.OnHover.Visible = false
end

function InsetBarButton.SetBubbleText(p, text)
	p.Frame.Button.OnHover.Bubble.Container.Title.Text = text
end

function InsetBarButton:PlayJiggleEffect()
	self.Frame.Button.Icon.Size = UDim2.new(
		self._original_icon_size.X.Scale * 1.5,
		self._original_icon_size.X.Offset * 1.5,
		self._original_icon_size.Y.Scale * 1.5,
		self._original_icon_size.Y.Offset * 1.5
	)
	self.Frame.Button.Icon:TweenSize(self._original_icon_size, "Out", "Back", 0.25, true)
end

function InsetBarButton:PlayBubbleEffect(text)
	self._bubble_effect_hash += 1
	local _bubble_effect_hash = self._bubble_effect_hash

	if not text then
		self:_DisableBubbleEffect()
		return
	end

	self._bubble_effect_playing = true
	self.Frame.Button.OnHover.Visible = true
	self.Frame.Button.OnHover.Bubble.Visible = true
	self.Frame.Button.OnHover.Bubble.Container.Title.Text = text
	task.delay(3, function()
		wait(3)

		if _bubble_effect_hash ~= self._bubble_effect_hash or not self.Frame:IsDescendantOf(Players) then
			return
		end

		self:_DisableBubbleEffect()
	end)
end

function InsetBarButton:Destroy()
	self.Clicked:Destroy()
	self.Entered:Destroy()
	pcall(function()
		self.Frame:Destroy()
	end)
end

function InsetBarButton:_DisableBubbleEffect()
	self:_ResetBubbleVisibility()
	self._bubble_effect_playing = false
	self:Leave()
end

function InsetBarButton:_ResetBubbleVisibility()
	self.Frame.Button.OnHover.Bubble.Visible = self._display_name ~= nil
end

function InsetBarButton:_UpdateBubble()
	self.Frame.Button.OnHover.Bubble.Container.Background.Size = UDim2.new(
		0.25,
		self.Frame.Button.OnHover.Bubble.Container.Title.TextBounds.X,
		1,
		0
	)
end

function InsetBarButton:_UpdateBubbleContainer()
	local v = 1

	for i = 1, #self.Frame.Button.OnHover.Bubble.Container.Title.Text do
		if string.sub(self.Frame.Button.OnHover.Bubble.Container.Title.Text, i, i) ~= "\n" then
			continue
		end

		v += 1
	end

	self.Frame.Button.OnHover.Bubble.Container.Size = UDim2.new(3.25, 0, v * 0.75, 0)
	self.Frame.Button.OnHover.Bubble.Container.Arrow.Size = UDim2.new(0.5 / v, 0, 0.5 / v, 0)
	self:_UpdateBubble()
end

function InsetBarButton:_UpdateMirrored()
	self.Frame.Button.OnHover.Bubble.Container.Title.AnchorPoint = self._is_mirrored and Vector2.new(1, 0.5) or Vector2.new(
		0,
		0.5
	)
	self.Frame.Button.OnHover.Bubble.Container.Title.Position = self._is_mirrored and UDim2.new(0.875, 0, 0.5, 0) or UDim2.new(
		0.125,
		0,
		0.5,
		0
	)
	self.Frame.Button.OnHover.Bubble.Container.Title.TextXAlignment = self._is_mirrored and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
	self.Frame.Button.OnHover.Bubble.Container.Background.AnchorPoint = self._is_mirrored and Vector2.new(1, 0.5) or Vector2.new(
		0,
		0.5
	)
	self.Frame.Button.OnHover.Bubble.Container.Background.Position = self._is_mirrored and UDim2.new(1, 0, 0.5, 0) or UDim2.new(
		0,
		0,
		0.5,
		0
	)
	self.Frame.Button.OnHover.Bubble.Container.Arrow.Position = self._is_mirrored and UDim2.new(0.75, 0, 0, 2) or UDim2.new(
		0.25,
		0,
		0,
		2
	)
	self.Frame.Button.OnHover.Bubble.Container.AnchorPoint = self._is_mirrored and Vector2.new(0.75, 0) or Vector2.new(
		0.25,
		0
	)
end

function InsetBarButton:_Setup()
	local v

	if typeof(self._visual) == "string" and #self._visual >= 13 then
		v = string.sub(self._visual, 1, 13) == "rbxassetid://"
	else
		v = false
	end

	self.Frame.Button.Icon.Image = not v and "" or self._visual or ""
	self.Frame.Button.Icon.Position = self._visual_position or UDim2.new(0.5, 0, 0.5, 0)
	self.Frame.Button.Icon.Size = self._visual_size or UDim2.new(0.5, 0, 0.5, 0)
	self.Frame.Button.Title.Position = self._visual_position or UDim2.new(0.5, 0, 0.5, 0)
	self.Frame.Button.Title.Size = self._visual_size or UDim2.new(0.5, 0, 0.5, 0)
	self.Frame.Button.Title.Text = v and "" or self._visual or ""
	self.Frame.Button.Title.TextColor3 = self._visual_color
	self.Frame.Button.Icon.ImageColor3 = self._visual_color
	self.Frame.Button.OnHover.Visible = false
	self.Frame.Button.OnHover.BackgroundTransparency = 0.75
	self.Frame.Button.OnHover.Bubble.Container.Title.Text = self._display_name or ""
	self._original_icon_size = self.Frame.Button.Icon.Size
end

function InsetBarButton:_Init()
	self.Frame.Destroying:Connect(function()
		self:Destroy()
	end)
	self.Frame.Button.MouseButton1Click:Connect(function()
		self.Clicked:Fire()
	end)
	self.Frame.MouseEnter:Connect(function()
		self:Enter()
	end)
	self.Frame.MouseLeave:Connect(function()
		self:Leave()
	end)
	self.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Leave()
	end)
	self.Frame.Button.OnHover.Bubble.Container.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateBubble()
	end)
	self.Frame.Button.OnHover.Bubble.Container.Title:GetPropertyChangedSignal("Text"):Connect(function()
		self:_UpdateBubbleContainer()
	end)
	self:_Setup()
	self:_UpdateMirrored()
	self:_UpdateBubble()
	self:_ResetBubbleVisibility()
	self:_UpdateBubbleContainer()
	self:Leave()
	ButtonEffect:Add(self.Frame.Button, true)
end

return InsetBarButton