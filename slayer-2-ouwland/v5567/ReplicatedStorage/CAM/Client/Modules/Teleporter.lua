local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local LoadingScreen = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.LoadingScreen)
local Config = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.LoadingScreen.Config)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Teleporter = {
	Started = simplesignal.new(),
	Finished = simplesignal.new()
}
local flag = false
local v = nil
local v2 = { Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat }
local coreGuiEnableds = nil

local function coverCoreGuis()
	Players.LocalPlayer:SetAttribute("LoadingScreen", true)

	if workspace:GetAttribute("HasVisibilityHandler") == true then
		return
	end

	coreGuiEnableds = {}

	for _, v3 in ipairs(v2) do
		coreGuiEnableds[v3] = StarterGui:GetCoreGuiEnabled(v3)
		StarterGui:SetCoreGuiEnabled(v3, false)
	end
end

local function uncoverCoreGuis()
	Players.LocalPlayer:SetAttribute("LoadingScreen", nil)

	if coreGuiEnableds == nil then
		return
	end

	for k, v3 in coreGuiEnableds do
		StarterGui:SetCoreGuiEnabled(k, v3)
	end

	coreGuiEnableds = nil
end

function Teleporter.ShowCover(p)
	if not (gameSettings.loadingScreenEnabled and v == nil) then
		return
	end

	coverCoreGuis()
	local v3, screenGui = LoadingScreen(Players.LocalPlayer:WaitForChild("PlayerGui"), p)
	v = v3

	if screenGui:IsA("ScreenGui") then
		TeleportService:SetTeleportGui(screenGui)
	end
end

function Teleporter.HideCover()
	local v3 = v

	if v3 == nil then
		return
	end

	v = nil
	uncoverCoreGuis()
	v3()
end

function Teleporter.Request(data, state)
	if flag then
		return false, "Busy"
	end

	if typeof(data) ~= "table" or typeof(data.placeId) ~= "number" and typeof(data.followName) ~= "string" then
		return false, "Invalid settings"
	end

	if typeof(state) ~= "table" then
		state = nil
	end

	if state == nil or state.Title == nil then
		local v3

		if data.placeId ~= nil then
			v3 = Worlds.ById[data.placeId]
		end

		local followName

		if v3 == nil then
			followName = data.followName
		else
			followName = v3.Name
		end

		if followName ~= nil then
			state = state == nil and {} or table.clone(state)
			state.Title = followName

			if data.privateOwner ~= nil and state.SubTitle == nil then
				state.SubTitle = "Private Server"
			end
		end
	end

	flag = true
	Teleporter.Started:Fire(data, state)
	Teleporter.ShowCover(state)
	local v3 = nil
	local v4 = nil
	local success, result = pcall(function()
		v3, v4 = SignalFunction.ToServer("TeleportServer", {
			placeId = data.placeId,
			jobId = data.jobId,
			allowFallback = data.allowFallback,
			followName = data.followName,
			privateOwner = data.privateOwner
		})
	end)

	if not success then
		v3 = false
		v4 = tostring(result)
	end

	local v5 = v3 == true

	if not v5 then
		local v6 = v ~= nil
		Teleporter.HideCover()

		if v6 then
			task.wait(Config.InInfo.Time)
		end
	end

	flag = false
	Teleporter.Finished:Fire(v5, v4, data)
	return v5, v4
end

return Teleporter