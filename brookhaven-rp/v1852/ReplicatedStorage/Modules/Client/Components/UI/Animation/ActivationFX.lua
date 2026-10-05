local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local TweenService = game:GetService("TweenService")
local v = Component.new({
	Tag = "ActivationFX"
})

function v.Construct(_) end

-- equivalent calls inferred from this helper; original call sites unknown
local function SubtractUDim2(size: UDim2, activationSizeDecrease: UDim2)
	return UDim2.new(
		size.X.Scale - activationSizeDecrease.X.Scale,
		size.X.Offset - activationSizeDecrease.X.Offset,
		size.Y.Scale - activationSizeDecrease.Y.Scale,
		size.Y.Offset - activationSizeDecrease.Y.Offset
	)
end

function v.GetTweenDescriptions(instance)
	local activationFXType = instance:GetAttribute("ActivationFXType") or "Quintic"
	local activationSizeDecrease = instance:GetAttribute("ActivationSizeDecrease") or 0.05
	local v2 = 1 / (instance:GetAttribute("ActivationTweenSpeed") or 1)

	if typeof(activationSizeDecrease) == "number" then
		activationSizeDecrease = UDim2.new(activationSizeDecrease, 0, activationSizeDecrease, 0)
	end

	local size = instance.Size
	local size2 = SubtractUDim2(size, activationSizeDecrease) -- equivalent call inferred; original call site unknown
	local tweenInfo = nil
	local tweenInfo2 = nil

	if activationFXType == "Quintic" then
		tweenInfo = TweenInfo.new(v2 * 0.175, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		tweenInfo2 = TweenInfo.new(v2 * 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	elseif activationFXType == "Back" then
		tweenInfo = TweenInfo.new(v2 * 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		tweenInfo2 = TweenInfo.new(v2 * 0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	elseif activationFXType == "Bouncy" then
		tweenInfo = TweenInfo.new(v2 * 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		tweenInfo2 = TweenInfo.new(v2 * 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut)
	elseif activationFXType == "Rubberband" then
		tweenInfo = TweenInfo.new(v2 * 0.65, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		tweenInfo2 = TweenInfo.new(v2 * 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, v2 * 0.4)
	else
		error((`Invalid ActivationFXType provided to ActivationFX component on instance {instance}: ActivationFXType = "{tostring(activationFXType)}"`))
	end

	return {
		info = tweenInfo,
		properties = {
			Size = size2
		}
	}, {
		info = tweenInfo2,
		properties = {
			Size = size
		}
	}
end

function v.GetActivationTweenCallback(p)
	local tweenDescriptions, v2 = v.GetTweenDescriptions(p)
	return function()
		local tween = TweenService:Create(p, tweenDescriptions.info, tweenDescriptions.properties)
		tween.Completed:Once(function(p2)
			if p2 == Enum.PlaybackState.Completed then
				TweenService:Create(p, v2.info, v2.properties):Play()
			end
		end)
		tween:Play()
		return tween
	end
end

function v:Start()
	assert(self.Instance:IsA("GuiButton"), "ActivationFX must be used on a GuiButton - got " .. self.Instance.ClassName)
	local activationTweenCallback = v.GetActivationTweenCallback(self.Instance)
	self.connection = self.Instance.Activated:Connect(activationTweenCallback)
end

function v:Stop()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

return v