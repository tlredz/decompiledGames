local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(frame, tweenInfo, p)
	local tween = TweenService:Create(frame, tweenInfo, p)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

script.Parent.Parent.ChildAdded:Connect(function(child)
	if not table.find({
		"grab",
		"stab",
		"reel",
		"harpoonMinigame"
	}, child.Name) then
		return
	end

	fastTween(script.Parent.Frame, TweenInfo.new(0.5), {
		BackgroundTransparency = 0.5
	}) -- equivalent call inferred; original call site unknown
	child.AncestryChanged:Once(function()
		fastTween(script.Parent.Frame, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown
	end)
end)