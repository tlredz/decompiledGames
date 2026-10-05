local util = game.ReplicatedStorage:WaitForChild("Util")
local Debris = require(util:WaitForChild("Debris"))
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Realm = require(game.ReplicatedStorage.Util.Realm)
local ifCurrentRealmHasTagAsync = Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent")
local AnalyticsUtil = require(game.ReplicatedStorage.Util.AnalyticsUtil)
local Easter2026 = require(game.ReplicatedStorage.EventConfig.Easter2026)
local Locations = require(script.Locations)
task.spawn(function()
	repeat
		local v = pcall(function()
			local StarterGui = game:GetService("StarterGui")
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		end)
		task.wait()
	until v
end)

for _, child in pairs(workspace:WaitForChild("_WorldOrigin"):WaitForChild("EnemyRegions"):GetChildren()) do
	child.Transparency = 1
end

local UserInputService = game:GetService("UserInputService")
game:GetService("ContextActionService")
local DoTeamSelection = require(ReplicatedStorage.React.Components.TeamSelection.DoTeamSelection)
LastInput:IsMobile()

if GuiService:IsTenFootInterface() then
	local _ = UserInputService.GamepadEnabled
end

local flag = false
local chooseTeam = script.Parent:WaitForChild("ChooseTeam")
local localPlayer = game.Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui")
local currentCamera = workspace.CurrentCamera
local v = {
	Sea2 = Locations.Sea2[1].CFrame,
	Sea1 = Locations.Sea1[1].CFrame
}
currentCamera.CameraType = "Scriptable"
local currentSeaAsync = Realm.getCurrentSeaAsync()
local v2

if currentSeaAsync then
	v2 = v[currentSeaAsync]
end

currentCamera.CFrame = v2 or currentCamera.CFrame
local cFrame = currentCamera.CFrame

-- equivalent calls inferred from this helper; original call sites unknown
local function fixcam()
	if not localPlayer.Team then
		currentCamera.CameraType = "Scriptable"
		currentCamera.CFrame = cFrame
		currentCamera.Focus = currentCamera.CFrame + currentCamera.CFrame.LookVector
	end
end

currentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
	fixcam() -- equivalent call inferred; original call site unknown
end)
currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
	fixcam() -- equivalent call inferred; original call site unknown
end)
workspace:WaitForChild("Map")

