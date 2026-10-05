local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)

local function ScaleMeasure(p)
	local ref = React.useRef()
	local setScale = p.SetScale
	React.useEffect(function()
		local current = ref.current

		if not current then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onAbsoluteSizeChanged()
			local v = current.AbsoluteSize.X / 1000
			setScale(v > 0 and v or 1)
		end

		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(onAbsoluteSizeChanged)
		onAbsoluteSizeChanged() -- equivalent call inferred; original call site unknown
		return function()
			absoluteSizeChangedConnection:Disconnect()
		end
	end, { setScale })
	return React.createElement("Folder", {}, {
		Measure = React.createElement("Frame", {
			Size = UDim2.fromOffset(1000, 0),
			BackgroundTransparency = 0.99999,
			BorderSizePixel = 0,
			ref = ref
		})
	})
end

return ScaleMeasure