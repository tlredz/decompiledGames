local v = {
	Modifiable = true,
	Selectable = true
}
local total = 57
local total2 = 19
local GuiService = game:GetService("GuiService")

if GuiService:IsTenFootInterface() then
	total += 10
	total2 += 10
end

pcall(function()
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCore("TopbarEnabled", false)
end)
local UserInputService = game:GetService("UserInputService")
local CloneStarterGuiForEditOrPlayModule = require(script.Parent.Parent:WaitForChild("CloneStarterGuiForEditOrPlayModule"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local getScriptSourceServerFunction = studioLiteFolder:WaitForChild("GetScriptSourceServerFunction")
local serverFunctions = studioLiteFolder:WaitForChild("ServerFunctions")
local part = nil
local insertFrame = script.Parent.Parent:WaitForChild("InsertFrame")
local insertScriptFrame = script.Parent.Parent:WaitForChild("InsertScriptFrame")
local insertLocalScriptFrame = script.Parent.Parent:WaitForChild("InsertLocalScriptFrame")
local insertModuleScriptFrame = script.Parent.Parent:WaitForChild("InsertModuleScriptFrame")
local localPlayer = game.Players.LocalPlayer

function WarnPlayer(text, duration)
	local warningText = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("WarningText")
	spawn(function()
		warningText.Visible = false
		task.wait(0.3)
		warningText.Text = text
		warningText.Visible = true
		task.wait(duration)
		warningText.Visible = false
	end)
end

function DialogOk(text, text2)
	_G.DialogAnswer = "?"
	local dialogOkFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("DialogOkFrame")
	local okTextLabel = dialogOkFrame:WaitForChild("OkTextLabel")
	okTextLabel.Text = text
	local okTextButton = dialogOkFrame:WaitForChild("OkTextButton")
	okTextButton.Text = text2
	dialogOkFrame.Visible = true

	while _G.DialogAnswer == "?" do
		task.wait(0.2)
	end
end

function DialogYesNo(text)
	_G.DialogAnswer = "?"
	local dialogYesNoFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("DialogYesNoFrame")
	local yesNoTextLabel = dialogYesNoFrame:WaitForChild("YesNoTextLabel")
	yesNoTextLabel.Text = text
	dialogYesNoFrame.Visible = true

	while _G.DialogAnswer == "?" do
		task.wait(0.2)
	end
end

local v2 = false
local workingImageLabel1 = script.Parent.Parent:WaitForChild("WorkingImageLabel1")
local workingImageLabel2 = script.Parent.Parent:WaitForChild("WorkingImageLabel2")

function WorkingWaiting()
	spawn(function()
		v2 = true

		for _ = 1, 100 do
			if not v2 then
				break
			end

			if workingImageLabel1.Visible then
				workingImageLabel1.Visible = false
				workingImageLabel2.Visible = true
			else
				workingImageLabel1.Visible = true
				workingImageLabel2.Visible = false
			end

			task.wait(0.1)
		end

		v2 = false
		workingImageLabel1.Visible = false
		workingImageLabel2.Visible = false
	end)
end

local v3 = {
	8,
	9,
	10,
	11,
	12,
	14,
	18,
	24,
	36,
	48
}
local fontSize = nil
local connections = {}

for i = 1, #v3 do
	if v3[i] <= 22 then
		fontSize = i - 1
	end
end

local v5 = {
	Background = Color3.new(0.9137254901960784, 0.9137254901960784, 0.9137254901960784),
	Border = Color3.new(0.5843137254901961, 0.5843137254901961, 0.5843137254901961),
	Selected = Color3.new(0.3764705882352941, 0.5490196078431373, 0.8274509803921568),
	BorderSelected = Color3.new(0.33725490196078434, 0.49019607843137253, 0.7372549019607844),
	Text = Color3.new(0, 0, 0),
	TextDisabled = Color3.new(0.5019607843137255, 0.5019607843137255, 0.5019607843137255),
	TextSelected = Color3.new(1, 1, 1),
	Button = Color3.new(0.8666666666666667, 0.8666666666666667, 0.8666666666666667),
	ButtonBorder = Color3.new(0.5843137254901961, 0.5843137254901961, 0.5843137254901961),
	ButtonSelected = Color3.new(1, 0, 0),
	Field = Color3.new(1, 1, 1),
	FieldBorder = Color3.new(0.7490196078431373, 0.7490196078431373, 0.7490196078431373),
	TitleBackground = Color3.new(0.6980392156862745, 0.6980392156862745, 0.6980392156862745)
}
local v6 = {
	Accessory = 32,
	Accoutrement = 32,
	AdvancedDragger = 0,
	Animation = 60,
	AnimationTrack = 60,
	AnimationTrackState = 60,
	Animator = 0,
	ArcHandles = 56,
	Attachment = 92,
	Authoring = 3,
	Backpack = 20,
	BackpackItem = 0,
	BadgeService = 0,
	BasePart = 1,
	BasePlayerGui = 46,
	BaseScript = 6,
	BevelMesh = 8,
	SurfaceGui = 64,
	BindableEvent = 67,
	BindableFunction = 66,
	BlockMesh = 8,
	BodyColors = 0,
	BoolValue = 4,
	BrickColorValue = 4,
	Button = 0,
	ButtonBindingWidget = 0,
	CFrameValue = 4,
	CacheableContentProvider = 0,
	Camera = 5,
	ChangeHistoryService = 0,
	CharacterAppearance = 0,
	CharacterMesh = 60,
	Chat = 0,
	ClickDetector = 41,
	Clothing = 40,
	CollectionService = 0,
	Color3Value = 4,
	Configuration = 58,
	ContentFilter = 0,
	ContentProvider = 0,
	ContextActionService = 0,
	Controller = 0,
	ControllerService = 0,
	CookiesService = 0,
	CoreGui = 0,
	CoreScript = 6,
	CornerWedgePart = 1,
	DataModel = 0,
	DataModelMesh = 8,
	DebugSettings = 3,
	DebuggerBreakpoint = 0,
	DebuggerService = 0,
	DebuggerWatch = 0,
	Decal = 7,
	Dialog = 62,
	DialogChoice = 63,
	Dragger = 0,
	DynamicRotate = 34,
	Explosion = 36,
	FWService = 0,
	FaceInstance = 0,
	FastLogSettings = 3,
	Feature = 0,
	FileMesh = 8,
	Fire = 61,
	Folder = 70,
	ForceField = 37,
	FormFactorPart = 1,
	Frame = 48,
	FriendService = 0,
	GamePassService = 0,
	GameSettings = 3,
	GenericSettings = 3,
	Geometry = 0,
	GlobalSettings = 3,
	GuiBase = 47,
	GuiBase2d = 0,
	GuiBase3d = 0,
	GuiButton = 51,
	GuiItem = 0,
	GuiLabel = 50,
	GuiObject = 48,
	GuiRoot = 0,
	GuiService = 0,
	GuidRegistryService = 0,
	Handles = 53,
	HandlesBase = 0,
	HingeConstraint = 89,
	Hopper = 0,
	Humanoid = 9,
	HumanoidController = 0,
	ImageButton = 52,
	ImageLabel = 49,
	InsertService = 0,
	Instance = 0,
	InstancePacketCache = 0,
	IntValue = 4,
	JointInstance = 34,
	JointsService = 0,
	Keyframe = 60,
	KeyframeSequence = 0,
	KeyframeSequenceProvider = 0,
	LayerCollector = 0,
	Light = 0,
	Lighting = 13,
	LoadingGui = 46,
	LocalBackpack = 0,
	LocalScript = 18,
	LocalWorkspace = 0,
	LuaSettings = 3,
	LuaWebService = 0,
	ManualSurfaceJointInstance = 0,
	MarketplaceService = 0,
	MeshContentProvider = 0,
	MeshPart = 1,
	Model = 2,
	ModuleScript = 76,
	Motor = 34,
	Motor6D = 34,
	Mouse = 0,
	NetworkMarker = 0,
	NetworkPeer = 0,
	NetworkReplicator = 29,
	NetworkSettings = 3,
	NotificationBox = 48,
	NotificationObject = 48,
	NumberValue = 4,
	ObjectValue = 4,
	PVAdornment = 0,
	PVInstance = 0,
	Pants = 44,
	ParallelRampPart = 1,
	Part = 1,
	PartAdornment = 0,
	PersonalServerService = 0,
	PhysicsPacketCache = 0,
	PhysicsService = 0,
	PhysicsSettings = 3,
	Platform = 1,
	Player = 12,
	PlayerGui = 46,
	PlayerHUD = 0,
	PlayerMouse = 0,
	Players = 21,
	Plugin = 0,
	PluginManager = 0,
	PluginMouse = 0,
	PointLight = 13,
	Pose = 60,
	PrismPart = 1,
	ProfilingItem = 0,
	PyramidPart = 1,
	RayValue = 4,
	ReflectionMetadata = 0,
	ReflectionMetadataCallbacks = 0,
	ReflectionMetadataClass = 0,
	ReflectionMetadataClasses = 0,
	ReflectionMetadataEvents = 0,
	ReflectionMetadataFunctions = 0,
	ReflectionMetadataItem = 0,
	ReflectionMetadataMember = 0,
	ReflectionMetadataProperties = 0,
	ReflectionMetadataYieldFunctions = 0,
	RenderHooksService = 0,
	RenderSettings = 3,
	ReplicatedFirst = 72,
	ReplicatedStorage = 72,
	RightAngleRampPart = 1,
	RootInstance = 0,
	RunService = 0,
	RunningAverageItemDouble = 0,
	RunningAverageItemInt = 0,
	RuntimeScriptService = 0,
	Scale9Frame = 0,
	ScreenGui = 47,
	Script = 6,
	ScriptContext = 0,
	ScriptDebugger = 0,
	ScriptInformationProvider = 0,
	ScriptService = 0,
	Seat = 35,
	Selection = 0,
	SelectionBox = 54,
	SelectionLasso = 57,
	ServerReplicator = 0,
	ServerScriptService = 82,
	ServerStorage = 74,
	ServiceProvider = 0,
	Shirt = 43,
	ShirtGraphic = 40,
	SkateboardController = 0,
	Sky = 28,
	Smoke = 59,
	SocialService = 0,
	Sound = 11,
	Sparkles = 42,
	SpawnLocation = 25,
	SpawnerService = 0,
	SpecialMesh = 8,
	SpotLight = 0,
	StarterGear = 20,
	StarterGui = 46,
	StarterPack = 20,
	StarterPlayer = 88,
	StarterPlayerScripts = 82,
	StarterCharacterScripts = 82,
	StarterScript = 18,
	Stats = 0,
	StatsItem = 0,
	Status = 2,
	StockSound = 11,
	StringValue = 4,
	StudioTool = 0,
	SurfaceSelection = 55,
	TaskScheduler = 0,
	Team = 24,
	Teams = 23,
	TeleportService = 0,
	TextBox = 51,
	TextButton = 51,
	TextLabel = 50,
	TextService = 0,
	Texture = 10,
	TextureContentProvider = 0,
	TextureTrail = 4,
	TimerService = 0,
	Tool = 17,
	Toolbar = 0,
	TotalCountTimeIntervalItem = 0,
	TouchTransmitter = 37,
	TrussPart = 1,
	TweenService = 0,
	UserGameSettings = 4,
	UserInputService = 0,
	UserSettings = 3,
	Vector3Value = 4,
	VehicleController = 0,
	VehicleSeat = 35,
	VelocityMotor = 34,
	VirtualUser = 0,
	Visit = 0,
	WedgePart = 1,
	Weld = 34,
	WeldConstraint = 34,
	Workspace = 19,
	BodyAngularVelocity = 182,
	BodyForce = 182,
	BodyGyro = 182,
	BodyPosition = 182,
	BodyThrust = 182,
	BodyVelocity = 182,
	CustomEvent = 182,
	CustomEventReceiver = 182,
	CylinderMesh = 182,
	DoubleConstrainedValue = 182,
	Flag = 182,
	FlagStand = 182,
	FloorWire = 182,
	FunctionalTest = 182,
	Glue = 182,
	GuiMain = 182,
	Hat = 182,
	Hint = 182,
	Hole = 182,
	HopperBin = 182,
	IntConstrainedValue = 182,
	ManualGlue = 182,
	ManualWeld = 182,
	Message = 182,
	MotorFeature = 182,
	Plane = 182,
	RocketPropulsion = 182,
	Rotate = 182,
	RotateP = 182,
	RotateV = 182,
	SelectionPartLasso = 182,
	SelectionPointLasso = 182,
	SkateboardPlatform = 182,
	Skin = 182,
	Snap = 182
}

function Create(instance, items)
	if type(instance) == "string" then
		instance = Instance.new(instance)
	end

	for k, item in pairs(items) do
		if type(k) == "number" then
			item.Parent = instance
		else
			instance[k] = item
		end
	end

	return instance
end

function Connect(object, callback)
	return object:connect(function(...)
		local v7 = { ... }
		spawn(function()
			callback(unpack(v7))
		end)
	end)
end

function GetScreen(parent)
	if parent == nil then
		return nil
	end

	while not parent:IsA("ScreenGui") do
		parent = parent.Parent

		if parent == nil then
			return nil
		end
	end

	return parent
end

local v7 = {}

function SetZIndex(guiObject, zIndex)
	if not v7[guiObject] then
		v7[guiObject] = true

		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = zIndex
		end

		local children = guiObject:GetChildren()

		for i = 1, #children do
			SetZIndex(children[i], zIndex)
		end

		v7[guiObject] = nil
	end
end

function SetZIndexOnChanged(p)
	return p.Changed:connect(function(p2)
		if p2 == "ZIndex" then
			SetZIndex(p, p.ZIndex)
		end
	end)
end

local image = "http://www.roblox.com/asset/?id=" .. 4525569834
local ContentProvider = game:GetService("ContentProvider")
ContentProvider:PreloadAsync({ image })
local floor = math.floor

local function iconDehash(p)
	return floor(p / 14 % 14), (floor(p % 14))
end

local function Icon(value, p)
	local v9, v10 = iconDehash(p)
	local vector = Vector2.new(256, 256)
	local v11

	if type(value) == "string" then
		v11 = value
		value = nil
	else
		v11 = "Frame"
	end

	local v12 = value or Create(v11, {
		Name = "Icon",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Create("ImageLabel", {
			Name = "IconMap",
			Active = false,
			BackgroundTransparency = 1,
			Image = image,
			Size = UDim2.new(vector.x / 16, 0, vector.y / 16, 0)
		})
	})

	if v12:FindFirstChild("IconMap") then
		v12.IconMap.Position = UDim2.new(-v10 - (2 * (v10 + 1) + 1) / 16, 0, -v9 - (2 * (v9 + 1) + 1) / 16, 0)

		if v12.Name == "Expand" then
			v12.IconMap.ImageColor3 = Color3.fromRGB(81, 81, 81)
		end
	end

	return v12
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ResetButtonColor(p)
	local active = p.Active
	p.Active = not active
	p.Active = active
end

local function ArrowGraphic(p, p2, p3, frame)
	local parent2 = Create("Frame", {
		Name = "Arrow Graphic",
		BorderSizePixel = 0,
		Size = UDim2.new(0, p, 0, p),
		Transparency = 1
	})

	if not frame then
		frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
	end

	local v10 = nil
	local transform

	if p2 == nil or p2 == "Up" then
		transform = function(p4, p5)
			return p4, p5
		end
	elseif p2 == "Down" then
		transform = function(p4, p5)
			return UDim2.new(0, p4.X.Offset, 0, p - p4.Y.Offset - 1), p5
		end
	elseif p2 == "Left" then
		transform = function(p4, p5)
			return UDim2.new(0, p4.Y.Offset, 0, p4.X.Offset), UDim2.new(0, p5.Y.Offset, 0, p5.X.Offset)
		end
	else
		transform = p2 == "Right" and function(p4, p5)
			return UDim2.new(0, p - p4.Y.Offset - 1, 0, p4.X.Offset), UDim2.new(0, p5.Y.Offset, 0, p5.X.Offset)
		end or v10
	end

	local scale

	if p3 then
		scale = function(p4, p5)
			return UDim2.new(p4.X.Offset / p, 0, p4.Y.Offset / p, 0), UDim2.new(p5.X.Offset / p, 0, p5.Y.Offset / p, 0)
		end
	else
		scale = function(p4, p5)
			return p4, p5
		end
	end

	local v11 = math.floor(p / 4)

	if p % 2 == 0 then
		local v12 = p / 2 - 1

		for i = 0, v12 do
			local clone = frame:Clone()
			local position, size = scale(transform(UDim2.new(0, v12 - i, 0, v11 + i), UDim2.new(0, (i + 1) * 2, 0, 1)))
			clone.Position = position
			clone.Size = size
			clone.Parent = parent2
		end
	else
		local v12 = (p - 1) / 2

		for i = 0, v12 do
			local clone = frame:Clone()
			local position, size = scale(transform(UDim2.new(0, v12 - i, 0, v11 + i), UDim2.new(0, i * 2 + 1, 0, 1)))
			clone.Position = position
			clone.Size = size
			clone.Parent = parent2
		end
	end

	if p % 4 > 1 then
		local clone = frame:Clone()
		local position, size = scale(transform(UDim2.new(0, 0, 0, p - v11 - 1), UDim2.new(0, p, 0, 1)))
		clone.Position = position
		clone.Size = size
		clone.Parent = parent2
	end

	return parent2
end

local function GripGraphic(vector, p, value, p2, frame)
	local parent2 = Create("Frame", {
		Name = "Grip Graphic",
		BorderSizePixel = 0,
		Size = UDim2.new(0, vector.x, 0, vector.y),
		Transparency = 1
	})

	if not frame then
		frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
	end

	local v10 = value or 2
	local scale

	if p2 then
		scale = function(p3)
			return UDim2.new(p3.X.Offset / vector.x, 0, p3.Y.Offset / vector.y, 0)
		end
	else
		scale = function(p3)
			return p3
		end
	end

	if p == "Vertical" then
		for i = 0, vector.x - 1, v10 do
			local clone = frame:Clone()
			clone.Size = scale(UDim2.new(0, 1, 0, vector.y))
			clone.Position = scale(UDim2.new(0, i, 0, 0))
			clone.Parent = parent2
		end
	elseif p == nil or p == "Horizontal" then
		for i = 0, vector.y - 1, v10 do
			local clone = frame:Clone()
			clone.Size = scale(UDim2.new(0, vector.x, 0, 1))
			clone.Position = scale(UDim2.new(0, 0, 0, i))
			clone.Parent = parent2
		end
	end

	return parent2
end

local v9 = {
	__index = {
		GetScrollPercent = function(self)
			return self.ScrollIndex / (self.TotalSpace - self.VisibleSpace)
		end,
		CanScrollDown = function(self)
			return self.ScrollIndex + self.VisibleSpace < self.TotalSpace
		end,
		CanScrollUp = function(self)
			return self.ScrollIndex > 0
		end,
		ScrollDown = function(self)
			self.ScrollIndex += self.PageIncrement
			self:Update()
		end,
		ScrollUp = function(self)
			self.ScrollIndex -= self.PageIncrement
			self:Update()
		end,
		ScrollTo = function(self, scrollIndex)
			self.ScrollIndex = scrollIndex
			self:Update()
		end,
		SetScrollPercent = function(self, p)
			self.ScrollIndex = math.floor((self.TotalSpace - self.VisibleSpace) * p + 0.5)
			self:Update()
		end
	}
}
v9.__index.CanScrollRight = v9.__index.CanScrollDown
v9.__index.CanScrollLeft = v9.__index.CanScrollUp
v9.__index.ScrollLeft = v9.__index.ScrollUp
v9.__index.ScrollRight = v9.__index.ScrollDown

function ScrollBar(p)
	local v10 = nil
	local GUI = Create("Frame", {
		Name = "ScrollFrame",
		Position = p and UDim2.new(0, 0, 1, -22) or UDim2.new(1, -22, 0, 0),
		Size = p and UDim2.new(1, 0, 0, 22) or UDim2.new(0, 22, 1, 0),
		BackgroundTransparency = 1,
		Create("ImageButton", {
			Name = "ScrollDown",
			Position = p and UDim2.new(1, -22, 0, 0) or UDim2.new(0, 0, 1, -22),
			Size = UDim2.new(0, 22, 0, 22),
			BackgroundColor3 = v5.Button,
			BorderColor3 = v5.Border
		}),
		Create("ImageButton", {
			Name = "ScrollUp",
			Size = UDim2.new(0, 22, 0, 22),
			BackgroundColor3 = v5.Button,
			BorderColor3 = v5.Border
		}),
		Create("ImageButton", {
			Name = "ScrollBar",
			Size = p and UDim2.new(1, -44, 1, 0) or UDim2.new(1, 0, 1, -44),
			Position = p and UDim2.new(0, 22, 0, 0) or UDim2.new(0, 0, 0, 22),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(0.94902, 0.94902, 0.94902),
			BorderColor3 = v5.Border,
			Create("ImageButton", {
				Name = "ScrollThumb",
				AutoButtonColor = false,
				Size = UDim2.new(0, 22, 0, 22),
				BackgroundColor3 = v5.Button,
				BorderColor3 = v5.Border
			})
		})
	})
	local v12 = Create("Frame", {
		Name = "Graphic",
		BorderSizePixel = 0,
		BackgroundColor3 = v5.Border
	})
	local scrollDown = GUI.ScrollDown
	local arrowGraphic = ArrowGraphic(11, p and "Right" or "Down", true, v12)
	arrowGraphic.Position = UDim2.new(0.5, -5.5, 0.5, -5.5)
	arrowGraphic.Parent = scrollDown
	local scrollUp = GUI.ScrollUp
	local arrowGraphic2 = ArrowGraphic(11, p and "Left" or "Up", true, v12)
	arrowGraphic2.Position = UDim2.new(0.5, -5.5, 0.5, -5.5)
	arrowGraphic2.Parent = scrollUp
	local scrollBar = GUI.ScrollBar
	local scrollThumb = scrollBar.ScrollThumb
	local gripGraphic = GripGraphic(Vector2.new(8.25, 8.25), p and "Vertical" or "Horizontal", 2, v12)
	gripGraphic.Position = UDim2.new(0.5, -4.125, 0.5, -4.125)
	gripGraphic.Parent = scrollThumb
	local object = setmetatable({
		GUI = GUI,
		ScrollIndex = 0,
		VisibleSpace = 0,
		TotalSpace = 0,
		PageIncrement = 1
	}, v9)
	local UpdateScrollThumb

	if p then
		UpdateScrollThumb = function()
			scrollThumb.Size = UDim2.new(object.VisibleSpace / object.TotalSpace, 0, 0, 22)

			if scrollThumb.AbsoluteSize.x < 22 then
				scrollThumb.Size = UDim2.new(0, 22, 0, 22)
			end

			local x = scrollBar.AbsoluteSize.x
			scrollThumb.Position = UDim2.new(object:GetScrollPercent() * (x - scrollThumb.AbsoluteSize.x) / x, 0, 0, 0)
		end
	else
		UpdateScrollThumb = function()
			scrollThumb.Size = UDim2.new(0, 22, object.VisibleSpace / object.TotalSpace, 0)

			if scrollThumb.AbsoluteSize.y < 22 then
				scrollThumb.Size = UDim2.new(0, 22, 0, 22)
			end

			local y = scrollBar.AbsoluteSize.y
			scrollThumb.Position = UDim2.new(0, 0, object:GetScrollPercent() * (y - scrollThumb.AbsoluteSize.y) / y, 0)
		end
	end

	local v16 = nil
	local v17 = nil
	local v18 = {
		BackgroundColor3 = v5.Border,
		BackgroundTransparency = 0
	}
	local v19 = {
		BackgroundColor3 = v5.Border,
		BackgroundTransparency = 0.7
	}

	local function Update()
		local totalSpace = object.TotalSpace
		local visibleSpace = object.VisibleSpace
		local scrollIndex = object.ScrollIndex

		if visibleSpace <= totalSpace then
			if scrollIndex > 0 then
				if totalSpace < scrollIndex + visibleSpace then
					object.ScrollIndex = totalSpace - visibleSpace
				end
			else
				object.ScrollIndex = 0
			end
		else
			object.ScrollIndex = 0
		end

		if object.UpdateCallback and object.UpdateCallback(object) == false then
			return
		end

		local canScrollDown = object:CanScrollDown()
		local canScrollUp = object:CanScrollUp()

		if canScrollDown ~= v16 then
			v16 = canScrollDown
			scrollDown.Active = canScrollDown
			scrollDown.AutoButtonColor = canScrollDown
			local children = arrowGraphic:GetChildren()
			local v20 = canScrollDown and v18 or v19

			for i = 1, #children do
				Create(children[i], v20)
			end
		end

		if canScrollUp ~= v17 then
			v17 = canScrollUp
			scrollUp.Active = canScrollUp
			scrollUp.AutoButtonColor = canScrollUp
			local children = arrowGraphic2:GetChildren()
			local v20 = canScrollUp and v18 or v19

			for i = 1, #children do
				Create(children[i], v20)
			end
		end

		scrollThumb.Visible = canScrollDown or canScrollUp
		UpdateScrollThumb()
	end

	object.Update = Update
	SetZIndexOnChanged(GUI)
	local v20 = Create("ImageButton", {
		Name = "MouseDrag",
		Position = UDim2.new(-0.25, 0, -0.25, 0),
		Size = UDim2.new(1.5, 0, 1.5, 0),
		Transparency = 1,
		AutoButtonColor = false,
		Active = true,
		ZIndex = 10
	})
	local now = 0
	scrollDown.MouseButton1Down:connect(function()
		now = tick()
		local v21 = now
		local mouseButton1UpConnection = nil
		mouseButton1UpConnection = v20.MouseButton1Up:connect(function()
			now = tick()
			v20.Parent = nil
			ResetButtonColor(scrollDown) -- equivalent call inferred; original call site unknown
			mouseButton1UpConnection:disconnect()
			v10 = nil
		end)
		v20.Parent = GetScreen(GUI)
		object:ScrollDown()
		task.wait(0.2)

		while now == v21 do
			object:ScrollDown()

			if not object:CanScrollDown() then
				break
			end

			task.wait()
		end
	end)
	scrollDown.MouseButton1Up:connect(function()
		now = tick()
	end)
	scrollUp.MouseButton1Down:connect(function()
		now = tick()
		local v21 = now
		local mouseButton1UpConnection = nil
		mouseButton1UpConnection = v20.MouseButton1Up:connect(function()
			now = tick()
			v20.Parent = nil
			ResetButtonColor(scrollUp) -- equivalent call inferred; original call site unknown
			mouseButton1UpConnection:disconnect()
			v10 = nil
		end)
		v20.Parent = GetScreen(GUI)
		object:ScrollUp()
		task.wait(0.2)

		while now == v21 do
			object:ScrollUp()

			if not object:CanScrollUp() then
				break
			end

			task.wait()
		end
	end)
	scrollUp.MouseButton1Up:connect(function()
		now = tick()
	end)

	if p then
		scrollBar.MouseButton1Down:connect(function(p2, _)
			now = tick()
			local v21 = now
			local mouseButton1UpConnection = nil
			mouseButton1UpConnection = v20.MouseButton1Up:connect(function()
				now = tick()
				v20.Parent = nil
				ResetButtonColor(scrollUp) -- equivalent call inferred; original call site unknown
				mouseButton1UpConnection:disconnect()
				v10 = nil
			end)
			v20.Parent = GetScreen(GUI)

			if scrollThumb.AbsolutePosition.x < p2 then
				object:ScrollTo(object.ScrollIndex + object.VisibleSpace)
				task.wait(0.2)

				while now == v21 and not (p2 < scrollThumb.AbsolutePosition.x + scrollThumb.AbsoluteSize.x) do
					object:ScrollTo(object.ScrollIndex + object.VisibleSpace)
					task.wait()
				end
			else
				object:ScrollTo(object.ScrollIndex - object.VisibleSpace)
				task.wait(0.2)

				while now == v21 and not (scrollThumb.AbsolutePosition.x < p2) do
					object:ScrollTo(object.ScrollIndex - object.VisibleSpace)
					task.wait()
				end
			end
		end)
	else
		scrollBar.MouseButton1Down:connect(function(_, p2)
			now = tick()
			local v21 = now
			local mouseButton1UpConnection = nil
			mouseButton1UpConnection = v20.MouseButton1Up:connect(function()
				now = tick()
				v20.Parent = nil
				ResetButtonColor(scrollUp) -- equivalent call inferred; original call site unknown
				mouseButton1UpConnection:disconnect()
				v10 = nil
			end)
			v20.Parent = GetScreen(GUI)

			if scrollThumb.AbsolutePosition.y < p2 then
				object:ScrollTo(object.ScrollIndex + object.VisibleSpace)
				task.wait(0.2)

				while now == v21 and not (p2 < scrollThumb.AbsolutePosition.y + scrollThumb.AbsoluteSize.y) do
					object:ScrollTo(object.ScrollIndex + object.VisibleSpace)
					task.wait()
				end
			else
				object:ScrollTo(object.ScrollIndex - object.VisibleSpace)
				task.wait(0.2)

				while now == v21 and not (scrollThumb.AbsolutePosition.y < p2) do
					object:ScrollTo(object.ScrollIndex - object.VisibleSpace)
					task.wait()
				end
			end
		end)
	end

	if p then
		scrollThumb.MouseButton1Down:connect(function(p2, _)
			now = tick()
			local v21 = p2 - scrollThumb.AbsolutePosition.x
			local mouseButton1UpConnection = nil
			local mouseMovedConnection = v20.MouseMoved:connect(function(p3, _)
				local x = scrollBar.AbsolutePosition.x
				local v22 = scrollBar.AbsoluteSize.x - scrollThumb.AbsoluteSize.x
				local v23 = x + v22
				local v24 = p3 - v21

				if v24 < x and x then
					v24 = x
				elseif v23 < v24 then
					v24 = v23 or v24
				end

				object:SetScrollPercent((v24 - x) / v22)
			end)
			mouseButton1UpConnection = v20.MouseButton1Up:connect(function()
				now = tick()
				v20.Parent = nil
				ResetButtonColor(scrollThumb) -- equivalent call inferred; original call site unknown
				mouseMovedConnection:disconnect()
				mouseMovedConnection = nil
				mouseButton1UpConnection:disconnect()
				v10 = nil
			end)
			v20.Parent = GetScreen(GUI)
		end)
	else
		scrollThumb.MouseButton1Down:connect(function(_, p2)
			now = tick()
			local v21 = p2 - scrollThumb.AbsolutePosition.y
			local mouseButton1UpConnection = nil
			local mouseMovedConnection = v20.MouseMoved:connect(function(_, p3)
				local y = scrollBar.AbsolutePosition.y
				local v22 = scrollBar.AbsoluteSize.y - scrollThumb.AbsoluteSize.y
				local v23 = y + v22
				local v24 = p3 - v21

				if v24 < y and y then
					v24 = y
				elseif v23 < v24 then
					v24 = v23 or v24
				end

				object:SetScrollPercent((v24 - y) / v22)
			end)
			mouseButton1UpConnection = v20.MouseButton1Up:connect(function()
				now = tick()
				v20.Parent = nil
				ResetButtonColor(scrollThumb) -- equivalent call inferred; original call site unknown
				mouseMovedConnection:disconnect()
				mouseMovedConnection = nil
				mouseButton1UpConnection:disconnect()
				v10 = nil
			end)
			v20.Parent = GetScreen(GUI)
		end)
	end

	function object:Destroy()
		GUI:Destroy()
		v20:Destroy()

		for k in pairs(object) do
			object[k] = nil
		end

		setmetatable(object, nil)
	end

	Update()
	return object
end

local parent = script.Parent
Create(parent, {
	BackgroundColor3 = v5.Field,
	BorderColor3 = v5.Border,
	Active = true
})
local parent7 = Create("Frame", {
	Name = "List",
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Position = UDim2.new(0, 0, 0, total),
	Size = UDim2.new(1, -22, 1, -total),
	Parent = parent
})
local v11 = ScrollBar(false)
v11.PageIncrement = 1
Create(v11.GUI, {
	Position = UDim2.new(1, -22, 0, total),
	Size = UDim2.new(0, 22, 1, -total),
	Parent = parent
})
local v12 = ScrollBar(true)
v12.PageIncrement = 22
Create(v12.GUI, {
	Position = UDim2.new(0, 0, 1, -22),
	Size = UDim2.new(1, -22, 0, 22),
	Visible = false,
	Parent = parent
})
local parent8 = Create("Frame", {
	Name = "Header",
	BackgroundColor3 = v5.Background,
	BorderColor3 = v5.Border,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, total),
	Parent = parent,
	Create("TextLabel", {
		Text = "Explorer",
		BackgroundTransparency = 1,
		TextColor3 = v5.Text,
		TextXAlignment = "Left",
		TextScaled = true,
		Font = "SourceSans",
		FontSize = fontSize,
		Position = UDim2.new(0, 4, 1, -18),
		Size = UDim2.new(1, -4, 0, 18)
	})
})
SetZIndexOnChanged(parent)
local v14 = Create("TextLabel", {
	Name = "TextWidth",
	TextXAlignment = "Left",
	TextYAlignment = "Center",
	Font = "SourceSans",
	FontSize = fontSize,
	Text = "",
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	Visible = false,
	Parent = parent
})

local function getTextWidth(name)
	v14.Text = name
	return v14.TextBounds.x
end

local v15 = {}
local v16 = {}
local totalSpace2 = 0
local r

r = function(list)
	for i = 1, #list do
		v15[#v15 + 1] = list[i]
		local v18 = list[i].Depth * 25 + 2 + 24 + 4 + getTextWidth(list[i].Object.Name) + 4 + 24

		if totalSpace2 < v18 then
			totalSpace2 = v18
		end

		if list[i].Expanded then
			r(list[i])
		end
	end
end

local function rawUpdateSize()
	v12.TotalSpace = totalSpace2
	v12.VisibleSpace = parent7.AbsoluteSize.x
	v12:Update()
	local visible = v12:CanScrollDown() or v12:CanScrollUp()
	v12.GUI.Visible = visible
	parent7.Size = UDim2.new(1, -22, 1, -22 * (visible and 1 or 0) - total)
	v11.VisibleSpace = math.ceil(parent7.AbsoluteSize.y / 25)
	v11.GUI.Size = UDim2.new(0, 22, 1, -22 * (visible and 1 or 0) - total)
	v11.TotalSpace = #v15 + 1
	v11:Update()
end

local function rawUpdateList()
	v15 = {}
	totalSpace2 = 0
	r(v16[game])
	rawUpdateSize()
end

local flag = false

local function updateList()
	if flag then
		return
	end

	flag = true
	task.wait(0.25)
	flag = false
	rawUpdateList()
end

local flag2 = false

local function updateScroll()
	if flag2 then
		return
	end

	flag2 = true
	task.wait(0.25)
	flag2 = false
	v11:Update()
end

local getSelection = script.Parent:FindFirstChild("GetSelection")

if not getSelection then
	getSelection = Create("BindableFunction", {
		Name = "GetSelection"
	})
	getSelection.Parent = script.Parent
end

local setSelection = script.Parent:WaitForChild("SetSelection", 2)

if not setSelection then
	setSelection = Create("BindableFunction", {
		Name = "SetSelection"
	})
	setSelection.Parent = script.Parent
end

local explorerSelectionChanged = workspace:FindFirstChild("ExplorerSelectionChanged")

if not explorerSelectionChanged then
	explorerSelectionChanged = Create("BindableEvent", {
		Name = "ExplorerSelectionChanged"
	})
	explorerSelectionChanged.Parent = workspace
end

local explorerSelectionChangedToMain = workspace:FindFirstChild("ExplorerSelectionChangedToMain")

if not explorerSelectionChangedToMain then
	explorerSelectionChangedToMain = Create("BindableEvent", {
		Name = "ExplorerSelectionChangedToMain"
	})
	explorerSelectionChangedToMain.Parent = workspace
end

local list2 = {}
local selected = {}
local v20 = {
	Selected = selected,
	List = list2
}

local function addObject(p)
	local v21 = false
	local v22 = false

	if selected[p] then
		return false, false
	end

	local v23 = v16[p]

	if not v23 then
		return v21, v22
	end

	table.insert(list2, p)
	selected[p] = true
	v23.Selected = true
	local parent2 = v23.Parent

	while parent2 do
		if not parent2.Expanded then
			parent2.Expanded = true
			v21 = true
		end

		parent2 = parent2.Parent
	end

	v22 = true
	return v21, v22
end

function v20:Set(list)
	local v21 = false
	local v22 = false
	insertFrame.Visible = false
	insertScriptFrame.Visible = false
	insertLocalScriptFrame.Visible = false
	insertModuleScriptFrame.Visible = false

	if list[1] then
		if list[1]:IsA("LuaSourceContainer") then
			ShowScript(list[1])
		else
			local viewScriptFrame = parent.Parent:WaitForChild("ViewScriptFrame")
			viewScriptFrame.Visible = false
		end

		if #list[1]:GetChildren() > 0 then
			parent8.GroupButton.Text = "Select children"
		else
			parent8.GroupButton.Text = "Group"
		end
	else
		parent8.GroupButton.Text = "Group"
	end

	if _G.GetObjectValue then
		_G.GetObjectValue = false
		_G.ObjectValue = list[1]
	else
		if #list2 > 0 then
			for i = 1, #list2 do
				local v23 = list2[i]
				local v24 = v16[v23]

				if not v24 then
					continue
				end

				v24.Selected = false
				selected[v23] = nil
			end

			list2 = {}
			v20.List = list2
			v22 = true
		end

		for i = 1, #list do
			local v23, v24 = addObject(list[i])
			v21 = v23 or v21
			v22 = v24 or v22
		end

		if v21 then
			rawUpdateList()
			v22 = true
		elseif v22 then
			v11:Update()
		end

		if v22 then
			explorerSelectionChanged:Fire()
			explorerSelectionChangedToMain:Fire()
		end
	end
end

function v20:Add(p)
	local v21, v22 = addObject(p)

	if v21 then
		rawUpdateList()
		explorerSelectionChanged:Fire()
		explorerSelectionChangedToMain:Fire()
	elseif v22 then
		v11:Update()
		explorerSelectionChanged:Fire()
		explorerSelectionChangedToMain:Fire()
	end

	if #list2 == 1 and #list2[1]:GetChildren() > 0 then
		parent8.GroupButton.Text = "Select children"
	else
		parent8.GroupButton.Text = "Group"
	end
end

function v20:Remove(p, p2)
	local v21 = selected[p] and v16[p]

	if v21 then
		v21.Selected = false
		selected[p] = nil

		for i = 1, #list2 do
			if list2[i] ~= p then
				continue
			end

			table.remove(list2, i)
			break
		end

		if not p2 then
			v11:Update()
		end

		if #list2 == 1 and #list2[1]:GetChildren() > 0 then
			parent8.GroupButton.Text = "Select children"
		else
			parent8.GroupButton.Text = "Group"
		end

		explorerSelectionChanged:Fire()
		explorerSelectionChangedToMain:Fire()
	end
end

function v20:Get()
	local result = {}

	for i = 1, #list2 do
		result[i] = list2[i]
	end

	return result
end

function setSelection.OnInvoke(...)
	v20:Set(...)
end

function getSelection.OnInvoke()
	return v20:Get()
end

local function cancelReparentDrag() end

local function cancelSelectDrag() end

local v21 = {}
local connections2 = {}
local v22 = Create("ImageButton", {
	Name = "MouseDrag",
	Position = UDim2.new(-0.25, 0, -0.25, 0),
	Size = UDim2.new(1.5, 0, 1.5, 0),
	Transparency = 1,
	AutoButtonColor = false,
	Active = true,
	ZIndex = 10
})

local function dragSelect(p, p2, p3)
	local connection = nil
	conDrag = v22.MouseMoved:connect(function(p4, p5)
		local v23 = Vector2.new(p4, p5) - parent7.AbsolutePosition
		local absoluteSize = parent7.AbsoluteSize

		if v23.x < 0 or v23.x > absoluteSize.x or v23.y < 0 or v23.y > absoluteSize.y then
			return
		end

		local v24 = math.ceil(v23.y / 25 + 12) + v11.ScrollIndex

		for i = v24 < p and v24 or p, p < v24 and v24 or p do
			local v25 = v15[i]

			if not v25 then
				continue
			end

			if p2 then
				v20:Add(v25.Object)
			else
				v20:Remove(v25.Object)
			end
		end

		p = v24
	end)

	local function cancelSelectDrag2()
		v22.Parent = nil
		conDrag:disconnect()
		connection:disconnect()

		local function cancelSelectDrag3() end

		cancelSelectDrag = cancelSelectDrag3
	end

	cancelSelectDrag = cancelSelectDrag2
	connection = v22[p3]:connect(cancelSelectDrag)
	v22.Parent = GetScreen(parent7)
end

local function dragReparent(object, _, _, _)
	local v23 = Create("Frame", {
		Transparency = 1,
		Visible = false,
		Create("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 1)
		}),
		Create("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.1,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0)
		}),
		Create("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.1,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 1)
		}),
		Create("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0)
		})
	})
	SetZIndex(v23, 9)
	local Y = -999
	conDrag = v22.MouseMoved:connect(function(p, p2)
		local vector = Vector2.new(p, p2)

		if Y == -999 then
			Y = vector.Y
		end

		local v24 = vector.Y - Y

		if v24 > 10 then
			if v11.VisibleSpace - 1 > 1 then
				v11:ScrollTo(v11.ScrollIndex - 1)
			else
				v11:ScrollTo(v11.ScrollIndex - v11.VisibleSpace)
			end

			Y = vector.Y
		elseif v24 < -10 then
			if v11.VisibleSpace - 1 > 1 then
				v11:ScrollTo(v11.ScrollIndex + 1)
			else
				v11:ScrollTo(v11.ScrollIndex + v11.VisibleSpace)
			end

			Y = vector.Y
		end
	end)
	local v24 = v20.Selected[object]

	if parent8["Select MultiButton"].BackgroundColor3 == Color3.new(1, 1, 1) then
		if v.Selectable then
			v20:Set({ object })
		end
	elseif v24 then
		v20:Remove(object)
	elseif v.Selectable then
		v20:Add(object)
	end
