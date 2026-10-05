local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local v = assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local Trove = require(ReplicatedStorage.packages.Trove)
local Signal = require(ReplicatedStorage.packages.Signal)
local legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
local BoatController = require(legacyControllers.BoatController)
local HudController = require(legacyControllers.HudController)
require(legacyControllers.WindowController)
local SettingsController = require(legacyControllers.SettingsController)
local BoatRacingTracks = require(ReplicatedStorage.shared.modules.BoatRacingTracks)
Net:RemoteEvent("JetskiRacing/StartRace", -1)
local remoteEvent = Net:RemoteEvent("JetskiRacing/JoinRace", -1)
local remoteEvent2 = Net:RemoteEvent("JetskiRacing/ExitRace", -1)
local remoteEvent3 = Net:RemoteEvent("JetskiRacing/FinishRace", -1)
local remoteEvent4 = Net:RemoteEvent("JetskiRacing/CompleteLap", -1)
local remoteEvent5 = Net:RemoteEvent("JetskiRacing/CountdownHandshake", -1)
local remoteEvent6 = Net:RemoteEvent("JetskiRacing/ChangeTrackState", -1)
local playerGui = HudController:GetPlayerGui()
local deviceInsetGui = HudController:GetDeviceInsetGui()
local jetskiRacing = playerGui:WaitForChild("jetskiRacing")
local timeLabel = jetskiRacing:WaitForChild("top"):WaitForChild("timer"):WaitForChild("timeLabel")
local lapLabel = jetskiRacing:WaitForChild("top"):WaitForChild("lap"):WaitForChild("lapLabel")
local container = jetskiRacing:WaitForChild("countdown"):WaitForChild("clip"):WaitForChild("container")
local waitingText = jetskiRacing:WaitForChild("countdown"):WaitForChild("waitingText")
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local anno_localpersistent = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localpersistent")
local child = nil
local v2 = 0
local v3 = {
	hud = true,
	backpack = true,
	deviceInset = true,
	Return = false,
	quickAccess = false,
	TopbarCentered = true,
	TopbarCenteredClipped = true,
	TopbarStandard = true,
	TopbarStandardClipped = true
}
local BoatRacingController = {
	trove = Trove.new(),
	TrackChanged = Signal.new()
}
local v4 = -2

local function setLightActive(part, flag: boolean)
	local v5 = part.Material == Enum.Material.Neon

	if not flag then
		part.Material = Enum.Material.Asphalt
		return
	end

	part.Material = Enum.Material.Neon

	if flag ~= v5 then
		for _, instance in part:QueryDescendants("ParticleEmitter, Sound") do
			if instance:IsA("ParticleEmitter") then
				instance:Emit(instance:GetAttribute("EmitCount") or instance.Rate)
			elseif instance:IsA("Sound") then
				instance:Play()
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function countdownText(p: number)
	if p < -1 then
		return ""
	end

	if p <= 0 then
		return "GO!"
	end

	if p > 3 then
		return ""
	end

	return (tostring(p))
end

local total = 0

