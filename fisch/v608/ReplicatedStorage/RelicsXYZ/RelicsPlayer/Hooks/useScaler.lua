local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)

local function useScaler(instance, value: number?)
	local state, setState = React.useState(nil)
	local v = value or 720
	local state2, setState2 = React.useState(0)
	React.useEffect(function()
		if not instance then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onAncestryChanged()
			local parent = instance.Parent

			if parent and parent:IsA("GuiObject") then
				setState(parent)
			else
				setState(nil)
			end
		end

		local ancestryChangedConnection = instance.AncestryChanged:Connect(onAncestryChanged)
		onAncestryChanged() -- equivalent call inferred; original call site unknown
		return function()
			ancestryChangedConnection:Disconnect()
		end
	end, { instance })
	React.useEffect(function()
		if not state then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateScale()
			local absoluteSize = state.AbsoluteSize
			local X = absoluteSize.X
			local Y = absoluteSize.Y
			local v2 = 1 / v
			local v3

			if Y < X then
				v3 = v2 * Y
			else
				v3 = v2 * X
			end

			setState2(v3)
		end

		updateScale() -- equivalent call inferred; original call site unknown
		local absoluteSizeChangedConnection = state:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
		return function()
			absoluteSizeChangedConnection:Disconnect()
		end
	end, { v, state })
	return state2
end

return useScaler