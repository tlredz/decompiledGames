local parent = script.Parent.Parent
local Util = require(parent.Util)
local State = require(parent.State)
local hooks = parent.Hooks
local useSettings = require(hooks.useSettings)
local useStyleSheet = require(hooks.useStyleSheet)
local shared = parent.Parent.Shared
local React = require(shared.React)
local Settings = require(shared.Settings)
local parent2 = script.Parent
local Button = require(parent2.Button)

local function VolumeSlider(p)
	local v = useStyleSheet("Sounds", "string")
	local state, setState = React.useState(false)
	local v2 = React.useContext(State.Context)
	local localMute = useSettings().LocalMute
	local ref = React.useRef(1)
	local setVolume = v2.SetVolume
	local volume = v2.Volume

	local function stepVolume(p2, p3)
		local parent3 = p2.Parent

		if not (parent3 and parent3:IsA("GuiObject")) then
			return volume
		end

		local audioPlayer = v2.GetAudioPlayer()
		local v3 = math.clamp((p3.Position.X - parent3.AbsolutePosition.X) / parent3.AbsoluteSize.X, 0, 1)
		setVolume(v3)

		if audioPlayer and not audioPlayer.IsPlaying then
			Util.PlaySound(v("Sound-Volume"), parent3, v3 / 60)
		end

		return v3
	end

	React.useEffect(function()
		if localMute then
			if volume > 0 then
				ref.current = volume
			else
				ref.current = 0.5
			end
		elseif volume == 0 then
			setVolume(ref.current)
		end
	end, { localMute })
	return React.createElement("Frame", {
		[React.Tag] = Util.ClassNames("Slider", "VolumeSlider", p[React.Tag])
	}, {
		List = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Mute = React.createElement(Button, {
			[React.Tag] = (localMute or volume == 0) and "VolumeButton Muted" or "VolumeButton",
			OnActivated = function()
				Settings.ChangeSetting("LocalMute", not localMute)
			end
		}),
		Slider = React.createElement("Frame", {
			[React.Tag] = "InnerSlider"
		}, {
			Fill = React.createElement("Frame", {
				[React.Tag] = "Fill",
				Size = UDim2.fromScale(localMute and 0 or volume, 1)
			}),
			InputCapture = React.createElement("ImageButton", {
				[React.Event.InputBegan] = function(p2, p3)
					if Util.IsPointerInput(p3) then
						local v9 = stepVolume(p2, p3)
						setState(true)

						if v9 > 0 then
							Settings.ChangeSetting("LocalMute", false)
						end
					end
				end,
				[React.Event.InputChanged] = function(p2, p3)
					if state and Util.IsMoveInput(p3) then
						stepVolume(p2, p3)
					end
				end,
				[React.Event.InputEnded] = function(p2, p3)
					if Util.IsMoveInput(p3) and state then
						local v9 = stepVolume(p2, p3)
						setState(false)

						if v9 == 0 then
							Settings.ChangeSetting("LocalMute", true)
						end
					end
				end
			})
		})
	})
end

return VolumeSlider