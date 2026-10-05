local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local Promise = require(packages:WaitForChild("Promise"))
require(ReplicatedStorage.shared.modules.character)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
require(ReplicatedStorage.packages.Observers)
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local cutscene = playerGui:WaitForChild("Cutscene")
local top = cutscene:WaitForChild("Top")
local bottom = cutscene:WaitForChild("Bottom")
local fade = cutscene:WaitForChild("Fade")
local v = {}
local v2 = {}
local v3 = {}
v.Instance = top
v.Positions = {}
v.Positions[true] = top.Position
v.Positions[false] = top.Position + UDim2.fromScale(0, -2)
v2.Instance = bottom
v2.Positions = {}
v2.Positions[true] = bottom.Position
v2.Positions[false] = bottom.Position + UDim2.fromScale(0, 2)
v3.Instance = fade
v3.Transparency = {}
v3.Transparency[true] = 0
v3.Transparency[false] = 1
v.Instance.Position = v.Positions[false]
v2.Instance.Position = v2.Positions[false]
v3.Instance.Transparency = v3.Transparency[false]
v.Instance.Visible = true
v2.Instance.Visible = true
v3.Instance.Visible = true
local bestiaryReplicator = DataController.BestiaryReplicator
local remoteEvent = Net:RemoteEvent("RequestCutscene", -1)
local remoteEvent2 = Net:RemoteEvent("RequestCutsceneSync", -1)
local remoteEvent3 = Net:RemoteEvent("RequestFade", -1)
local remoteEvent4 = Net:RemoteEvent("RequestSaneFade", -1)
local remoteEvent5 = Net:RemoteEvent("RequestToggleFade", -1)
local remoteEvent6 = Net:RemoteEvent("CameraReplicationFocusSet", -1)
local unreliableRemoteEvent = Net:UnreliableRemoteEvent("CameraReplicationFocusUpdate", -1)
local v4 = {}
local v5 = SettingsController:GetSettingValue("disableCutscenes") == false
local v6 = {
	Fischmas2025Event = true,
	DivineSealBreak = true,
	NoiseformFinal = true,
	Fischfest26Final = true,
	LullabyMasteryFinal = true,
	death = true,
	NereusDeviceRepair = true,
	NorthMeteorShower = true,
	FlyingDutchmanVoyage = true
}
local v7 = {
	MagmaLeviathanCapture = "Magma Leviathan",
	FrozenLeviathanCapture = "Frozen Leviathan",
	CrownedAnglerCapture = "Crowned Anglerfish",
	CrystallizedSeadragonCapture = "Crystallized Seadragon",
	SeaLeviathanCapture = "Sea Leviathan",
	NorthstarWhaleCapture = "Northstar Whale",
	ScyllaCapture = "Scylla",
	MobyCapture = "Moby"
}
local v8 = {
	KrakenCapture = { "The Kraken", "Ancient Kraken" },
	MegalodonCapture = { "Megalodon", "Phantom Megalodon", "Ancient Megalodon" }
}
local CutsceneController = {}
local enableds = {}

function CutsceneController.DisableAllScreens(_, value)
	return Promise.new(function(callback, _, _)
		local function enable()
			for k, v9 in enableds do
				k.Enabled = v9 or k.Name == "hud" or k.Name == "backpack" or k.Name == "reel" or k.Name == "shakeui" or k.Name == "stab" or script.Name == "harpoonMinigame"
			end

			table.clear(enableds)
			callback()
		end

		for _, v9 in playerGui:QueryDescendants("ScreenGui") do
			if v9 == cutscene or v9:HasTag("IgnoreCinematic") then
				continue
			end

			if enableds[v9] == nil then
				enableds[v9] = v9.Enabled
			end

			v9.Enabled = false
		end

		if type(value) == "number" or value == nil then
			task.wait(value or 1)
			enable()
		elseif type(value) == "function" then
			value(enable)
		end
	end)
end

function CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(duration: number, duration2, color: Color3?, p)
	return Promise.new(function(callback, _, _)
		v3.Instance.Transparency = v3.Transparency[false]
		v3.Instance.BackgroundColor3 = color or Color3.new(0, 0, 0)
		local tweenInfo = TweenInfo.new(duration, p or Enum.EasingStyle.Quint)
		local tweenInfo2 = TweenInfo.new(duration2, p or Enum.EasingStyle.Quint)
		TweenService:Create(v3.Instance, tweenInfo, {
			Transparency = v3.Transparency[true]
		}):Play()
		task.wait(duration)
		TweenService:Create(v3.Instance, tweenInfo2, {
			Transparency = v3.Transparency[false]
		}):Play()
		task.wait(duration2)
		callback()
	end)
end

function CutsceneController:FadeToggle(duration: number, flag: boolean, color: Color3?)
	return Promise.new(function(callback, _, _)
		v3.Instance.Transparency = v3.Transparency[not flag]
		v3.Instance.BackgroundColor3 = color or Color3.new(0, 0, 0)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
		TweenService:Create(v3.Instance, tweenInfo, {
			Transparency = v3.Transparency[flag]
		}):Play()
		GuiService:SetGameplayPausedNotificationEnabled(not flag)
		task.wait(duration)
		callback()
	end)
end

