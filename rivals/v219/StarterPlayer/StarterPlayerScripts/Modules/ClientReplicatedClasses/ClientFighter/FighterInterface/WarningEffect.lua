local TweenService = game:GetService("TweenService")
game:GetService("Players")
local WarningEffect = {}
WarningEffect.__index = WarningEffect

function WarningEffect.new(fighterInterface)
	local self = setmetatable({}, WarningEffect)
	self.FighterInterface = fighterInterface
	self.WarningVignette = self.FighterInterface.Frame:WaitForChild("WarningVignette")
	self.WarningVignetteTexture = self.WarningVignette:WaitForChild("Texture")
	self.WarningVignetteContainer = self.WarningVignette:WaitForChild("Container")
	self.WarningVignetteContainerBackground = self.WarningVignetteContainer:WaitForChild("Frame"):WaitForChild("Container"):WaitForChild("Background")
	self._connections = {}
	self._warning_effect_tweens = {}
	self:_Init()
	return self
end

function WarningEffect:SetEnabled(p, duration)
	self:_Cleanup()
	self.WarningVignette.ImageTransparency = 1
	self.WarningVignette.ImageColor3 = Color3.fromRGB(255, 215, 0)
	self.WarningVignetteTexture.ImageTransparency = 1
	self.WarningVignetteContainer.Visible = false
	self.WarningVignetteContainerBackground.ImageColor3 = Color3.fromRGB(255, 215, 0)

	if not p or duration >= 1e999 then
		return
	end

	local tweenInfo = TweenInfo.new(duration / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(self.WarningVignette, tweenInfo, {
		ImageTransparency = 0
	})
	tween:Play()
	table.insert(self._warning_effect_tweens, tween)
	local tween2 = TweenService:Create(self.WarningVignette, tweenInfo2, {
		ImageColor3 = Color3.fromRGB(255, 50, 50)
	})
	tween2:Play()
	table.insert(self._warning_effect_tweens, tween2)
	local tween3 = TweenService:Create(self.WarningVignetteTexture, tweenInfo, {
		ImageTransparency = 0
	})
	tween3:Play()
	table.insert(self._warning_effect_tweens, tween3)
	local tween4 = TweenService:Create(self.WarningVignetteContainerBackground, tweenInfo2, {
		ImageColor3 = Color3.fromRGB(255, 50, 50)
	})
	tween4:Play()
	table.insert(self._warning_effect_tweens, tween4)
	local thread = task.spawn(function()
		tick()

		while true do
			self.FighterInterface:CreateSound("rbxassetid://114467311328776", 0.5, 1, script, true, 10)
			self.WarningVignette.Container.Visible = true
			wait(0.4)
			self.WarningVignette.Container.Visible = false
			wait(0.15)
		end
	end)
	table.insert(self._warning_effect_tweens, {
		Cancel = function()
			task.cancel(thread)
		end
	})
end

function WarningEffect:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self:_Cleanup()
end

function WarningEffect:_Cleanup()
	for _, _warning_effect_tween in pairs(self._warning_effect_tweens) do
		_warning_effect_tween:Cancel()
	end

	self._warning_effect_tweens = {}
end

function WarningEffect:_Init() end

return WarningEffect