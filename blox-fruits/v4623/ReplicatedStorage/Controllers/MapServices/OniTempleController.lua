local OniTempleController = {
	IsMapLoaded = true,
	SpawnPoint = nil
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Realm = require(game.ReplicatedStorage.Util.Realm)

if not (Flags.RED_CORRUPTION_EVENT_ENABLED or Flags.CELEBRATION_REALM.ENABLED and Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent")) then
	return OniTempleController
end

local Reparent = require(ReplicatedStorage.Reparent)
local StaticThread = require(game.ReplicatedStorage.Util.StaticThread)
local Result = require(game.ReplicatedStorage.Packages.Result)
local Net = require(game.ReplicatedStorage.Modules.Net)
local runAsync = require(game.ReplicatedStorage.Util.runAsync)
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local oniRealm = workspace.Map:WaitForChild("Oni Realm")
local oniRealm2 = workspace.Map:WaitForChild("Oni Realm")
local localPlayer = game.Players.LocalPlayer
local position = oniRealm:GetPivot().Position
local _ = oniRealm:GetPivot().Position
local remoteFunction = Net:RemoteFunction("OniTempleTransportation")
local v = nil
local v2 = 0
local map = Reparent.CreateMap(oniRealm)
local map2 = Reparent.CreateMap(oniRealm2)
local v3 = false
local v4 = nil
local now = tick()

function OniTempleController:IsMapInWorkspace()
	return OniTempleController.IsMapLoaded
end

function OniTempleController:LockState()
	OniTempleController.IsLoopStateLocked = true
end

function OniTempleController:UnlockState()
	OniTempleController.IsLoopStateLocked = false
end

function OniTempleController:LoadMap()
	v2 = tick() + 15
	Reparent.Parent(map, 0.001, function(p)
		if p then
			OniTempleController.IsMapLoaded = true

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
			OniTempleController.IsMapLoaded2 = true
		end
	end)

	if oniRealm:FindFirstChild("SpecialLocations") then
		local specialLocations = oniRealm:FindFirstChild("SpecialLocations")
		specialLocations.Parent = nil
	end

	print("loaded")
end

function OniTempleController:UnloadMap()
	if self:IsMapInWorkspace() then
		Reparent.Unparent(map, 0.001, function(_) end)
		Reparent.Unparent(map2, 0.001, function(_) end)
		OniTempleController.IsMapLoaded = false
	end
end

function OniTempleController:RequestLeaveIslandAbnormally()
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

function OniTempleController:RequestLeaveIsland()
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
	if OniTempleController.IsLoopStateLocked then
		return false
	end

	local character = not Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") and localPlayer.Character

	if not character then
		return false
	end

	local v5 = character:GetPivot().Position - position

	if v5.Magnitude > 8000 then
		if OniTempleController.IsMapLoaded and v2 < tick() then
			OniTempleController:UnloadMap()
		end
	elseif OniTempleController.IsMapLoaded then
		if v5.Magnitude < 3000 and (math.abs(v5.X) > 2000 or math.abs(v5.Z) > 2000 or math.abs(v5.Y) > 900) and math.abs(v5.Y) < 2000 then
			OniTempleController:RequestLeaveIslandAbnormally()
		end
	else
		OniTempleController:LoadMap()
	end

	return false
end, 0.01)

local function GetBaseOni1Dialogue()
	local runAsync2 = require(game.ReplicatedStorage.Util.runAsync)
	return {
		Text = { "The gate to the Oni Domain has opened. I can take you there. Would you like to go?" },
		Option1 = {
			Label = "Yes",
			JumpTo = function()
				v4.resumeWhenCallbackFinishes(function()
					while not OniTempleController.CAN_TRANSPORT do
						task.wait()
					end

					return Result.try(function()
						now = tick() + 10
						local RedCloudsTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.RedCloudsTransitionEffect)
						local Sound = require(game.ReplicatedStorage.Util.Sound)
						local v5 = Sound:Play("GravFruit_M1_Meteor_IncomingLoop_01_V2", workspace._WorldOrigin)
						v5.PlaybackSpeed = 0.75
						v5.Volume = 0.65
						runAsync2(function()
							RedCloudsTransitionEffect.Play()
						end)
						OniTempleController:LockState()
						tick()
						runAsync2(function()
							OniTempleController:LoadMap()
						end):awaitResult()
						task.wait(1)
						local v6 = remoteFunction:InvokeServer("InitiateTeleportToTemple")
						task.spawn(function()
							task.wait(1)
							task.delay(1, function()
								OniTempleController:UnlockState()
							end)
							RedCloudsTransitionEffect.StopEarly()
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
		Title = "Oni",
		Get = GetBaseOni1Dialogue
	}
end

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

local connections = {}
local now2 = tick()

-- equivalent calls inferred from this helper; original call sites unknown
local function handleDoorPart(p)
	if not connections[p] then
		p.CanTouch = true
		connections[p] = p.Touched:Connect(function(otherPart)
			if now > tick() then
				return
			end

			local character = game.Players.LocalPlayer.Character

			if not (otherPart.Parent and character and otherPart:IsDescendantOf(game.Players.LocalPlayer.Character)) then
				return
			end

			now = tick() + 10

			if oniRealm:GetAttribute("Open") then
				local v5

				if now2 < tick() then
					local OniCastleTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.OniCastleTransitionEffect)
					v5 = OniCastleTransitionEffect
					runAsync(function()
						v5.Play()
					end)
				else
					v5 = nil
				end

				tick()

				if now2 < tick() then
					now2 = tick() + 1800
					local Sound = require(game.ReplicatedStorage.Util.Sound)
					local play = Sound:Play("SanguineArtZHit2", workspace._WorldOrigin)
					play.PlaybackSpeed = 0.75
					task.wait(1)
					local v6 = character:GetPivot():Inverse() * workspace.CurrentCamera.CFrame
					local v7 = remoteFunction:InvokeServer("InitiateTeleportToInterior")
					workspace.Camera.CFrame = character:GetPivot() * v6
					task.spawn(function()
						task.wait(1)
						v5.StopEarly()
					end)

					if v7 == -1 then
						return {
							Text = { "Not while you're in combat." }
						}
					end

					return false
				else
					local v6 = character:GetPivot():Inverse() * workspace.CurrentCamera.CFrame
					local v7 = remoteFunction:InvokeServer("InitiateTeleportToInterior")
					workspace.Camera.CFrame = character:GetPivot() * v6

					if v7 == -1 then
						return {
							Text = { "Not while you're in combat." }
						}
					end

					return false
				end
			else
				local v5 = math.round(secondsUntilNextHourHalfMarker2() / 60)
				local Notification = require(game.ReplicatedStorage.Notification)
				Notification.new("The door to this realm is sealed. Come back in " .. v5 .. (v5 == 1 and " minute." or " minutes.")):Display()
				return warn("not open")
			end
		end)
	end
end

local CollectionService = game:GetService("CollectionService")

for _, v5 in CollectionService:GetTagged("OniInteriorDoor") do
	if connections[v5] then
		continue
	end

	v5.CanTouch = true
	connections[v5] = v5.Touched:Connect(function(otherPart)
		if now > tick() then
			return
		end

		local character = game.Players.LocalPlayer.Character

		if not (otherPart.Parent and character and otherPart:IsDescendantOf(game.Players.LocalPlayer.Character)) then
			return
		end

		now = tick() + 10

		if oniRealm:GetAttribute("Open") then
			local v6

			if now2 < tick() then
				local OniCastleTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.OniCastleTransitionEffect)
				v6 = OniCastleTransitionEffect
				runAsync(function()
					v6.Play()
				end)
			else
				v6 = nil
			end

			tick()

			if now2 < tick() then
				now2 = tick() + 1800
				local Sound = require(game.ReplicatedStorage.Util.Sound)
				local play = Sound:Play("SanguineArtZHit2", workspace._WorldOrigin)
				play.PlaybackSpeed = 0.75
				task.wait(1)
				local v7 = character:GetPivot():Inverse() * workspace.CurrentCamera.CFrame
				local v8 = remoteFunction:InvokeServer("InitiateTeleportToInterior")
				workspace.Camera.CFrame = character:GetPivot() * v7
				task.spawn(function()
					task.wait(1)
					v6.StopEarly()
				end)

				if v8 == -1 then
					return {
						Text = { "Not while you're in combat." }
					}
				end

				return false
			else
				local v7 = character:GetPivot():Inverse() * workspace.CurrentCamera.CFrame
				local v8 = remoteFunction:InvokeServer("InitiateTeleportToInterior")
				workspace.Camera.CFrame = character:GetPivot() * v7

				if v8 == -1 then
					return {
						Text = { "Not while you're in combat." }
					}
				end

				return false
			end
		else
			local v6 = math.round(secondsUntilNextHourHalfMarker2() / 60)
			local Notification = require(game.ReplicatedStorage.Notification)
			Notification.new("The door to this realm is sealed. Come back in " .. v6 .. (v6 == 1 and " minute." or " minutes.")):Display()
			return warn("not open")
		end
	end)
end

local CollectionService2 = game:GetService("CollectionService")
CollectionService2:GetInstanceAddedSignal("OniInteriorDoor"):Connect(function(p)
	handleDoorPart(p) -- equivalent call inferred; original call site unknown
end)

local function GetCastleOniDialogue()
	require(game.ReplicatedStorage.Util.runAsync)
	return {
		Text = { "..." },
		Option1 = {
			Label = "Enter the Castle",
			JumpTo = function()
				v4.resumeWhenCallbackFinishes(function()
					return Result.try(function() end):unwrapOr({
						Text = { "..." }
					})
				end)
			end
		}
	}
end

local function OnCastleOniInteracted()
	return {
		Title = "Oni",
		Get = GetCastleOniDialogue
	}
end

function OniTempleController.InitializeNPC(p)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v4 = DialogueController
	task.spawn(function()
		task.spawn(p.new, "Oni1", function(_)
			return OnOniTeleportInteracted()
		end, 4)
	end)
	task.spawn(function()
		task.spawn(p.new, "Red Gacha", function(_)
			return {
				Title = "Red Gacha",
				Get = function()
					local v5 = runAsync(remoteFunction.InvokeServer, remoteFunction, "GetRedHeadRollCount")
					return {
						Text = { "Strange… a trespasser dares to bargain here. Give me 250 <Color=Maroon>Oni Tokens<Color=/>, and we’ll see if the shadows accept your intrusion." },
						Option1 = {
							Label = "Continue",
							JumpTo = function()
								local v6 = 10 - v5:awaitResult()
								local v7 = v6 > 0

								if v6 == 0 then
									v6 = `<Color=Maroon>{v6}<Color=/>`
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

function OniTempleController.OnStart(_)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v4 = DialogueController

	if OniTempleController.IsMapLoaded and not v3 then
		v3 = true

		for _, moduleScript in script.MapComponents:GetChildren() do
			require(moduleScript)
		end
	end

	task.spawn(function()
		warn("oni domain fog etc")
		local oniDomainFog = script.OniDomainFog
		oniDomainFog.Parent = game.Lighting.LightingLayers
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

			if v5 == "Oni Realm" or v5 == "Oni Realm (Interior)" then
				if oniDomainFog.Intensity.Value < 1 then
					if thread then
						pcall(task.cancel, thread)
					end

					thread = task.spawn(function()
						while oniDomainFog.Intensity.Value < 1 do
							oniDomainFog.Intensity.Value = math.clamp(
								oniDomainFog.Intensity.Value + task.wait() * 0.2,
								0,
								1
							)
						end
					end)
				end

				oniDomainFog:SetAttribute("Enabled", true)

				if not renderSteppedConnection then
					local RunService = game:GetService("RunService")
					renderSteppedConnection = RunService.RenderStepped:Connect(function()
						game.Lighting.ClockTime = 12
					end)
					game.Lighting.GeographicLatitude = 0
				end
			elseif oniDomainFog:GetAttribute("Enabled") then
				if thread then
					pcall(task.cancel, thread)
				end

				thread = task.spawn(function()
					while oniDomainFog.Intensity.Value < 1 do
						oniDomainFog.Intensity.Value = math.clamp(
							oniDomainFog.Intensity.Value - task.wait() * 0.2,
							0,
							1
						)
					end
				end)

				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					game.Lighting.GeographicLatitude = 66
					renderSteppedConnection = nil
				end

				oniDomainFog:SetAttribute("Enabled", false)
			end
		end
	end)
	v:Start()
end

task.spawn(function()
	while not oniRealm:FindFirstChild("BigDoor", true) do
		task.wait()
	end

	local bigDoor = oniRealm:FindFirstChild("BigDoor", true)

	if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
		bigDoor:Destroy()
		return
	end

	bigDoor.Touched:Connect(function(otherPart)
		if now > tick() then
			return
		end

		if localPlayer.Character and otherPart and otherPart:IsDescendantOf(localPlayer.Character) then
			now = tick() + 5
			task.wait(0.5)
			OniTempleController:RequestLeaveIsland()
		end
	end)
	Reparent.Unparent(map, 1e999)
	Reparent.Unparent(map2, 1e999)
	OniTempleController.CAN_TRANSPORT = true
end)
OniTempleController.Enabled = true
return OniTempleController