local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local CameraTools = require(script.CameraTools)
local Config = require(script.Config)
local InvitePrompt = require(script.InvitePrompt)
local PanelWindow = require(script.PanelWindow)
local Remotes = require(script.Remotes)
require(script.Types)
local isServer = RunService:IsServer()
local Icon

if isServer then
	Icon = nil
else
	Icon = require(ReplicatedStorage.TopbarPlus.Icon)
end

local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = nil
local v2 = 0

local function mountIcon(p)
	v = Icon.new():setName(Config.ICON_NAME):setLabel(Config.ICON_LABEL)
	v.selected:Connect(function()
		v:deselect()
		PanelWindow.toggle(p)
	end)
end

local function clientInit()
	Remotes.inviteReceived:connect(InvitePrompt.enqueue)
end

local function clientUIInit()
	Remotes.getAccess:request():andThen(function(p)
		if p.isCC then
			mountIcon(p)
		end
	end):catch(function(p)
		logger:warn(string.format("could not resolve CC access: %s", (tostring(p))))
	end)
end

local function clientUpdate()
	local now = os.clock()

	if now - v2 >= Config.TICK_INTERVAL then
		v2 = now
		InvitePrompt.tick(now)
		PanelWindow.tick(now)
	end
end

local registerFeature = FeatureManager.RegisterFeature
local name = script.Name

if isServer then
	clientInit = nil
end

if isServer then
	clientUIInit = nil
end

if isServer then
	clientUpdate = nil
end

local onRender

if not isServer then
	onRender = CameraTools.render
end

registerFeature(name, {
	OnInit = clientInit,
	OnUIInit = clientUIInit,
	OnUpdate = clientUpdate,
	OnRender = onRender
})
return {
	remotes = Remotes
}