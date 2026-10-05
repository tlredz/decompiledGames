local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
local parent = script.Parent
local useSignal = require(parent.useSignal)
local useProperty = require(parent.useProperty)
local GuiService = game:GetService("GuiService")

local function useFormFactor()
	local state, setState = React.useState("Desktop")
	local v = useProperty(workspace, function(p)
		return p.CurrentCamera
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		if GuiService:IsTenFootInterface() then
			if state ~= "TenFoot" then
				setState("TenFoot")
			end
		else
			local v2 = v.ViewportSize.Y >= 600 and "Desktop" or "Phone"

			if state ~= v2 then
				setState(v2)
			end
		end
	end

	useSignal(v:GetPropertyChangedSignal("ViewportSize"), update)
	update() -- equivalent call inferred; original call site unknown
	return state
end

return useFormFactor