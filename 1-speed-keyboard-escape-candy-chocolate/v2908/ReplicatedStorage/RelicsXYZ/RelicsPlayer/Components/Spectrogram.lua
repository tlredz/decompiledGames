local parent = script.Parent.Parent
local State = require(parent.State)
local shared = parent.Parent.Shared
local React = require(shared.React)
local Ripple = require(shared.Ripple)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)
local v = {
	tension = 300,
	friction = 10
}
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.45, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 0)
})
local anchorPoint = Vector2.yAxis / 2
local color = Color3.fromHex("#FFFFFF")
local uDim = UDim2.fromScale(0.0078125, 1)

local function Spectrogram(p)
	local spectrogram = React.useContext(State.Context).GetSpectrogram()
	local v3, v4 = React.useMemo(function()
		local result = {}
		local children = {}

		for i = 1, 128 do
			local motion = Ripple.createMotion(0.125, v)
			local ref = React.createRef()
			motion:onStep(function(p2)
				local current = ref.current

				if current then
					current.Offset = Vector2.new(0, 0.5 - p2)
				end
			end)
			result[i] = {
				Peak = 0.5 / i,
				Motion = motion
			}
			children[i] = React.createElement("Frame", {
				Position = UDim2.fromScale((i - 1) * 0.0078125, 0.5),
				AnchorPoint = anchorPoint,
				Size = uDim,
				BackgroundColor3 = color,
				BorderSizePixel = 0
			}, {
				Gradient = React.createElement("UIGradient", {
					ref = ref,
					Rotation = 90,
					Transparency = numberSequence
				})
			})
		end

		return result, children
	end, {})
	p.AutoPlay = nil
	useClock(40, function(p2)
		if not spectrogram then
			return
		end

		local spectrum = spectrogram:GetSpectrum()

		for k, v5 in v3 do
			local peak = spectrum[k] or 0

			if v5.Peak < peak then
				v5.Peak = peak
			end

			local v7 = peak / (v5.Peak + 0.0001)
			local motion = v5.Motion
			motion:spring(0.125 + v7 * 0.4, v)
			motion:step(p2)
		end
	end, { spectrogram })
	return React.createElement("CanvasGroup", p, v4, p.children)
end

return Spectrogram