end

local v23 = Create("ImageButton", {
	Name = "Entry",
	Transparency = 1,
	AutoButtonColor = false,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 24),
	Create("Frame", {
		Name = "IndentFrame",
		BackgroundTransparency = 1,
		BackgroundColor3 = v5.Selected,
		BorderColor3 = v5.BorderSelected,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Create(Icon("ImageButton", 0), {
			Name = "Expand",
			AutoButtonColor = false,
			Position = UDim2.new(0, -22, 0.5, -11),
			Size = UDim2.new(0, 22, 0, 22)
		}),
		Create(Icon(nil, 0), {
			Name = "ExplorerIcon",
			Position = UDim2.new(0, 3, 0.5, -11),
			Size = UDim2.new(0, 22, 0, 22)
		}),
		Create("TextLabel", {
			Name = "EntryText",
			BackgroundTransparency = 1,
			TextColor3 = v5.Text,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Font = "SourceSans",
			FontSize = fontSize,
			Text = "",
			Position = UDim2.new(0, 30, 0, 0),
			Size = UDim2.new(1, -2, 1, 0)
		}),
		Create("ImageButton", {
			Name = "Plus",
			AutoButtonColor = false,
			Position = UDim2.new(1, -24, 0, 0),
			Size = UDim2.new(0, 24, 0, 24),
			ZIndex = 2,
			Image = "rbxassetid://1039338162",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ImageTransparency = 0.5
		})
	})
})

