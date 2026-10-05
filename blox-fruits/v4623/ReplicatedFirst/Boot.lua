local Chat = game:GetService("Chat")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("ReactRoblox"))
local Global = require(ReplicatedFirst:WaitForChild("Global"))
local LoadingScreen = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Components"):WaitForChild("LoadingScreen"))
local TEXTURES = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Components"):WaitForChild("LoadingScreen"):WaitForChild("TEXTURES"))
local v = {}

for _, v2 in TEXTURES.IMAGES do
	table.insert(v, v2)
end

for _, v2 in TEXTURES.SPRITES do
	table.insert(v, v2.Image)
end

table.freeze(v)
local v2 = {}

for _, v3 in v do
	v2[v3] = Enum.AssetFetchStatus.None
end

local createElement = React.createElement
Chat:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, function()
	return {
		BubbleChatEnabled = true
	}
end)

if Workspace.StreamingEnabled then
	GuiService:SetGameplayPausedNotificationEnabled(false)
end

Workspace.PersistentLoaded:Connect(function()
	Global.PersistentLoaded = true
end)
local localPlayer = Players.LocalPlayer
local arrivingTeleportGui = TeleportService:GetArrivingTeleportGui()

local function bootLoadingScreen()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function getIfLoadComplete()
		if localPlayer:GetAttribute("LoadComplete") then
			return true
		end

		return (localPlayer:GetAttribute("LoadComplete"))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getLoadingMessage()
		return localPlayer:GetAttribute("LoadingMessage") or "Loading Blox Fruits"
	end

	local function getLoadedAssets()
		local count = 0

		for _, v3 in v2 do
			if v3 == Enum.AssetFetchStatus.Loading or v3 == Enum.AssetFetchStatus.None then
				break
			else
				count += 1
			end
		end

		return count
	end

	local frame = Instance.new("Frame")
	frame.Name = "Root"
	frame.Size = UDim2.fromScale(1, 1)
	frame:SetAttribute("LoadingMessage", getLoadingMessage())
	frame.BackgroundTransparency = 1

	local function loadingScreenContainer(_)
		local state, setState = React.useState((getLoadedAssets()))
		local state2, setState2 = React.useState(getLoadingMessage())
		local state3, setState3 = React.useState(arrivingTeleportGui and "Loading" or "Unloaded")
		React.useEffect(function()
			if state >= #v and state3 == "Unloaded" then
				setState3("Loading")
			end
		end, { state, state3 })
		React.useEffect(function()
			if state3 == "Loaded" then
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
			else
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
			end

			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end, { state3 })
		React.useEffect(function()
			if state3 == "Loading" then
				local loadCompleteChangedConnection = localPlayer:GetAttributeChangedSignal("LoadComplete"):Connect(function()
					if getIfLoadComplete() then
						task.wait(2)
						setState3("Loaded")
					end
				end)
				local thread = task.delay(2, function()
					if getIfLoadComplete() then
						setState3("Loaded")
					end
				end)
				return function()
					loadCompleteChangedConnection:Disconnect()
					task.cancel(thread)
				end
			else
				if state3 ~= "Unloaded" then
					return function() end
				end

				local loadCompleteChangedConnection = localPlayer:GetAttributeChangedSignal("LoadComplete"):Connect(function()
					if not (localPlayer:GetAttribute("LoadComplete") or localPlayer:GetAttribute("LoadComplete")) then
						setState3("Loading")
					end
				end)

				if not (localPlayer:GetAttribute("LoadComplete") or localPlayer:GetAttribute("LoadComplete")) then
					setState3("Loading")
				end

				return function()
					loadCompleteChangedConnection:Disconnect()
				end
			end
		end, { state3 })
		React.useEffect(function()
			local loadingMessageChangedConnection = localPlayer:GetAttributeChangedSignal("LoadingMessage"):Connect(function()
				setState2(getLoadingMessage())
				frame:SetAttribute("LoadingMessage", getLoadingMessage())
			end)
			setState2(getLoadingMessage())
			frame:SetAttribute("LoadingMessage", getLoadingMessage())
			return function()
				loadingMessageChangedConnection:Disconnect()
			end
		end, {})
		React.useEffect(function()
			local thread = task.spawn(function()
				ContentProvider:PreloadAsync(v, function(p: string, p2)
					if not table.find(v, p) then
						return
					end

					v2[p] = p2
					setState(getLoadedAssets)
				end)
			end)
			return function()
				task.cancel(thread)
			end
		end, { state3 })
		return createElement(LoadingScreen, {
			Stage = state3,
			LoadingMessage = state2,
			AssetsLoaded = state,
			AssetsNeeded = #v,
			Size = UDim2.fromScale(1, 1)
		})
	end

	ReactRoblox.createRoot(frame):render((ReactRoblox.createPortal(createElement(loadingScreenContainer, {}), frame)))
	return frame
end

local screenGui = Instance.new("ScreenGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.ScreenInsets = Enum.ScreenInsets.None
screenGui.DisplayOrder = 1000
screenGui.Name = "LoadingGui"
local bootLoadingScreen_2 = bootLoadingScreen()
bootLoadingScreen_2.Parent = screenGui
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
ReplicatedFirst:RemoveDefaultLoadingScreen()
TeleportService:SetTeleportGui(screenGui)