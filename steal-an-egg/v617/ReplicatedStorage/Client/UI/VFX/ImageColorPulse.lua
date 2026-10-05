local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Log = require(ReplicatedStorage.Packages.Log)
local t = require(ReplicatedStorage.Packages.t)
local _ = {
	fromScale = 0.9,
	toScale = 1.15,
	restScale = 1,
	sharedScaleAttribute = "PressScaleOwner"
}
local v = Log.new()

local function beginPulse(parent, color: Color3, p)
	t.strict(t.instanceIsA("GuiButton"))(parent)
	t.strict(t.Color3)(color)
	t.strict(t.TweenInfo)(p)
	local imageColor3 = parent.ImageColor3
	local uIScale = Instance.new("UIScale")
	uIScale.Parent = parent
	uIScale.Scale = 0.9
	local v2 = { TweenService:Create(uIScale, p, {
			Scale = 1.15
		}), TweenService:Create(parent, p, {
			ImageColor3 = color
		}) }

	for _, v3 in v2 do
		v3:Play()
	end

	v:AtTrace():Log("image pulse running")
	local v3 = false

	local function settle()
		if not v3 then
			v3 = true

			for _, v4 in v2 do
				v4:Cancel()
			end

			parent.ImageColor3 = imageColor3
			uIScale.Scale = 1

			if not uIScale:GetAttribute("PressScaleOwner") then
				uIScale:Destroy()
			end

			v:AtTrace():Log("image pulse stopped")
		end
	end

	return settle
end

return {
	Start = beginPulse
}