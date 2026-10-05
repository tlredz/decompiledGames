local parent = script.Parent.Parent
local Story = require(parent.Story)
local CoreGui = game:GetService("CoreGui")
local components = parent.Components
local MainWindow = require(components.MainWindow)
local EquipWheelController = require(components.EquipWheelController)
local shared = parent.Parent.Shared
local State = require(parent.State)
local React = require(shared.React)

local function CustomStory(props)
	local v = React.useContext(State.Context)
	local ref = React.useRef(nil)
	local state, setState = React.useState(CoreGui)
	React.useEffect(function()
		local current = ref.current
		local parent2 = current and current.Parent

		if parent2 then
			setState(parent2)
		end

		v.SetEquipWheelOpen(true)
	end, {})
	return React.createElement(React.Fragment, nil, {
		Probe = React.createElement("Configuration", {
			ref = ref
		}),
		MainWindow = React.createElement(MainWindow, {
			AnchorPoint = props.AnchorPoint,
			Position = props.Position,
			Scale = props.Scale
		}),
		EquipWheel = React.createElement(EquipWheelController, {
			Root = state
		}),
		OpenWheel = React.createElement("TextButton", {
			Text = "Toggle Equip Wheel",
			Size = UDim2.fromOffset(200, 50),
			[React.Event.Activated] = function()
				v.SetEquipWheelOpen(not v.EquipWheelOpen)
			end
		})
	})
end

return Story.Custom(CustomStory)