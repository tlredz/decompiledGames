local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local table2 = Asserts.Table({
	JoinSource = Asserts.Enum(Enum.JoinSource),
	ItemType = Asserts.Optional(Asserts.Enum(Enum.AvatarItemType)),
	AssetId = Asserts.Optional(Asserts.Pattern("^rbxassetid://%d+$")),
	OutfitId = Asserts.Optional(Asserts.Pattern("^rbxassetid://%d+$")),
	AssetType = Asserts.Optional(Asserts.Enum(Enum.AssetType))
})
local table3 = Asserts.Table({
	SourceGameId = Asserts.Optional(Asserts.Integer),
	SourcePlaceId = Asserts.Optional(Asserts.Integer),
	ReferredByPlayerId = Asserts.Optional(Asserts.Integer),
	Members = Asserts.Optional(Asserts.UniqueArray(Asserts.Integer)),
	TeleportData = Asserts.Optional(Asserts.Storable),
	LaunchData = Asserts.Optional(Asserts.Storable),
	GameJoinContext = Asserts.Optional(table2)
})
local finiteNonNegatives = {}

for _, v in ipairs(Enum.DeveloperMemoryTag:GetEnumItems()) do
	local name = v.Name
	finiteNonNegatives[name == "PhysicsParts" and "BaseParts" or name] = Asserts.FiniteNonNegative
end

local table4 = Asserts.Table({
	ContactsCount = Asserts.IntegerNonNegative,
	DataReceiveKbps = Asserts.FiniteNonNegative,
	DataSendKbps = Asserts.FiniteNonNegative,
	FrameTime = Asserts.FiniteNonNegative,
	HeartbeatTime = Asserts.FiniteNonNegative,
	InstanceCount = Asserts.IntegerNonNegative,
	MovingPrimitivesCount = Asserts.IntegerNonNegative,
	PhysicsReceiveKbps = Asserts.FiniteNonNegative,
	PhysicsSendKbps = Asserts.FiniteNonNegative,
	PhysicsStepTime = Asserts.FiniteNonNegative,
	PrimitivesCount = Asserts.IntegerNonNegative,
	RenderCPUFrameTime = Asserts.FiniteNonNegative,
	RenderGPUFrameTime = Asserts.Number,
	SceneDrawcallCount = Asserts.IntegerNonNegative,
	SceneTriangleCount = Asserts.IntegerNonNegative,
	ShadowsDrawcallCount = Asserts.IntegerNonNegative,
	ShadowsTriangleCount = Asserts.IntegerNonNegative,
	UI2DDrawcallCount = Asserts.IntegerNonNegative,
	UI2DTriangleCount = Asserts.IntegerNonNegative,
	UI3DDrawcallCount = Asserts.IntegerNonNegative,
	UI3DTriangleCount = Asserts.IntegerNonNegative,
	MemoryUsageMbForTag = Asserts.Table(finiteNonNegatives),
	TotalMemoryUsageMb = Asserts.FiniteNonNegative
})
local v = {
	AssertGameJoinContext = table2,
	AssertJoinData = table3,
	AssertData = Asserts.Table({
		System = Asserts.Table({
			UWP = Asserts.Optional(Asserts.Boolean),
			Windows = Asserts.Boolean,
			Time = Asserts.Finite,
			Clock = Asserts.Finite,
			ElapsedTime = Asserts.Finite,
			TimezoneOffset = Asserts.String,
			Timezone = Asserts.String,
			TimezoneDST = Asserts.Boolean,
			HeapSize = Asserts.FiniteNonNegative,
			RobloxVersion = Asserts.StringRange(0, 20)
		}),
		Game = Asserts.Table({
			LoadingDuration = Asserts.Optional(Asserts.FiniteNonNegative)
		}),
		LocalPlayer = Asserts.Table({
			JoinData = table3,
			NetworkPing = Asserts.Optional(Asserts.FinitePositive)
		}),
		TeleportService = Asserts.Table({
			TeleportData = Asserts.Optional(Asserts.Storable)
		}),
		Workspace = Asserts.Table({
			ServerTimeNow = Asserts.Finite,
			RealPhysicsFPS = Asserts.FiniteNonNegative,
			DistributedGameTime = Asserts.FiniteNonNegative,
			NumAwakeParts = Asserts.FiniteNonNegative,
			PhysicsThrottling = Asserts.IntegerRange(0, 100)
		}),
		Stats = Asserts.Optional(table4),
		UserInputService = Asserts.Table({
			DeviceForm = Asserts.Optional(Asserts.Enum(Enum.DeviceForm)),
			Platform = Asserts.Enum(Enum.Platform)
		}),
		GuiService = Asserts.Table({
			IsTenFootInterface = Asserts.Boolean,
			TouchControlsEnabled = Asserts.Boolean,
			GuiInsetTopLeft = Asserts.Vector2Finite,
			GuiInsetBotRight = Asserts.Vector2Finite,
			IsModalDialog = Asserts.Boolean,
			MenuIsOpen = Asserts.Boolean,
			PreferredTransparency = Asserts.Range(0, 1),
			ReducedMotionEnabled = Asserts.Boolean,
			CoreGuiNavigationEnabled = Asserts.Boolean,
			GuiNavigationEnabled = Asserts.Boolean,
			AutoSelectGuiEnabled = Asserts.Boolean
		}),
		CurrentCamera = Asserts.Table({
			ViewportSize = Asserts.Vector2Finite
		}),
		LocalizationService = Asserts.Table({
			RobloxLocaleId = Asserts.StringRange(0, 1000),
			SystemLocaleId = Asserts.StringRange(0, 5000)
		}),
		VoiceChatService = Asserts.Table({
			VoiceEnabled = Asserts.Optional(Asserts.Boolean)
		}),
		UserSettings = Asserts.Table({
			GameSettings = Asserts.Table({
				ControlMode = Asserts.Enum(Enum.ControlMode),
				VignetteEnabled = Asserts.Boolean,
				ComputerCameraMovementMode = Asserts.Enum(Enum.ComputerCameraMovementMode),
				ComputerMovementMode = Asserts.Enum(Enum.ComputerMovementMode),
				GamepadCameraSensitivity = Asserts.FiniteNonNegative,
				MouseSensitivity = Asserts.Range(0, 10),
				RotationType = Asserts.Enum(Enum.RotationType),
				SavedQualityLevel = Asserts.Enum(Enum.SavedQualitySetting),
				TouchCameraMovementMode = Asserts.Enum(Enum.TouchCameraMovementMode),
				TouchMovementMode = Asserts.Enum(Enum.TouchMovementMode),
				InFullScreen = Asserts.Boolean,
				InStudioMode = Asserts.Boolean
			})
		})
	}),
	AcceptRemote = script:WaitForChild("Accept"),
	PingRemote = script:WaitForChild("Ping"),
	MenuStateRemote = script:WaitForChild("MenuState"),
	FocusStateRemote = script:WaitForChild("FocusState"),
	FpsRemote = script:WaitForChild("Fps"),
	LibMPDeviceRemote = script:WaitForChild("LibMPDevice"),
	LibMPRequiringRemote = script:WaitForChild("LibMPRequiring"),
	LibMPRequiredRemote = script:WaitForChild("LibMPRequired"),
	LibMPFrameRemote = script:WaitForChild("LibMPFrame"),
	LiveRequestRemote = script:WaitForChild("LiveRequest"),
	LiveResponseRemote = script:WaitForChild("LiveResponse")
}
return table.freeze(v)