function BoatRacingController:Tick(p2: number)
	for _, screenGui in playerGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and v3[screenGui.Name] ~= nil then
			screenGui.Enabled = false
		end
	end

	deviceInsetGui.Enabled = false
	ProximityPromptService.Enabled = false
	local serverTimeNow = workspace:GetServerTimeNow()

	if v.GameplayPaused and self.startedAt <= serverTimeNow and self.raceType == "singleplayer" then
		total += p2
	end

	local v5 = math.max(serverTimeNow - self.startedAt - total, 0)
	local v6 = self.startedAt - serverTimeNow
	local v7 = math.ceil(v6)
	local v8 = v6 % 1
	timeLabel.Text = string.format("%01i:%02i<font size='8'>.%02i</font>", v5 // 60, v5 % 60, v5 % 1 * 100)
	local humanoid = v.Character and v.Character:FindFirstChildWhichIsA("Tool") and v.Character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		humanoid:UnequipTools()
	end

	if v7 <= 3 then
		if v7 >= -2 then
			container.nextNum.Text = countdownText(v7)
			local lastNum = container.lastNum
			lastNum.Text = countdownText(v7 + 1)

			if v7 == -1 then
				container.Position = UDim2.fromScale(0, -1)
			else
				container.Position = UDim2.fromScale(
					0,
					-TweenService:GetValue(1 - v8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				)
			end

			container.Visible = true
		else
			container.Visible = false
		end

		waitingText.Visible = false
	elseif v7 > 0 then
		container.Visible = false
		waitingText.Visible = true
	end

	if child and v4 ~= v7 then
		local descendants = child:QueryDescendants("Model.CountdownStoplight")

		for _, descendant in ipairs(descendants) do
			for i = 0, 4 do
				local part = descendant:FindFirstChild((tostring(i)))

				if part and part:IsA("BasePart") then
					setLightActive(part, v7 <= i)
				end
			end
		end
	end

	v4 = v7
end

function BoatRacingController:EndRace()
	self.trove:Clean()
	jetskiRacing.Enabled = false

	for _, screenGui in playerGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and v3[screenGui.Name] == true then
			screenGui.Enabled = true
		end
	end

	deviceInsetGui.Enabled = true
	ProximityPromptService.Enabled = true
	self.currentTrackName = nil
	self.TrackChanged:Fire(nil, 0)

	if self.currentMusic then
		local tween = TweenService:Create(self.currentMusic, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		})
		tween.Completed:Once(function()
			self.currentMusic:Stop()
			self.currentMusic = nil
			tween:Destroy()
		end)
		tween:Play()
		TweenService:Create(SoundService.music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = SoundService.music:GetAttribute("DefaultVolume") * (SettingsController:GetSettingValue("musicVolume") / 100)
		}):Play()
	end
end

