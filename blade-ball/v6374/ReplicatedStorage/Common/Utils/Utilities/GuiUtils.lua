local Signal = require(script.Parent.Signal)
local GuiUtils = {
	IsGuiObjectVisible = function(_, instance)
		local parent = instance

		while parent do
			if parent:IsA("ScreenGui") then
				if not parent.Enabled then
					warn(instance:GetFullName(), "not visible1")
					return false
				end
			elseif parent:IsA("GuiObject") then
				if not parent.Visible then
					warn(instance:GetFullName(), "not visible2")
					return false
				end
			else
				if parent:IsA("PlayerGui") then
					return true
				end

				if (parent:IsA("SurfaceGui") or parent:IsA("BillboardGui")) and parent.Enabled and parent:IsDescendantOf(workspace) and parent.Adornee and parent.Adornee.Parent then
					return true
				end
			end

			parent = parent.Parent
		end

		return true
	end
}
local v = {}
setmetatable(v, {
	__mode = "kv"
})

function GuiUtils.getActivatedSignal(p)
	local v2 = v[p]

	if not v2 then
		v2 = Signal.new()
		p.Activated:Connect(function()
			v2:Fire()
		end)
		v[p] = v2
	end

	return v2
end

function GuiUtils.mirrorActivated(p, p2)
	local activatedSignal = GuiUtils.getActivatedSignal(p2)
	return p.Activated:Connect(function()
		activatedSignal:Fire()
	end)
end

return GuiUtils