if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") or Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
	task.spawn(function()
		local v3 = {}

		if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
			for _, v4 in Locations.CelebrationEvent do
				table.insert(v3, v4.CFrame)
			end
		else
			for _, v4 in Locations.Sea3 do
				if Easter2026.NO_MORE_GAMEPLAY_AT:ToDateTimeUTC().UnixTimestamp > DateTime.now().UnixTimestamp then
					continue
				end

				table.insert(v3, v4.CFrame)
			end
		end

		local function getNearestPoints(focalSpawnPoint)
			local v4 = 1e999
			local v5 = {}

			for _, cf in pairs(v3) do
				local magnitude = (cf.Position - focalSpawnPoint).Magnitude

				if magnitude < v4 then
					(focalSpawnPoint - cf.Position):Dot(cf.LookVector)
					v4 = magnitude
				end

				if not (#v5 > 3 or magnitude > 5000) then
					table.insert(v5, {
						distance = magnitude,
						cf = cf,
						showTime = 15
					})
				end
			end

			table.sort(v5, function(a, b)
				return a.distance < b.distance
			end)
			local result = {}

			for _ = 1, #v5 do
				local v6 = table.remove(v5, math.random(1, #v5))

				if v6 then
					table.insert(result, v6)
				end
			end

			return result
		end

		if workspace.StreamingEnabled then
			local total = 0

			repeat
				total += task.wait()
			until localPlayer:GetAttribute("FocalSpawnPoint") or total > 10

			if localPlayer:GetAttribute("FocalSpawnPoint") then
				local nearestPoints = getNearestPoints(localPlayer:GetAttribute("FocalSpawnPoint"))

				if #nearestPoints > 0 then
					v3 = nearestPoints
					nearestPoints[1].showTime = 15
					game.ReplicatedStorage.Remotes:WaitForChild("RequestStreamAroundAsync"):FireServer({
						nearestPoints[1],
						nearestPoints[2]
					})
				end
			else
				print("not found spawn point")
			end
		end

		if typeof(v3[1]) == "CFrame" then
			for k, cf in pairs(v3) do
				v3[k] = {
					cf = cf,
					dist = cf.Position.Magnitude,
					showTime = 15
				}
			end
		end

		local v4 = 1
		currentCamera.CFrame = v3[v4].cf
		cFrame = currentCamera.CFrame
		task.spawn(function() end)
		local lastTime = tick()
		tick()
		local v5 = false
		local total = 0

		while currentCamera.CameraType == Enum.CameraType.Scriptable do
			if tick() - lastTime > v3[v4].showTime and not v5 then
				v5 = true
				task.spawn(function()
					local v6 = v4 + 1
					local v7 = #v3 < v6 and 1 or v6

					if workspace.StreamingEnabled then
						if v7 ~= v4 then
							local folder = Instance.new("Folder", game.ReplicatedStorage)
							Debris:AddItem(folder, 2)

							if game.ReplicatedStorage.EffectContainer:FindFirstChild("BlindCam") then
								local Effect = require(game.ReplicatedStorage.Effect)
								Effect.new("BlindCam"):play({
									Reference = folder,
									Color = Color3.new(0.06, 0.06, 0.06),
									Duration = 0.1,
									Fade = 0.25,
									ZIndex = -10
								})
							end

							task.delay(0.4, function()
								folder:Destroy()
							end)
							task.wait(0.04)
						end
					elseif v7 ~= v4 then
						local Effect = require(game.ReplicatedStorage.Effect)
						Effect.new("BlindCam"):play({
							Color = Color3.new(0.06, 0.06, 0.06),
							Duration = 0.1,
							Fade = 0.25,
							ZIndex = -10
						})
					end

					task.wait(0.26)
					total = 0
					v4 += 1

					if v4 > #v3 then
						v4 = 1
					end

					if currentCamera.CameraType == Enum.CameraType.Scriptable then
						currentCamera.CFrame = v3[v4].cf
						cFrame = currentCamera.CFrame
					end

					lastTime = tick()
					v5 = false
					v4 = v7
					game.ReplicatedStorage.Remotes:WaitForChild("RequestStreamAroundAsync"):FireServer({ v3[v4 + 1] })
				end)
			end

			currentCamera.CFrame = v3[v4].cf * CFrame.new(0, 0, -math.min(20, total / 1.5))
			cFrame = currentCamera.CFrame
			total += task.wait()
		end
	end)
end

local function change(p: string)
	if flag then
		return
	end

	flag = true
	Notification.new("Joining..."):Display()
	local success, _ = pcall(function()
		remotes.CommF_:InvokeServer("SetTeam2", p)
	end)

	if success then
		repeat
			task.wait()
		until localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Characters)
	else
		flag = false
		Notification.new("<Color=Red>Player data still not ready, please wait and try again.<Color=/>"):Display()
	end
end

local uIListLayout = chooseTeam.Container:FindFirstChildWhichIsA("UIListLayout")
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
script.Parent:WaitForChild("HomescreenPlayButton").Activated:Connect(function()
	change("Pirates")
end)

if workspace.StreamingEnabled then
	local v3 = false
	task.spawn(function()
		game.ReplicatedStorage.Remotes:WaitForChild("RequestStreamAroundAsync"):FireServer("SpawnPoint")
		game.ReplicatedStorage.Remotes:WaitForChild("RequestStreamAroundAsync").OnClientEvent:Wait()
		v3 = true
	end)
	local total = 0

	repeat
		total += task.wait(0.03333333333333333)
	until v3 or total > 30
end

DoTeamSelection()
chooseTeam:WaitForChild("Container"):WaitForChild("Pirates"):WaitForChild("Frame"):WaitForChild("TextButton").Activated:Connect(function()
	if ifCurrentRealmHasTagAsync then
		AnalyticsUtil.reportActivity("TeamSelect/Team/RipFamily")
		change("Rip Family")
	else
		AnalyticsUtil.reportActivity("TeamSelect/Team/Pirates")
		change("Pirates")
	end
end)
chooseTeam:WaitForChild("Container"):WaitForChild("Marines"):WaitForChild("Frame"):WaitForChild("TextButton").Activated:Connect(function()
	if ifCurrentRealmHasTagAsync then
		AnalyticsUtil.reportActivity("TeamSelect/Team/RedArmy")
		change("Red Army")
	else
		AnalyticsUtil.reportActivity("TeamSelect/Team/Marines")
		change("Marines")
	end
end)
task.spawn(function()
	if ifCurrentRealmHasTagAsync then
		local pirate = chooseTeam.Container.Pirates.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("Pirate")
		pirate.Pants.PantsTemplate = "http://www.roblox.com/asset/?id=12006404759"
		local pirate_2 = chooseTeam.Container.Pirates.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("Pirate")
		pirate_2.Shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=12006400330"
		local dummyB = chooseTeam.Container.Marines.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("DummyB")
		dummyB.Pants.PantsTemplate = "http://www.roblox.com/asset/?id=4678568647"
		local dummyB_2 = chooseTeam.Container.Marines.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("DummyB")
		dummyB_2.Shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=4735441672"
		local Anims = require(game.ReplicatedStorage.Util.Anims)
		Anims:Get(
			chooseTeam.Container.Pirates.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("Pirate"),
			"RedKingAnim"
		):Play()
		local Anims2 = require(game.ReplicatedStorage.Util.Anims)
		Anims2:Get(
			chooseTeam.Container.Marines.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("DummyB"),
			"RipIndraAnim"
		):Play()
	else
		local Anims = require(game.ReplicatedStorage.Util.Anims)
		Anims:Get(
			chooseTeam.Container.Pirates.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("Pirate"),
			"Menu_Idle"
		):Play()
		local Anims2 = require(game.ReplicatedStorage.Util.Anims)
		Anims2:Get(
			chooseTeam.Container.Marines.Frame.ViewportFrame:WaitForChild("WorldModel"):WaitForChild("DummyB"),
			"Menu_Idle"
		):Play()
	end
end)
local Global = require(game.ReplicatedStorage.Global)
Global.reducing = false

local function fastModeButton()
	AnalyticsUtil.reportActivity("TeamSelect/FastMode")
	local textLabel = chooseTeam:FindFirstChild("FastModeButton") and chooseTeam.FastModeButton:FindFirstChild("TextLabel")
	local Global2 = require(game.ReplicatedStorage.Global)

	if Global2.reducing then
		return
	end

	local Global3 = require(game.ReplicatedStorage.Global)
	Global3.reducing = true

	if textLabel then
		textLabel.Text = "Working.."
		chooseTeam.FastModeButton.Notify.Text = "(You can play while it's working, usually takes 20 to 80 seconds to finish)"
	end

	local Global4 = require(game.ReplicatedStorage.Global)
	Global4.FastMode = true
	local TextChatService = game:GetService("TextChatService")
	TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage("<font color=\"#00FF00\">Tip: Try disabling allied FX in the settings menu for even less lag!</font>")
	local map = workspace:WaitForChild("Map")
	local unloaded = game.ReplicatedStorage:WaitForChild("Unloaded")
	require(util.FPSTracker)
	local smoothPlastic = Enum.Material.SmoothPlastic
	local descendants = map:GetDescendants()
	task.wait(0.5)
	local descendants2 = unloaded:GetDescendants()
	task.wait(0.5)
	local clock = os.clock
	local wait = task.wait
	local _ = rawget
	local isA = unloaded.IsA
	local now = clock()
	local lastTime = tick()
	local v3 = now
	local count = 0

	for _, texture in next, descendants, nil do
		if isA(texture, "BasePart") then
			texture.Material = smoothPlastic
			count += 1

			if clock() - now > 0.008333333333333333 then
				local text = "Working.. " .. count

				if textLabel then
					textLabel.Text = text
				end

				wait()
				wait()
				now = clock()
			end
		elseif texture:IsA("Texture") and not texture:GetAttribute("Offset") then
			texture:Destroy()
		end
	end

	for _, texture in next, descendants2, nil do
		if isA(texture, "BasePart") then
			texture.Material = smoothPlastic
			count += 1

			if clock() - now > 0.008333333333333333 then
				local text = "Working.. " .. count

				if textLabel then
					textLabel.Text = text
				end

				wait()
				wait()
				now = clock()
			end
		elseif texture:IsA("Texture") and not texture:GetAttribute("Offset") then
			texture:Destroy()
		end
	end

	localPlayer.PlayerScripts.OptimizerClientActor:SendMessage("Optimize", true)
	print("Time taken to Fast Mode: ", tick() - lastTime, clock() - v3)
	local text2 = "Finished in " .. math.floor(tick() - lastTime) .. "s"
	pcall(function()
		chooseTeam.FastModeButton.Notify.Text = "Materials have been disabled."
		textLabel.Text = text2
	end)
end

chooseTeam:WaitForChild("FastModeButton").Activated:Connect(fastModeButton)
local TeleportService = game:GetService("TeleportService")
local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData()

if localPlayerTeleportData ~= nil and type(localPlayerTeleportData) == "table" then
	local autoJoinTeam = localPlayerTeleportData.AutoJoinTeam

	if autoJoinTeam == "Pirates" or autoJoinTeam == "Marines" then
		change(autoJoinTeam)
	end
end