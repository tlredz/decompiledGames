local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GUI = require(ReplicatedStorage.Client.GUI)
local TutorialProp = require(script.Parent.TutorialProp)
local t = require(ReplicatedStorage.Packages.t)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local uDim = UDim2.fromScale(0.01, 0.01)
local v = { "AbsolutePosition", "AbsoluteSize" }
local strict = t.strict(t.instanceIsA("GuiObject"))

local function ringGoal(instance, clone)
	local absoluteSize = instance.AbsoluteSize
	local v2 = instance.AbsolutePosition + absoluteSize * 0.5 - clone.AbsolutePosition
	return {
		Size = UDim2.new(0, absoluteSize.X * 1.15, 0, absoluteSize.Y * 1.15),
		Position = UDim2.new(0, v2.X, 0, v2.Y)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tutorialLayerHost()
	local screenGui = GUI.TutorialInstructions()
	assert(screenGui:IsA("ScreenGui"), "the tutorial instruction layer is not a ScreenGui")
	local parent = screenGui.Parent
	assert(parent and parent:IsA("PlayerGui"), "the tutorial instruction layer sits outside PlayerGui")
	return parent
end

return {
	Attach = function(instance)
		strict(instance)
		local clone, maid = TutorialProp.Clone("ClickTarget", "GuardTutorialHighlight")
		clone.Enabled = true
		clone.Parent = tutorialLayerHost()
		local container = clone.Container
		assert(container:IsA("Frame"), "the highlight template has no Container frame")
		container.Size = uDim
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function discard()
			if v2 then
				v2:Cancel()
				v2:Destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reseat()
			local v3 = ringGoal(instance, clone)
			discard() -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(container, tweenInfo, v3)
			v2 = tween
			tween:Play()
		end

		reseat() -- equivalent call inferred; original call site unknown

		for _, propertyName in v do
			maid:Add(instance:GetPropertyChangedSignal(propertyName):Connect(reseat))
		end

		maid:Add(clone:GetPropertyChangedSignal("AbsolutePosition"):Connect(reseat))
		maid:Add(discard)
		return TutorialProp.Teardown("Removing the tutorial highlight ring", maid)
	end
}