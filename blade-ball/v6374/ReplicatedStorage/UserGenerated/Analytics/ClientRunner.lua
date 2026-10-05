local now = os.clock()
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local VoiceChatServiceHelper = require(ReplicatedStorage.UserGenerated.Roblox.VoiceChatServiceHelper)
local ThreadJoin = require(ReplicatedStorage.UserGenerated.Concurrency.ThreadJoin)
local ClientKit = require(ReplicatedStorage.UserGenerated.Analytics.ClientKit)
local UTF8Sub = require(ReplicatedStorage.UserGenerated.Strings.UTF8Sub)
local DeviceForm = require(ReplicatedStorage.UserGenerated.Roblox.DeviceForm)
local localPlayer = Players.LocalPlayer
local now2 = nil

function SafeGet(p, p2: string, p3)
	local success, result = pcall(function(_, _)
		return p[p2]
	end, p, p2)

	if success then
		return result
	end

	return p3
end

function IsUWP()
	local success, result = pcall(function()
		return tostring({ 1 }):match("^table: 0x(00000000%x+)$") ~= nil
	end)
	return success and result
end

function IsWindows()
	return SafeGet(GuiService, "IsWindows", false)
end

function IsLoaded()
	if not game:IsLoaded() then
		return false
	end

	local character = localPlayer.Character

	if not character then
		return false
	end

	if character.PrimaryPart and character:FindFirstChild("Humanoid") then
		return true
	end

	return false
end

task.spawn(function()
	while not IsLoaded() do
		task.wait()
	end

	now2 = os.clock()
end)

function GetStartTime()
	local __StartTime = _G.__StartTime

	if type(__StartTime) == "number" then
		return __StartTime
	end

	return now
end

function GetLoadDurationAsync(flag: boolean?)
	local v

	while true do
		v = now2

		if v then
			break
		end

		if flag then
			return nil
		else
			task.wait()
		end
	end

	return (math.max(0, v - GetStartTime()))
end

