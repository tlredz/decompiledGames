local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(script.Types.Interface)
local color = Color3.fromRGB(191, 0, 3)
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ScreenEffects = {}
ScreenEffects.__index = ScreenEffects
ScreenEffects.__class = "GuardRunBackEffects"

function ScreenEffects.new()
	local self = setmetatable({}, ScreenEffects)
	local runBackEffects = playerGui:WaitForChild("RunBackEffects")
	assert(runBackEffects:IsA("ScreenGui"), "PlayerGui.RunBackEffects must be a ScreenGui")
	local run = runBackEffects:WaitForChild("Run")
	assert(run:IsA("GuiObject"), "RunBackEffects.Run must be a GuiObject")
	local blur = runBackEffects:WaitForChild("Blur")
	assert(blur:IsA("ImageLabel"), "RunBackEffects.Blur must be an ImageLabel")
	self._activeSerial = 0
	self._blurOriginalTransparency = blur.ImageTransparency
	self._blurTween = nil
	self._runOriginalColor = run.BackgroundColor3
	self._runTween = nil
	self._widgets = {
		Blur = blur,
		Run = run,
		ScreenGui = runBackEffects
	}
	self:_init()
	return self
end

function ScreenEffects:_cancelTweens()
	local _blurTween = self._blurTween

	if _blurTween ~= nil then
		_blurTween:Cancel()
		_blurTween:Destroy()
	end

	self._blurTween = nil
	local _runTween = self._runTween

	if _runTween ~= nil then
		_runTween:Cancel()
		_runTween:Destroy()
	end

	self._runTween = nil
end

function ScreenEffects:_resetVisualState()
	local _widgets = self._widgets
	_widgets.Blur.Visible = true
	_widgets.Blur.ImageTransparency = self._blurOriginalTransparency
	_widgets.Run.BackgroundColor3 = self._runOriginalColor
	_widgets.ScreenGui.Enabled = false
end

function ScreenEffects:_playCycle(p: number, flag: boolean)
	if p ~= self._activeSerial then
		return
	end

	local _widgets = self._widgets
	local imageTransparency = flag and 1 or self._blurOriginalTransparency
	local _runOriginalColor

	if flag then
		_runOriginalColor = color
	else
		_runOriginalColor = self._runOriginalColor
	end

	self:_cancelTweens()
	local tween = TweenService:Create(_widgets.Blur, tweenInfo, {
		ImageTransparency = imageTransparency
	})
	local tween2 = TweenService:Create(_widgets.Run, tweenInfo, {
		BackgroundColor3 = _runOriginalColor
	})
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween2.Completed:Once(function()
		tween2:Destroy()
	end)
	self._blurTween = tween
	self._runTween = tween2
	tween:Play()
	tween2:Play()
	task.spawn(function()
		tween.Completed:Wait()

		if p ~= self._activeSerial then
			return
		end

		self:_playCycle(p, not flag)
	end)
end

function ScreenEffects:Start(flag: boolean?)
	self._activeSerial += 1
	local _widgets = self._widgets
	_widgets.ScreenGui.Enabled = true
	_widgets.Blur.Visible = flag ~= true
	_widgets.Blur.ImageTransparency = self._blurOriginalTransparency
	_widgets.Run.BackgroundColor3 = self._runOriginalColor
	self:_playCycle(self._activeSerial, true)
end

function ScreenEffects:Stop()
	self._activeSerial += 1
	self:_cancelTweens()
	self:_resetVisualState()
end

function ScreenEffects:_init()
	self:Stop()
end

return ScreenEffects