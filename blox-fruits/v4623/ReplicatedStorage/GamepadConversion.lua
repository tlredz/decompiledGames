local UserInputService = game:GetService("UserInputService")
local v = {
	[Enum.KeyCode.ButtonX] = { Enum.KeyCode.Z, "Z", "X" },
	[Enum.KeyCode.ButtonY] = { Enum.KeyCode.X, "X", "Y" },
	[Enum.KeyCode.ButtonB] = { Enum.KeyCode.C, "C", "B" },
	[Enum.KeyCode.ButtonL2] = { Enum.KeyCode.V, "V", "L2" },
	[Enum.KeyCode.DPadRight] = { Enum.KeyCode.F, "F", "Right" }
}
local GamepadConversion = {}
GamepadConversion.template = script.Template

function GamepadConversion.changeBtns(value)
	if type(value) == "string" then
		for k, v3 in pairs(v) do
			if v3[2] ~= value:upper() then
				continue
			end

			value = k
			break
		end
	end

	for k, v2 in pairs(v) do
		if k == value or v2[1] == value then
			return k, v2[1], v2[2], v2[3], v2[4]
		end
	end
end

function GamepadConversion.getImg(value)
	if type(value) == "string" then
		for k, v3 in pairs(v) do
			if v3[2] ~= value:upper() then
				continue
			end

			value = k
			break
		end
	end

	for k, v2 in pairs(v) do
		if not (k == value or v2[1] == value) then
			continue
		end

		local v3 = k
		local success, result = pcall(function()
			return UserInputService:GetImageForKeyCode(v3)
		end)
		return not success and "" or result
	end
end

function GamepadConversion.getButtons()
	local result = {}

	for k, _ in pairs(v) do
		table.insert(result, k)
	end

	return result
end

return GamepadConversion