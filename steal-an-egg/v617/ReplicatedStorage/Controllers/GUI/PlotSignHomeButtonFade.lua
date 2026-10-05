local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local PlotSignHomeButtonFade = {}
PlotSignHomeButtonFade.__index = PlotSignHomeButtonFade
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function PlotSignHomeButtonFade.new(yourBase)
	local home = yourBase:FindFirstChild("Home")
	assert(home ~= nil, "YourBase.Home must exist")
	assert(home:IsA("ImageButton"), "YourBase.Home must be an ImageButton")
	local object = setmetatable({}, PlotSignHomeButtonFade)
	object._activeTween = nil
	object._home = home
	object._revision = 0
	object._trove = Trove.new()
	object._visible = nil
	object._yourBase = yourBase
	return object
end

function PlotSignHomeButtonFade:SetVisible(visible: boolean)
	if self._visible == visible then
		return
	end

	self._visible = visible
	self._revision += 1
	local _revision = self._revision
	self._trove:Clean()

	if visible then
		self._yourBase.Enabled = true
	end

	local tween = TweenService:Create(self._home, tweenInfo, {
		ImageTransparency = visible and 0 or 1
	})
	self._activeTween = tween
	self._trove:Add(function()
		if self._activeTween == tween then
			tween:Cancel()
			self._activeTween = nil
		end
	end)
	self._trove:Add(tween.Completed:Connect(function(p)
		if self._revision ~= _revision or self._activeTween ~= tween then
			return
		end

		self._activeTween = nil

		if p == Enum.PlaybackState.Completed and not visible then
			self._yourBase.Enabled = false
		end
	end))
	tween:Play()
end

function PlotSignHomeButtonFade:Destroy()
	self._revision += 1
	self._trove:Destroy()
end

return PlotSignHomeButtonFade