function v11.UpdateCallback(data)
	for _, connection in pairs(connections) do
		connection:disconnect()
	end

	connections = {}

	for i = 1, data.VisibleSpace do
		local v24 = v15[i + data.ScrollIndex]

		if v24 then
			local v25 = v21[i]

			if not v25 then
				v25 = Create(v23:Clone(), {
					Position = UDim2.new(0, 2, 0, (i - 1) * 25 + 2),
					Size = UDim2.new(0, totalSpace2, 0, 24),
					ZIndex = parent7.ZIndex
				})
				v21[i] = v25
				local expand = v25.IndentFrame.Expand
				local v26 = i
				expand.MouseEnter:connect(function()
					local v28 = v15[v26 + data.ScrollIndex]

					if #v28 > 0 then
						if v28.Expanded then
							Icon(expand, 180)
						else
							Icon(expand, 179)
						end
					end
				end)
				local v28 = i
				local expand2 = expand
				expand.MouseLeave:connect(function()
					local v30 = v15[v28 + data.ScrollIndex]

					if #v30 > 0 then
						if v30.Expanded then
							Icon(expand2, 166)
						else
							Icon(expand2, 165)
						end
					end
				end)
				local v30 = i
				expand.MouseButton1Down:connect(function()
					local v31 = v15[v30 + data.ScrollIndex]

					if #v31 > 0 then
						v31.Expanded = not v31.Expanded
						rawUpdateList()
					end
				end)
				local v31 = i
				v25.MouseButton1Down:connect(function(p, p2)
					local v32 = v15[v31 + data.ScrollIndex]

					if v.Modifiable then
						local vector = Vector2.new(p, p2)
						dragReparent(v32.Object, v25:Clone(), vector, Vector2.new(-90, 0))
					elseif v.Selectable then
						if parent8["Select MultiButton"].BackgroundColor3 == Color3.new(1, 1, 1) then
							dragSelect(v31 + data.ScrollIndex, true, "MouseButton1Up")
						elseif v20.Selected[v32.Object] then
							dragSelect(v31 + data.ScrollIndex, false, "MouseButton1Up")
						else
							dragSelect(v31 + data.ScrollIndex, true, "MouseButton1Up")
						end
					end
				end)
				local v32 = i
				v25.MouseButton2Down:connect(function()
					if not v.Selectable then
						return
					end

					local v33 = v15[v32 + data.ScrollIndex]

					if v20.Selected[v33.Object] then
						v20:Remove(v33.Object)
						dragSelect(v32 + data.ScrollIndex, false, "MouseButton2Up")
					else
						v20:Add(v33.Object)
						dragSelect(v32 + data.ScrollIndex, true, "MouseButton2Up")
					end
				end)
				v25.Parent = parent7
			end

			v25.Visible = true
			local object = v24.Object

			if #v24 == 0 then
				v25.IndentFrame.Expand.Visible = false
			else
				if v24.Expanded then
					Icon(v25.IndentFrame.Expand, 166)
				else
					Icon(v25.IndentFrame.Expand, 165)
				end

				v25.IndentFrame.Expand.Visible = true
			end

			Icon(v25.IndentFrame.ExplorerIcon, v6[object.ClassName] or 0)
			local v26 = v24.Depth * 25
			v25.IndentFrame.Position = UDim2.new(0, v26, 0, 0)
			v25.IndentFrame.Size = UDim2.new(1, -v26, 1, 0)

			if connections2[v25] then
				connections2[v25]:disconnect()
			end

			local entryText = v25.IndentFrame.EntryText
			entryText.Text = object.Name
			connections2[v25] = v24.Object.Changed:connect(function(p)
				if p == "Name" then
					entryText.Text = object.Name
				end
			end)
			v25.IndentFrame.Plus.Position = UDim2.new(0, entryText.TextBounds.X + 22 + 10, 0, 0)
			local object2 = object
			connections[#connections + 1] = v25.IndentFrame.Plus.MouseButton1Down:connect(function()
				part = object2
				insertFrame.Position = UDim2.new(1, -400, 0, v25.AbsolutePosition.Y + 60)
				insertFrame.Size = UDim2.new(
					0,
					200,
					0,
					(math.min(535, insertFrame.Parent.AbsoluteSize.Y - (v25.AbsolutePosition.Y + 60) - 25))
				)
				insertFrame.Visible = true
			end)
			v25.IndentFrame.Transparency = v24.Selected and 0 or 1
			entryText.TextColor3 = v5[v24.Selected and "TextSelected" or "Text"]
			v25.Size = UDim2.new(0, totalSpace2, 0, 24)
		elseif v21[i] then
			v21[i].Visible = false
		end
	end

	for i = data.VisibleSpace + 1, data.TotalSpace do
		local v24 = v21[i]

		if not v24 then
			continue
		end

		v21[i] = nil
		v24:Destroy()
	end
