local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local completed = Enum.PlaybackState.Completed
local v = {
	fadeSeconds = 0.2,
	easing = Enum.EasingStyle.Quad,
	direction = Enum.EasingDirection.Out,
	shown = {
		OutlineTransparency = 0
	},
	hidden = {
		OutlineTransparency = 1
	},
	restingLook = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		FillColor = Color3.fromRGB(255, 255, 255),
		FillTransparency = 1,
		OutlineColor = Color3.fromRGB(255, 255, 255),
		OutlineTransparency = 1
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function glide(highlight, hidden, p: number?)
	local tween = TweenService:Create(highlight, TweenInfo.new(p or v.fadeSeconds, v.easing, v.direction), hidden)
	tween:Play()
	return tween
end

local function raise(p, name: string, p2: number?)
	t.strict(t.instanceIsA("Model"))(p)
	t.strict(t.string)(name)
	t.strict(t.optional(t.number))(p2)
	local restingLook = v.restingLook
	local highlight = Instance.new("Highlight")

	for k, v2 in restingLook do
		highlight[k] = v2
	end

	highlight.Adornee = p
	highlight.Name = name
	highlight.Parent = p
	local shown = v.shown
	TweenService:Create(highlight, TweenInfo.new(p2 or v.fadeSeconds, v.easing, v.direction), shown):Play()
	return highlight
end

local function lower(highlight, p: number?)
	assert(highlight:IsA("Highlight"), "fade-out was handed something that is not a Highlight")
	t.strict(t.optional(t.number))(p)

	local function reap(p2)
		if p2 == completed then
			highlight:Destroy()
		end
	end

	;(glide(highlight, v.hidden, p)).Completed:Once(reap)
end

return {
	FadeIn = raise,
	FadeOut = lower
}