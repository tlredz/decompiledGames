local LastInput = require(game.ReplicatedStorage:WaitForChild("Modules").LastInput)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Modules.Util.Signal)
local ViewportOverlay = require(game.ReplicatedStorage.Controllers.UI.ViewportOverlay)
local TextButtonComponent = require(script.Parent.TextButtonComponent)
local ContextActionService = game:GetService("ContextActionService")
game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local v = nil
local v2 = nil
local window = nil
local content = nil
local textLabel = nil
local buttons = nil
local uDim = UDim2.new(0, 400, 0, 250)
local uDim2 = UDim2.new(0.5, 0, 0.5, 0)
local vector = Vector2.new(0.5, 0.5)
local uDim3 = UDim2.new(0.5, 0, 0, -5)
local vector2 = Vector2.new(0.5, 1)
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Circular)

local function fn(flag: boolean, fn2)
	if v then
		v:Cancel()
		v = nil
	end

	if flag then
		window.Position = uDim3
		window.AnchorPoint = vector2

		if fn2 then
			fn2()
		end
	else
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(window, tweenInfo, {
			Position = uDim3,
			AnchorPoint = vector2
		})
		tween:Play()
		tween.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed and fn2 then
				fn2()
			end
		end)
	end
end

local function fn2(flag: boolean, fn3)
	if v then
		v:Cancel()
		v = nil
	end

	if flag then
		window.Position = uDim2
		window.AnchorPoint = vector

		if fn3 then
			fn3()
		end
	else
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(window, tweenInfo2, {
			Position = uDim2,
			AnchorPoint = vector
		})
		tween:Play()
		tween.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed and fn3 then
				fn3()
			end
		end)
		v = tween
	end
end

local class = {}
class.__index = class

function class:SetTitle(text: string)
	textLabel.Text = text
end

function class:SetSize(udim: UDim2)
	if self._Destroyed then
		return
	end

	window.Size = UDim2.fromOffset(udim.X.Offset, udim.Y.Offset)
end

function class:Open(flag: boolean?)
	if self._Destroyed then
		return
	end

	for _, frame in pairs(content:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = true
		end
	end

	ViewportOverlay:SetDisplayOrder(v2.DisplayOrder - 1):Lock("PromptWindow")
	v2.Enabled = true
	fn2(flag == true, function()
		if LastInput:Get() == "Gamepad" then
			GuiService.SelectedObject = buttons
		end
	end)

	local function controllerAction(_: string, p2, p3)
		if p2 ~= Enum.UserInputState.End or p3.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return Enum.ContextActionResult.Pass
		end

		GuiService.SelectedObject = buttons
		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"ControllerPromptAction",
		controllerAction,
		false,
		5,
		Enum.KeyCode.ButtonB
	)
	self._Maid:Add(function()
		ContextActionService:UnbindAction("ControllerPromptAction")
	end)
end

function class:AddTemplate(value)
	if self._Destroyed then
		return
	end

	local clone = nil

	if typeof(value) == "string" then
		clone = assert((v2:FindFirstChild("Templates"):FindFirstChild(value))):Clone()
	elseif typeof(value) == "Instance" then
		clone = value
	end

	assert(clone, "No template found")
	clone.Visible = false
	clone.Parent = content
	return clone
end

function class:AddButton(p: string, p2)
	if self._Destroyed then
		return
	end

	assert(self._Buttons[p] == nil, "Button already exists my guyyyy")
	self._Buttons[p] = self._Maid:Add(TextButtonComponent(nil, p2))
	local instance = self._Buttons[p].Instance
	instance.SelectionGroup = true
	instance.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	instance.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	instance.Parent = buttons

	if LastInput:Get() == "Gamepad" then
		buttons.NextSelectionDown = self._Buttons[p].Instance
		buttons.NextSelectionUp = self._Buttons[p].Instance
	end

	return self._Buttons[p]
end

function class:OnDestroy(callback)
	if self._Destroyed then
		return nil
	end

	return self._Maid:Add(callback)
end

function class:Destroy(flag: boolean?)
	if not self._Destroyed then
		self._Destroyed = true

		if not flag then
			for _, _Button in pairs(self._Buttons) do
				_Button:UpdateProperties({
					Active = false,
					AutoButtonColor = false,
					Selectable = false
				})
			end
		end

		fn(flag == true, function()
			self._Maid:Destroy()
		end)
	end
end

return function(p)
	v2 = p
	window = v2:FindFirstChild("Window")
	content = window:FindFirstChild("Content")
	textLabel = window:FindFirstChild("Title"):FindFirstChild("TextLabel")
	buttons = window:FindFirstChild("Buttons")
	local maid = Trove.new()
	local object = setmetatable({
		_Maid = maid,
		_Destroyed = false,
		_Buttons = {}
	}, class)
	maid:Add(function()
		v2.Enabled = false
		ViewportOverlay:Unlock("PromptWindow")
		object:SetTitle("")
		window.Size = uDim
		textLabel.Text = ""
		table.clear(object._Buttons)

		for _, frame in pairs(content:GetChildren()) do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end
	end)
	return object
end