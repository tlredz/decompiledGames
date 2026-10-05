local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Signal = require(ReplicatedStorage.Packages.Signal)

local function asset(p: string)
	return (`rbxassetid://{p}`)
end

local v = {
	microsoft = {
		[Enum.KeyCode.ButtonA] = "rbxassetid://113824701684322",
		[Enum.KeyCode.ButtonB] = "rbxassetid://107100143818564",
		[Enum.KeyCode.ButtonX] = "rbxassetid://121994310218398",
		[Enum.KeyCode.ButtonY] = "rbxassetid://118121490246715",
		[Enum.KeyCode.ButtonL1] = "rbxassetid://128016621986260",
		[Enum.KeyCode.ButtonL2] = "rbxassetid://121095629027146",
		[Enum.KeyCode.ButtonL3] = "rbxassetid://98426369439432",
		[Enum.KeyCode.ButtonR1] = "rbxassetid://86739128961101",
		[Enum.KeyCode.ButtonR2] = "rbxassetid://121138812911138",
		[Enum.KeyCode.ButtonR3] = "rbxassetid://108823668376359",
		[Enum.KeyCode.ButtonSelect] = "rbxassetid://73640706748399",
		[Enum.KeyCode.ButtonStart] = "rbxassetid://121407964275535",
		[Enum.KeyCode.DPadDown] = "rbxassetid://134006970980101",
		[Enum.KeyCode.DPadLeft] = "rbxassetid://113523064631322",
		[Enum.KeyCode.DPadRight] = "rbxassetid://125621109562134",
		[Enum.KeyCode.DPadUp] = "rbxassetid://110656716055777",
		[Enum.KeyCode.Thumbstick1] = "rbxassetid://86234104961357",
		[Enum.KeyCode.Thumbstick2] = "rbxassetid://92731666763608"
	},
	sony = {
		[Enum.KeyCode.ButtonA] = "rbxassetid://140688515494419",
		[Enum.KeyCode.ButtonB] = "rbxassetid://89979188218128",
		[Enum.KeyCode.ButtonX] = "rbxassetid://105740811198422",
		[Enum.KeyCode.ButtonY] = "rbxassetid://102844478766253",
		[Enum.KeyCode.ButtonL1] = "rbxassetid://101741164721625",
		[Enum.KeyCode.ButtonL2] = "rbxassetid://92051888341203",
		[Enum.KeyCode.ButtonL3] = "rbxassetid://71736763291675",
		[Enum.KeyCode.ButtonR1] = "rbxassetid://108359563054786",
		[Enum.KeyCode.ButtonR2] = "rbxassetid://95486021989419",
		[Enum.KeyCode.ButtonR3] = "rbxassetid://100766112822921",
		[Enum.KeyCode.ButtonStart] = "rbxassetid://115132567456286",
		[Enum.KeyCode.DPadDown] = "rbxassetid://101700700938948",
		[Enum.KeyCode.DPadLeft] = "rbxassetid://114773739810891",
		[Enum.KeyCode.DPadRight] = "rbxassetid://110011411664004",
		[Enum.KeyCode.DPadUp] = "rbxassetid://77095582918408",
		[Enum.KeyCode.Thumbstick1] = "rbxassetid://87994926804700",
		[Enum.KeyCode.Thumbstick2] = "rbxassetid://123691072001381"
	}
}
local v4 = {
	Changed = Signal.new()
}
local v5 = {}
local v6 = {}
local v7 = nil

local function relabelled(p)
	local success, stringForKeyCode = pcall(UserInputService.GetStringForKeyCode, UserInputService, p)

	if success then
		if typeof(stringForKeyCode) == "string" and stringForKeyCode ~= "" then
			success = stringForKeyCode ~= p.Name
		else
			success = false
		end
	end

	return success
end