function CutsceneController:Fade(p: number, value: number?, value2: number?, color: Color3?)
	return Promise.new(function(callback, _, _)
		local v9 = p * (value or 0.1)
		local v10 = p * (value2 or 0.1)
		local v11 = p - v9 - v10
		v3.Instance.Transparency = v3.Transparency[false]
		v3.Instance.BackgroundColor3 = color or Color3.new(0, 0, 0)
		local tweenInfo = TweenInfo.new(v9, Enum.EasingStyle.Quint)
		TweenInfo.new(v10, Enum.EasingStyle.Quint)
		TweenService:Create(v3.Instance, tweenInfo, {
			Transparency = v3.Transparency[true]
		}):Play()
		task.wait(v9 + v11)
		TweenService:Create(v3.Instance, tweenInfo, {
			Transparency = v3.Transparency[false]
		}):Play()
		task.wait(v10)
		callback()
	end)
end

function CutsceneController.ShowBars(_, p: number, value: number?, value2: number?)
	return Promise.new(function(callback, _, _)
		local v9 = p * (value or 0.1)
		local v10 = p * (value2 or 0.1)
		local v11 = p - v9 - v10
		v.Instance.Position = v.Positions[false]
		v2.Instance.Position = v2.Positions[false]
		local tweenInfo = TweenInfo.new(v9, Enum.EasingStyle.Quint)
		local tweenInfo2 = TweenInfo.new(v10, Enum.EasingStyle.Quint)
		TweenService:Create(v.Instance, tweenInfo, {
			Position = v.Positions[true]
		}):Play()
		TweenService:Create(v2.Instance, tweenInfo, {
			Position = v2.Positions[true]
		}):Play()
		task.wait(v9 + v11)
		TweenService:Create(v.Instance, tweenInfo2, {
			Position = v.Positions[false]
		}):Play()
		TweenService:Create(v2.Instance, tweenInfo2, {
			Position = v2.Positions[false]
		}):Play()
		task.wait(v10)
		callback()
	end)
end

local maxBubbles = nil
local maxDistance = nil

local function wasPreviouslyDiscovered(p: string)
	bestiaryReplicator:WaitForLoaded()
	local v9 = bestiaryReplicator:TryIndex({ "Bestiary" })

	if not v9 then
		return false
	end

	local v10 = v9[p]

	if not v10 then
		return false
	end

	local discovered = tonumber(v10.Discovered)
	return not (discovered and os.time() - discovered <= 10)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasPreviouslyDiscoveredAnyFish(items)
	for _, item in items do
		if wasPreviouslyDiscovered(item) then
			return true
		end
	end

	return false
end

function CutsceneController:StartCutscene(p: string, p2, ...)
	if v6[p] ~= true and not v5 then
		local v9 = v7[p]
		local v10 = v8[p]

		if v9 then
			if wasPreviouslyDiscovered(v9) then
				return
			end
		else
			if not v10 then
				return
			end

			-- equivalent call inferred; original call site unknown
			if hasPreviouslyDiscoveredAnyFish(v10) then
				return
			end
		end
	end

	if p2 == localPlayer then
		workspace:SetAttribute("ClientCutsceneRunning", true)
		local bubbleChatConfiguration = TextChatService:FindFirstChild("BubbleChatConfiguration")

		if bubbleChatConfiguration then
			if not maxBubbles then
				maxBubbles = bubbleChatConfiguration.MaxBubbles
			end

			if not maxDistance then
				maxDistance = bubbleChatConfiguration.MaxDistance
			end

			bubbleChatConfiguration.MaxBubbles = 0
			bubbleChatConfiguration.MaxDistance = 0
		end
	end

	local v9 = { v4[p]:Start(p2, ...):await() }

	if not v9[1] then
		warn(`[Cutscene] "{p}" failed:`, v9[2])
	end

	if p2 ~= localPlayer then
		return table.unpack(v9)
	end

	workspace:SetAttribute("ClientCutsceneRunning", nil)
	local bubbleChatConfiguration = TextChatService:FindFirstChild("BubbleChatConfiguration")

	if bubbleChatConfiguration then
		bubbleChatConfiguration.MaxBubbles = maxBubbles or 3
		bubbleChatConfiguration.MaxDistance = maxDistance or 100
	end

	return table.unpack(v9)
end

function CutsceneController:Start()
	for _, moduleScript in script:WaitForChild("Cutscenes"):GetChildren() do
		local v9 = v4
		local name = moduleScript.Name
		local module = require(moduleScript)
		v9[name] = module
	end

	script.Cutscenes.ChildAdded:Connect(function(child)
		local v9 = v4
		local name = child.Name
		local module = require(child)
		v9[name] = module
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string, ...)
		if v4[p] then
			CutsceneController:StartCutscene(p, ...)
		end
	end)
	remoteEvent2.OnClientEvent:Connect(function(p: string, p2: string, ...)
		if v4[p2] then
			CutsceneController:StartCutscene(p2, ...)
			remoteEvent2:FireServer(p)
		end
	end)
	remoteEvent3.OnClientEvent:Connect(function(...)
		CutsceneController:Fade(...)
	end)
	remoteEvent4.OnClientEvent:Connect(function(...)
		CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(...)
	end)
	remoteEvent5.OnClientEvent:Connect(function(...)
		CutsceneController:FadeToggle(...)
	end)
	local v9 = false
	local preRenderConnection = nil
	local total = 0
	remoteEvent6.OnClientEvent:Connect(function(p)
		if not v9 and p then
			preRenderConnection = RunService.PreRender:Connect(function(dt)
				total += dt

				if total < 0.1 then
					return
				end

				total = 0
				unreliableRemoteEvent:FireServer(currentCamera.CFrame.Position)
			end)
		end

		v9 = p

		if not v9 and preRenderConnection then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end
	end)
	SettingsController:GetSettingChangedSignal("disableCutscenes"):Connect(function(flag: boolean)
		v5 = flag == false
	end)
end

return CutsceneController