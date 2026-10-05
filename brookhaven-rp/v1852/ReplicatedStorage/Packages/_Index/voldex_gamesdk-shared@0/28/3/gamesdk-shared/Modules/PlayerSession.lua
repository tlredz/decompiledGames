game:GetService("Players")
local VRService = game:GetService("VRService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent.Parent
local Promise = require(parent.Promise)
local currentCamera = workspace.CurrentCamera
local PlayerSession = {
	_remote = nil,
	_initialized = false
}

local function warno(...)
	warn("[GameSdk - PlayerSession]", ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - PlayerSession] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if PlayerSession._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCharacterSize(p)
	return TextService:GetTextSize(utf8.char(p), 16, Enum.Font.SourceSans, Vector2.new(1000, 1000))
end

local characterSize = getCharacterSize(65535) -- equivalent call inferred; original call site unknown

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidCharacter(p)
	return TextService:GetTextSize(utf8.char(p), 16, Enum.Font.SourceSans, Vector2.new(1000, 1000)) ~= characterSize
end

local function onClientEvent(p: string, ...)
	local v = { ... }

	if p == "set-session" then
		TeleportService:SetTeleportSetting("SdkSessionId", v[1])
	end
end

function PlayerSession.Init()
	if PlayerSession._initialized ~= false then
		error("[GameSdk - PlayerSession] Already initialized")
	end

	PlayerSession._remote = ReplicatedStorage:WaitForChild("GameSdkPlayerSessionRemoteEvent", 20)

	if PlayerSession._remote == nil then
		error("[GameSdk - PlayerSession] Failed to find remote event")
	end

	PlayerSession._remote.OnClientEvent:Connect(onClientEvent)
	PlayerSession._initialized = true
end

function PlayerSession.Start()
	PlayerSession._remote:FireServer(
		"set-session-platform",
		TeleportService:GetTeleportSetting("SdkSessionId"),
		PlayerSession.GetPlatform()
	)
	PlayerSession.GetDevice():timeout(30):andThen(function(p)
		PlayerSession._remote:FireServer("set-device", p)
	end):catch(function(_)
		warno("Failed to get device for client")
	end)
end

function PlayerSession.GetPlatform()
	local success, result = pcall(version)

	if GuiService:IsTenFootInterface() and (not success or result:find("^1%.") ~= nil) then
		return "Console"
	end

	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		local viewportSize = currentCamera.ViewportSize

		if math.min(viewportSize.X, viewportSize.Y) <= 500 then
			return "Mobile"
		end

		return "Tablet"
	elseif UserInputService.VREnabled and VRService.VREnabled then
		return "VR"
	else
		return "Desktop"
	end
end

function PlayerSession.GetDevice()
	return Promise.new(function(callback, _)
		local v = version()
		local imageForKeyCode = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonSelect):lower()
		local v2 = v:find("^0%.") ~= nil
		local v3 = GuiService:IsTenFootInterface() and v:find("^1%.") ~= nil
		local v4 = v:find("^2%.") ~= nil
		local vREnabled = UserInputService.VREnabled and VRService.VREnabled
		local isWindows = GuiService.IsWindows
		local validCharacter = isValidCharacter(63743) -- equivalent call inferred; original call site unknown
		local v5 = nil
		local v6

		if v3 then
			local v7 = imageForKeyCode:find("xbox") ~= nil
			local v8 = imageForKeyCode:find("ps4") ~= nil
			local v9 = imageForKeyCode:find("ps5") ~= nil
			v6 = (v7 or isWindows) and "XboxOne" or v8 and "PS4" or v9 and "PS5" or v5
		elseif v4 then
			if isWindows then
				v6 = "UWP"
			elseif vREnabled then
				v6 = "VR"
			elseif validCharacter then
				v6 = "iOS"
			elseif UserInputService.TouchEnabled then
				v6 = "Android"
			else
				v6 = "Linux"
			end
		else
			v6 = v2 and (isWindows and "Windows" or "MacOS") or v5
		end

		if v6 == nil then
			callback("None")
		elseif UserInputService.GamepadEnabled then
			callback(v6 .. " / Controller")
		elseif UserInputService.TouchEnabled then
			callback(v6 .. " / Touch")
		else
			callback(v6 .. " / Keyboard")
		end
	end)
end

return PlayerSession