local function vendor()
	local v8 = v7

	if v8 ~= nil then
		return v8
	end

	local buttonY = Enum.KeyCode.ButtonY
	local success, stringForKeyCode = pcall(UserInputService.GetStringForKeyCode, UserInputService, buttonY)

	if success then
		if typeof(stringForKeyCode) == "string" and stringForKeyCode ~= "" then
			success = stringForKeyCode ~= buttonY.Name
		else
			success = false
		end
	end

	v8 = success and "sony" or "microsoft"
	v7 = v8
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function verify(p: string)
	v6[p] = true
	task.spawn(function()
		local v8 = false
		pcall(function()
			ContentProvider:PreloadAsync({ p }, function(_: string, p2)
				v8 = p2 == Enum.AssetFetchStatus.Success
			end)
		end)
		v6[p] = nil
		v5[p] = v8

		if not v8 then
			warn((`gamepad glyph {p} did not load; using the engine glyph instead`))
			v4.Changed:Fire()
		end
	end)
end

local function bespoke(p)
	local v9 = v7

	if v9 == nil then
		local buttonY = Enum.KeyCode.ButtonY
		local success, stringForKeyCode = pcall(UserInputService.GetStringForKeyCode, UserInputService, buttonY)

		if success then
			if typeof(stringForKeyCode) == "string" and stringForKeyCode ~= "" then
				success = stringForKeyCode ~= buttonY.Name
			else
				success = false
			end
		end

		v9 = success and "sony" or "microsoft"
		v7 = v9
	end

	local v10 = v[v9][p]

	if v10 == nil then
		return nil
	end

	if v5[v10] == nil and v6[v10] == nil then
		verify(v10) -- equivalent call inferred; original call site unknown
	end

	if v5[v10] == false then
		return nil
	end

	return v10
end

local function engineGlyph(p)
	local success, imageForKeyCode = pcall(UserInputService.GetImageForKeyCode, UserInputService, p)

	if success and typeof(imageForKeyCode) == "string" and imageForKeyCode ~= "" then
		return imageForKeyCode
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function announce()
	v7 = nil
	v4.Changed:Fire()
end

function v4.Vendor()
	local v8 = v7

	if v8 ~= nil then
		return v8
	end

	local buttonY = Enum.KeyCode.ButtonY
	local success, stringForKeyCode = pcall(UserInputService.GetStringForKeyCode, UserInputService, buttonY)

	if success then
		if typeof(stringForKeyCode) == "string" and stringForKeyCode ~= "" then
			success = stringForKeyCode ~= buttonY.Name
		else
			success = false
		end
	end

	v8 = success and "sony" or "microsoft"
	v7 = v8
	return v8
end

function v4.Image(p)
	local v9 = v7

	if v9 == nil then
		local buttonY = Enum.KeyCode.ButtonY
		local success, stringForKeyCode = pcall(UserInputService.GetStringForKeyCode, UserInputService, buttonY)

		if success then
			if typeof(stringForKeyCode) == "string" and stringForKeyCode ~= "" then
				success = stringForKeyCode ~= buttonY.Name
			else
				success = false
			end
		end

		v9 = success and "sony" or "microsoft"
		v7 = v9
	end

	local v10 = v[v9][p]

	if v10 == nil then
		v10 = nil
	else
		if v5[v10] == nil and v6[v10] == nil then
			verify(v10) -- equivalent call inferred; original call site unknown
		end

		if v5[v10] == false then
			v10 = nil
		end
	end

	if v10 then
		return v10
	end

	local success, imageForKeyCode = pcall(UserInputService.GetImageForKeyCode, UserInputService, p)

	if success and typeof(imageForKeyCode) == "string" and imageForKeyCode ~= "" then
		return imageForKeyCode
	end

	return nil
end

UserInputService.GamepadConnected:Connect(announce)
UserInputService.GamepadDisconnected:Connect(announce)
UserInputService.LastInputTypeChanged:Connect(function(p)
	if string.find(p.Name, "Gamepad", 1, true) == 1 then
		announce() -- equivalent call inferred; original call site unknown
	end
end)
return table.freeze(v4)