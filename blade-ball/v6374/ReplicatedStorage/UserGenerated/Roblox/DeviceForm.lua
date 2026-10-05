local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local function SafeGet(p, p2: string, p3)
	local success, result = pcall(function()
		return p[p2]
	end)

	if success then
		return result
	end

	return p3
end

local function IsWindows()
	local v = GuiService
	local v2 = "IsWindows"
	local success, result = pcall(function()
		return v[v2]
	end)

	if success then
		return result
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCharacterSize(p: number)
	return TextService:GetTextSize(utf8.char(p), 16, Enum.Font.SourceSans, Vector2.new(1000, 1000))
end

local point = GetCharacterSize(65535) -- equivalent call inferred; original call site unknown

-- equivalent calls inferred from this helper; original call sites unknown
local function IsValidCharacter(p: number)
	return TextService:GetTextSize(utf8.char(p), 16, Enum.Font.SourceSans, Vector2.new(1000, 1000)) ~= point
end

return table.freeze({
	DetectorVersion = "heuristic_v1",
	Get = function()
		if UserInputService.VREnabled then
			return Enum.DeviceForm.VR
		end

		if GuiService:IsTenFootInterface() then
			return Enum.DeviceForm.Console
		end

		local v = GuiService
		local v2 = "IsWindows"
		local success, result = pcall(function()
			return v[v2]
		end)

		if not success then
			result = false
		end

		if result then
			return Enum.DeviceForm.Desktop
		end

		if UserInputService.GyroscopeEnabled or UserInputService.AccelerometerEnabled then
			return Enum.DeviceForm.Phone
		end

		if UserInputService.MouseEnabled then
			return Enum.DeviceForm.Desktop
		end

		if UserInputService.TouchEnabled then
			return Enum.DeviceForm.Phone
		end

		if UserInputService.GamepadEnabled then
			return Enum.DeviceForm.Console
		end

		return nil
	end,
	GetPlatform = function()
		local v = tostring(version())
		local imageForKeyCode = ""
		pcall(function()
			imageForKeyCode = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonSelect):lower()
		end)
		local v2 = v:find("^0%.") ~= nil
		local v3 = GuiService:IsTenFootInterface() and v:find("^1%.") ~= nil
		local v4 = v:find("^2%.") ~= nil
		local vREnabled = UserInputService.VREnabled and VRService.VREnabled
		local v5 = GuiService
		local v6 = "IsWindows"
		local success, result = pcall(function()
			return v5[v6]
		end)

		if not success then
			result = false
		end

		local validCharacter = IsValidCharacter(63743) -- equivalent call inferred; original call site unknown

		if v3 then
			local v8 = imageForKeyCode:find("xbox") ~= nil
			local v9 = imageForKeyCode:find("ps4") ~= nil
			local v10 = imageForKeyCode:find("ps5") ~= nil

			if v8 or result then
				return Enum.Platform.XBoxOne
			end

			if v9 then
				return Enum.Platform.PS4
			end

			if v10 then
				return Enum.Platform.PS5
			end
		elseif v4 then
			if result then
				return Enum.Platform.UWP
			end

			if vREnabled then
				return Enum.Platform.MetaOS
			end

			if validCharacter then
				return Enum.Platform.IOS
			end

			if UserInputService.TouchEnabled then
				return Enum.Platform.Android
			end

			return Enum.Platform.Linux
		elseif v2 then
			if result then
				return Enum.Platform.Windows
			end

			return Enum.Platform.OSX
		end

		return Enum.Platform.None
	end
})