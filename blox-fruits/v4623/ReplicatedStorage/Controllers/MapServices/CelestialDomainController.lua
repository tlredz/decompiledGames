local CelestialDomainController = {
	IsMapLoaded = true,
	SpawnPoint = nil
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Realm = require(game.ReplicatedStorage.Util.Realm)

if not (Flags.CELESTIAL_DOMAIN_EVENT_ENABLED or Flags.CELEBRATION_REALM.ENABLED and Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent")) then
	return CelestialDomainController
end

local Reparent = require(ReplicatedStorage.Reparent)
local StaticThread = require(game.ReplicatedStorage.Util.StaticThread)
local Result = require(game.ReplicatedStorage.Packages.Result)
local Net = require(game.ReplicatedStorage.Modules.Net)
local runAsync = require(game.ReplicatedStorage.Util.runAsync)
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local celestialDomain = workspace.Map:WaitForChild("Celestial Domain")
local celestialDomain2 = workspace.Map:WaitForChild("Celestial Domain")
local localPlayer = game.Players.LocalPlayer
local position = celestialDomain:GetPivot().Position
local _ = celestialDomain:GetPivot().Position
local remoteFunction = Net:RemoteFunction("CelestialDomainTransportation")
local v = nil
local v2 = 0
local map = Reparent.CreateMap(celestialDomain)
local map2 = Reparent.CreateMap(celestialDomain2)
local v3 = false
local v4 = nil

local function secondsUntilNextHourHalfMarker2(p: number?)
	local v5 = p or os.time()
	local v6 = os.date("*t", v5)
	local v7 = v6.sec + v6.min * 60 + v6.hour * 3600

	for i = 0, 24 do
		if v7 < i * 3600 + 1800 then
			return i * 3600 + 1800 - v7
		end
	end
end

local now = tick()

function CelestialDomainController:IsMapInWorkspace()
	return CelestialDomainController.IsMapLoaded
end

function CelestialDomainController:LockState()
	CelestialDomainController.IsLoopStateLocked = true
end

function CelestialDomainController:UnlockState()
	CelestialDomainController.IsLoopStateLocked = false
end

function SetupCelestial(instance)
	if instance.Name ~= "Celestial Domain" then
		return
	end

	local elevator = instance:WaitForChild("Elevator")
	local lever = elevator:WaitForChild("Lever")
	local handle = lever:WaitForChild("Handle")
	local base = lever:WaitForChild("Base")
	local center = lever:WaitForChild("Center")
	local proximityPrompt = base:WaitForChild("ProximityPrompt")

	if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
		return
	end

	local flag = false
	proximityPrompt.Triggered:Connect(function()
		local humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart or flag then
			return
		end

		flag = true
		proximityPrompt.Enabled = false
		local v5 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Bounce()
			pcall(function()
				local Sound = require(game.ReplicatedStorage.Util.Sound)
				Sound:FadeOut(v5, 0.1)
			end)
			task.wait(1)
			flag = false
			proximityPrompt.Enabled = true
		end

		if instance:GetAttribute("Open") then
			local cFrame = center.CFrame
			local v6 = remoteFunction:InvokeServer("InitiateTeleportToInterior")
			task.spawn(function()
				os.clock()
				local Sound = require(game.ReplicatedStorage.Util.Sound)
				v5 = Sound:Play("LeverSFX", center)
				local total = -55

				while total < 55 and v6 ~= -1 do
					handle.CFrame = cFrame * CFrame.Angles(math.rad(total), 0, 0) * CFrame.new(
						0,
						3.8 + handle.Size.Y / 2 - 0.2,
						0
					)
					total += task.wait() * 110
				end

				if v6 == -1 then
					handle.CFrame = cFrame * CFrame.Angles(-0.9599310885968813, 0, 0) * CFrame.new(
						0,
						3.8 + handle.Size.Y / 2 - 0.2,
						0
					)
					Bounce() -- equivalent call inferred; original call site unknown
				else
					local v7 = {}

					for _, v8 in pairs(game.Players:GetPlayers()) do
						if not (v8.Character and v8.Character:FindFirstChild("HumanoidRootPart")) then
							continue
						end

						local v9 = v7
						local CharacterTransparency = require(game.ReplicatedStorage.CharacterTransparency)
						table.insert(v9, CharacterTransparency:AddStack(v8.Character, "CelestialIntroInvis", 2))
					end

					task.delay(6, function()
						for _, v8 in pairs(v7) do
							v8:Destroy()
						end

						v7 = {}
					end)
					local v8 = base.CFrame * CFrame.new(
						-8.87597656,
						11.3945312,
						-127.740234,
						0.814030766,
						0,
						0.580821931,
						0.365652531,
						0.776965439,
						-0.512467563,
						-0.451278478,
						0.629543245,
						0.632473648
					)
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					task.delay(6, function()
						workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					end)
					workspace.CurrentCamera.CFrame = CFrame.new(v8.Position, base.Position)
					local clone = elevator:Clone()
					clone.Parent = workspace
					local Sound2 = require(game.ReplicatedStorage.Util.Sound)
					v5 = Sound2:Play("ChainDragging", nil, nil, nil, nil, 0.5)

					for _, part in pairs(elevator:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Transparency = 1
						end
					end

					for _, part in pairs(clone:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CanCollide = false
						part.CanTouch = false
						part.CanQuery = false
					end

					local position2 = humanoidRootPart.Position
					local pivot = clone:GetPivot()
					local frame = Instance.new("Frame", game.Players.LocalPlayer.PlayerGui.Smokescreen)
					frame.Size = UDim2.fromScale(2, 2)
					frame.AnchorPoint = Vector2.new(0.5, 0.5)
					frame.Position = UDim2.fromScale(0.5, 0.5)
					frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					frame.BackgroundTransparency = 1
					frame.Name = "Blackout"
					frame.ZIndex = 1000000
					local total2 = 0

					while total2 < 150 and v6 ~= -1 do
						total2 += task.wait() * 43
						clone:PivotTo(pivot + Vector3.new(0, total2, 0))
						workspace.CurrentCamera.CFrame = CFrame.new(
							v8.Position + Vector3.new(0, total2 / 2.2, 0),
							base.Position + Vector3.new(0, total2 * 2, 0)
						)

						if total2 > 110 then
							frame.BackgroundTransparency = (150 - total2) / 40
						end
					end

					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

					local function ReturnCamera()
						for _, v9 in pairs(v7) do
							v9:Destroy()
						end

						v7 = {}
						workspace.CurrentCamera.CFrame = CFrame.new(
							-4984.84717,
							-9070.21484,
							11965.3701,
							-0.0252713207,
							-0.433893889,
							0.900609612,
							0,
							0.900897384,
							0.4340325,
							-0.999680638,
							0.0109685743,
							-0.0227668639
						)
						workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
						workspace.CurrentCamera.CFrame = CFrame.new(
							-4984.84717,
							-9070.21484,
							11965.3701,
							-0.0252713207,
							-0.433893889,
							0.900609612,
							0,
							0.900897384,
							0.4340325,
							-0.999680638,
							0.0109685743,
							-0.0227668639
						)
						clone:Destroy()

						for _, part in pairs(elevator:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Transparency = 0
							end
						end

						local TweenService = game:GetService("TweenService")
						TweenService:Create(frame, TweenInfo.new(1), {
							BackgroundTransparency = 1
						}):Play()
						game.Debris:AddItem(frame, 3)
					end

					pcall(function()
						local Sound3 = require(game.ReplicatedStorage.Util.Sound)
						Sound3:FadeOut(v5, 0.5)
						v5 = nil
					end)

					if v6 ~= -1 and humanoidRootPart then
						while (humanoidRootPart.Position - position2).Magnitude < 200 and humanoidRootPart.Parent == game.Players.LocalPlayer.Character and v6 ~= -1 do
							position2 = humanoidRootPart.Position
							task.wait()
						end

						task.wait(0.6)
					end

					ReturnCamera()
					Bounce() -- equivalent call inferred; original call site unknown
				end
			end)

			if v6 ~= -1 then
				return
			end

			task.delay(1, function()
				flag = false
			end)
			return {
				Text = { "Not while you're in combat." }
			}
		else
			local v6 = secondsUntilNextHourHalfMarker2()
			local v7 = math.round(v6 / 60)
			local v8

			if v7 == 0 then
				v8 = math.round(v6) .. " second"

				if v6 ~= 1 then
					v8 ..= "s"
				end
			else
				v8 = v7 .. " minute"

				if v8 ~= 1 then
					v8 ..= "s"
				end
			end

			local Notification = require(game.ReplicatedStorage.Notification)
			Notification.new("The door to this realm is sealed. Come back in " .. v8 .. "."):Display()
			Bounce() -- equivalent call inferred; original call site unknown
		end
	end)
end

SetupCelestial(celestialDomain)

function CelestialDomainController:LoadMap()
	v2 = tick() + 15
	Reparent.Parent(map, 0.001, function(p)
		if p then
			CelestialDomainController.IsMapLoaded = true

			if not v3 then
				v3 = true

				for _, moduleScript in script.MapComponents:GetChildren() do
					require(moduleScript)
				end
			end

			task.delay(10, function()
				v:Start()
			end)
		end
	end)
	Reparent.Parent(map2, 0.001, function(p)
		if p then
			CelestialDomainController.IsMapLoaded2 = true
		end
	end)

	if celestialDomain:FindFirstChild("SpecialLocations") then
		local specialLocations = celestialDomain:FindFirstChild("SpecialLocations")
		specialLocations.Parent = nil
	end
end

function CelestialDomainController:UnloadMap()
	if self:IsMapInWorkspace() then
		Reparent.Unparent(map, 0.001, function(_) end)
		Reparent.Unparent(map2, 0.001, function(_) end)
		CelestialDomainController.IsMapLoaded = false
	end
end

function CelestialDomainController:RequestLeaveIslandAbnormally()
	runAsync(function()
		local WhiteCloudsTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.WhiteCloudsTransitionEffect)
		WhiteCloudsTransitionEffect.Play()
	end)
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	local v5 = Sound:Play("GravFruit_M1_Meteor_IncomingLoop_01_V2", workspace._WorldOrigin)
	v5.PlaybackSpeed = 0.75
	v5.Volume = 0.65
	task.wait(0.25)
	remoteFunction:InvokeServer("LeaveAbnormally")
	task.wait(1.5)
	task.spawn(function()
		local Sound2 = require(game.ReplicatedStorage.Util.Sound)
		Sound2:FadeOut(v5)
	end)
	local WhiteCloudsTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.WhiteCloudsTransitionEffect)
	WhiteCloudsTransitionEffect.StopEarly()
	task.wait(1)
	v5:Stop()
end

function CelestialDomainController:RequestLeaveIsland()
	runAsync(function()
		local WhiteCloudsTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.WhiteCloudsTransitionEffect)
		WhiteCloudsTransitionEffect.Play()
	end)
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	local v5 = Sound:Play("GravFruit_M1_Meteor_IncomingLoop_01_V2", workspace._WorldOrigin)
	v5.PlaybackSpeed = 0.75
	v5.Volume = 0.65
	task.wait(1)
	remoteFunction:InvokeServer("Leave")
	task.wait(1.5)
	task.spawn(function()
		local Sound2 = require(game.ReplicatedStorage.Util.Sound)
		Sound2:FadeOut(v5)
	end)
	local WhiteCloudsTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.WhiteCloudsTransitionEffect)
	WhiteCloudsTransitionEffect.StopEarly()
	task.wait(1)
	v5:Stop()
end

v = StaticThread.new(function(_)
	if CelestialDomainController.IsLoopStateLocked then
		return false
	end

	local character = not Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") and localPlayer.Character

	if not character then
		return false
	end

	local v5 = character:GetPivot().Position - position

	if v5.Magnitude > 8000 then
		if CelestialDomainController.IsMapLoaded and v2 < tick() then
			CelestialDomainController:UnloadMap()
		end
	elseif CelestialDomainController.IsMapLoaded then
		if v5.Magnitude < 3000 and (math.abs(v5.X) > 3000 or math.abs(v5.Z) > 3000 or math.abs(v5.Y) > 1500) and math.abs(v5.Y) < 2000 then
			print(math.abs(v5.X), math.abs(v5.Y), (math.abs(v5.Z)))
			CelestialDomainController:RequestLeaveIslandAbnormally()
		end
	else
		CelestialDomainController:LoadMap()
	end

	return false
end, 0.01)

local function GetBaseOni1Dialogue()
	local runAsync2 = require(game.ReplicatedStorage.Util.runAsync)
	return {
		Text = { "The celestial domain is near. I can take you there." },
		Option1 = {
			Label = "Yes",
			JumpTo = function()
				v4.resumeWhenCallbackFinishes(function()
					while not CelestialDomainController.CAN_TRANSPORT do
						task.wait()
					end

					return Result.try(function()
						now = tick() + 10
						local CelestialTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.CelestialTransitionEffect)
						local Sound = require(game.ReplicatedStorage.Util.Sound)
						local v5 = Sound:Play("GravFruit_M1_Meteor_IncomingLoop_01_V2", workspace._WorldOrigin)
						v5.PlaybackSpeed = 0.75
						v5.Volume = 0.65
						runAsync2(function()
							CelestialTransitionEffect.Play()
						end)
						CelestialDomainController:LockState()
						tick()
						runAsync2(function()
							CelestialDomainController:LoadMap()
						end):awaitResult()
						task.wait(1)
						local v6 = remoteFunction:InvokeServer("InitiateTeleportToTemple")
						task.spawn(function()
							task.wait(1)
							task.delay(1, function()
								CelestialDomainController:UnlockState()
							end)
							CelestialTransitionEffect.StopEarly()
							task.spawn(function()
								local Sound2 = require(game.ReplicatedStorage.Util.Sound)
								Sound2:FadeOut(v5)
							end)
						end)

						if v6 == -1 then
							return {
								Text = { "Not while you're in combat." }
							}
						end

						return false
					end):unwrapOr({
						Text = { "..." }
					})
				end)
			end
		}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnOniTeleportInteracted()
	return {
		Title = "Celestial Member",
		Get = GetBaseOni1Dialogue
	}
end

local function secondsUntilNextHourHalfMarker22(p: number?)
	local v5 = p or os.time()
	local v6 = os.date("*t", v5)
	local v7 = v6.sec + v6.min * 60 + v6.hour * 3600

	for i = 0, 24 do
		if v7 < i * 3600 + 1800 then
			return i * 3600 + 1800 - v7
		end
	end
end

function CelestialDomainController.InitializeNPC(p)
	warn("InitializeNPC")
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v4 = DialogueController
	task.spawn(function()
		task.spawn(p.new, "Celestial", function(_)
			return OnOniTeleportInteracted()
		end, 4)
	end)
	task.spawn(function()
		task.spawn(p.new, "Celestial Gacha", function(_)
			return {
				Title = "Celestial Gacha",
				Get = function()
					local v5 = runAsync(remoteFunction.InvokeServer, remoteFunction, "GetRipEventRollCount")
					return {
						Text = { game.Players.LocalPlayer.DisplayName:find("rip_", nil, true) and "Greetings, <Color=BrightPurple>celestial warrior<Color=/>. Hand over 250 <Color=BrightPurple>Celestial Tokens<Color=/>, and a prize may be yours." or game.Players.LocalPlayer.DisplayName:find(
								"red_",
								nil,
								true
							) and "An <Color=Maroon>intruder<Color=/> dares to enter the <Color=BrightPurple>Celestial Domain<Color=/>? Very well.. Hand over 250 <Color=BrightPurple>Celestial Tokens<Color=/>, and we may show you mercy." or "A mere mortal in the <Color=BrightPurple>Celestial Domain<Color=/>? Nonsense. Give me 250 <Color=BrightPurple>Celestial Tokens<Color=/>, and I might not call the soldiers to deal with you." },
						Option1 = {
							Label = "Continue",
							JumpTo = function()
								local v6 = 10 - v5:awaitResult()
								local v7 = v6 > 0

								if v6 == 0 then
									v6 = `<Color=Red>{v6}<Color=/>`
								end

								return {
									Text = { (`You can roll 10 times every 2 hours, you have {v6} rolls remaining.`) },
									Option1 = v7 and {
										Label = "Continue",
										JumpTo = function()
											v4.resumeWhenCallbackFinishes(function()
												return false
											end)
										end
									} or nil
								}
							end
						}
					}
				end
			}
		end, 4)
	end)
end

function CelestialDomainController.OnStart()
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v4 = DialogueController
	local NPCTable = require(game.ReplicatedStorage.NPCTable)
	NPCTable.onLoaded(CelestialDomainController.InitializeNPC)

	if CelestialDomainController.IsMapLoaded and not v3 then
		v3 = true

		for _, moduleScript in script.MapComponents:GetChildren() do
			require(moduleScript)
		end
	end

	task.spawn(function()
		local celestialDomainFog = script.CelestialDomainFog
		celestialDomainFog.Parent = game.Lighting.LightingLayers
		local thread = nil
		local renderSteppedConnection = nil

		while task.wait(1) do
			if not localPlayer.Character then
				continue
			end

			local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			local _, _, v5 = GetWaterHeightAtLocation(humanoidRootPart.Position)

			if v5 == "Celestial Domain" or v5 == "Celestial Domain (Interior)" then
				celestialDomainFog:SetAttribute("Enabled", true)

				if celestialDomainFog.Intensity.Value < 1 then
					if thread then
						pcall(task.cancel, thread)
					end

					thread = task.spawn(function()
						while celestialDomainFog.Intensity.Value < 1 do
							celestialDomainFog.Intensity.Value = math.clamp(
								celestialDomainFog.Intensity.Value + task.wait() * 0.2,
								0,
								1
							)
						end
					end)
				end

				if not renderSteppedConnection then
					local RunService = game:GetService("RunService")
					renderSteppedConnection = RunService.RenderStepped:Connect(function()
						game.Lighting.ClockTime = 12
					end)
					game.Lighting.GeographicLatitude = 0
				end
			elseif celestialDomainFog:GetAttribute("Enabled") then
				if renderSteppedConnection then
					if thread then
						pcall(task.cancel, thread)
					end

					thread = task.spawn(function()
						while celestialDomainFog.Intensity.Value > 0 do
							celestialDomainFog.Intensity.Value = math.clamp(
								celestialDomainFog.Intensity.Value - task.wait() * 0.2,
								0,
								1
							)
						end
					end)
					renderSteppedConnection:Disconnect()
					game.Lighting.GeographicLatitude = 66
					renderSteppedConnection = nil
				end

				celestialDomainFog:SetAttribute("Enabled", false)
			end
		end
	end)
	v:Start()
	local glow = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("TopHUDList"):WaitForChild("CelestialMeter"):WaitForChild("CelestialMeter"):WaitForChild("Glow")
	local v5 = game.TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		ImageTransparency = 0.5
	})
	local v6 = game.TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		ImageTransparency = 1
	})
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startTweenLoop()
		flag = true
		task.defer(function()
			while flag do
				v5:Play()
				v5.Completed:Wait()
				v6:Play()
				v6.Completed:Wait()
			end

			v6:Play()
		end)
	end

	local function stopTweenLoop()
		flag = false
	end

	local function controlBackgroundNoise()
		local currentLocation = localPlayer:GetAttribute("CurrentLocation")

		if workspace:GetAttribute("CelestialEventActive") and currentLocation == "Celestial Domain" then
			script.EventBackgroundNoise:Play()
			startTweenLoop() -- equivalent call inferred; original call site unknown
		else
			script.EventBackgroundNoise:Stop()
			flag = false
		end
	end

	local function eventActiveChanged()
		controlBackgroundNoise()

		if localPlayer:GetAttribute("CurrentLocation") ~= "Celestial Domain" then
			return
		end

		if workspace:GetAttribute("CelestialEventActive") then
			script.EventStart:Play()
		else
			script.EventEnd:Play()
		end
	end

	workspace:GetAttributeChangedSignal("CelestialEventActive"):Connect(eventActiveChanged)
	localPlayer:GetAttributeChangedSignal("CurrentLocation"):Connect(controlBackgroundNoise)
end

task.spawn(function()
	if not Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
		while not celestialDomain:FindFirstChild("BigDoor", true) do
			task.wait()
		end

		celestialDomain:FindFirstChild("BigDoor", true).Touched:Connect(function(otherPart)
			if now > tick() then
				return
			end

			if localPlayer.Character and otherPart and otherPart:IsDescendantOf(localPlayer.Character) then
				now = tick() + 5
				task.wait(0.5)
				CelestialDomainController:RequestLeaveIsland()
			end

			Reparent.Unparent(map, 1e999)
			Reparent.Unparent(map2, 1e999)
			CelestialDomainController.CAN_TRANSPORT = true
		end)
	end
end)
CelestialDomainController.Enabled = true
return CelestialDomainController