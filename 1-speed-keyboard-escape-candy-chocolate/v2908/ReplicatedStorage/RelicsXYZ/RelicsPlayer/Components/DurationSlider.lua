local parent = script.Parent.Parent
local Util = require(parent.Util)
local State = require(parent.State)
local shared = parent.Parent.Shared
local React = require(shared.React)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)
local useProperty = require(hooks.useProperty)
local useCurrentSong = require(hooks.useCurrentSong)

local function DurationSlider(p)
	local state, setState = React.useState(false)
	local v = React.useContext(State.Context)
	local audioPlayer = v.GetAudioPlayer()
	local setJumpToTime = v.SetJumpToTime
	local ref = React.useRef(nil)
	local v2, v3 = React.useBinding(0)
	local sampleMode = useCurrentSong().SampleMode
	local v4 = useProperty(audioPlayer, function(p2)
		return p2 and p2.TimeLength or 0
	end)
	local samplePreviewRange, v5 = Util.GetSamplePreviewRange(v4)

	if not sampleMode then
		v5 = v4
	end

	local current = ref.current

	if not current then
		if audioPlayer and audioPlayer.IsReady then
			current = audioPlayer.TimePosition
		else
			current = nil
		end
	end

	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local ref4 = React.useRef(nil)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stepTime(p2, p3)
		local parent2 = p2.Parent

		if parent2 and parent2:IsA("GuiObject") then
			local current2 = math.clamp((p3.Position.X - parent2.AbsolutePosition.X) / parent2.AbsoluteSize.X, 0, 1) * v5

			if sampleMode then
				current2 += samplePreviewRange
			end

			ref.current = current2
			v3(current2)
		end
	end

	useClock(10, function()
		if audioPlayer then
			v3(ref.current or audioPlayer.TimePosition)
		end
	end, { audioPlayer, v5 })
	React.useEffect(function()
		local current2 = ref2.current

		if current2 then
			current2.Text = string.format("%02d:%02d", v5 // 60, v5 % 60)
		end
	end, { v5 })
	return React.createElement("Frame", {
		[React.Tag] = Util.ClassNames("Slider", "DurationSlider", p[React.Tag])
	}, {
		Slider = React.createElement("Frame", {
			[React.Tag] = "InnerSlider"
		}, {
			Fill = React.createElement("Frame", {
				[React.Tag] = "Fill",
				Size = v2:map(function(value: number?)
					local v10 = value or 0

					if sampleMode then
						v10 -= samplePreviewRange
					end

					local v11 = math.clamp(v10 / (v5 or 1), 0, 1)
					return UDim2.fromScale(v11, 1)
				end),
				ref = ref4
			}),
			InputCapture = React.createElement("ImageButton", {
				[React.Event.InputBegan] = function(p2, p3)
					if Util.IsPointerInput(p3) then
						stepTime(p2, p3) -- equivalent call inferred; original call site unknown
						setState(true)
					end
				end,
				[React.Event.InputChanged] = function(p2, p3)
					if Util.IsMoveInput(p3) and state then
						stepTime(p2, p3) -- equivalent call inferred; original call site unknown
					end
				end,
				[React.Event.InputEnded] = function(p2, p3)
					if Util.IsMoveInput(p3) and state then
						stepTime(p2, p3) -- equivalent call inferred; original call site unknown
						setJumpToTime(ref.current)
					end

					ref.current = nil
					setState(false)
				end
			}),
			TimePos = React.createElement("TextLabel", {
				[React.Tag] = "TimePos",
				Text = v2:map(function(value: number)
					if sampleMode then
						value -= samplePreviewRange
					end

					local v12 = math.clamp(value, 0, v5)

					if current then
						return (string.format("%02d:%02d", v12 // 60, v12 % 60))
					end

					return "--:--"
				end),
				ref = ref3
			}),
			Duration = React.createElement("TextLabel", {
				[React.Tag] = "Duration",
				Text = not v5 and "--:--" or string.format("%02d:%02d", v5 // 60, v5 % 60),
				ref = ref2
			})
		})
	})
end

return DurationSlider