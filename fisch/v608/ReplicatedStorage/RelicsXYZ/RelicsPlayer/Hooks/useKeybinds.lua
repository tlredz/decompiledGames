local parent = script.Parent
local useTagged = require(parent.useTagged)
local useAttribute = require(parent.useAttribute)

-- equivalent calls inferred from this helper; original call sites unknown
local function useKeyCode(p, p2: string, p3)
	return useAttribute(p, p2, function(keyCode)
		if typeof(keyCode) == "EnumItem" then
			if keyCode:IsA("KeyCode") then
				return keyCode
			end
		else
			local v = typeof(keyCode) == "string" and Enum.KeyCode:FromName(keyCode)

			if v then
				return v
			end
		end

		return p3 or Enum.KeyCode.Unknown
	end)
end

local function useKeybinds()
	local v = useTagged("RelicsKeybinds")[1]
	local minimize = useKeyCode(v, "Minimize", Enum.KeyCode.N) -- equivalent call inferred; original call site unknown
	local equipWheel = useKeyCode(v, "EquipWheel", Enum.KeyCode.R) -- equivalent call inferred; original call site unknown
	local M = Enum.KeyCode.M
	return {
		Minimize = minimize,
		EquipWheel = equipWheel,
		TogglePlayer = useAttribute(v, "TogglePlayer", function(keyCode)
			if typeof(keyCode) == "EnumItem" then
				if keyCode:IsA("KeyCode") then
					return keyCode
				end
			else
				local v4 = typeof(keyCode) == "string" and Enum.KeyCode:FromName(keyCode)

				if v4 then
					return v4
				end
			end

			return M or Enum.KeyCode.Unknown
		end)
	}
end

return useKeybinds