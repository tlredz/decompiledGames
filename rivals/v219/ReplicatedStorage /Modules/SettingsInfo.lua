local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local SettingsInfo = {}
SettingsInfo.__index = SettingsInfo

local function verify_confirm(p)
	return p
end

local function verify_boolean(p)
	if typeof(p) == "boolean" then
		return p
	end
end

local function verify_hotkey(p)
	if p == nil or p == "nil" then
		return "nil"
	end

	if Utility:GetInputEnumFromName(p) then
		return p
	end
end

local function verify_color(p)
	if Utility:IsValidHex(p) then
		return p
	end
end

function SettingsInfo.new(section, name, displayName, image, description, inputType, defaultValue, ...)
	local isConfirmSetting

	if #inputType >= 7 then
		isConfirmSetting = string.sub(inputType, #inputType - 6, #inputType) == "Confirm"
	else
		isConfirmSetting = false
	end

	if isConfirmSetting and inputType ~= "Confirm" then
		inputType = string.sub(inputType, 1, #inputType - 7)
	end

	local object = setmetatable({}, SettingsInfo)
	object.Section = section
	object.Name = name
	object.DisplayName = displayName
	object.Image = image
	object.Description = description
	object.DefaultValue = defaultValue
	object.InputType = inputType
	object.IsConfirmSetting = isConfirmSetting
	object.VerifyInput = nil
	object.Options = nil
	object.Min = nil
	object.Max = nil
	object.Increment = nil
	object.IsPercent = nil
	local v2 = { ... }

	if object.InputType == "Confirm" then
		object.VerifyInput = verify_confirm
	elseif object.InputType == "Toggle" or object.InputType == "ToggleConfirm" or object.InputType == "Checkbox" then
		object.VerifyInput = verify_boolean
	elseif object.InputType == "Hotkey" then
		object.VerifyInput = verify_hotkey
	elseif object.InputType == "Color" then
		object.VerifyInput = verify_color
	elseif object.InputType == "Options" or object.InputType == "OptionsConfirm" or object.InputType == "Dropdown" or object.InputType == "DropdownConfirm" then
		local options = table.unpack(v2)
		object.Options = options

		function object.VerifyInput(value)
			if typeof(value) ~= "string" or not (table.find(options, value) and value) then
				value = nil
			end

			return value
		end
	elseif object.InputType == "Slider" or object.InputType == "SliderConfirm" then
		local min, max, increment, isPercent = table.unpack(v2)
		object.Min = min
		object.Max = max
		object.Increment = increment
		object.IsPercent = isPercent

		function object.VerifyInput(value)
			local v7

			if value and typeof(value) == "string" and #value > 1 and string.sub(value, #value) == "%" and tonumber((string.sub(
				value,
				1,
				#value - 1
			))) then
				v7 = tonumber((string.sub(value, 1, #value - 1))) / 100
			else
				v7 = tonumber(value)
			end

			return string.lower((tostring(v7))) ~= "nan" and typeof(v7) == "number" and math.floor(math.clamp(
				v7,
				object.Min,
				object.Max
			) * object.Increment + 0.5) / object.Increment or nil
		end
	end

	object:_Init()
	return object
end

function SettingsInfo:_Init() end

return SettingsInfo