end

function v12.UpdateCallback(_)
	for i = 1, v11.VisibleSpace do
		if not v15[i + v11.ScrollIndex] then
			continue
		end

		local v24 = v21[i]

		if v24 then
			v24.Position = UDim2.new(0, 2 - v12.ScrollIndex, 0, (i - 1) * 25 + 2)
		end
	end
end

Connect(parent7.Changed, function(p)
	if p == "AbsoluteSize" then
		rawUpdateSize()
	end
end)
parent.MouseWheelForward:connect(function()
	if v11.VisibleSpace - 1 > 6 then
		v11:ScrollTo(v11.ScrollIndex - 6)
	else
		v11:ScrollTo(v11.ScrollIndex - v11.VisibleSpace)
	end
end)
parent.MouseWheelBackward:connect(function()
	if v11.VisibleSpace - 1 > 6 then
		v11:ScrollTo(v11.ScrollIndex + 6)
	else
		v11:ScrollTo(v11.ScrollIndex + v11.VisibleSpace)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function insert(list, p, p2)
	for i = #list, p, -1 do
		local v24 = list[i]
		v24.Index = i + 1
		list[i + 1] = v24
	end

	p2.Index = p
	list[p] = p2
end

local function remove(list, p)
	local v24 = list[p]

	for i = p + 1, #list do
		local v25 = list[i]
		v25.Index = i - 1
		list[i - 1] = v25
	end

	list[#list] = nil
	v24.Index = 0
	return v24
end

local function depth(parent2)
	local v24 = -1

	while parent2 do
		parent2 = parent2.Parent
		v24 += 1
	end

	return v24
end

local v24 = {}

local function nodeIsVisible(p)
	local parent2 = p.Parent
	local expanded = true

	while parent2 and expanded do
		expanded = expanded and parent2.Expanded
		parent2 = parent2.Parent
	end

	return expanded
end

local function removeObject(p)
	local v25 = v16[p]

	if not v25 then
		return
	end

	local parent2 = v25.Parent
	local expanded = true

	while parent2 and expanded do
		expanded = expanded and parent2.Expanded
		parent2 = parent2.Parent
	end

	v20:Remove(p, true)
	local parent3 = v25.Parent
	local index = v25.Index
	local v26 = parent3[index]

	for i = index + 1, #parent3 do
		local v27 = parent3[i]
		v27.Index = i - 1
		parent3[i - 1] = v27
	end

	parent3[#parent3] = nil
	v26.Index = 0
	v16[p] = nil
	v24[p]:disconnect()
	v24[p] = nil

	if expanded then
		updateList()
		return
	end

	local parent4 = parent3.Parent
	local expanded2 = true

	while parent4 and expanded2 do
		expanded2 = expanded2 and parent4.Expanded
		parent4 = parent4.Parent
	end

	if expanded2 then
		updateScroll()
	end
end

local function moveObject(parent2, p)
	local v25 = v16[parent2]

	if not v25 then
		return
	end

	local parent9 = v16[p]

	if not parent9 then
		return
	end

	local parent3 = v25.Parent
	local expanded = true

	while parent3 and expanded do
		expanded = expanded and parent3.Expanded
		parent3 = parent3.Parent
	end

	local parent4 = v25.Parent
	local index = v25.Index
	local v27 = parent4[index]

	for i = index + 1, #parent4 do
		local v28 = parent4[i]
		v28.Index = i - 1
		parent4[i - 1] = v28
	end

	parent4[#parent4] = nil
	v27.Index = 0
	v25.Parent = parent9
	local depth3 = -1

	while parent2 do
		parent2 = parent2.Parent
		depth3 += 1
	end

	v25.Depth = depth3
	local r2

	r2 = function(list, depth2)
		for i = 1, #list do
			list[i].Depth = depth2
			r2(list[i], depth2 + 1)
		end
	end

	local depth4 = v25.Depth + 1

	for i = 1, #v25 do
		v25[i].Depth = depth4
		r2(v25[i], depth4 + 1)
	end

	insert(parent9, #parent9 + 1, v25) -- equivalent call inferred; original call site unknown

	if not expanded then
		local parent5 = v25.Parent
		local expanded2 = true

		while parent5 and expanded2 do
			expanded2 = expanded2 and parent5.Expanded
			parent5 = parent5.Parent
		end

		if not expanded2 then
			local parent6 = v25.Parent.Parent
			local expanded3 = true

			while parent6 and expanded3 do
				expanded3 = expanded3 and parent6.Expanded
				parent6 = parent6.Parent
			end

			if expanded3 then
				updateScroll()
			end

			return
		end
	end

	updateList()
end

local function check(instance)
	return instance.AncestryChanged
end

local function addObject2(instance, p)
	if script and not pcall(check, instance) then
		return
	end

	local parent5 = v16[instance.Parent]

	if not parent5 then
		return
	end

	if instance.ClassName == "" or instance.ClassName == "Terrain" or instance.ClassName == "PublishService" or instance.ClassName == "VideoCaptureService" or instance.Name == "FlyCameraLocal" or instance.Name == "StudioGui" or instance.Name == "GetWorkspaceFunction" or instance.Name:sub(
		1,
		24
	) == "ExplorerSelectionChanged" or instance.Name == "ServerFunctions" or instance.Name == "MainConvertModule" or instance.Name == "StudioLiteFolder" or instance.Name:sub(
		1,
		3
	) == "SL_" or instance.Name == "FlyCameraFocus" or instance.Name == localPlayer.Name and instance.Parent == workspace then
		return
	end

	local parent2 = instance
	local depth2 = -1
	local v27 = {
		Object = instance,
		Parent = parent5,
		Index = 0,
		Expanded = false,
		Selected = false,
		Depth = 0
	}

	while parent2 do
		parent2 = parent2.Parent
		depth2 += 1
	end

	v27.Depth = depth2
	v24[instance] = Connect(instance.AncestryChanged, function(p2, p3)
		if p2 == instance then
			if p3 == nil then
				removeObject(p2)
			else
				moveObject(p2, p3)
			end
		end
	end)
	v16[instance] = v27
	insert(parent5, #parent5 + 1, v27) -- equivalent call inferred; original call site unknown

	if not p then
		local parent3 = v27.Parent
		local expanded = true

		while parent3 and expanded do
			expanded = expanded and parent3.Expanded
			parent3 = parent3.Parent
		end

		if expanded then
			updateList()
			return
		end

		local parent4 = v27.Parent.Parent
		local expanded2 = true

		while parent4 and expanded2 do
			expanded2 = expanded2 and parent4.Expanded
			parent4 = parent4.Parent
		end

		if expanded2 then
			updateScroll()
		end
	end
end

v16[game] = {
	Object = game,
	Parent = nil,
	Index = 0,
	Expanded = true
}
Connect(game.DescendantAdded, addObject2)
Connect(game.DescendantRemoving, removeObject)

local function get(instance)
	return instance:GetChildren()
end

local r2

r2 = function(object)
	local success, result = pcall(get, object)

	if success then
		addObject2(object, true)

		for i = 1, #result do
			r2(result[i])
		end
	end
end

r2(game.Workspace)
r2(game.Players)
r2(game.Lighting)
r2(game.ReplicatedFirst)
r2(game.ReplicatedStorage)
_G.sss = Instance.new("Folder")
_G.sss.Name = "ServerScriptService"
_G.sss.Parent = game
_G.ss = Instance.new("Folder")
_G.ss.Name = "ServerStorage"
_G.ss.Parent = game
task.wait()
r2(game.StarterGui)
r2(game.StarterPack)
r2(game.StarterPlayer)
r2(game.Teams)
v11.VisibleSpace = math.ceil(parent7.AbsoluteSize.y / 25)
updateList()

function RemoveGUIDraggerHandles()
	if _G.SL_ImageLabelsFolderClone then
		_G.SL_ImageLabelsFolderClone:Destroy()
		CloneStarterGuiForEditOrPlayModule:Edit()
	end

	local character = game.Players.LocalPlayer.Character

	if character:FindFirstChild("SL_MoveLocal") then
		character:FindFirstChild("SL_MoveLocal"):Destroy()
	end

	if character:FindFirstChild("SL_SizeLocal") then
		character:FindFirstChild("SL_SizeLocal"):Destroy()
	end
end

local v25 = {}
local v26 = parent8.AbsoluteSize.X / 6
local v27 = total - total2
local v28 = 6

local function makeButton(p, _, text)
	local parent2 = Create("TextButton", {
		Name = text .. "Button",
		Visible = v.Modifiable and v.Selectable,
		Position = UDim2.new((v28 - 1) / 6, 0, 0, 0),
		BorderSizePixel = 1,
		Size = UDim2.new(0.16666666666666666, 0, 0, v27),
		Text = text,
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextSize = 9,
		TextWrap = true,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		Parent = parent8
	})
	parent2.LineHeight = 0.95
	Create(Icon("Frame", p), {
		Name = text .. "Frame",
		Visible = v.Modifiable and v.Selectable,
		Position = UDim2.new(1, -(v26 * 0.7), 0, 0),
		BorderSizePixel = 1,
		Size = UDim2.new(0, v26 * 0.4, 0, v27 * 0.4),
		Parent = parent2
	})
	v28 -= 1
	v25[#v25 + 1] = parent2
	return parent2
end

local clones = {}

local function delete(p)
	p.Parent = nil
end

makeButton(171, 171, "Select Multi").MouseButton1Click:connect(function()
	RemoveGUIDraggerHandles()

	if not v.Modifiable then
		return
	end

	local selectMultiButton = parent8["Select MultiButton"]

	if selectMultiButton.BackgroundColor3 == Color3.new(0.7, 1, 0.7) then
		selectMultiButton.BackgroundColor3 = Color3.new(1, 1, 1)
	else
		selectMultiButton.BackgroundColor3 = Color3.new(0.7, 1, 0.7)
	end
end)
makeButton(173, 173, "Group").MouseButton1Click:connect(function()
	RemoveGUIDraggerHandles()

	if not v.Modifiable then
		return
	end

	local list = v20.List

	if parent8.GroupButton.Text == "Select children" and #list == 1 then
		v20:Set(list[1]:GetChildren())
		parent8.GroupButton.Text = "Group"
		parent8["Select MultiButton"].BackgroundColor3 = Color3.new(0.7, 1, 0.7)
	else
		if not (#list > 0) then
			spawn(function()
				script.Parent.Parent.WarningText.Text = "Select something first."
				script.Parent.Parent.WarningText.Visible = true
				task.wait(2)
				script.Parent.Parent.WarningText.Visible = false
			end)
			return
		end

		local parent2 = list[1].Parent

		for i = 1, #list do
			if list[i].Parent == parent2 then
				if ("Workspace Players Lighting Replicate Starter"):find(list[i].ClassName:sub(1, 7), 1, true) then
					script.Parent.Parent.WarningText.Text = "Can't group " .. list[i].ClassName
					script.Parent.Parent.WarningText.Visible = true
					task.wait(3)
					script.Parent.Parent.WarningText.Visible = false
					return
				end
			else
				script.Parent.Parent.WarningText.Text = "Must have same parent."
				script.Parent.Parent.WarningText.Visible = true
				task.wait(3)
				script.Parent.Parent.WarningText.Visible = false
				return
			end
		end

		local model = Instance.new("Model")
		model.Parent = list[1].Parent

		for i = 1, #list do
			list[i].Parent = model
		end

		task.wait(0.1)
		v20:Set({ model })
		parent8["Select MultiButton"].BackgroundColor3 = Color3.new(1, 1, 1)
	end
end)
makeButton(174, 174, "Cut/ delete").MouseButton1Click:connect(function()
	RemoveGUIDraggerHandles()

	if not v.Modifiable then
		return
	end

	clones = {}
	local list = v20.List

	if not (#list > 0) then
		spawn(function()
			script.Parent.Parent.WarningText.Text = "Select something first."
			script.Parent.Parent.WarningText.Visible = true
			task.wait(2)
			script.Parent.Parent.WarningText.Visible = false
		end)
		return
	end

	local flag3 = false
	local v29 = {}

	for i = 1, #list do
		local v30 = i
		pcall(function()
			local clone = list[v30]:Clone()

			if clone then
				if list[v30]:IsDescendantOf(game.StarterGui) then
					flag3 = true
				end

				table.insert(clones, clone)
				table.insert(v29, list[v30])
			end
		end)
	end

	for i = 1, #v29 do
		if v29[i] ~= _G.sss and v29[i] ~= _G.ss then
			pcall(delete, v29[i])
		end
	end

	if flag3 then
		CloneStarterGuiForEditOrPlayModule:Edit()
	end

	local viewScriptFrame = parent.Parent:WaitForChild("ViewScriptFrame")
	viewScriptFrame.Visible = false
end)
makeButton(175, 175, "Copy").MouseButton1Click:connect(function()
	RemoveGUIDraggerHandles()

	if not v.Modifiable then
		return
	end

	clones = {}
	local list = v20.List

	if #list > 0 then
		for i = 1, #list do
			local v29 = i
			pcall(function()
				table.insert(clones, list[v29]:Clone())
			end)
		end
	else
		spawn(function()
			script.Parent.Parent.WarningText.Text = "Select something first."
			script.Parent.Parent.WarningText.Visible = true
			task.wait(2)
			script.Parent.Parent.WarningText.Visible = false
		end)
	end
end)
local flag3 = true
makeButton(176, 176, "Paste into").MouseButton1Click:connect(function()
	RemoveGUIDraggerHandles()

	if flag3 then
		flag3 = false

		if not v.Modifiable then
			return
		end

		local list = v20.List

		if list and #list == 1 then
			local parent2 = list[1]

			for i = 1, #clones do
				local clone = clones[i]:Clone()

				if clone:FindFirstChild("SL_AttachmentAdornee") then
					clone.SL_AttachmentAdornee:Destroy()
				end

				clone.Parent = parent2

				if i ~= 1 then
					continue
				end

				task.wait(0.2)
				v20:Set({ clone })
			end

			if parent2.ClassName == "StarterGui" or parent2:IsDescendantOf(game.StarterGui) then
				if parent2.ClassName == "StarterGui" then
					CloneStarterGuiForEditOrPlayModule:Edit()
				else
					CloneStarterGuiForEditOrPlayModule:Edit(list[1])
				end
			end
		elseif list and #list == 0 then
			spawn(function()
				script.Parent.Parent.WarningText.Text = "Select something first."
				script.Parent.Parent.WarningText.Visible = true
				task.wait(2)
				script.Parent.Parent.WarningText.Visible = false
			end)
		else
			spawn(function()
				script.Parent.Parent.WarningText.Text = "Select just one new parent."
				script.Parent.Parent.WarningText.Visible = true
				task.wait(2)
				script.Parent.Parent.WarningText.Visible = false
			end)
		end

		task.wait(0.2)
		flag3 = true
	end
end)
makeButton(175, 175, "Dupli").MouseButton1Click:connect(function()
	RemoveGUIDraggerHandles()

	if not v.Modifiable then
		return
	end

	local v29 = v20:Get()

	if #v29 > 0 then
		local parent2 = v29[1].Parent

		if parent2 then
			for i = 1, #v29 do
				local v30 = i
				pcall(function()
					local clone = v29[v30]:Clone()
					clone.Parent = parent2

					if clone:FindFirstChild("SL_AttachmentAdornee") then
						clone.SL_AttachmentAdornee:Destroy()
					end
				end)
			end

			if parent2.ClassName == "StarterGui" or parent2:IsDescendantOf(game.StarterGui) then
				if parent2.ClassName == "StarterGui" then
					CloneStarterGuiForEditOrPlayModule:Edit()
				else
					CloneStarterGuiForEditOrPlayModule:Edit(v29[1])
				end
			end
		end
	else
		spawn(function()
			script.Parent.Parent.WarningText.Text = "Select something first."
			script.Parent.Parent.WarningText.Visible = true
			task.wait(2)
			script.Parent.Parent.WarningText.Visible = false
		end)
	end
end)
local v29 = {
	Modifiable = function(p)
		for i = 1, #v25 do
			v25[i].Visible = p and v.Selectable
		end
	end,
	Selectable = function(p)
		for i = 1, #v25 do
			v25[i].Visible = p and v.Modifiable
		end

		v20:Set({})
	end
}
local setOption = script.Parent:FindFirstChild("SetOption")

if not setOption then
	setOption = Create("BindableFunction", {
		Name = "SetOption"
	})
	setOption.Parent = script.Parent
end

function setOption.OnInvoke(p, p2)
	if v29[p] then
		v[p] = p2
		v29[p](p2)
	end
end

local getOption = script.Parent:FindFirstChild("GetOption")

if not getOption then
	getOption = Create("BindableFunction", {
		Name = "GetOption"
	})
	getOption.Parent = script.Parent
end

function getOption.OnInvoke(p)
	if p then
		return v[p]
	end

	local result = {}

	for k, v30 in pairs(v) do
		result[k] = v30
	end

	return result
end

function NewPart(instance, parent2)
	instance.Anchored = true
	instance.CanCollide = false
	instance:SetAttribute("SL_Anchored", false)
	instance:SetAttribute("SL_CanCollide", true)
	instance.TopSurface = Enum.SurfaceType.Smooth
	instance.BottomSurface = Enum.SurfaceType.Smooth
	instance.Parent = parent2
	local cFrame = workspace.CurrentCamera.CFrame
	local vector = Vector3.new(
		math.floor((cFrame.X + cFrame.lookVector.X * 30) * 2) / 2,
		instance.Size.Y / 2,
		math.floor((cFrame.Z + cFrame.lookVector.Z * 30) * 2) / 2
	)
	local raycastResult = workspace:Raycast(Vector3.new(vector.X, cFrame.Y, vector.Z), (Vector3.new(0, -cFrame.Y, 0)))

	if raycastResult then
		vector = Vector3.new(
			vector.X,
			raycastResult.Instance.Position.Y + raycastResult.Instance.Size.Y / 2 + instance.Size.Y / 2,
			vector.Z
		)
	end

	instance.Position = vector
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local studioLiteFolder2 = ReplicatedStorage2:WaitForChild("StudioLiteFolder")
local ColorizeSourceModule = require(studioLiteFolder2:WaitForChild("ColorizeSourceModule"))
local vector = Vector2.new(0, 0)
local connections3 = {}

function MobileAddKeyboard()
	for i = 1, #connections3 do
		if connections3[i] then
			connections3[i]:disconnect()
		end
	end

	connections3 = {}
	local viewScriptFrame = parent.Parent:WaitForChild("ViewScriptFrame")
	local scrollingFrame = viewScriptFrame:WaitForChild("ScrollingFrame")
	local mouseLocation = nil
	local v30 = 1
	local v31 = 1
	local v32 = nil
	local textButton = nil
	local v33 = nil
	local text = nil

	for _, child in pairs(scrollingFrame:GetChildren()) do
		if child.Name ~= "SL_CodeTextBox" or child.Parent:FindFirstChild("MobileCursorTextButton") then
			continue
		end

		child.Active = false
		child.Selectable = false
		child.TextEditable = false
		textButton = Instance.new("TextButton")
		textButton.Name = "MobileCursorTextButton"

		if _G.GamepadService then
			textButton.Active = true
		else
			textButton.Active = false
		end

		textButton.Size = UDim2.new(1, 0, 0, 1600)
		textButton.Position = UDim2.new(0, 50, 0, 0)
		textButton.ZIndex = 5
		textButton.BackgroundTransparency = 1
		textButton.BorderSizePixel = 0
		textButton.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold)
		textButton.TextSize = 14
		textButton.TextColor3 = Color3.new(0, 1, 1)
		textButton.AutomaticSize = Enum.AutomaticSize.XY
		textButton.Text = ""
		textButton.TextXAlignment = Enum.TextXAlignment.Left
		textButton.TextYAlignment = Enum.TextYAlignment.Top
		textButton.Parent = child.Parent
		v33 = child
		local v35 = textButton
		connections3[#connections3 + 1] = textButton.MouseButton1Click:Connect(function()
			mouseLocation = UserInputService:GetMouseLocation()
			v30 = mouseLocation.X - v35.AbsolutePosition.X
			v31 = mouseLocation.y - v35.AbsolutePosition.Y + parent.Parent.AbsolutePosition.Y
			v30 = math.clamp(v30, 0, v35.AbsoluteSize.X)
			v31 = math.clamp(v31, 0, v35.AbsoluteSize.Y)
			v30 = math.floor(v30 / 7) + 1
			v31 = math.floor(v31 / 14) + 1
			v32 = v33.ContentText:split("\n")

			if v31 > #v32 then
				v31 = #v32
			end

			if v30 > #v32[v31] then
				v30 = #v32[v31] + 1
			end
		end)
	end

	spawn(function()
		local WAIT_INTERVAL = 0.5
		local v35 = 0

		while viewScriptFrame.Visible do
			if textButton and v30 >= 1 and v31 >= 1 then
				v35 -= 1

				if v35 <= 0 then
					local v36 = v33
					local colorizeSource, v37 = ColorizeSourceModule:ColorizeSource(v33.ContentText, false, true, v31)
					v36.Text = colorizeSource
					v30 += v37
					local saveChangesTo = v33:WaitForChild("SaveChangesTo")
					saveChangesTo.Value.Text = v33.ContentText
					v35 = 3
				end

				text = ("\n"):rep(v31 - 1) .. (" "):rep(v30 - 1) .. "|"
				textButton.Text = text
				task.wait(WAIT_INTERVAL)
				textButton.Text = ""
				task.wait(WAIT_INTERVAL)
				vector = scrollingFrame.CanvasPosition
			else
				task.wait(WAIT_INTERVAL)
			end
		end
	end)
	local keyboardFrame = viewScriptFrame:WaitForChild("KeyboardFrame")
	local altKeyboardTextBoxFrame = viewScriptFrame:WaitForChild("AltKeyboardTextBoxFrame")
	local altKeyboardTextBox = altKeyboardTextBoxFrame:WaitForChild("AltKeyboardTextBox")
	local keyboardRow1Frame = keyboardFrame:WaitForChild("KeyboardRow1Frame")
	local keyboardRow2Frame = keyboardFrame:WaitForChild("KeyboardRow2Frame")
	local keyboardRow3Frame = keyboardFrame:WaitForChild("KeyboardRow3Frame")
	local keyboardRow4Frame = keyboardFrame:WaitForChild("KeyboardRow4Frame")
	connections3[#connections3 + 1] = altKeyboardTextBox.FocusLost:Connect(function()
		v33.Text = altKeyboardTextBox.ContentText
		altKeyboardTextBoxFrame.Visible = false
		task.wait(0.2)
		scrollingFrame.CanvasPosition = Vector2.new(0, 0)
	end)

	for _, child in pairs(keyboardFrame:GetChildren()) do
		for _, child2 in pairs(child:GetChildren()) do
			if child2.ClassName:sub(-6) ~= "Button" then
				continue
			end

			local v35 = child2
			connections3[#connections3 + 1] = child2.MouseButton1Click:Connect(function()
				-- [DEDUP] synthesized from 2 duplicated terminal regions
				local function deduplicatedTail()
					for i, child3 in pairs(keyboardRow2Frame:GetChildren()) do
						if child3.ClassName == "TextButton" and #child3.Text == 1 and child3.Text >= "A" and child3.Text <= "Z" then
							child3.Text = child3.Text:lower()
						end
					end

					for i, child3 in pairs(keyboardRow3Frame:GetChildren()) do
						if child3.ClassName == "TextButton" and #child3.Text == 1 and child3.Text >= "A" and child3.Text <= "Z" then
							child3.Text = child3.Text:lower()
						end
					end

					for i, child3 in pairs(keyboardRow4Frame:GetChildren()) do
						if child3.ClassName == "TextButton" and #child3.Text == 1 and child3.Text >= "A" and child3.Text <= "Z" then
							child3.Text = child3.Text:lower()
						end
					end
				end

				if textButton and v30 >= 0 and v31 >= 0 then
					textButton.Text = ""
					scrollingFrame.CanvasPosition = vector
					local parts = v33.ContentText:split("\n")
					local part2 = parts[v31]

					if #v35.Text == 1 then
						parts[v31] = part2:sub(1, v30 - 1) .. v35.Text .. part2:sub(v30)
						v33.Text = table.concat(parts, "\n")
						v30 += 1

						if v35.Text >= "A" and v35.Text <= "Z" and keyboardRow4Frame:WaitForChild("Col01KeyShiftButton").Text == "Shift" then
							local col01KeyShiftButton = keyboardRow4Frame:WaitForChild("Col01KeyShiftButton")
							col01KeyShiftButton.Text = "shift"
							return deduplicatedTail()
						end
					elseif v35.Text == "↑" and v31 > 1 then
						v31 -= 1

						if v30 > #parts[v31] then
							v30 = #parts[v31] + 1
						end
					elseif v35.Text == "↓" and v31 + 1 <= #parts then
						v31 += 1

						if v30 > #parts[v31] then
							v30 = #parts[v31] + 1
						end
					elseif v35.Text == "→" and v31 + 1 <= #parts then
						if v30 >= #part2 then
							v31 += 1
							v30 = 1
						else
							v30 += 1
						end
					elseif v35.Text == "←" and (v30 > 1 or v31 > 1) then
						if v30 > 1 then
							v30 -= 1
							return
						end

						v31 -= 1
						v30 = #parts[v31] + 1
					elseif v35.Text == "Space" then
						parts[v31] = part2:sub(1, v30 - 1) .. " " .. part2:sub(v30)
						v33.Text = table.concat(parts, "\n")
						v30 += 1
					elseif v35.Text == "←Backspace" then
						if v30 > 1 then
							if v30 >= #part2 then
								parts[v31] = part2:sub(1, v30 - 2)
							else
								parts[v31] = part2:sub(1, v30 - 2) .. part2:sub(v30)
							end

							v33.Text = table.concat(parts, "\n")
							v30 -= 1
						elseif v31 > 1 then
							parts[v31] = parts[v31 - 1] .. part2

							if parts[v31 - 1] == " " then
								v30 = #parts[v31 - 1]
							else
								v30 = #parts[v31 - 1] + 1
							end

							table.remove(parts, v31 - 1)
							v33.Text = table.concat(parts, "\n")
							v31 -= 1
						end
					elseif v35.Text == "Delete→" then
						if v30 >= #part2 and v31 < #parts then
							parts[v31] = part2 .. parts[v31 + 1]
							table.remove(parts, v31 + 1)
						elseif v30 == 1 then
							parts[v31] = part2:sub(2)
						else
							parts[v31] = part2:sub(1, v30 - 1) .. part2:sub(v30 + 1)
						end

						v33.Text = table.concat(parts, "\n")
					elseif v35.Text == "Enter" then
						if v30 == #part2 then
							table.insert(parts, v31 + 1, " ")
						elseif v30 == 1 then
							table.insert(parts, v31, " ")
						else
							parts[v31] = part2:sub(1, v30 - 1)
							table.insert(parts, v31 + 1, part2:sub(v30))
						end

						v33.Text = table.concat(parts, "\n")
						v30 = 1
						v31 += 1
					elseif v35.Text == "shift" then
						v35.Text = "Shift"

						for i, child3 in pairs(keyboardRow2Frame:GetChildren()) do
							if child3.ClassName == "TextButton" and #child3.Text == 1 and child3.Text >= "a" and child3.Text <= "z" then
								child3.Text = child3.Text:upper()
							end
						end

						for i, child3 in pairs(keyboardRow3Frame:GetChildren()) do
							if child3.ClassName == "TextButton" and #child3.Text == 1 and child3.Text >= "a" and child3.Text <= "z" then
								child3.Text = child3.Text:upper()
							end
						end

						for i, child3 in pairs(keyboardRow4Frame:GetChildren()) do
							if child3.ClassName == "TextButton" and #child3.Text == 1 and child3.Text >= "a" and child3.Text <= "z" then
								child3.Text = child3.Text:upper()
							end
						end
					elseif v35.Text == "SHIFT" then
						v35.Text = "shift"
						return deduplicatedTail()
					elseif v35.Text == "Shift" then
						v35.Text = "SHIFT"
					elseif v35.Text == "+/*" then
						v35.Text = "abc"
						local col11KeyTildeButton = keyboardRow1Frame:WaitForChild("Col11KeyTildeButton")
						col11KeyTildeButton.Text = "-"
						local col01KeyqButton = keyboardRow2Frame:WaitForChild("Col01KeyqButton")
						col01KeyqButton.Text = "!"
						local col02KeywButton = keyboardRow2Frame:WaitForChild("Col02KeywButton")
						col02KeywButton.Text = "@"
						local col03KeyeButton = keyboardRow2Frame:WaitForChild("Col03KeyeButton")
						col03KeyeButton.Text = "#"
						local col04KeyrButton = keyboardRow2Frame:WaitForChild("Col04KeyrButton")
						col04KeyrButton.Text = "$"
						local col05KeytButton = keyboardRow2Frame:WaitForChild("Col05KeytButton")
						col05KeytButton.Text = "%"
						local col06KeyyButton = keyboardRow2Frame:WaitForChild("Col06KeyyButton")
						col06KeyyButton.Text = "^"
						local col07KeyuButton = keyboardRow2Frame:WaitForChild("Col07KeyuButton")
						col07KeyuButton.Text = "&"
						local col08KeyiButton = keyboardRow2Frame:WaitForChild("Col08KeyiButton")
						col08KeyiButton.Text = "*"
						local col09KeyoButton = keyboardRow2Frame:WaitForChild("Col09KeyoButton")
						col09KeyoButton.Text = "_"
						local col10KeypButton = keyboardRow2Frame:WaitForChild("Col10KeypButton")
						col10KeypButton.Text = "+"
						local col01KeyaButton = keyboardRow3Frame:WaitForChild("Col01KeyaButton")
						col01KeyaButton.Text = "`"
						local col02KeysButton = keyboardRow3Frame:WaitForChild("Col02KeysButton")
						col02KeysButton.Text = "{"
						local col03KeydButton = keyboardRow3Frame:WaitForChild("Col03KeydButton")
						col03KeydButton.Text = "}"
						local col04KeyfButton = keyboardRow3Frame:WaitForChild("Col04KeyfButton")
						col04KeyfButton.Text = "["
						local col05KeygButton = keyboardRow3Frame:WaitForChild("Col05KeygButton")
						col05KeygButton.Text = "]"
						local col06KeyhButton = keyboardRow3Frame:WaitForChild("Col06KeyhButton")
						col06KeyhButton.Text = "|"
						local col07KeyjButton = keyboardRow3Frame:WaitForChild("Col07KeyjButton")
						col07KeyjButton.Text = "\\"
						local col08KeykButton = keyboardRow3Frame:WaitForChild("Col08KeykButton")
						col08KeykButton.Text = ";"
						local col09KeylButton = keyboardRow3Frame:WaitForChild("Col09KeylButton")
						col09KeylButton.Text = "'"
						local col02KeyzButton = keyboardRow4Frame:WaitForChild("Col02KeyzButton")
						col02KeyzButton.Text = "+"
						local col03KeyxButton = keyboardRow4Frame:WaitForChild("Col03KeyxButton")
						col03KeyxButton.Text = "-"
						local col04KeycButton = keyboardRow4Frame:WaitForChild("Col04KeycButton")
						col04KeycButton.Text = "*"
						local col05KeyvButton = keyboardRow4Frame:WaitForChild("Col05KeyvButton")
						col05KeyvButton.Text = "/"
						local col06KeybButton = keyboardRow4Frame:WaitForChild("Col06KeybButton")
						col06KeybButton.Text = "?"
						local col07KeynButton = keyboardRow4Frame:WaitForChild("Col07KeynButton")
						col07KeynButton.Text = "<"
						local col08KeymButton = keyboardRow4Frame:WaitForChild("Col08KeymButton")
						col08KeymButton.Text = ">"
					elseif v35.Text == "abc" then
						v35.Text = "+/*"
						local col11KeyTildeButton_2 = keyboardRow1Frame:WaitForChild("Col11KeyTildeButton")
						col11KeyTildeButton_2.Text = "~"
						local col01KeyShiftButton_2 = keyboardRow4Frame:WaitForChild("Col01KeyShiftButton")
						col01KeyShiftButton_2.Text = "shift"
						local col01KeyqButton_2 = keyboardRow2Frame:WaitForChild("Col01KeyqButton")
						col01KeyqButton_2.Text = "q"
						local col02KeywButton_2 = keyboardRow2Frame:WaitForChild("Col02KeywButton")
						col02KeywButton_2.Text = "w"
						local col03KeyeButton_2 = keyboardRow2Frame:WaitForChild("Col03KeyeButton")
						col03KeyeButton_2.Text = "e"
						local col04KeyrButton_2 = keyboardRow2Frame:WaitForChild("Col04KeyrButton")
						col04KeyrButton_2.Text = "r"
						local col05KeytButton_2 = keyboardRow2Frame:WaitForChild("Col05KeytButton")
						col05KeytButton_2.Text = "t"
						local col06KeyyButton_2 = keyboardRow2Frame:WaitForChild("Col06KeyyButton")
						col06KeyyButton_2.Text = "y"
						local col07KeyuButton_2 = keyboardRow2Frame:WaitForChild("Col07KeyuButton")
						col07KeyuButton_2.Text = "u"
						local col08KeyiButton_2 = keyboardRow2Frame:WaitForChild("Col08KeyiButton")
						col08KeyiButton_2.Text = "i"
						local col09KeyoButton_2 = keyboardRow2Frame:WaitForChild("Col09KeyoButton")
						col09KeyoButton_2.Text = "o"
						local col10KeypButton_2 = keyboardRow2Frame:WaitForChild("Col10KeypButton")
						col10KeypButton_2.Text = "p"
						local col01KeyaButton_2 = keyboardRow3Frame:WaitForChild("Col01KeyaButton")
						col01KeyaButton_2.Text = "a"
						local col02KeysButton_2 = keyboardRow3Frame:WaitForChild("Col02KeysButton")
						col02KeysButton_2.Text = "s"
						local col03KeydButton_2 = keyboardRow3Frame:WaitForChild("Col03KeydButton")
						col03KeydButton_2.Text = "d"
						local col04KeyfButton_2 = keyboardRow3Frame:WaitForChild("Col04KeyfButton")
						col04KeyfButton_2.Text = "f"
						local col05KeygButton_2 = keyboardRow3Frame:WaitForChild("Col05KeygButton")
						col05KeygButton_2.Text = "g"
						local col06KeyhButton_2 = keyboardRow3Frame:WaitForChild("Col06KeyhButton")
						col06KeyhButton_2.Text = "h"
						local col07KeyjButton_2 = keyboardRow3Frame:WaitForChild("Col07KeyjButton")
						col07KeyjButton_2.Text = "j"
						local col08KeykButton_2 = keyboardRow3Frame:WaitForChild("Col08KeykButton")
						col08KeykButton_2.Text = "k"
						local col09KeylButton_2 = keyboardRow3Frame:WaitForChild("Col09KeylButton")
						col09KeylButton_2.Text = "l"
						local col02KeyzButton_2 = keyboardRow4Frame:WaitForChild("Col02KeyzButton")
						col02KeyzButton_2.Text = "z"
						local col03KeyxButton_2 = keyboardRow4Frame:WaitForChild("Col03KeyxButton")
						col03KeyxButton_2.Text = "x"
						local col04KeycButton_2 = keyboardRow4Frame:WaitForChild("Col04KeycButton")
						col04KeycButton_2.Text = "c"
						local col05KeyvButton_2 = keyboardRow4Frame:WaitForChild("Col05KeyvButton")
						col05KeyvButton_2.Text = "v"
						local col06KeybButton_2 = keyboardRow4Frame:WaitForChild("Col06KeybButton")
						col06KeybButton_2.Text = "b"
						local col07KeynButton_2 = keyboardRow4Frame:WaitForChild("Col07KeynButton")
						col07KeynButton_2.Text = "n"
						local col08KeymButton_2 = keyboardRow4Frame:WaitForChild("Col08KeymButton")
						col08KeymButton_2.Text = "m"
					elseif v35.Text == "Alt Keyboard" then
						altKeyboardTextBox.Text = v33.ContentText
						altKeyboardTextBoxFrame.Visible = true
						task.wait()
						altKeyboardTextBox:CaptureFocus()
					end
				elseif viewScriptFrame.Parent.WarningText.Visible == false then
					spawn(function()
						local warningText = viewScriptFrame.Parent:WaitForChild("WarningText")
						warningText.Text = "Tap to place cursor."
						viewScriptFrame.Parent.WarningText.Visible = true
						task.wait(3)
						viewScriptFrame.Parent.WarningText.Visible = false
					end)
				end
			end)
		end
	end
end

function ShowScript(instance)
	insertScriptFrame.Visible = false
	insertLocalScriptFrame.Visible = false
	insertModuleScriptFrame.Visible = false
	local viewScriptFrame = parent.Parent:WaitForChild("ViewScriptFrame")
	local scrollingFrame = viewScriptFrame:WaitForChild("ScrollingFrame")
	local viewScriptTextLabelTemplate = viewScriptFrame:WaitForChild("ViewScriptTextLabelTemplate")
	local keyboardFrame = viewScriptFrame:WaitForChild("KeyboardFrame")
	scrollingFrame:ClearAllChildren()
	local name = instance.Name
	local flag4 = false

	for _, child in pairs(instance:GetChildren()) do
		if child.Name:sub(1, 3) ~= "SL_" then
			continue
		end

		local clone = child:Clone()
		clone.Parent = viewScriptFrame.ScrollingFrame

		if clone:FindFirstChild("SaveChangesTo") then
			clone.SaveChangesTo.Value = child
		end

		if child.Name == "SL_CodeTextBox" then
			child.Position = UDim2.new(0, 52, 0, 0)
			flag4 = true
		elseif child.Name == "SL_1ReadOnly" then
			name = child.ContentText:match("[%s%-]*(%w+)")
		end
	end

	scrollingFrame.Size = UDim2.new(1, 0, 1, -55)
	keyboardFrame.Visible = false

	if flag4 then
		local clone_2 = viewScriptFrame.LineNumbersTextLabel:Clone()
		clone_2.Parent = scrollingFrame
		scrollingFrame.LineNumbersTextLabel.Visible = true
		local textLabel = viewScriptFrame:WaitForChild("TextLabel")
		textLabel.Text = instance.Name

		if _G.DynamicThumb then
			keyboardFrame.Visible = true
			scrollingFrame.Size = UDim2.new(1, 0, 1, -165)
			MobileAddKeyboard()
		else
			local dummyIndentColorizeButton = viewScriptFrame:WaitForChild("DummyIndentColorizeButton")
			dummyIndentColorizeButton.Visible = true
		end
	else
		local textLabel_2 = viewScriptFrame:WaitForChild("TextLabel")
		textLabel_2.Text = instance.Name .. "  (read only)"
		local v30 = getScriptSourceServerFunction:InvokeServer(instance.ClassName .. name)
		local v31 = not v30 and "Not found." or ColorizeSourceModule:ColorizeSource(v30, true, false)
		local total3 = 0

		for _, text in pairs(v31:split("\n")) do
			local clone = viewScriptTextLabelTemplate:Clone()
			clone.Text = text
			clone.Position = UDim2.new(clone.Position.X.Scale, clone.Position.X.Offset, clone.Position.Y.Scale, total3)
			clone.Visible = true
			clone.Parent = viewScriptFrame.ScrollingFrame
			total3 += 16
		end
	end

	viewScriptFrame.Visible = true
	local toolboxFrame = viewScriptFrame.Parent:WaitForChild("ToolboxFrame")
	toolboxFrame.Visible = false
	insertScriptFrame.Visible = false
	insertLocalScriptFrame.Visible = false
	insertModuleScriptFrame.Visible = false
end

for _, child in pairs(insertScriptFrame:WaitForChild("ScrollingFrame"):GetChildren()) do
	if child.Name:sub(1, 3) ~= "Row" then
		continue
	end

	local v30 = child
	child:WaitForChild("InsertScriptButton").Activated:Connect(function()
		insertScriptFrame.Visible = false
		WorkingWaiting()
		local script2 = Instance.new("Script")
		script2.Name = v30:WaitForChild("NameTextLabel").Text
		script2.Parent = part
		serverFunctions:InvokeServer("LoadAssetToPlayerGui", "InsertScript" .. v30:WaitForChild("NameTextLabel").Text)

		for i, child2 in pairs(game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("InsertScript" .. v30:WaitForChild("NameTextLabel").Text):GetChildren()) do
			local clone = child2:Clone()
			clone.Parent = script2
		end

		serverFunctions:InvokeServer(
			"ClearAssetFromPlayerGui",
			"InsertScript" .. v30:WaitForChild("NameTextLabel").Text
		)
		v20:Set({ script2 })
		v2 = false
	end)
end

for _, child in pairs(insertLocalScriptFrame:WaitForChild("ScrollingFrame"):GetChildren()) do
	if not (child.Name:sub(1, 3) == "Row" and child:FindFirstChild("InsertScriptButton")) then
		continue
	end

	local v30 = child
	child:WaitForChild("InsertScriptButton").Activated:Connect(function()
		insertLocalScriptFrame.Visible = false
		WorkingWaiting()
		local localScript = Instance.new("LocalScript")
		localScript.Name = v30:WaitForChild("NameTextLabel").Text
		localScript.Parent = part
		serverFunctions:InvokeServer(
			"LoadAssetToPlayerGui",
			"InsertLocalScript" .. v30:WaitForChild("NameTextLabel").Text
		)

		for i, child2 in pairs(game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("InsertLocalScript" .. v30:WaitForChild("NameTextLabel").Text):GetChildren()) do
			local clone = child2:Clone()
			clone.Parent = localScript
		end

		serverFunctions:InvokeServer(
			"ClearAssetFromPlayerGui",
			"InsertLocalScript" .. v30:WaitForChild("NameTextLabel").Text
		)
		v20:Set({ localScript })
		v2 = false
	end)
end

for _, child in pairs(insertModuleScriptFrame:WaitForChild("ScrollingFrame"):GetChildren()) do
	if not (child.Name:sub(1, 3) == "Row" and child:FindFirstChild("InsertScriptButton")) then
		continue
	end

	local v30 = child
	child:WaitForChild("InsertScriptButton").Activated:Connect(function()
		insertModuleScriptFrame.Visible = false
		WorkingWaiting()
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = v30:WaitForChild("NameTextLabel").Text
		moduleScript.Parent = part
		serverFunctions:InvokeServer(
			"LoadAssetToPlayerGui",
			"InsertModuleScript" .. v30:WaitForChild("NameTextLabel").Text
		)

		for i, child2 in pairs(game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("InsertModuleScript" .. v30:WaitForChild("NameTextLabel").Text):GetChildren()) do
			local clone = child2:Clone()
			clone.Parent = moduleScript
		end

		serverFunctions:InvokeServer(
			"ClearAssetFromPlayerGui",
			"InsertModuleScript" .. v30:WaitForChild("NameTextLabel").Text
		)
		v20:Set({ moduleScript })
		v2 = false
	end)
end

function NewInstance(className)
	_G.DialogAnswer = "Yes"

	if className == "Script" and part.ClassName ~= "Workspace" and not part:IsDescendantOf(workspace) and part.Name ~= "ServerScriptService" and not part:IsDescendantOf(_G.sss) and part.Name ~= "ServerStorage" and not part:IsDescendantOf(_G.ss) and part.Name ~= "StarterPack" and not part:IsDescendantOf(game.StarterPack) and part.Name ~= "StarterGui" and not part:IsDescendantOf(game.StarterGui) and part.Name ~= "StarterPlayer" and not part:IsDescendantOf(game.StarterPlayer) then
		DialogYesNo("Stripts run on the server and their actions are seen by all players. Usually Scripts go inside a Part, Model, Tool or ServerScriptService. Continue anyway?")
	elseif className == "LocalScript" and part.ClassName ~= "Tool" and (not part.Parent or part.Parent.ClassName ~= "Tool") and not (part:IsDescendantOf(game.StarterPlayer) or part:IsDescendantOf(game.StarterGui)) then
		DialogYesNo("LocalScript normally goes inside a Tool, a GUI, StarterPlayerScripts, or StarterCharacterScripts. Continue anyway?")
	elseif ("TextLabel TextButton ImageLabel ImageButton "):find(className, 1, true) and not ("Frame ScrollingFrame ScreenGui SurfaceGui BillboardGui "):find(
		part.ClassName,
		1,
		true
	) then
		DialogYesNo(className .. " usually goes inside a ScreenGui, SurfaceGui, BillboardGui or Frame. Continue anyway?")
	elseif className == "ScreenGui" and part.ClassName ~= "StarterGui" then
		DialogYesNo("ScreenGui usually goes inside a StarterGui. Continue anyway?")
	elseif className == "Frame" and not ("Frame ScrollingFrame ScreenGui SurfaceGui BillboardGui "):find(
		part.ClassName,
		1,
		true
	) then
		DialogYesNo("A Frame usually goes inside a ScreenGui, SurfaceGui, BillboardGui or another Frame. Continue anyway?")
	elseif className == "SurfaceGui" and not part:IsDescendantOf(workspace) then
		DialogYesNo("A SurfaceGui usually goes inside a part in workspace. Continue anyway?")
	elseif (className == "Smoke" or className == "Fire" or className == "Sparkles") and part:IsDescendantOf(workspace) and part.ClassName == "Model" then
		DialogOk(className .. " must be parented to a Part, not a model.", "Cancel")
	elseif (className == "Smoke" or className == "Fire" or className == "Sparkles") and part:IsDescendantOf(workspace) and not part:IsA("BasePart") and part.ClassName ~= "Attachment" then
		DialogOk(className .. " must be parented to a Part or attachment.", "Cancel")
	elseif className == "Part" and part:IsA("BasePart") then
		DialogYesNo("Parts usually go inside Workspace, models, or folders. Putting them in another part might not do what you want.  Continue anyway?")
	elseif className == "Truss" and part:IsA("BasePart") then
		DialogYesNo("Trusses usually go inside Workspace, models, or folders. Putting them in another part might not do what you want.  Continue anyway?")
	end

	if _G.DialogAnswer == "Yes" then
		local success, result = pcall(function()
			if className == "Script" then
				if parent.Parent.AbsoluteSize.X < 1100 then
					insertScriptFrame.Position = UDim2.new(0, 3, 0, 2)
					insertScriptFrame.Size = UDim2.new(1, -5, 1, -4)
				end

				insertScriptFrame.Visible = true
				insertLocalScriptFrame.Visible = false
				insertModuleScriptFrame.Visible = false
				local viewScriptFrame = parent.Parent:WaitForChild("ViewScriptFrame")
				viewScriptFrame.Visible = false
				local toolboxFrame = parent.Parent:WaitForChild("ToolboxFrame")
				toolboxFrame.Visible = false
				local insertFrame_2 = parent.Parent:WaitForChild("InsertFrame")
				insertFrame_2.Visible = false
			elseif className == "LocalScript" then
				if parent.Parent.AbsoluteSize.X < 1100 then
					insertLocalScriptFrame.Position = UDim2.new(0, 3, 0, 2)
					insertLocalScriptFrame.Size = UDim2.new(1, -5, 1, -4)
				end

				insertScriptFrame.Visible = false
				insertLocalScriptFrame.Visible = true
				insertModuleScriptFrame.Visible = false
				local viewScriptFrame_2 = parent.Parent:WaitForChild("ViewScriptFrame")
				viewScriptFrame_2.Visible = false
				local toolboxFrame_2 = parent.Parent:WaitForChild("ToolboxFrame")
				toolboxFrame_2.Visible = false
				local insertFrame_3 = parent.Parent:WaitForChild("InsertFrame")
				insertFrame_3.Visible = false
			elseif className == "ModuleScript" then
				if parent.Parent.AbsoluteSize.X < 1100 then
					insertModuleScriptFrame.Position = UDim2.new(0, 3, 0, 2)
					insertModuleScriptFrame.Size = UDim2.new(1, -5, 1, -4)
				end

				insertScriptFrame.Visible = false
				insertLocalScriptFrame.Visible = false
				insertModuleScriptFrame.Visible = true
				local viewScriptFrame_3 = parent.Parent:WaitForChild("ViewScriptFrame")
				viewScriptFrame_3.Visible = false
				local toolboxFrame_3 = parent.Parent:WaitForChild("ToolboxFrame")
				toolboxFrame_3.Visible = false
				local insertFrame_4 = parent.Parent:WaitForChild("InsertFrame")
				insertFrame_4.Visible = false
			else
				local instance = Instance.new(className)

				if instance:IsA("BasePart") then
					NewPart(instance, part)
				else
					if ("TextLabel TextButton TextBox"):find(className, 1, true) then
						instance.Size = UDim2.new(0, 200, 0, 50)
						instance.BackgroundColor3 = Color3.fromRGB(162, 162, 162)
					elseif ("ImageLabel ImageButton "):find(className, 1, true) then
						instance.Size = UDim2.new(0, 100, 0, 100)
						instance.BackgroundColor3 = Color3.fromRGB(162, 162, 162)
					elseif className:sub(-5) == "Frame" then
						instance.Size = UDim2.new(0, 200, 0, 200)
						instance.BackgroundColor3 = Color3.fromRGB(162, 162, 162)
						instance.BorderColor3 = Color3.fromRGB(27, 42, 53)
						instance.BorderSizePixel = 1
					elseif className == "BillboardGui" then
						instance.Size = UDim2.new(0, 200, 0, 50)
					elseif className == "SurfaceGui" then
						instance.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
						instance.ClipsDescendants = true
					end

					instance.Parent = part
				end

				task.wait(0.3)

				if instance:IsDescendantOf(game.StarterGui) then
					CloneStarterGuiForEditOrPlayModule:Edit(instance)
				end

				v20:Set({ instance })
				insertFrame.Visible = false
			end
		end)

		if not success then
			WarnPlayer(script.Name .. " " .. result, 9)
		end
	end
end

local scrollingFrame = insertFrame:WaitForChild("ScrollingFrame")

for _, child in ipairs(scrollingFrame:GetChildren()) do
	if child.ClassName == "TextButton" then
		local v30 = child
		child.MouseButton1Click:Connect(function()
			NewInstance(v30.Name)
		end)
	elseif child.ClassName == "TextBox" then
		local v30 = child
		child.FocusLost:Connect(function()
			if v30.Text and #v30.Text > 0 then
				NewInstance(v30.Text)
				v30.Text = ""
			end
		end)
	end
end