function BoatRacingController:StartRace(data)
	self.trove:Clean()
	self.startedAt = 1e999
	self.lapCount = data.lapCount
	self.raceType = data.raceType
	self.currentLap = 1
	jetskiRacing.Enabled = true
	total = 0
	lapLabel.Text = `<font size="8">Lap</font> 1/{data.lapCount}`
	jetskiRacing.top.lap.Visible = data.lapCount > 1
	self.currentTrackName = data.trackName
	self.TrackChanged:Fire(data.trackName, 0)
	self.trove:Add(RunService.RenderStepped:Connect(function(dt)
		self:Tick(dt)
	end))
	self:Tick(0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function st(p: number)
	local v5 = p % 10

	if p >= 11 and p <= 13 then
		return (`{p}th`)
	end

	if v5 == 1 then
		return (`{p}st`)
	elseif v5 == 2 then
		return (`{p}nd`)
	elseif v5 == 3 then
		return (`{p}rd`)
	end

	return (`{p}th`)
end

function BoatRacingController:Start()
	remoteEvent.OnClientEvent:Connect(function(p)
		BoatRacingController:StartRace(p)
	end)
	remoteEvent2.OnClientEvent:Connect(function(p)
		BoatRacingController:EndRace()
		anno_localthought:Fire((`Disqualified: {p}`))
	end)
	remoteEvent4.OnClientEvent:Connect(function(currentLap)
		self.currentLap = currentLap
		lapLabel.Text = `<font size="8">Lap</font> {self.currentLap}/{self.lapCount}`
	end)
	remoteEvent5.OnClientEvent:Connect(function(_, _, startedAt, p)
		local serverTimeNow = workspace:GetServerTimeNow()

		if startedAt < serverTimeNow or startedAt - serverTimeNow > 20 then
			anno_localpersistent:Fire("Device Clock Desync", [[
					<b>It looks like your device's clock is out of sync</b> <font transparency="0.35"><i>(or you just have REALLY bad internet)</i></font>, which may impact your experience while racing.
					
					Possible solutions:
					• Sync your device's clock with time servers.
					• Reinstall the Roblox client.
					• Check your internet connection.
					• Join a different game server.
					
					If the issue persists, please contact support.
				]])
		end

		self.startedAt = startedAt
		remoteEvent5:FireServer()
		self.trove:Add(task.delay(startedAt - serverTimeNow - 1, function()
			local instance = BoatController.Physics.currentBoat.Instance
			instance:SetAttribute("AccelerateOnly", true)
			instance:SetAttribute("NoMometumLoss", true)
			task.wait(3)
			instance:SetAttribute("NoMometumLoss", false)
		end))
		self.trove:Add(task.delay(startedAt - serverTimeNow, function()
			BoatController.Physics.currentBoat.Instance:SetAttribute("BlockControls", false)
			BoatController.Physics.currentBoat.Instance:SetAttribute("AccelerateOnly", false)
			local boatRacingTrack = BoatRacingTracks[p]

			if boatRacingTrack.MusicName then
				local child2 = ReplicatedStorage.resources.sounds.music:FindFirstChild(boatRacingTrack.MusicName)

				if child2 and child2 ~= self.currentMusic then
					TweenService:Create(SoundService.music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						Volume = 0
					}):Play()
					child2.Volume = (child2:GetAttribute("OriginalVolume") or 0.5) * (SettingsController:GetSettingValue("musicVolume") / 100)
					child2:Play()

					if self.currentMusic then
						self.currentMusic:Stop()
					end

					self.currentMusic = child2
				end
			end
		end))
	end)
	remoteEvent3.OnClientEvent:Connect(function(p, p2, p3, p4)
		BoatRacingController:EndRace()
		local v5 = string.format("%01i:%05.2f", p2 // 60, p2 % 60)
		local v6 = {}

		if p4 then
			table.insert(v6, "<b>Personal Best!</b>")
		end

		if p3 then
			table.insert(v6, (`<b>#{p3}</b> in server leaderboard`))
		end

		local v7

		if p then
			local v9 = st(p) -- equivalent call inferred; original call site unknown
			v7 = `You got <b>{v9} place</b>`
		else
			v7 = "You completed the race"
		end

		anno_localthought:Fire((`{v7} in <b>{v5}</b>!{not (#v6 > 0) and "" or ` ({table.concat(v6, " - ")})`}`))
	end)
	task.spawn(function()
		local boatRacingTracks = workspace:WaitForChild("world"):WaitForChild("BoatRacingTracks", 1e999)

		local function updateTrackVisibility()
			for _, folder in boatRacingTracks:GetChildren() do
				local v5 = child == folder

				for _, descendant in folder:GetDescendants() do
					if descendant.Name == "barrier" then
						descendant.CanCollide = v5
					elseif descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
						descendant.LocalTransparencyModifier = v5 and 0 or 1
					elseif descendant:IsA("LayerCollector") or descendant:IsA("Light") then
						descendant.Enabled = v5
					end
				end
			end

			for _, part in CollectionService:GetTagged("NoCollideDuringBoatRace") do
				if part:IsA("BasePart") then
					part.CanCollide = child == nil
				end
			end

			for _, part in CollectionService:GetTagged("HideDuringBoatRace") do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = child == nil and 0 or 1
				end
			end
		end

		boatRacingTracks.DescendantAdded:Connect(function(descendant)
			local v5

			if child == nil then
				v5 = false
			else
				v5 = descendant:IsDescendantOf(child)
			end

			if descendant.Name == "barrier" and descendant:IsA("BasePart") then
				descendant.CanCollide = v5
			elseif descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
				descendant.LocalTransparencyModifier = v5 and 0 or 1
			elseif descendant:IsA("LayerCollector") or descendant:IsA("Light") then
				descendant.Enabled = v5
			end
		end)
		CollectionService:GetInstanceAddedSignal("NoCollideDuringBoatRace"):Connect(function(part)
			if part:IsA("BasePart") then
				part.CanCollide = child == nil
			end
		end)
		CollectionService:GetInstanceAddedSignal("HideDuringBoatRace"):Connect(function(part)
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = child == nil and 0 or 1
			end
		end)
		self.TrackChanged:Connect(function(childName, p)
			v2 = p

			if childName then
				child = boatRacingTracks:WaitForChild(childName, 5)
			else
				child = nil
			end

			updateTrackVisibility()
		end)
		remoteEvent6.OnClientEvent:Connect(function(p)
			v2 = p
			updateTrackVisibility()
		end)
		updateTrackVisibility()
	end)
end

return BoatRacingController