function Build()
	local loadingDuration = GetLoadDurationAsync(false)
	local now3 = os.time()
	local now4 = os.clock()
	local serverTimeNow = workspace:GetServerTimeNow()
	local elapsedTime2 = elapsedTime()
	local gameSettings = UserSettings().GameSettings
	local guiInset, guiInsetBotRight = GuiService:GetGuiInset()
	local networkPing2 = nil
	pcall(function()
		local networkPing = localPlayer:GetNetworkPing()

		if networkPing > 0 then
			networkPing2 = networkPing * 1000
		end
	end)
	local joinData = localPlayer:GetJoinData()

	if joinData.LaunchData ~= nil then
		pcall(function()
			joinData.LaunchData = HttpService:JSONDecode(joinData.LaunchData)
		end)
	end

	local stats

	if Stats.MemoryTrackingEnabled then
		stats = {
			ContactsCount = Stats.ContactsCount,
			DataReceiveKbps = Stats.DataReceiveKbps,
			DataSendKbps = Stats.DataSendKbps,
			FrameTime = Stats.FrameTime,
			HeartbeatTime = Stats.HeartbeatTime,
			InstanceCount = Stats.InstanceCount,
			MovingPrimitivesCount = Stats.MovingPrimitivesCount,
			PhysicsReceiveKbps = Stats.PhysicsReceiveKbps,
			PhysicsSendKbps = Stats.PhysicsSendKbps,
			PhysicsStepTime = Stats.PhysicsStepTime,
			PrimitivesCount = Stats.PrimitivesCount,
			RenderCPUFrameTime = Stats.RenderCPUFrameTime,
			RenderGPUFrameTime = Stats.RenderGPUFrameTime,
			SceneDrawcallCount = Stats.SceneDrawcallCount,
			SceneTriangleCount = Stats.SceneTriangleCount,
			ShadowsDrawcallCount = Stats.ShadowsDrawcallCount,
			ShadowsTriangleCount = Stats.ShadowsTriangleCount,
			UI2DDrawcallCount = Stats.UI2DDrawcallCount,
			UI2DTriangleCount = Stats.UI2DTriangleCount,
			UI3DDrawcallCount = Stats.UI3DDrawcallCount,
			UI3DTriangleCount = Stats.UI3DTriangleCount,
			MemoryUsageMbForTag = 0,
			TotalMemoryUsageMb = 0
		}
		local memoryUsageMbForTags = {}

		for _, v6 in ipairs(Enum.DeveloperMemoryTag:GetEnumItems()) do
			local name = v6.Name
			memoryUsageMbForTags[name == "PhysicsParts" and "BaseParts" or name] = Stats:GetMemoryUsageMbForTag(v6)
		end

		stats.MemoryUsageMbForTag = memoryUsageMbForTags
		stats.TotalMemoryUsageMb = Stats:GetTotalMemoryUsageMb()
	end

	local v6 = {
		System = {
			UWP = IsUWP(),
			Windows = IsWindows(),
			Time = now3,
			Clock = now4,
			ElapsedTime = elapsedTime2,
			TimezoneOffset = os.date("%z"),
			Timezone = HttpService:UrlEncode((os.date("%Z"))),
			TimezoneDST = os.date("*t").isdst == true,
			HeapSize = gcinfo(),
			RobloxVersion = UTF8Sub(tostring(version()), 1, 20)
		},
		Game = {
			LoadingDuration = loadingDuration
		},
		LocalPlayer = {
			JoinData = joinData,
			NetworkPing = networkPing2
		},
		TeleportService = {
			TeleportData = TeleportService:GetLocalPlayerTeleportData()
		},
		Workspace = {
			ServerTimeNow = serverTimeNow,
			RealPhysicsFPS = workspace:GetRealPhysicsFPS(),
			DistributedGameTime = workspace.DistributedGameTime,
			NumAwakeParts = workspace:GetNumAwakeParts(),
			PhysicsThrottling = workspace:GetPhysicsThrottling()
		},
		Stats = stats,
		UserInputService = {
			DeviceForm = DeviceForm.Get(),
			Platform = DeviceForm.GetPlatform()
		},
		GuiService = {
			IsTenFootInterface = GuiService:IsTenFootInterface(),
			TouchControlsEnabled = GuiService.TouchControlsEnabled,
			GuiInsetTopLeft = guiInset,
			GuiInsetBotRight = guiInsetBotRight,
			IsModalDialog = SafeGet(GuiService, "IsModalDialog", false),
			MenuIsOpen = GuiService.MenuIsOpen,
			PreferredTransparency = math.clamp(GuiService.PreferredTransparency, 0, 1),
			ReducedMotionEnabled = GuiService.ReducedMotionEnabled,
			CoreGuiNavigationEnabled = GuiService.CoreGuiNavigationEnabled,
			GuiNavigationEnabled = GuiService.GuiNavigationEnabled,
			AutoSelectGuiEnabled = GuiService.AutoSelectGuiEnabled
		},
		CurrentCamera = {
			ViewportSize = workspace.CurrentCamera.ViewportSize
		},
		LocalizationService = {
			RobloxLocaleId = LocalizationService.RobloxLocaleId:lower(),
			SystemLocaleId = UTF8Sub(LocalizationService.SystemLocaleId:lower(), 1, 1000)
		},
		VoiceChatService = {},
		UserSettings = {
			GameSettings = {
				ControlMode = gameSettings.ControlMode,
				VignetteEnabled = gameSettings.VignetteEnabled,
				ComputerCameraMovementMode = gameSettings.ComputerCameraMovementMode,
				ComputerMovementMode = gameSettings.ComputerMovementMode,
				GamepadCameraSensitivity = gameSettings.GamepadCameraSensitivity,
				MouseSensitivity = gameSettings.MouseSensitivity,
				RotationType = gameSettings.RotationType,
				SavedQualityLevel = gameSettings.SavedQualityLevel,
				TouchCameraMovementMode = gameSettings.TouchCameraMovementMode,
				TouchMovementMode = gameSettings.TouchMovementMode,
				InFullScreen = gameSettings:InFullScreen(),
				InStudioMode = gameSettings:InStudioMode()
			}
		}
	}
	local threads = {}
	table.insert(threads, task.spawn(function()
		v6.VoiceChatService.VoiceEnabled = VoiceChatServiceHelper.IsVoiceEnabledForUserIdAsync(
			localPlayer.UserId,
			false
		)
	end))

	for _, v7 in ipairs(threads) do
		ThreadJoin(v7)
	end

	return v6
end

local flag = false

function Send()
	if flag then
		return true
	end

	flag = true
	local v = pcall(function()
		local v2 = Build()
		ClientKit.AcceptRemote:FireServer(v2)
	end)
	flag = false
	return v
end

local v = -1e999
GuiService.MenuOpened:Connect(function()
	local now3 = os.clock()

	if now3 - v > 15 then
		v = now3
		Send()
	end
end)
UserInputService.WindowFocusReleased:Connect(function()
	local now3 = os.clock()

	if now3 - v > 15 then
		v = now3
		Send()
	end
end)
task.spawn(function()
	while true do
		Send()
		task.wait(150 + 300 * math.random())
	end
end)