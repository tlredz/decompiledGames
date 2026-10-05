local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CUI = require(ReplicatedStorage.CUI)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local CameraTools = require(script.Parent.CameraTools)
local Config = require(script.Parent.Config)
local ContentTab = require(script.Parent.ContentTab)
local EventsTab = require(script.Parent.EventsTab)
local GiftsTab = require(script.Parent.GiftsTab)
local PlayerPicker = require(script.Parent.PlayerPicker)
local PlayersTab = require(script.Parent.PlayersTab)
require(script.Parent.Types)
local WorldsTab = require(script.Parent.WorldsTab)
local NotificationSystem

if RunService:IsServer() then
	NotificationSystem = nil
else
	NotificationSystem = require(ReplicatedStorage.NotificationSystem)
end

local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {}
local v2 = nil
local v3 = 0
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function setStatus(message: string, flag: boolean)
	local v5 = v2:SetText(message)
	local v6

	if flag then
		v6 = Config.ERROR_COLOR
	else
		v6 = Config.SUCCESS_COLOR
	end

	v5:SetTextColor(v6)
	v3 = os.clock() + Config.STATUS_DURATION
end

local function report(p, flag: boolean)
	setStatus(p.message, not p.success) -- equivalent call inferred; original call site unknown

	if flag then
		local v7 = (p.success and "✓ " or "✗ ") .. p.message
		local v8

		if p.success then
			v8 = Config.TOAST_SUCCESS_COLOR
		else
			v8 = Config.TOAST_ERROR_COLOR
		end

		NotificationSystem:ShowMessage(v7, v8)
	end
end

local function reportError(p)
	logger:warn(string.format("request failed: %s", (tostring(p))))
	v2:SetText("Request failed, try again"):SetTextColor(Config.ERROR_COLOR)
	v3 = os.clock() + Config.STATUS_DURATION
end

local function build(object, p)
	local targetChanged = Signal.new()
	local v6 = nil
	v6 = {
		getTarget = function()
			return v4
		end,
		setTarget = function(p2)
			v4 = p2
			targetChanged:Fire()
		end,
		targetChanged = targetChanged,
		openPlayerPicker = function()
			PlayerPicker.open(v6, object)
		end,
		setStatus = setStatus,
		report = report,
		reportError = reportError
	}
	CameraTools.bindInput()
	object:SetTitle(Config.WINDOW_ID)
	object.Components:AddTab(function(object2)
		local v7 = { "Players", "Gifts" }

		if p.isSandbox then
			table.insert(v7, "CC Worlds")
		end

		if p.isCCWorld then
			table.insert(v7, "Content")
			table.insert(v7, "Events")
		end

		object2:SetTabs(v7)
		table.insert(v, PlayersTab.build(object2:GetComponentCtn("Players"), v6))
		table.insert(v, GiftsTab.build(object2:GetComponentCtn("Gifts"), v6))

		if p.isSandbox then
			table.insert(v, WorldsTab.build(object2:GetComponentCtn("CC Worlds"), v6, p.isCCWorld))
		end

		if p.isCCWorld then
			table.insert(v, ContentTab.build(object2:GetComponentCtn("Content"), v6))
			table.insert(v, EventsTab.build(object2:GetComponentCtn("Events"), v6))
		end
	end)
	v2 = object.Components:AddText(function(object2)
		object2:SetText("")
	end)
end

local PanelWindow = {}

function PanelWindow.toggle(p)
	local window = CUI.GetWindow(Config.WINDOW_ID, Config.WINDOW_WIDTH, function(p2)
		build(p2, p)
	end)

	if window:IsVisible() then
		window:SetVisible(false)
		return
	end

	window:SetVisible(true)

	for _, v5 in v do
		v5.refresh()
	end
end

function PanelWindow.tick(p: number)
	if v3 > 0 and v3 <= p then
		v3 = 0
		v2:SetText("")
	end

	for _, v5 in v do
		v5.tick(p)
	end
end

return PanelWindow