local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local AvatarEditorService = game:GetService("AvatarEditorService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Promise)
require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Types.Analytics)
local v5 = require3(ReplicatedStorage2.Shared.WeightRandom)
local v6 = require3(ReplicatedStorage2.Shared.Analytics.ImpressionTrackingData)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Packages.Trove)
local v9 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v10 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v11 = require3(ReplicatedStorage2.ServerInfo)
local remoteEvent = v:RemoteEvent("SetDeviceType")
local remoteEvent2 = v:RemoteEvent("SessionAnalyticsEvent")
local localPlayer = Players.LocalPlayer
local v12 = {}
local v13 = game.GameId ~= 4777817887
local AnalyticsController = {
	_impressionTrackingTrove = v8.new(),
	Started = false,
	GetRemoteConfigValue = function(_, _: string, p, _: number?)
		return v3.new(function(callback, _)
			callback(p)
		end)
	end,
	RunEligibleExperiments = function(self)
		for _, v14 in v12 do
			if v14.Disabled then
				continue
			end

			local v15 = (typeof(self.RemoteConfig) ~= "table" and {} or self.RemoteConfig)[v14.RemoteConfig] or v14.DefaultValue

			if v13 and v14.TestConfigValues then
				local osTimeJoined = v2.Client:WaitReplion("Data"):Get("osTimeJoined") or 0
				local v16 = localPlayer.UserId * osTimeJoined // 1000000
				v15 = v5.getPicker(v14.TestConfigValues, nil, nil, v16)()
			end

			local v16 = v14.Configs[v15] or v14.Configs[v14.DefaultValue]

			if v16 then
				task.spawn(v16, localPlayer)
			end
		end
	end,
	_promptFavorite = function(self)
		if v11.isRhythmServer() then
			return
		end

		local v14 = v2.Client:WaitReplion("Data")
		local promptedFavoriteGame = v14:Get("PromptedFavoriteGame")
		local v15 = v14:Get("SessionCount") > 1
		local v16 = nil
		pcall(function()
			v16 = localPlayer:IsInGroup(12836673)
		end)

		if v16 and not promptedFavoriteGame and v4:GetKey("PromptFavoriteGame") and v15 then
			task.delay(90, function()
				while localPlayer.Character and localPlayer.Character.Parent == workspace.Alive do
					task.wait(1)
				end

				task.wait(3)
				v:RemoteEvent("PromptedFavoriteGame"):FireServer()
				pcall(
					AvatarEditorService.PromptSetFavorite,
					AvatarEditorService,
					13772394625,
					Enum.AvatarItemType.Asset,
					true
				)
			end)
		end
	end,
	TrackImpression = function(self, p)
		local impression = v6.Impressions[p]

		if impression and not impression.Disabled then
			v6.TrackImpression:FireServer(p)
		elseif v13 then
			warn(not impression and "Invalid impressionType" or `{p} tracking is disabled`)
		end
	end,
	_watchMapImpressions = function(self, childName, p)
		self._impressionTrackingTrove:Clean()
		local impression = v6.Impressions[p]

		if impression.Type ~= "Map" then
			return
		end

		local currentCamera = workspace.CurrentCamera
		local v14 = false
		local v15 = false
		local v16 = 0
		self._impressionTrackingTrove:Add(v9.Every(1, function()
			local now = os.clock()

			if now - v16 <= impression.ImpressionCooldown then
				return
			end

			local child = workspace.Map:FindFirstChild(childName)
			local BALLSPAWN = child and child:WaitForChild("BALLSPAWN", 3)
			local pivot = BALLSPAWN and BALLSPAWN:GetPivot()

			if not pivot then
				return
			end

			local v17 = (pivot.Position - currentCamera.CFrame.Position).Magnitude <= 250

			if v17 == v14 then
				if v17 and not v15 then
					v15 = true
					v16 = now
					self:TrackImpression(p)
				end
			else
				if not v17 then
					v15 = false
				end

				v14 = v17
			end
		end))
	end,
	_startTrackingImpressions = function(self)
		local v14 = {}

		for k, impression in v6.Impressions do
			if impression.Disabled then
				continue
			end

			if impression.Type == "UI" then
				local v15 = 0
				local v16 = impression
				local v17 = k
				v7:OnGuiOpen(impression.Name, function()
					local now = os.clock()

					if v16.ImpressionCooldown and now - v15 < v16.ImpressionCooldown then
						return
					end

					v15 = now
					self:TrackImpression(v17)
				end)
			elseif impression.Type == "Map" then
				v14[impression.Name] = k
			end
		end

		workspace:GetAttributeChangedSignal("GameActive"):Connect(function()
			if not workspace:GetAttribute("GameActive") then
				return
			end

			local currentlySelectedMap = workspace:GetAttribute("CurrentlySelectedMap")
			self._impressionTrackingTrove:Clean()

			if v14[currentlySelectedMap] then
				self:_watchMapImpressions(currentlySelectedMap, v14[currentlySelectedMap])
			end
		end)
	end
}
local flag = false
local object = setmetatable({}, {
	__mode = "k"
})
local v14 = {
	HUD = true,
	Hotbar = true,
	Chat = true,
	BubbleChat = true,
	PlayerList = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isInMatch()
	return workspace:GetAttribute("GameActive") == true and localPlayer.Character ~= nil and localPlayer.Character.Parent == workspace:FindFirstChild("Alive")
end

local function getScreenGui(parent)
	while parent do
		if parent:IsA("ScreenGui") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function isActuallyVisible(guiObject, screenGui)
	local v15

	if guiObject.AbsoluteSize.X > 0 then
		v15 = guiObject.AbsoluteSize.Y > 0
	else
		v15 = false
	end

	if not (screenGui.Enabled and guiObject.Visible and v15) then
		return false
	end

	local parent = guiObject.Parent

	while parent and parent ~= screenGui do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return true
end

local function getOpenUIs(playerGui)
	local names = {}

	for _, screenGui in playerGui:GetChildren() do
		if not screenGui:IsA("ScreenGui") or v14[screenGui.Name] or not screenGui.Enabled then
			continue
		end

		for _, guiObject in screenGui:GetDescendants() do
			if not (guiObject:IsA("GuiObject") and isActuallyVisible(guiObject, screenGui)) then
				continue
			end

			table.insert(names, screenGui.Name)
			break
		end

		if #names >= 8 then
			break
		end
	end

	return names
end

local function startSessionAnalytics()
	if flag then
		return
	end

	flag = true
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local lastAction = "Join"
	local lastTime = os.clock()
	local now = os.clock()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function send(p: string, options)
		remoteEvent2:FireServer(p, options or {})
	end

	local function connectButton(button)
		if button:IsA("GuiButton") and not object[button] then
			object[button] = true
			button.Activated:Connect(function()
				local parent = button

				while true do
					if not parent then
						parent = nil
						break
					end

					if parent:IsA("ScreenGui") then
						break
					else
						parent = parent.Parent
					end
				end

				local ui = not parent and "UnknownUI" or parent.Name
				lastAction = `UI-{button.Name}`
				send("UIInteraction", {
					ui = ui,
					control = button.Name,
					inMatch = isInMatch()
				}) -- equivalent call inferred; original call site unknown
			end)
		end
	end

	local v16 = 0
	local flag2 = false
	local v17 = false
	local count = 0

	for _, button in playerGui:GetDescendants() do
		if not button:IsA("GuiButton") or object[button] then
			continue
		end

		object[button] = true
		local v18 = button
		button.Activated:Connect(function()
			local parent = v18

			while true do
				if not parent then
					parent = nil
					break
				end

				if parent:IsA("ScreenGui") then
					break
				else
					parent = parent.Parent
				end
			end

			local ui = not parent and "UnknownUI" or parent.Name
			lastAction = `UI-{v18.Name}`
			send("UIInteraction", {
				ui = ui,
				control = v18.Name,
				inMatch = isInMatch()
			}) -- equivalent call inferred; original call site unknown
		end)
	end

	playerGui.DescendantAdded:Connect(connectButton)
	UserInputService.InputBegan:Connect(function(_, _: boolean)
		lastTime = os.clock()

		if lastTime - v16 >= 2 then
			v16 = lastTime
			send("Activity") -- equivalent call inferred; original call site unknown
		end

		if flag2 then
			flag2 = false
			lastAction = "AFKEnd"
			send("AFKEnd") -- equivalent call inferred; original call site unknown
		end
	end)

	local function observeCharacter(instance)
		local humanoid = instance:WaitForChild("Humanoid", 10)

		if humanoid and humanoid:IsA("Humanoid") then
			humanoid.Running:Connect(function(p: number)
				if v17 or p <= 0.5 or humanoid.MoveDirection.Magnitude <= 0.05 then
					return
				end

				v17 = true
				lastAction = "Move"
				send("FirstMove") -- equivalent call inferred; original call site unknown
			end)
		end
	end

	if localPlayer.Character then
		task.spawn(observeCharacter, localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(observeCharacter)
	RunService.RenderStepped:Connect(function()
		count += 1
	end)
	task.spawn(function()
		while localPlayer.Parent do
			task.wait(5)

			if flag2 or not (os.clock() - lastTime >= 60) then
				continue
			end

			flag2 = true
			lastAction = "AFKStart"
			send("AFKStart") -- equivalent call inferred; original call site unknown
		end
	end)
	task.spawn(function()
		while localPlayer.Parent do
			task.wait(15)
			local now2 = os.clock()
			local v18 = math.max(now2 - now, 0.001)
			local fps = count / v18
			local pingMs = 0
			count = 0
			now = now2
			pcall(function()
				pingMs = localPlayer:GetNetworkPing() * 1000
			end)
			send("Snapshot", {
				lastAction = lastAction,
				openUIs = getOpenUIs(playerGui),
				inMatch = isInMatch(),
				fps = fps,
				pingMs = pingMs
			}) -- equivalent call inferred; original call site unknown
		end
	end)
end

function AnalyticsController:Start()
	if AnalyticsController.Started then
		return
	end

	local function updateDeviceType(p)
		if p ~= "Console" then
			p = (p == "Phone" or p == "Tablet") and "Mobile" or "Desktop"
		end

		remoteEvent:FireServer(p)
	end

	v10:Observe(updateDeviceType)

	for _, child in script.Experiments:GetChildren() do
		local v15 = require3(child)

		if v15.RemoteConfig then
			v12[child.Name] = v15
		end
	end

	AnalyticsController.Started = true
	self.RemoteConfig = {}
	startSessionAnalytics()
	self:RunEligibleExperiments()
	self:_startTrackingImpressions()

	if not v11.isMedalServer() then
		self:_promptFavorite()
	end
end

return AnalyticsController