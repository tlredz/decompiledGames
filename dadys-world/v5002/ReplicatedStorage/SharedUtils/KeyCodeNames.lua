local v = {}
local KeyCodeNames = {}

for _, v2 in ipairs(Enum.KeyCode:GetEnumItems()) do
	v[v2.Name] = v2
end

function KeyCodeNames.fromName(value)
	if typeof(value) == "string" then
		return v[value]
	end

	return nil
end

function KeyCodeNames.toName(p)
	if typeof(p) == "EnumItem" then
		return p.Name
	end

	return nil
end

function KeyCodeNames.isValidName(p)
	return v[p] ~= nil
end

local v2 = {
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
	KeypadPeriod = "Num .",
	KeypadPlus = "Num +",
	KeypadMinus = "Num -",
	KeypadMultiply = "Num *",
	KeypadDivide = "Num /",
	KeypadEnter = "Num Enter",
	Minus = "-",
	Equals = "=",
	LeftBracket = "[",
	RightBracket = "]",
	BackSlash = "\\",
	Semicolon = ";",
	Quote = "'",
	Comma = ",",
	Period = ".",
	Slash = "/",
	BackQuote = "`",
	Return = "Enter",
	Tilde = "~"
}

function KeyCodeNames.toDisplay(name)
	if typeof(name) == "EnumItem" then
		name = name.Name
	end

	if typeof(name) == "string" then
		return v2[name] or name
	end

	return nil
end

return KeyCodeNames