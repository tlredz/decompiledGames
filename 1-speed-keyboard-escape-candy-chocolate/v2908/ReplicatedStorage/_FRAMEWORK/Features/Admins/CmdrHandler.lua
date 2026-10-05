local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePlayerAccess(instance)
	instance:SetAttribute("HasCmdr", AdminPermissions.hasPermission(instance.UserId, "cmdr"))
end

local function initializeServer()
	local Cmdr = require(ReplicatedStorage.Packages.Cmdr)
	Cmdr:RegisterHooksIn(ReplicatedStorage.Cmdr.Hooks)
	Cmdr:RegisterTypesIn(ServerScriptService.Cmdr.Types)
	Cmdr:RegisterDefaultCommands({ "Help", "DefaultDebug", "DefaultUtil" })
	Cmdr:RegisterCommandsIn(ServerScriptService.Cmdr.Commands)
	Cmdr:RegisterCommandsIn(ReplicatedStorage.Cmdr.Commands)
	AdminPermissions.fillPermissionToNonLinkedCommands(Cmdr.Registry:GetCommandNames())
	ReplicatedStorage:SetAttribute("CMDR_Ready", true)
	Players.PlayerAdded:Connect(updatePlayerAccess)

	for _, v in Players:GetPlayers() do
		updatePlayerAccess(v) -- equivalent call inferred; original call site unknown
	end

	logger:print("Cmdr server initialized")
end

local function tryInitializeClient()
	if ReplicatedStorage:GetAttribute("CMDR_Ready") ~= true then
		return
	end

	local cmdrClient = ReplicatedStorage:FindFirstChild("CmdrClient")

	if not (cmdrClient and cmdrClient:IsA("ModuleScript")) then
		return
	end

	local module = require(cmdrClient)
	local v = assert(Players.LocalPlayer, "Cmdr client requires a local player")
	module:SetPlaceName("Keyboard Escape")

	local function updateAccessOnLocalSide()
		local hasCmdr = v:GetAttribute("HasCmdr") == true
		module:SetActivationKeys(hasCmdr and { Enum.KeyCode.Equals, Enum.KeyCode.F2 } or {})

		if not hasCmdr then
			module:Hide()
		end
	end

	v:GetAttributeChangedSignal("HasCmdr"):Connect(updateAccessOnLocalSide)
	updateAccessOnLocalSide()
	AdminPermissions.fillPermissionToNonLinkedCommands(module.Registry:GetCommandNames())
	logger:print("Cmdr client initialized")
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = -999,
	OnInit = function()
		if RunService:IsServer() then
			initializeServer()
			return
		end

		ReplicatedStorage:GetAttributeChangedSignal("CMDR_Ready"):Connect(tryInitializeClient)
		tryInitializeClient()
	end
})
return {}