local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local ColorsUtil = require(ReplicatedStorage.Common.ColorsUtil)
return Observers.observeTagNoAncestry("UI_AssignGradient", function(parent)
	local maid = Utils.Maid.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateColor(p: string)
		if not p then
			maid.Color = nil
			return
		end

		local colorGradient = ColorsUtil:GetColorGradient(p)

		if colorGradient then
			colorGradient.Parent = parent
		end

		maid.Color = colorGradient
	end

	local gradientColor = parent:GetAttribute("GradientColor")

	if gradientColor then
		local colorGradient = ColorsUtil:GetColorGradient(gradientColor)

		if colorGradient then
			colorGradient.Parent = parent
		end

		maid.Color = colorGradient
	else
		UpdateColor() -- equivalent call inferred; original call site unknown
	end

	maid.OnGradientColorChange = parent:GetAttributeChangedSignal("GradientColor"):Connect(UpdateColor)
	return function()
		maid:Destroy()
	end
end)