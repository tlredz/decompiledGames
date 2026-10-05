local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local EventBoardView = require(ReplicatedStorage.Shared.Modules.EventBoardView)
local Log = require(ReplicatedStorage.Packages.Log)
local PlotState = require(ReplicatedStorage.Client.PlotState)
return {
	Start = function()
		local localPlayer = Players.LocalPlayer
		local v = Log.new()
		local connections = {}
		local flag = false
		local v2 = nil
		local id = nil
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local v6 = nil

		local function setShown(folder, enabled: boolean)
			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") then
					local boardClear = descendant:GetAttribute("BoardClear")
					descendant.Transparency = not enabled and 1 or typeof(boardClear) ~= "number" and 0 or boardClear
				elseif descendant:IsA("SurfaceGui") then
					descendant.Enabled = enabled
				elseif descendant:IsA("ProximityPrompt") then
					descendant.Enabled = enabled
				end
			end
		end

		local function getOwnBoard()
			local localSlot = PlotState.ResolveLocalSlot()

			if localSlot == nil then
				return nil
			end

			local plots = Workspace:FindFirstChild("Plots")
			local child

			if plots ~= nil then
				child = plots:FindFirstChild((tostring(localSlot)))
			end

			local eventBoard

			if child ~= nil then
				eventBoard = child:FindFirstChild("EventBoard")
			end

			if eventBoard == nil or not eventBoard:IsA("Model") then
				return nil
			end

			return eventBoard
		end

		local function formatTimer(p)
			return (`NEXT UPDATE\n{EventBoardView.Countdown(p.StartsAt - os.time())}`)
		end

		local function takeDown()
			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)

			if v3 ~= nil then
				v3:Destroy()
				v3 = nil
			end

			if v4 ~= nil then
				v4:Destroy()
				v4 = nil
			end

			local v7 = v2

			if v7 ~= nil and v7.Parent ~= nil then
				setShown(v7, false)
			end

			v2 = nil
			id = nil
		end

		local function onTriggered(p)
			if flag then
				return
			end

			flag = true
			local success, result = pcall(SocialService.PromptRsvpToEventAsync, SocialService, p.Id)

			if success then
				local success2, eventRsvpStatusAsync = pcall(SocialService.GetEventRsvpStatusAsync, SocialService, p.Id)

				if success2 and eventRsvpStatusAsync == Enum.RsvpStatus.Going then
					takeDown()
				end

				flag = false
			else
				v:AtWarning():Log((`EventBoard RSVP prompt failed: {result}`))
				flag = false
			end
		end

		local function mount(data, ownBoard)
			setShown(ownBoard, true)
			local display = ownBoard:FindFirstChild("Display")
			local surfaceGui

			if display ~= nil then
				surfaceGui = display:FindFirstChildWhichIsA("SurfaceGui")
			end

			if surfaceGui ~= nil then
				local surfaceGuiFrame = surfaceGui:FindFirstChild("Frame") or surfaceGui
				local eventCountdown = surfaceGuiFrame:FindFirstChild("EventCountdown")

				if eventCountdown ~= nil then
					eventCountdown:Destroy()
				end

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "EventCountdown"
				textLabel.BackgroundTransparency = 1
				textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				textLabel.Position = UDim2.fromScale(0.5, 0.5)
				textLabel.Size = UDim2.fromScale(0.9, 0.45)
				textLabel.TextScaled = true
				textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				textLabel.Text = `NEXT UPDATE\n{EventBoardView.Countdown(data.StartsAt - os.time())}`
				textLabel.ZIndex = 5
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Thickness = 3
				uIStroke.Color = Color3.fromRGB(0, 0, 0)
				uIStroke.Parent = textLabel
				textLabel.Parent = surfaceGuiFrame
				v3 = textLabel
			end

			local proximityPrompt = ownBoard:FindFirstChildWhichIsA("ProximityPrompt", true)

			if proximityPrompt == nil then
				v:AtWarning():Log("EventBoard has no ProximityPrompt, sign-up is display only")
			else
				proximityPrompt.RequiresLineOfSight = false
				proximityPrompt.MaxActivationDistance = EventBoardView.PromptDistance
				proximityPrompt.HoldDuration = 0

				if data.Title ~= "" then
					proximityPrompt.ObjectText = data.Title
				end

				if proximityPrompt.ActionText == "" then
					proximityPrompt.ActionText = "Follow Event"
				end

				table.insert(connections, proximityPrompt.Triggered:Connect(function(player)
					if player == localPlayer then
						task.spawn(onTriggered, data)
					end
				end))
			end

			if display ~= nil and display:IsA("BasePart") then
				local sound = Instance.new("Sound")
				sound.Name = "EventBoardAmbience"
				sound.SoundId = "rbxassetid://139717384302574"
				sound.Looped = true
				sound.Volume = 0.5
				sound.RollOffMode = Enum.RollOffMode.Linear
				sound.RollOffMinDistance = 4
				sound.RollOffMaxDistance = 14
				sound.SoundGroup = SoundService:FindFirstChild("Gameplay")
				sound.Parent = display
				v4 = sound
				table.insert(connections, RunService.Heartbeat:Connect(function()
					local character = localPlayer.Character
					local humanoidRootPart

					if character ~= nil then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					local v7

					if humanoidRootPart == nil then
						v7 = false
					else
						v7 = humanoidRootPart:IsA("BasePart") and (humanoidRootPart.Position - display.Position).Magnitude <= 14
					end

					if v7 and not sound.IsPlaying then
						sound:Play()
					elseif not v7 and sound.IsPlaying then
						sound:Stop()
					end
				end))
			end

			v2 = ownBoard
			id = data.Id
			v5 = nil
			v:AtInfo():Log((`EventBoard mounted for event {data.Id}`))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reportBail(formatted: string)
			if v5 == formatted then
				return
			end

			v5 = formatted
			v:AtInfo():Log((`EventBoard hidden: {formatted}`))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isVariantServer()
			return Workspace:GetAttribute("ExpandedLobbyServerGroup") == "Variant"
		end

		local function waitForVariantServer()
			local v7 = os.clock() + 60

			while Workspace:GetAttribute("ExpandedLobbyServerGroup") == nil and os.clock() < v7 do
				task.wait(0.5)
			end

			return isVariantServer()
		end

		local function apply()
			if flag then
				return
			end

			if v2 ~= nil and v2.Parent == nil then
				takeDown()
			end

			local v7 = v6

			if isVariantServer() then
				if v7 == nil then
					if v5 ~= "no upcoming event (none active and not yet started for this universe)" then
						v5 = "no upcoming event (none active and not yet started for this universe)"
						v:AtInfo():Log("EventBoard hidden: no upcoming event (none active and not yet started for this universe)")
					end

					takeDown()
				elseif EventBoardView.ShouldShow(v7) then
					if v2 ~= nil and id == v7.Id then
						return
					end

					local ownBoard = getOwnBoard()

					if ownBoard == nil then
						reportBail(`no EventBoard model found on plot {tostring(PlotState.ResolveLocalSlot())}`) -- equivalent call inferred; original call site unknown
					else
						takeDown()
						mount(v7, ownBoard)
					end
				else
					reportBail(`event {v7.Id} hidden: player is already going`) -- equivalent call inferred; original call site unknown
					takeDown()
				end
			else
				reportBail(`server group is {tostring(Workspace:GetAttribute("ExpandedLobbyServerGroup"))}, not Variant`) -- equivalent call inferred; original call site unknown
				takeDown()
			end
		end

		local function refreshUpcoming()
			local success, result = pcall(function()
				return SocialService:GetUpcomingExperienceEventsAsync()
			end)

			if success then
				v6 = EventBoardView.Pick(result, os.time())
				return true
			end

			v:AtWarning():Log((`EventBoard failed to fetch experience events: {result}`))
			return false
		end

		task.spawn(function()
			if not waitForVariantServer() then
				v:AtInfo():Log((`EventBoard idle, server group is {tostring(Workspace:GetAttribute("ExpandedLobbyServerGroup"))}`))
				return
			end

			PlotState.LocalPlotChanged:Connect(function()
				apply()
			end)
			task.spawn(function()
				while true do
					local v7 = refreshUpcoming()
					apply()
					local v8

					if v7 then
						v8 = EventBoardView.RefreshSeconds
					else
						v8 = EventBoardView.RetryBackoffSeconds
					end

					task.wait(v8)
				end
			end)
			task.spawn(function()
				while true do
					task.wait(EventBoardView.TimerUpdateSeconds)
					local v7 = v3
					local v8 = v6

					if v7 ~= nil and v7.Parent ~= nil and v8 ~= nil then
						v7.Text = `NEXT UPDATE\n{EventBoardView.Countdown(v8.StartsAt - os.time())}`
					end
				end
			end)
			task.spawn(function()
				while true do
					task.wait(5)

					if v6 ~= nil and (v2 == nil or v2.Parent == nil) then
						apply()
					end
				end
			end)
		end)
	end
}