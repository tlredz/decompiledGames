local v = {
	ScreenGui = "Enabled",
	BillboardGui = "Enabled",
	SurfaceGui = "Enabled"
}
return table.freeze({
	Watch = function(parent, callback, callback2)
		if typeof(parent) ~= "Instance" or not parent:IsA("GuiBase") then
			return nil
		end

		local connections = {}
		local result = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function shiftHidden(p: number)
			result.hidden += p

			if result.hidden > 0 and not result.isMuted then
				result.isMuted = true
				callback()
			elseif result.hidden == 0 and result.isMuted then
				result.isMuted = false
				callback2()
			end
		end

		result = {
			hidden = 0,
			links = connections,
			isMuted = false,
			Destroy = function()
				for _, connection in ipairs(connections) do
					connection:Disconnect()
				end

				table.clear(result)
			end
		}

		while parent and parent:IsA("GuiBase") do
			local v2 = v[parent.ClassName] or parent:IsA("GuiObject") and "Visible" or nil

			if v2 then
				if not parent[v2] then
					result.hidden += 1

					if result.hidden > 0 and not result.isMuted then
						result.isMuted = true
						callback()
					elseif result.hidden == 0 and result.isMuted then
						result.isMuted = false
						callback2()
					end
				end

				local v3 = parent
				local v4 = v2
				connections[#connections + 1] = parent:GetPropertyChangedSignal(v2):Connect(function()
					shiftHidden(v3[v4] and -1 or 1) -- equivalent call inferred; original call site unknown
				end)
			end

			parent = parent.Parent
		end

		return result
	end
})