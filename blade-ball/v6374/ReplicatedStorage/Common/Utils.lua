local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local script2 = script
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local isStudio = RunService:IsStudio()
local PhysicsService = game:GetService("PhysicsService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local localPlayer = not isServer and Players.LocalPlayer
local ContextActionService = not isServer and game:GetService("ContextActionService")
local userInputService = not isServer

if userInputService then
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	userInputService = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
end

local function fn() end

local function safeRequire(p)
	fn("Require", p)
	local thread = task.delay(10, function()
		fn("Taking too long to require", p)
	end)
	local v2 = require3(p)

	if coroutine.status(thread) == "suspended" then
		task.cancel(thread)
	end

	return v2
end

return {
	Network = safeRequire(script2.Utilities.Network),
	Settings = safeRequire(script2.Utilities.Settings),
	SwordUtil = safeRequire(script2.Utilities.SwordUtil),
	Icons = safeRequire(script2.Utilities.Icons),
	BaseObject = safeRequire(script2.Utilities.BaseObject),
	Create = safeRequire(script2.Utilities.Create),
	Debug = safeRequire(script2.Utilities.Debug),
	ValueConvertor = safeRequire(script2.Utilities.ValueConvertor),
	Sounds = safeRequire(script2.Utilities.Sounds),
	Binder = safeRequire(script2.Utilities.Binder),
	Tags = safeRequire(script2.Utilities.Tags),
	Thread = safeRequire(script2.Utilities.Thread),
	FFlag = safeRequire(script2.Utilities.FFlag),
	Physics = safeRequire(script2.Utilities.Physics),
	Table = safeRequire(script2.Utilities.Table),
	Maid = safeRequire(script2.Utilities.Maid),
	State = safeRequire(script2.Utilities.State),
	Random = safeRequire(script2.Utilities.Random),
	String = safeRequire(script2.Utilities.String),
	PlayerMaids = safeRequire(script2.Utilities.PlayerMaids),
	Signal = safeRequire(script2.Utilities.Signal),
	VectorViewer = safeRequire(script2.Utilities.VectorViewer),
	Streamer = safeRequire(script2.Utilities.Streamer),
	StateStack = safeRequire(script2.Utilities.StateStack),
	Events = safeRequire(script2.Utilities.Events),
	Promise = safeRequire(script2.Utilities.Promise),
	Spring = safeRequire(script2.Utilities.Spring),
	Visual = safeRequire(script2.Utilities.Visual),
	Job = safeRequire(script2.Utilities.Job),
	RewardInfo = safeRequire(script2.Utilities.RewardInfo),
	Statable = safeRequire(script2.Utilities.Statable),
	Inst = safeRequire(script2.Utilities.Inst),
	Easing = safeRequire(script2.Numerical.Easing),
	CFrame = safeRequire(script2.Numerical.CFrame),
	Vector = safeRequire(script2.Numerical.Vector),
	CameraUtils = safeRequire(script2.Utilities.CameraUtils),
	EasingUtil = safeRequire(script2.Numerical.EasingUtil),
	Pages = safeRequire(script2.Utilities.Pages),
	GuiUtils = safeRequire(script2.Utilities.GuiUtils),
	Pcall = safeRequire(script2.Utilities.Pcall),
	RunService = RunService,
	Heartbeat = RunService.Heartbeat,
	Stepped = RunService.Stepped,
	RenderStepped = RunService.RenderStepped,
	LocalPlayer = localPlayer,
	ServerStorage = ServerStorage,
	ServerScriptService = ServerScriptService,
	PhysicsService = PhysicsService,
	ContextActionService = ContextActionService,
	UserInputService = userInputService,
	Debris = game:GetService("Debris"),
	IsServer = isServer,
	IsClient = isClient,
	IsStudio = isStudio
}