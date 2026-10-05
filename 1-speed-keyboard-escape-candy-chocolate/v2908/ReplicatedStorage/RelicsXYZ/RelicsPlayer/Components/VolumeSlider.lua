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
	local v2, v3 = React.useBinding(false)
	local v4 = React.useContext(State.Context)
	local localMute = useSettings().LocalMute
	local ref = React.useRef(1)
	local volume = v4.Volume
	local setVolume = v4.SetVolume
	local v5, v6 = React.useBinding(volume)
	React.useEffect(function()
		if not v2:getValue() then
			v6(volume)
		end
	end, { volume })
	local v7 = React.useCallback(function(p2, p3)
		local parent3 = p2.Parent

		if not (parent3 and parent3:IsA("GuiObject")) then
			return volume
		end

		local audioPlayer = v4.GetAudioPlayer()
		local v8 = math.clamp((p3.Position.X - parent3.AbsolutePosition.X) / parent3.AbsoluteSize.X, 0, 1)
		v6(v8)
		setVolume(v8)

		if audioPlayer and not audioPlayer.IsPlaying then
			Util.PlaySound(v("Sound-Volume"), parent3, v8 / 60)
		end

		return v8
	end, { volume })
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
				Size = v5:map(function(p2: number)
					return UDim2.fromScale(localMute and 0 or p2, 1)
				end)
			}),
			InputCapture = React.createElement("ImageButton", {
				[React.Event.InputBegan] = function(p2, p3)
					if Util.IsPointerInput(p3) then
						local v14 = v7(p2, p3)
						v3(true)

						if v14 > 0 then
							Settings.ChangeSetting("LocalMute", false)
						end
					end
				end,
				[React.Event.InputChanged] = function(p2, p3)
					if v2:getValue() and Util.IsMoveInput(p3) then
						v7(p2, p3)
					end
				end,
				[React.Event.InputEnded] = function(p2, p3)
					if Util.IsMoveInput(p3) and v2:getValue() then
						local v14 = v7(p2, p3)
						v3(false)

						if v14 == 0 then
							Settings.ChangeSetting("LocalMute", true)
						end
					end
				end
			})
		})
	})
end

return VolumeSlider