local v = {}
local HotkeyCombo = {
	MaxKeys = 4
}
local v2 = {
	F5 = true,
	I = true,
	O = true,
	Return = true,
	KeypadEnter = true
}
local v3 = {
	Zero = "0",
	One = "1",
	Two = "2",
	Three = "3",
	Four = "4",
	Five = "5",
	Six = "6",
	Seven = "7",
	Eight = "8",
	Nine = "9",
	KeypadZero = "Num 0",
	KeypadOne = "Num 1",
	KeypadTwo = "Num 2",
	KeypadThree = "Num 3",
	KeypadFour = "Num 4",
	KeypadFive = "Num 5",
	KeypadSix = "Num 6",
	KeypadSeven = "Num 7",
	KeypadEight = "Num 8",
	KeypadNine = "Num 9",
	KeypadPlus = "Num +",
	KeypadMinus = "Num -",
	KeypadMultiply = "Num *",
	KeypadDivide = "Num /",
	KeypadPeriod = "Num .",
	Minus = "-",
	Equals = "=",
	Backquote = "`",
	LeftBracket = "[",
	RightBracket = "]",
	BackSlash = "\\",
	Semicolon = ";",
	Quote = "'",
	Comma = ",",
	Period = ".",
	Slash = "/",
	LeftShift = "L Shift",
	RightShift = "R Shift",
	LeftControl = "L Ctrl",
	RightControl = "R Ctrl",
	LeftAlt = "L Alt",
	RightAlt = "R Alt",
	PageUp = "Page Up",
	PageDown = "Page Down",
	CapsLock = "Caps Lock",
	Return = "Enter"
}

for _, v4 in Enum.KeyCode:GetEnumItems() do
	if v4 ~= Enum.KeyCode.Unknown then
		v[v4.Name] = v4
	end
end

function HotkeyCombo.isConfirmKeyCode(p)
	return p == Enum.KeyCode.Return or p == Enum.KeyCode.KeypadEnter
end

function HotkeyCombo.keyCodeFromName(value)
	if typeof(value) == "string" then
		return v[value]
	end

	return nil
end

function HotkeyCombo.isValidKeyCodeName(p)
	return HotkeyCombo.keyCodeFromName(p) ~= nil
end

function HotkeyCombo.isValidHotkeyKeyCodeName(p)
	return HotkeyCombo.isValidKeyCodeName(p) and v2[p] ~= true
end

function HotkeyCombo.label(p: string)
	return v3[p] or p
end

function HotkeyCombo.copy(list)
	if not list or #list == 0 then
		return nil
	end

	local result = {}

	for k, v4 in list do
		result[k] = v4
	end

	return result
end

function HotkeyCombo.normalize(items)
	if typeof(items) ~= "table" then
		return nil
	end

	local v4 = {}
	local result = {}

	for _, item in items do
		if not HotkeyCombo.isValidHotkeyKeyCodeName(item) or v4[item] then
			continue
		end

		v4[item] = true
		table.insert(result, item)

		if #result >= HotkeyCombo.MaxKeys then
			break
		end
	end

	if #result > 0 then
		return result
	end

	return nil
end

function HotkeyCombo.sanitize(value)
	if typeof(value) == "string" then
		if HotkeyCombo.isValidHotkeyKeyCodeName(value) then
			return { value }
		end

		return nil
	else
		if typeof(value) ~= "table" then
			return nil
		end

		local count = 0
		local v4 = {}
		local result = {}

		for _, item in value do
			count += 1

			if HotkeyCombo.MaxKeys < count then
				return nil
			end

			if HotkeyCombo.isValidHotkeyKeyCodeName(item) and not v4[item] then
				v4[item] = true
				table.insert(result, item)
			else
				return nil
			end
		end

		if #result > 0 then
			return result
		end

		return nil
	end
end

function HotkeyCombo.signature(p)
	local copy = HotkeyCombo.copy(p) or {}
	table.sort(copy)
	return table.concat(copy, "+")
end

return HotkeyCombo