local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local TweenService = game:GetService("TweenService")
local v = Component.new({
	Tag = "HoverFX"
})

function v.Construct(_) end

local function AddUDim2(udim: UDim2, udim2: UDim2)
	return UDim2.new(
		udim.X.Scale + udim2.X.Scale,
		udim.X.Offset + udim2.X.Offset,
		udim.Y.Scale + udim2.Y.Scale,
		udim.Y.Offset + udim2.Y.Offset
	)
end

function v.GetTweenDescriptions(instance)
	local hoverFXType = instance:GetAttribute("HoverFXType") or "Back"
	local hoverSizeIncrease = instance:GetAttribute("HoverSizeIncrease") or 0.05
	local hoverTweenSpeed = instance:GetAttribute("HoverTweenSpeed") or 1

	if typeof(hoverSizeIncrease) == "number" then
		hoverSizeIncrease = UDim2.new(hoverSizeIncrease, 0, hoverSizeIncrease, 0)
	end

	local fn = nil
	local v2 = nil

	if hoverFXType == "Back" then
		fn = {
			info = TweenInfo.new(hoverTweenSpeed * 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			properties = 0
		}
		local size = instance.Size
		local v4 = hoverSizeIncrease
		fn.properties = {
			Size = UDim2.new(
				size.X.Scale + v4.X.Scale,
				size.X.Offset + v4.X.Offset,
				size.Y.Scale + v4.Y.Scale,
				size.Y.Offset + v4.Y.Offset
			)
		}
		v2 = {
			info = TweenInfo.new(hoverTweenSpeed * 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			properties = {
				Size = instance.Size
			}
		}
	elseif hoverFXType == "Rubberband" then
		fn = {
			info = TweenInfo.new(hoverTweenSpeed * 0.65, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
			properties = 0
		}
		local size = instance.Size
		local v4 = hoverSizeIncrease
		fn.properties = {
			Size = UDim2.new(
				size.X.Scale + v4.X.Scale,
				size.X.Offset + v4.X.Offset,
				size.Y.Scale + v4.Y.Scale,
				size.Y.Offset + v4.Y.Offset
			)
		}
		v2 = {
			info = TweenInfo.new(hoverTweenSpeed * 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			properties = {
				Size = instance.Size
			}
		}
	elseif hoverFXType == "Bouncy" then
		fn = {
			info = TweenInfo.new(hoverTweenSpeed * 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
			properties = 0
		}
		local size = instance.Size
		local v4 = hoverSizeIncrease
		fn.properties = {
			Size = UDim2.new(
				size.X.Scale + v4.X.Scale,
				size.X.Offset + v4.X.Offset,
				size.Y.Scale + v4.Y.Scale,
				size.Y.Offset + v4.Y.Offset
			)
		}
		v2 = {
			info = TweenInfo.new(hoverTweenSpeed * 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			properties = {
				Size = instance.Size
			}
		}
	elseif hoverFXType == "GrowRotate" then
		local hoverFXTypeModifier = instance:GetAttribute("HoverFXTypeModifier") or 10

		fn = function()
			local tweenInfo = TweenInfo.new(hoverTweenSpeed * 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local size = instance.Size
			local v6 = hoverSizeIncrease
			TweenService:Create(instance, tweenInfo, {
				Size = UDim2.new(
					size.X.Scale + v6.X.Scale,
					size.X.Offset + v6.X.Offset,
					size.Y.Scale + v6.Y.Scale,
					size.Y.Offset + v6.Y.Offset
				),
				Rotation = instance.Rotation + math.random(-hoverFXTypeModifier * 100, hoverFXTypeModifier * 100) / 100
			}):Play()
		end

		v2 = {
			info = TweenInfo.new(hoverTweenSpeed * 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			properties = {
				Size = instance.Size,
				Rotation = instance.Rotation
			}
		}
	else
		error((`Invalid HoverFXType provided to HoverFX component on instance {instance}: HoverFXType = "{tostring(hoverFXType)}"`))
	end

	return fn, v2
end

function v:Start()
	assert(self.Instance:IsA("GuiObject"), "HoverFX must be used on a GuiObject - got " .. self.Instance.ClassName)
	local tweenDescriptions, hoverEnd = v.GetTweenDescriptions(self.Instance)
	self.connections = UIAnimationEffects.ConnectButtonHoverAndActivationFX(self.Instance, self.Instance, {
		Hover = tweenDescriptions,
		HoverEnd = hoverEnd
	})
end

function v:Stop()
	if self.connections then
		for _, connection in self.connections do
			connection:Disconnect()
		end

		self.connections = nil
	end
end

return v