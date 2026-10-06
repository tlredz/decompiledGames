local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local PassiveList = require(ReplicatedStorage.Chest.Modules.PassiveList)
require(ReplicatedStorage.Chest.Modules.RaidBossList)
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local WindModule = require(ReplicatedStorage.Chest.Modules.WindModule)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local character = localPlayer.Character
local currentCamera = workspace.CurrentCamera
local PeoUtils2 = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local CustomNames = require(ReplicatedStorage.Chest.Modules:WaitForChild("CustomNames"))
local Players = game:GetService("Players")
game:GetService("Workspace")

function _G.MenuAlert(_) end

local playerGui = localPlayer.PlayerGui

if not character then
	while wait() do
		character = localPlayer.Character

		if character then
			break
		end
	end
end

_G.DangerTimeClient = 45
local getMaxJump = ReplicatedStorage.Chest.Remotes.Functions:WaitForChild("GetMaxJump")
local kenEvent = ReplicatedStorage.Chest.Remotes.Functions:WaitForChild("KenEvent")
local armament = ReplicatedStorage.Chest.Remotes.Events:WaitForChild("Armament")
local turnOffKenHaki = ReplicatedStorage.Chest.Remotes.Events:WaitForChild("TurnOffKenHaki")
local ProfileManager = require(ReplicatedStorage.Chest.Assets.Modules.ProfileManager)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local ArmamentBodyLevel = require(ReplicatedStorage.Chest.Modules.ArmamentBodyLevel)
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
local AccessoriesList = require(ReplicatedStorage.Chest.Modules.AccessoriesList)
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Island, workspace.Ships }
local v = ProfileManager.AwaitProfile(localPlayer)

while not v do
	v = ProfileManager.AwaitProfile(localPlayer)
	task.wait(1)
end

local lastTime = tick()
local lastTime2 = tick()
local v2 = true
local flag = nil

function GetAnimator()
	local humanoid = v:GetHumanoid()

	if humanoid then
		return humanoid:FindFirstChildOfClass("Animator") or humanoid
	end
end

task.spawn(function()
	character:WaitForChild("Animate"):Destroy()
end)
task.spawn(function()
	repeat
		wait()
	until localPlayer.PlayerGui and localPlayer.PlayerGui:FindFirstChild("Popup") and localPlayer.PlayerGui.Popup:FindFirstChild("Frame")

	local frame = localPlayer.PlayerGui.Popup.Frame
	local SetupSortModule = require(ReplicatedStorage.Chest.Modules.SetupSortModule)
	SetupSortModule.Init({
		MainFrame = frame,
		Bin = localPlayer.PlayerGui.Popup.Bin
	})
end)
spawn(function()
	game.Lighting.Blur.Enabled = false

	for _, child in pairs(game.Lighting:GetChildren()) do
		if child.Name == "KenColor" then
			child:Destroy()
		end
	end
end)
local v3 = true
_G.IsOpenKenHaki = false
_G.NPCTalk = false

if not workspace:FindFirstChild("Effects") then
	repeat
		wait(0.1)
	until workspace:FindFirstChild("Effects")
end

local waterWave = workspace.Effects:FindFirstChild("WaterWave")

if not waterWave then
	waterWave = ReplicatedStorage.Chest.Etc.WaterWave:Clone()
	waterWave.Parent = workspace.Effects
end

local flag2 = nil
local sandWave = workspace.SeaFolder:FindFirstChild("SandWave")
local fakeSand = workspace.SeaFolder:WaitForChild("FakeSand")

if not sandWave then
	sandWave = ReplicatedStorage.Chest.Etc.SandWave:Clone()
	sandWave.Parent = workspace.SeaFolder
end

local sea = workspace.SeaFolder:FindFirstChild("Sea")

if not sea then
	sea = ReplicatedStorage.Chest.Etc.Sea:Clone()
	sea.Parent = workspace.SeaFolder
end

_G.ConquerorCDClient = 60

repeat
	wait(0.1)
until localPlayer:FindFirstChild("PlayerStats") and localPlayer:FindFirstChild("DataLoaded")

local raceTbl = localPlayer.PlayerStats.RaceTbl
local race = ""
local flag3 = nil
local flag4 = nil
_G.RaceClient = ""
_G.IsRaceV2Client = nil
_G.IsRaceV3Client = nil
_G.MouseHit = CFrame.new()
task.spawn(function()
	if localPlayer.PlayerStats.DFName.Value == "IceIce" or localPlayer.PlayerStats.DFName.Value == "MagmaMagma" then
		ReplicatedStorage.Chest.Remotes.Functions.DFPassive:InvokeServer(localPlayer)
	end
end)
local characterUpgradeStats = character:WaitForChild("CharacterUpgradeStats")
local v4 = 1

function CheckDayNight()
	if Lighting.ClockTime >= 6 and Lighting.ClockTime < 18 then
		return "Day"
	end

	return "Night"
end

function UpdateMaxJump()
	task.spawn(function()
		local v5 = getMaxJump:InvokeServer()

		if v5 then
			v4 = v5
		end
	end)
end

_G.UpdateMaxJump = UpdateMaxJump

function UpdateRace()
	local jSONDecode = HttpService:JSONDecode(raceTbl.Value)

	if jSONDecode and jSONDecode.Race then
		race = jSONDecode.Race

		if _G.CheckAwakeClient(localPlayer, race .. "V2") then
			flag3 = true
		else
			flag3 = nil
		end

		if _G.CheckAwakeClient(localPlayer, race .. "V3") then
			flag4 = true
		else
			flag4 = nil
		end

		_G.RaceClient = race
		_G.IsRaceV2Client = flag3
		_G.IsRaceV3Client = flag4
		UpdateMaxJump()
	end
end

raceTbl.Changed:Connect(function()
	UpdateRace()
	wait()
end)
UpdateRace()
task.spawn(function()
	local FootstepSoundData = require(script:WaitForChild("FootstepSoundData"))
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	local v5 = nil

	local function UpdateFootstep()
		if not humanoidRootPart:FindFirstChild("Running") then
			return
		end

		v5 = FootstepSoundData[humanoid.FloorMaterial] or FootstepSoundData[Enum.Material.Concrete]
		humanoidRootPart.Running.SoundId = v5.SoundId
		humanoidRootPart.Running.Volume = v5.SoundVolume

		if _G.AntiMobSkill() then
			humanoidRootPart.Running.Volume = 0
		end

		if _G.Run then
			humanoidRootPart.Running.PlaybackSpeed = humanoid.WalkSpeed / (v5.SpeedPit / 0.6)
		else
			humanoidRootPart.Running.PlaybackSpeed = humanoid.WalkSpeed / v5.SpeedPit
		end
	end

	local function UpdateSpeedPit()
		if not (v5 and humanoidRootPart:FindFirstChild("Running")) then
			return
		end

		humanoidRootPart.Running.SoundId = v5.SoundId
		humanoidRootPart.Running.Volume = v5.SoundVolume

		if _G.AntiMobSkill() then
			humanoidRootPart.Running.Volume = 0
		end

		if _G.Run then
			humanoidRootPart.Running.PlaybackSpeed = humanoid.WalkSpeed / (v5.SpeedPit / 0.6)
		else
			humanoidRootPart.Running.PlaybackSpeed = humanoid.WalkSpeed / v5.SpeedPit
		end
	end

	humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(UpdateFootstep)
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(UpdateSpeedPit)
	UpdateFootstep()
	UpdateSpeedPit()
end)
UpdateMaxJump()
local v5 = true
localPlayer.PlayerStats.lvl.Changed:Connect(function()
	wait()
	UpdateMaxJump()
end)
localPlayer.PlayerStats.Misc.Changed:Connect(function()
	wait()
	UpdateMaxJump()
	UpdateRace()
end)
local v6 = 1
local v7 = {
	AT1 = true,
	AT2 = true,
	AT3 = true,
	AT4 = true,
	HumanAT1 = true,
	HumanAT2 = true,
	HumanAT3 = true,
	HumanAT4 = true,
	Dragon_AT1 = true,
	Dragon_AT2 = true,
	Dragon_AT3 = true,
	Attack1 = true,
	Attack2 = true,
	Attack3 = true,
	Attack4 = true,
	Combat1 = true,
	Combat2 = true,
	Combat3 = true,
	Combat4 = true
}
local v8 = nil
local v9 = true
local v10 = nil

function _G.Dash(instance)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid or (humanoid.Sit or humanoid.WalkSpeed == 0) or not localPlayer.Character then
		return
	end

	local aDashAnimation = ReplicatedStorage.Chest.Animation.ADashAnimation
	local humanoid2 = instance.Humanoid
	local humanoidRootPart = instance.HumanoidRootPart

	if _G.CheckDoingClient(localPlayer) and not localPlayer.Character:GetAttribute("IgnoreDash") then
		return
	end

	if _G.AntiMob() or humanoid2.Health <= 0 or _G.CheckStunClient(localPlayer) or humanoidRootPart.Position.Y <= -2.5 then
		return
	end

	if not v9 then
		return
	end

	v9 = nil
	local track = GetAnimator():LoadAnimation(aDashAnimation["AnimationF" .. v6])
	local animName = "AnimationF" .. v6

	if instance:GetAttribute("CustomDash") then
		track = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.CustomWeaponAnims[instance:GetAttribute("CustomDash")].Dash["AnimationF" .. v6])
		animName = "AnimationF" .. v6
	end

	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or _G.ShiftLockMobile then
		local dot = humanoid2.MoveDirection:Dot(humanoid2.Torso.CFrame.RightVector)

		if dot >= 0.707 then
			track = GetAnimator():LoadAnimation(aDashAnimation.AnimationR)
			animName = "AnimationR"

			if instance:GetAttribute("CustomDash") then
				local animationR = ReplicatedStorage.Chest.Animation.CustomWeaponAnims[instance:GetAttribute("CustomDash")].Dash:FindFirstChild("AnimationR")

				if animationR then
					track = GetAnimator():LoadAnimation(animationR)
				end
			end
		elseif dot <= -0.707 then
			track = GetAnimator():LoadAnimation(aDashAnimation.AnimationL)
			animName = "AnimationL"

			if instance:GetAttribute("CustomDash") then
				local animationL = ReplicatedStorage.Chest.Animation.CustomWeaponAnims[instance:GetAttribute("CustomDash")].Dash:FindFirstChild("AnimationL")

				if animationL then
					track = GetAnimator():LoadAnimation(animationL)
				end
			end
		end

		if humanoid2.MoveDirection:Dot(humanoid2.Torso.CFrame.LookVector) <= -0.707 then
			track = GetAnimator():LoadAnimation(aDashAnimation.AnimationB)
			animName = "AnimationB"

			if instance:GetAttribute("CustomDash") then
				local animationB = ReplicatedStorage.Chest.Animation.CustomWeaponAnims[instance:GetAttribute("CustomDash")].Dash:FindFirstChild("AnimationB")

				if animationB then
					track = GetAnimator():LoadAnimation(animationB)
				end
			end
		end
	end

	if instance:FindFirstChild("Wolf") then
		local v12 = string.gsub(animName, "%d+", "")
		track = GetAnimator():LoadAnimation(aDashAnimation.Wolf[v12])
	end

	if instance:FindFirstChild("Giraffe") then
		local v12 = string.gsub(animName, "%d+", "")
		track = GetAnimator():LoadAnimation(aDashAnimation.Giraffe[v12])
	end

	if instance:FindFirstChild("ShadowBear") then
		local v12 = string.gsub(animName, "%d+", "")

		if v12 == "AnimationF" then
			v12 = "AnimationF" .. v6
		end

		track = GetAnimator():LoadAnimation(aDashAnimation.ShadowBear[v12])
		track.Looped = false
		track.Priority = Enum.AnimationPriority.Action2
	end

	if instance:FindFirstChild("Leopard") then
		local v12 = string.gsub(animName, "%d+", "")

		if v12 == "AnimationF" then
			v12 = "AnimationF" .. v6
		end

		track = GetAnimator():LoadAnimation(aDashAnimation.Leopard[v12])
		track.Looped = false
		track.Priority = Enum.AnimationPriority.Action2
	end

	if instance:FindFirstChild("ToyTrex") then
		local v12

		if string.find(animName, "AnimationF") then
			v8 = not v8
			v12 = v8 and "AnimationF1" or "AnimationF"
		else
			v12 = animName
		end

		track = GetAnimator():LoadAnimation(aDashAnimation.ToyTrex[v12])
		track.Priority = Enum.AnimationPriority.Action2
	end

	local spinosaurus = instance:FindFirstChild("Spinosaurus") or instance:FindFirstChild("Allosaurus") or instance:FindFirstChild("Brachiosaurus") or instance:FindFirstChild("Tree_KL") or instance:FindFirstChild("Demon_KL")

	if spinosaurus then
		local v12

		if string.find(animName, "AnimationF") then
			v8 = not v8
			v12 = v8 and "AnimationF1" or "AnimationF"
		else
			v12 = animName
		end

		track = GetAnimator():LoadAnimation(aDashAnimation[spinosaurus.Name][v12])
		track.Priority = Enum.AnimationPriority.Action2
	end

	if instance:FindFirstChild("Phoenix_Model") then
		if string.find(animName, "AnimationF") then
			animName = "DashFront"
		elseif string.find(animName, "AnimationR") then
			animName = "DashRight"
		elseif string.find(animName, "AnimationL") then
			animName = "DashLeft"
		elseif string.find(animName, "AnimationB") then
			animName = "DashBack"
		else
			animName = animName
		end

		track = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2[animName])
	elseif instance:FindFirstChild("Pteranodon_KL") then
		if string.find(animName, "AnimationF") then
			animName = "DashFront"
		elseif string.find(animName, "AnimationR") then
			animName = "DashRight"
		elseif string.find(animName, "AnimationL") then
			animName = "DashLeft"
		elseif string.find(animName, "AnimationB") then
			animName = "DashBack"
		else
			animName = animName
		end

		track = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.PterPter[animName])
	end

	for _, v12 in pairs(humanoid2:GetPlayingAnimationTracks()) do
		if v12.Name == "Animation" then
			v12:Stop()
		elseif v7[v12.Name] then
			v12:Stop()
		end
	end

	if v10 and v10.IsPlaying then
		v10:Stop()
		v10 = nil
	end

	track.Priority = Enum.AnimationPriority.Action2
	track:Play()
	v10 = track

	if instance:FindFirstChild("Leopard") then
		track:AdjustSpeed(1.25)
	end

	if instance:FindFirstChild("Phoenix_Model") then
		track:AdjustSpeed(1.25)
	end

	if instance:FindFirstChild("Pteranodon_KL") then
		track:AdjustSpeed(1.25)
	end

	if instance:FindFirstChild("Giraffe") then
		track:AdjustSpeed(1.25)
	end

	if instance:FindFirstChild("ShadowBear") then
		track:AdjustSpeed(1.75)
	end

	v6 += 1

	if v6 > 2 then
		v6 = 1
	end

	local v12 = humanoid2.MoveDirection * createVector(1, 0, 1)
	local v13

	if v12.Magnitude == 0 then
		v12 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)
		v13 = true
	else
		v13 = nil
	end

	local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v12 * createVector(1, 0, 1))
	local lastTime3 = tick()
	local name = nil
	local phoenix_Model = instance:FindFirstChild("Phoenix_Model") or instance:FindFirstChild("Pteranodon_KL")

	if phoenix_Model then
		task.spawn(function()
			name = phoenix_Model.Name
			local flying = humanoidRootPart:FindFirstChild("Flying")
			local flyingGyro = humanoidRootPart:FindFirstChild("FlyingGyro")

			if flying and flyingGyro then
				instance:SetAttribute("CustomFlyingMoving", true)
				local linearVelocity = Instance.new("LinearVelocity")
				linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
				linearVelocity.MaxAxesForce = createVector(200000, 200000, 200000)
				linearVelocity.Attachment0 = humanoidRootPart:FindFirstChildOfClass("Attachment")
				linearVelocity.VectorVelocity = cframe.LookVector * (400 - (tick() - lastTime3) * 13.7)
				linearVelocity.Parent = humanoidRootPart
				Scheduler.new(0.23):OnStep(function(_)
					if humanoid2.MoveDirection.Magnitude > 0 then
						cframe = CFrame.new(
							humanoidRootPart.Position,
							humanoidRootPart.Position + humanoid2.MoveDirection * createVector(1, 0, 1)
						)
						v13 = nil
					elseif UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter and v13 then
						cframe = CFrame.new(
							humanoidRootPart.Position,
							humanoidRootPart.Position + workspace.CurrentCamera.CFrame.LookVector * createVector(
								1,
								0,
								1
							)
						)
					end

					if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
						flyingGyro.CFrame = workspace.CurrentCamera.CFrame
					else
						flyingGyro.CFrame = cframe
					end

					linearVelocity.VectorVelocity = cframe.LookVector * (400 - (tick() - lastTime3) * 13.7)
				end):Execute()
				flyingGyro.P = 3000
				linearVelocity.VectorVelocity = createVector(0, 0, 0)
				task.wait(0.1)
				linearVelocity:Destroy()
				instance:SetAttribute("CustomFlyingMoving", nil)
			end

			wait(0.1)
			v9 = true
		end)
	else
		task.spawn(function()
			if humanoidRootPart:FindFirstChild("GeppoBV") then
				humanoidRootPart.GeppoBV:Destroy()
			end

			local v14 = 200000
			humanoidRootPart.RotVelocity = Vector3.new()
			humanoidRootPart.Velocity = Vector3.new()
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "DashBV"
			bodyVelocity.MaxForce = Vector3.new(v14, 0, v14)
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = "DashBG"
			bodyGyro.MaxTorque = createVector(0, 300000, 0)
			bodyGyro.P = 57000
			bodyGyro.CFrame = CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + v12 * createVector(1, 0, 1)
			)

			if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				bodyGyro.Parent = humanoidRootPart
			end

			local position = humanoidRootPart.Position
			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Include
			raycastParams2.FilterDescendantsInstances = { workspace.Island, workspace.Ships }
			local v15 = workspace:Raycast(position, createVector(0, -5, 0), raycastParams2) and true or nil
			local _ = currentCamera.CFrame.LookVector * createVector(1, 0, 1)
			local v16 = _G.RaceClient == "Mink" and _G.IsRaceV2Client and 215 or 185
			local v17 = (localPlayer.Character:FindFirstChild("Wolf") or localPlayer.Character:FindFirstChild("Giraffe") or localPlayer.Character:FindFirstChild("ShadowBear")) and 225 or v16
			local v18 = localPlayer.Character:FindFirstChild("Leopard") and 250 or v17

			if localPlayer.Character:FindFirstChild("ToyTrex") then
				v18 = 300
				name = "toytrex"
			end

			if localPlayer.Character:FindFirstChild("Spinosaurus") then
				v18 = 325
				name = "Spinosaurus"
			end

			if localPlayer.Character:FindFirstChild("Allosaurus") then
				v18 = 300
				name = "Allosaurus"
			end

			if localPlayer.Character:FindFirstChild("Tree_KL") then
				v18 = 300
				name = "Tree_KL"
			end

			if localPlayer.Character:FindFirstChild("Demon_KL") then
				v18 = 300
				name = "Demon_KL"
			end

			if localPlayer.Character:FindFirstChild("Brachiosaurus") then
				v18 = 300
				name = "Brachiosaurus"
			end

			if localPlayer.Character:FindFirstChild("Buddha") then
				v18 = 250
				v14 = 500000000
			end

			if localPlayer.Character:FindFirstChild("Slow") or flag then
				v18 /= 2.33
			end

			local v19 = instance:GetAttribute("MinkAwakenV3") and 427.5 or v18
			bodyVelocity.Velocity = cframe.LookVector * v19

			if humanoid2.FloorMaterial == Enum.Material.Air then
				bodyVelocity.MaxForce = Vector3.new(v14, v14, v14)
			else
				bodyVelocity.MaxForce = Vector3.new(v14, 0, v14)
			end

			bodyVelocity.Parent = humanoidRootPart
			_G.PU:Dust(bodyVelocity, 0.34500000000000003)
			PeodizService.new({
				Time = 0.23
			}, function(p)
				if humanoid2.MoveDirection.Magnitude > 0 then
					cframe = CFrame.new(
						humanoidRootPart.Position,
						humanoidRootPart.Position + humanoid2.MoveDirection * createVector(1, 0, 1)
					)
					v13 = nil
				elseif UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter and v13 then
					cframe = CFrame.new(
						humanoidRootPart.Position,
						humanoidRootPart.Position + workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)
					)
				end

				if math.floor(p * 10) % 2 == 1 then
					if workspace:Raycast(humanoidRootPart.Position, cframe.LookVector * 3, raycastParams2) then
						if v14 > 50000 then
							v14 = 50000

							if humanoid2.FloorMaterial == Enum.Material.Air then
								bodyVelocity.MaxForce = Vector3.new(v14, v14, v14)
							else
								bodyVelocity.MaxForce = Vector3.new(v14, 0, v14)
							end
						end
					elseif v14 <= 50000 then
						v14 = 200000

						if instance:FindFirstChild("Buddha") then
							v14 = 500000000
						end

						if humanoid2.FloorMaterial == Enum.Material.Air then
							bodyVelocity.MaxForce = Vector3.new(v14, v14, v14)
						else
							bodyVelocity.MaxForce = Vector3.new(v14, 0, v14)
						end
					end
				end

				if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
					bodyGyro.MaxTorque = createVector(0, 0, 0)
				else
					bodyGyro.MaxTorque = createVector(0, 300000, 0)
				end

				bodyGyro.CFrame = cframe
				bodyVelocity.Velocity = cframe.LookVector * (v19 - (tick() - lastTime3) * 13.7)

				if tick() - lastTime3 >= 0.23 then
					return true
				end
			end)
			bodyVelocity.Velocity = cframe.LookVector * v19 / 1.3
			bodyVelocity.MaxForce = Vector3.new(v14, 0, v14)
			humanoidRootPart.RotVelocity = Vector3.new()

			if not v15 then
				humanoidRootPart.Velocity *= 0.25
				bodyVelocity.Velocity *= 0.25
			end

			wait()
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
			wait(0.05)
			v9 = true
		end)
	end

	ReplicatedStorage.Chest.Remotes.Bindables.RemoteEvent:Fire(localPlayer, humanoidRootPart.CFrame, {
		RootPart = humanoidRootPart,
		UpperTorso = localPlayer.Character.UpperTorso,
		Velocity = humanoidRootPart.Velocity,
		Character = instance,
		AnimName = animName,
		Special = name
	}, "Dash")
	ReplicatedStorage.Chest.Remotes.Events.ClientRemote:FireServer({
		RootPart = humanoidRootPart,
		UpperTorso = localPlayer.Character.UpperTorso,
		Velocity = humanoidRootPart.Velocity,
		Character = instance,
		AnimName = animName,
		Special = name,
		Type = "Dash"
	})
end

local v11 = true
local lastTime3 = tick()
tick()
local v12 = 1
local count = 0
local lastTime4 = tick()
local v13 = nil

function _G.Geppo()
	local character2 = localPlayer.Character
	local humanoid = character2:WaitForChild("Humanoid", 30)
	local humanoidRootPart = character2:WaitForChild("HumanoidRootPart", 30)

	if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
		return
	end

	if humanoid.WalkSpeed ~= 0 and humanoid.Health >= 1 and not (_G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer)) then
		if character2:FindFirstChild("Pteranodon_KL") or character2:FindFirstChild("Phoenix_Model") or character2:FindFirstChild("NoJump") then
			return
		end

		if not v11 or _G.AntiMob() or humanoidRootPart:FindFirstChild("BodyVelocity") or script.cds.Value <= 0 then
			return
		end

		if tick() - lastTime4 <= 0.75 then
			count += 1
			local v14 = count

			if v4 + 5 < v14 then
				character2.Head:Destroy()
				return
			end
		else
			count = 0
		end

		v11 = false
		v5 = nil
		local _ = (workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 5)).Position
		lastTime3 = tick()
		script.cds.Value = script.cds.Value - 1

		if _G.CheckSettingClient(localPlayer, "Setting_JumpText") then
			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Jump Left", { script.cds.Value, v4 })
		end

		if humanoidRootPart:FindFirstChild("DashBV") then
			humanoidRootPart.DashBV:Destroy()
		end

		local v14 = race == "Sky" and (flag3 and 60 or 70) or 50
		local v15 = (character2:FindFirstChild("ToyTrex") or character2:FindFirstChild("Spinosaurus") or character2:FindFirstChild("Allosaurus") or character2:FindFirstChild("Brachiosaurus") or character2:FindFirstChild("Tree_KL") or character2:FindFirstChild("Demon_KL")) and 90 or v14
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "GeppoBV"
		bodyVelocity.MaxForce = createVector(0, 100000, 0)
		bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * 1 + Vector3.new(0, v15, 0)
		local v16 = nil

		if character2:FindFirstChild("ToyTrex") then
			bodyVelocity.MaxForce = createVector(3000, 100000, 3000)
			v16 = "toytrex"
		elseif character2:FindFirstChild("Spinosaurus") then
			bodyVelocity.MaxForce = createVector(4000, 100000, 4000)
			v16 = "Spinosaurus"
		elseif character2:FindFirstChild("Allosaurus") then
			bodyVelocity.MaxForce = createVector(3000, 100000, 3000)
			v16 = "Allosaurus"
		elseif character2:FindFirstChild("Tree_KL") then
			bodyVelocity.MaxForce = createVector(5000, 100000, 5000)
			v16 = "Tree_KL"
		elseif character2:FindFirstChild("Demon_KL") then
			bodyVelocity.MaxForce = createVector(5000, 100000, 5000)
			v16 = "Demon_KL"
		elseif character2:FindFirstChild("Brachiosaurus") then
			bodyVelocity.MaxForce = createVector(2000, 100000, 2000)
			v16 = "Brachiosaurus"
		elseif character2:FindFirstChild("Buddha") then
			bodyVelocity.MaxForce = createVector(10000000, 500000000, 10000000)
		end

		bodyVelocity.P = 5000
		bodyVelocity.Parent = humanoidRootPart
		_G.PU:Dust(bodyVelocity, 0.3)
		wait()
		ReplicatedStorage.Chest.Remotes.Bindables.RemoteEvent:Fire(localPlayer, humanoidRootPart.CFrame, {
			Character = character2,
			RootPart = humanoidRootPart,
			UpperTorso = localPlayer.Character.UpperTorso,
			Velocity = humanoidRootPart.Velocity,
			Special = v16
		}, "Geppo")
		ReplicatedStorage.Chest.Remotes.Events.ClientRemote:FireServer({
			IsSpecial = v16,
			Type = "Geppo"
		})
		local v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation["Sky" .. v12]

		if character2:FindFirstChild("ShadowBear") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.ShadowBear["ShadowBearSky" .. v12]
		elseif character2:FindFirstChild("Wolf") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Wolf["WolfSky" .. v12]
		elseif character2:FindFirstChild("Giraffe") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Giraffe["GiraffeSky" .. v12]
		elseif character2:FindFirstChild("Leopard") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Leopard["LeopardSky" .. v12]
		elseif character2:FindFirstChild("ToyTrex") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.ToyTrex["ToyTrexSky" .. v12]
		elseif character2:FindFirstChild("Spinosaurus") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Spinosaurus["Sky" .. v12]
		elseif character2:FindFirstChild("Allosaurus") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Allosaurus["Sky" .. v12]
		elseif character2:FindFirstChild("Brachiosaurus") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Brachiosaurus["Sky" .. v12]
		elseif character2:FindFirstChild("Tree_KL") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Tree_KL["Sky" .. v12]
		elseif character2:FindFirstChild("Demon_KL") then
			v17 = ReplicatedStorage.Chest.Animation.AGeppoAnimation.Demon_KL["Sky" .. v12]
		end

		if v13 and v13.IsPlaying then
			v13:Stop()
			v13:Destroy()
			v13 = nil
		end

		local track = GetAnimator():LoadAnimation(v17)
		track:Play(0.1, 1, 1.5)
		track.Priority = Enum.AnimationPriority.Action2
		track.Stopped:Once(function()
			track:Play(0, 1, 0)
			track.TimePosition = track.Length - 0.01
			task.wait(0.25)
			track:Stop(0.25)
			track:Destroy()
		end)
		v13 = track
		v12 += 1

		if v12 > 2 then
			v12 = 1
		end

		task.spawn(function()
			wait(0.3)

			if bodyVelocity then
				bodyVelocity:Destroy()
			end

			lastTime4 = tick()
			v11 = true
		end)
	end
end

function _G.TeleportSoru()
	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid or (humanoid.Sit or humanoid.WalkSpeed == 0 or humanoid.Health <= 0) then
		return
	end

	if not (localPlayer.PlayerStats.Soru.Value == "Soru" and v2 and localPlayer.PlayerStats.Soru.Value == "Soru") then
		return
	end

	if _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer) or _G.AntiMob() then
		return
	end

	local v14 = 150
	local v15 = 15
	task.spawn(function()
		if race == "Human" then
			if flag3 then
				if flag3 then
					v14 *= 1.5
					v15 /= 2
				end
			else
				v14 *= 1.2
			end
		end

		if character:GetAttribute("HumanAwakenV3") then
			v15 /= 2
		end
	end)
	local humanoidRootPart = character.HumanoidRootPart
	local v16 = math.clamp((humanoidRootPart.Position - mouse.Hit.p).Magnitude, 0, v14)
	local v17 = CFrame.new(humanoidRootPart.Position, mouse.Hit.p) * CFrame.new(0, 0, -v16)
	local v18 = v17.p + createVector(0, 2, 0)
	local v19 = v18 + createVector(0, -10, 0)
	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterDescendantsInstances = { workspace.Effects, character, workspace.CharacterWorkshop }
	raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
	local v20 = (character:FindFirstChild("Pteranodon_KL") or character:FindFirstChild("Phoenix_Model")) and 20 or 3
	local raycastResult = workspace:Raycast(v18, createVector(0, -10, 0), raycastParams2)

	if raycastResult then
		local _, v21, _ = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v17.LookVector):ToOrientation()
		local cFrame = humanoidRootPart.CFrame
		local cFrame2 = CFrame.new(v17.p) * CFrame.new(0, v20, 0) * CFrame.fromOrientation(0, v21, 0)

		if v19.Y <= -2.5 then
			cFrame2 = CFrame.new(v17.p.X, v20, v17.p.Z) * CFrame.fromOrientation(0, v21, 0)
		end

		humanoidRootPart.CFrame = cFrame2
		ReplicatedStorage.Chest.Remotes.Events.ButtonR3:FireServer({ cFrame, cFrame2 })
		v2 = false
		character:SetAttribute("Teleport", v15)
		task.spawn(function()
			wait(v15)
			v2 = true
			character:SetAttribute("Teleport", nil)
		end)
	elseif not raycastResult and v19.Y <= -2.5 then
		local _, v21, _ = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v17.LookVector):ToOrientation()
		local cFrame = humanoidRootPart.CFrame
		local cFrame2 = CFrame.new(v17.p.X, v20, v17.p.Z) * CFrame.fromOrientation(0, v21, 0)
		humanoidRootPart.CFrame = cFrame2
		ReplicatedStorage.Chest.Remotes.Events.ButtonR3:FireServer({ cFrame, cFrame2 })
		v2 = false
		character:SetAttribute("Teleport", v15)
		spawn(function()
			wait(v15)
			v2 = true
			character:SetAttribute("Teleport", nil)
		end)
	end
end

function _G.ConquerorStart()
	if not (_G.ConquerorDB or RunService:IsStudio()) or localPlayer.PlayerStats.HAOHAKI.Value ~= "HAOYOUHAVEIT" and localPlayer.PlayerStats.haogamepass.Value ~= "HAOYOUHAVEIT" then
		return
	end

	if _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer) then
		return
	end

	_G.ConquerorCooldown(localPlayer)
	ReplicatedStorage.Chest.Remotes.Events.Conqueror:FireServer()
end

localPlayer.Character.Humanoid.StateChanged:Connect(function(_, p)
	if p == Enum.HumanoidStateType.Landed then
		if not v5 then
			v5 = true
		end
	elseif p == Enum.HumanoidStateType.Seated then
		currentCamera.CameraSubject = localPlayer.Character.Humanoid
	end
end)
local v14 = nil
local v15 = true
spawn(function()
	local cds = script.cds

	while wait(1) do
		local value = cds.Value

		if v4 < value then
			cds.Value = v4
		end

		while cds.Value < v4 do
			v15 = false

			if tick() - lastTime3 >= 1 and (v5 or character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position.Y <= -4) then
				cds.Value = v4
			end

			wait(0.5)
		end

		if not v15 and cds.Value == v4 and _G.CheckSettingClient(localPlayer, "Setting_JumpText") then
			v15 = true
			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Jump Max", { cds.Value, v4 })
		end

		cds.Changed:Wait()
	end
end)

function _G.CheckBoughtClient(instance, p)
	if HttpService:JSONDecode(instance:WaitForChild("PlayerStats"):WaitForChild("Bought").Value)[p] then
		return true
	end

	return false
end

local v16 = {}
local flag5 = false

function ClearPassiveText(p)
	local targetRootPart = p.TargetRootPart

	if not targetRootPart then
		return
	end

	local observationPassives = targetRootPart:FindFirstChild("ObservationPassives")

	if not observationPassives then
		return
	end

	for _, label in pairs(observationPassives:GetChildren()) do
		if label:IsA("TextLabel") then
			label:Destroy()
		end
	end
end

function PassiveTextInstance(data)
	local passive = data.Passive
	local tier = data.Tier
	local observationPassives = data.ObservationPassives
	local clone = ReplicatedStorage.Chest.Gui.PassiveText:Clone()

	if tier == "Iconic" then
		clone.TextColor3 = Color3.fromRGB(255, 255, 0)
	elseif tier == "Celestial" then
		clone.TextColor3 = Color3.fromRGB(0, 255, 255)
	elseif tier == "Curse" then
		clone.TextColor3 = Color3.fromRGB(255, 0, 0)
	elseif tier == "Paradox" then
		clone.TextColor3 = Color3.fromRGB(0, 170, 0)
	end

	clone.Text = _G.ProcessName(CustomNames[passive.Name] or passive.Name)
	clone.Name = passive.Name
	clone.Parent = observationPassives
end

local v17 = {}

function ClearConnection()
	for _, connection in pairs(v17) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	v17 = {}
end

local v18 = {}

function HidingRace()
	if #v18 > 0 then
		for _, part in ipairs(v18) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end
	end
end

function ClearRaceCaches()
	if #v18 > 0 then
		for _, part in ipairs(v18) do
			if part:IsA("BasePart") then
				part.Transparency = part:GetAttribute("Transparency") or 0
			end
		end
	end

	table.clear(v18)
end

function KenHaki(p)
	if _G.CheckAwakeClient(localPlayer, "Observation") then
		flag5 = true
	else
		flag5 = false
	end

	if p == "Open" then
		ClearConnection()
		_G.IsOpenKenHaki = true
		ClearRaceCaches()
		local clone = ReplicatedStorage.Chest.Gui.Circle:Clone()
		clone.Parent = localPlayer.PlayerGui.MainGui.StarterFrame
		_G.PU:Dust(clone, 1)
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Circular), {
			Size = UDim2.new(4, 0, 4, 0)
		}):Play()
		game.Lighting.Blur.Enabled = true
		local clone2 = script.KenHaki.KenColor:Clone()
		clone2.Enabled = true
		clone2.Parent = game.Lighting

		if flag5 then
			local sound = PeoUtils2.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15160003749",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.sfx_is
			sound:Play()
		else
			local sound = PeoUtils2.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15159998867",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.sfx_is
			sound:Play()
		end

		v16 = {}
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid")
			local connections = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function safeDestroy(instance)
				if instance and instance.Parent then
					instance:Destroy()
				end
			end

			local function cleanupTargetObjects(instance)
				if not instance then
					return
				end

				safeDestroy(instance:FindFirstChild("ObservationNameUsed")) -- equivalent call inferred; original call site unknown
				safeDestroy(instance:FindFirstChild("ObservationHealthUsed")) -- equivalent call inferred; original call site unknown
				safeDestroy(instance:FindFirstChild("ObservationPassives")) -- equivalent call inferred; original call site unknown
				safeDestroy(instance.Parent:FindFirstChild("ObservationHighlightUsed")) -- equivalent call inferred; original call site unknown
				safeDestroy(instance:FindFirstChild("ObservationTargetUsed")) -- equivalent call inferred; original call site unknown
				safeDestroy(instance:FindFirstChild("ObservationToolsUsed")) -- equivalent call inferred; original call site unknown
			end

			local function cleanupConnections()
				for _, connection in ipairs(connections) do
					if connection.Connected then
						connection:Disconnect()
					end
				end

				table.clear(connections)
			end

			local function createHighlight(parent, color)
				if _G.AntiMobSkillTarget(parent) then
					return
				end

				if not parent:FindFirstChild("ObservationHighlightUsed") then
					local highlight = Instance.new("Highlight")
					highlight.Adornee = parent
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillColor = color
					highlight.FillTransparency = 0.5
					highlight.OutlineColor = color
					highlight.Name = "ObservationHighlightUsed"
					highlight.Parent = parent
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function createTargetDot(parent)
				if not parent:FindFirstChild("ObservationTargetUsed") then
					local clone3 = ReplicatedStorage.Chest.Gui.ObservationTargetGUI:Clone()
					clone3.Name = "ObservationTargetUsed"
					clone3.Parent = parent
				end
			end

			local function createObservationName(parent)
				if not (parent and parent.Name) then
					return
				end

				if not parent:FindFirstChild("ObservationNameUsed") then
					local clone3 = ReplicatedStorage.Chest.Gui.ObservationName:Clone()
					clone3.Name = "ObservationNameUsed"
					clone3.TextLabel.Text = parent.Parent.Name
					clone3.Parent = parent
					local playerFromCharacter = Players:GetPlayerFromCharacter(parent.Parent)

					if playerFromCharacter then
						local playerStats = playerFromCharacter:FindFirstChild("PlayerStats")

						if not playerStats then
							return
						end

						local value = playerStats.lvl.Value
						clone3.TextLabel.Text = string.format("%s [Lv. %d]", parent.Parent.Name, value)
					end
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function destroyVisuals(instance)
				safeDestroy(instance.Parent:FindFirstChild("ObservationHighlightUsed")) -- equivalent call inferred; original call site unknown
				safeDestroy(instance:FindFirstChild("ObservationTargetUsed")) -- equivalent call inferred; original call site unknown
				safeDestroy(instance:FindFirstChild("ObservationNameUsed")) -- equivalent call inferred; original call site unknown
			end

			local function updateHealthBar(data, parent)
				if Players:GetPlayerFromCharacter(data.Parent) == localPlayer then
					return
				end

				if not parent:FindFirstChild("ObservationHealthUsed") then
					local clone3 = ReplicatedStorage.Chest.Gui.ObservationHealth:Clone()
					clone3.Name = "ObservationHealthUsed"
					clone3.CanvasGroup.Bar.Size = UDim2.new(math.clamp(data.Health / data.MaxHealth, 0, 1), 0, 1, 0)
					clone3.Parent = parent
					table.insert(connections, data.HealthChanged:Connect(function()
						if clone3 and clone3.Parent then
							clone3.CanvasGroup.Bar.Size = UDim2.new(
								math.clamp(data.Health / data.MaxHealth, 0, 1),
								0,
								1,
								0
							)
						end
					end))
					table.insert(connections, data.Died:Connect(function()
						cleanupTargetObjects(parent)
					end))
				end
			end

			local function ObservationPassiveInstance(p2)
				local targetRootPart = p2.TargetRootPart

				if not targetRootPart then
					return
				end

				local playerFromCharacter = Players:GetPlayerFromCharacter(targetRootPart.Parent)

				if playerFromCharacter and localPlayer == playerFromCharacter then
					return
				end

				local characterPassives = targetRootPart.Parent:FindFirstChild("CharacterPassives")

				if not characterPassives then
					return
				end

				ClearPassiveText({
					TargetRootPart = targetRootPart
				})

				for _, child in pairs(characterPassives:GetChildren()) do
					if PassiveList[child.Name] then
						local tier = PassiveList[child.Name].Tier

						if tier == "Iconic" or tier == "Celestial" or tier == "Curse" then
							if targetRootPart:FindFirstChild("ObservationPassives") then
								if not targetRootPart.ObservationPassives:FindFirstChild(child.Name) then
									PassiveTextInstance({
										Passive = child,
										Tier = tier,
										ObservationPassives = targetRootPart.ObservationPassives
									})
								end
							else
								local clone3 = ReplicatedStorage.Chest.Gui.ObservationPassives:Clone()
								clone3.Parent = targetRootPart
								PassiveTextInstance({
									Passive = child,
									Tier = tier,
									ObservationPassives = clone3
								})
							end
						end
					elseif child:GetAttribute("Paradox") then
						if targetRootPart:FindFirstChild("ObservationPassives") then
							if not targetRootPart.ObservationPassives:FindFirstChild(child.Name) then
								PassiveTextInstance({
									Passive = child,
									Tier = "Paradox",
									ObservationPassives = targetRootPart.ObservationPassives
								})
							end
						else
							local clone3 = ReplicatedStorage.Chest.Gui.ObservationPassives:Clone()
							clone3.Parent = targetRootPart
							PassiveTextInstance({
								Passive = child,
								Tier = "Paradox",
								ObservationPassives = clone3
							})
						end
					end
				end
			end

			local function updateDisplayName(p2, instance)
				if not flag5 or (not instance or instance == localPlayer) then
					return
				end

				local playerStats = instance:FindFirstChild("PlayerStats")

				if not playerStats then
					return
				end

				local value = playerStats.lvl.Value
				p2.DisplayName = string.format("%s [Lv. %d]", p2.Parent.Name, value)
			end

			local function createObservationTools(playerFromCharacter, parent)
				if not flag5 or (not playerFromCharacter or playerFromCharacter == localPlayer) then
					return
				end

				local playerStats = playerFromCharacter:FindFirstChild("PlayerStats")

				if not playerStats then
					return
				end

				local observationToolsUsed = parent:FindFirstChild("ObservationToolsUsed")

				if not observationToolsUsed then
					observationToolsUsed = ReplicatedStorage.Chest.Gui.ObservationTools:Clone()
					observationToolsUsed.Name = "ObservationToolsUsed"
					observationToolsUsed.Parent = parent
				end

				local value = playerStats.FightingStyle.Value
				local value2 = playerStats.DFName.Value
				local value3 = playerStats.SwordName.Value
				local value4 = playerStats.Accessory.Value
				local frame = observationToolsUsed.Frame
				local v19 = playerFromCharacter.Character:FindFirstChild(value) or playerFromCharacter.Backpack:FindFirstChild(value)

				if v19 then
					frame.FightingStyle.Image = v19.TextureId
					frame.FightingStyle.Visible = true

					if playerFromCharacter.Character:FindFirstChild(value) then
						frame.FightingStyle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
					end
				end

				if value2 ~= "None" and SwordList[value2] then
					frame.Fruit.Image = SwordList[value2].Image
					frame.Fruit.Visible = true
				end

				if value3 ~= "None" and SwordList[value3] then
					frame.Sword.Image = SwordList[value3].Image
					frame.Sword.Visible = true

					if playerFromCharacter.Character:FindFirstChild(value3) then
						frame.Sword.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
					end
				end

				if value4 ~= "None" and AccessoriesList[value4] then
					frame.Accessory.Image = AccessoriesList[value4].Image
					frame.Accessory.Visible = true
				end

				if playerFromCharacter.Character:FindFirstChild("LegacyPose") or playerFromCharacter.Backpack:FindFirstChild("LegacyPose") then
					frame.LegacyPose.Image = SwordList.LegacyPose.Image
					frame.LegacyPose.Visible = true

					if playerFromCharacter.Character:FindFirstChild("LegacyPose") then
						frame.LegacyPose.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
					end
				end
			end

			local ShowRaceAppearance

			ShowRaceAppearance = function(child, p2, p3, instance)
				for _, child2 in ipairs(child:GetChildren()) do
					if child2:IsA("Model") then
						ShowRaceAppearance(child2)
					elseif child2:IsA("BasePart") and child2.Name ~= "RootPart" and child2.Name ~= "MainMotor6D" then
						child2.Transparency = p3 and child2:GetAttribute("Transparency") or not (p2 and instance:FindFirstChild("LowerTorso")) and 1 or instance.LowerTorso.Transparency or 1
					end
				end

				return true
			end

			local function RevealRace(instance, p2, p3)
				if not flag5 then
					return
				end

				for _, child in ipairs(instance:GetChildren()) do
					if child:GetAttribute("RaceModel") then
						ShowRaceAppearance(child, p2, p3, instance)
					end
				end
			end

			local v19 = {}

			while _G.IsOpenKenHaki and humanoid.Health > 0 and character:FindFirstChild("Services") and character.Services.KenHaki.Value > 0 do
				if character:FindFirstChild("ObservationHighlightUsed") and _G.AntiMobSkillTarget(character) then
					safeDestroy(character:FindFirstChild("ObservationHighlightUsed")) -- equivalent call inferred; original call site unknown
				end

				for _, folder in pairs(workspace:GetChildren()) do
					if not (folder:IsA("Folder") and folder.Name ~= "SeaMonster" and folder.Name ~= "GhostMonster" and folder.Name ~= "AllNPC") then
						continue
					end

					local v20

					if folder.Name == "Monster" then
						v20 = 1000
					else
						v20 = 20000
					end

					for _, model in pairs(folder:GetDescendants()) do
						if not model:IsA("Model") then
							continue
						end

						local humanoid2 = model:FindFirstChildOfClass("Humanoid")
						local humanoidRootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("RootPart")

						if not humanoid2 or not humanoidRootPart or humanoid2.Health <= 0 then
							continue
						end

						local targetRootPart = humanoidRootPart
						local v22 = model
						local v23 = humanoid2
						task.spawn(function()
							local magnitude = (targetRootPart.Position - character.HumanoidRootPart.Position).Magnitude

							if _G.AntiMobObservation and _G.AntiMobObservation(v22) then
								return
							end

							if v20 <= magnitude then
								cleanupTargetObjects(targetRootPart)
								destroyVisuals(targetRootPart) -- equivalent call inferred; original call site unknown
								v19[v22] = nil
							else
								if magnitude < 100 then
									safeDestroy(targetRootPart:FindFirstChild("ObservationNameUsed")) -- equivalent call inferred; original call site unknown
								elseif magnitude >= 100 and magnitude < v20 then
									createObservationName(targetRootPart)
								end

								if magnitude < 300 then
									safeDestroy(targetRootPart:FindFirstChild("ObservationTargetUsed")) -- equivalent call inferred; original call site unknown
									local playerFromCharacter = Players:GetPlayerFromCharacter(v23.Parent)

									if playerFromCharacter then
										if _G.AntiMobShowRace(v23.Parent) then
											RevealRace(v22, false)
										else
											RevealRace(v22, true)
										end

										if _G.CheckAllyClient(localPlayer, playerFromCharacter) then
											createHighlight(targetRootPart.Parent, Color3.fromRGB(0, 255, 0))
										elseif playerFromCharacter == localPlayer then
											createHighlight(targetRootPart.Parent, Color3.fromRGB(255, 255, 255))
										else
											createHighlight(targetRootPart.Parent, Color3.fromRGB(255, 0, 0))
										end
									else
										createHighlight(targetRootPart.Parent, Color3.fromRGB(255, 0, 0))
									end
								elseif magnitude >= 300 and magnitude < v20 then
									safeDestroy(targetRootPart.Parent:FindFirstChild("ObservationHighlightUsed")) -- equivalent call inferred; original call site unknown
									createTargetDot(targetRootPart) -- equivalent call inferred; original call site unknown
								end

								if magnitude < 300 then
									updateHealthBar(v23, targetRootPart)
									ObservationPassiveInstance({
										TargetRootPart = targetRootPart
									})
								elseif magnitude >= 300 and magnitude < 1000 then
									safeDestroy(targetRootPart:FindFirstChild("ObservationHealthUsed")) -- equivalent call inferred; original call site unknown
									safeDestroy(targetRootPart:FindFirstChild("ObservationPassives")) -- equivalent call inferred; original call site unknown
								end

								local playerFromCharacter = Players:GetPlayerFromCharacter(v23.Parent)
								local v24 = v23
								local playerStats = flag5 and playerFromCharacter and playerFromCharacter ~= localPlayer and playerFromCharacter:FindFirstChild("PlayerStats")

								if playerStats then
									local value = playerStats.lvl.Value
									v24.DisplayName = string.format("%s [Lv. %d]", v24.Parent.Name, value)
								end

								createObservationTools(playerFromCharacter, targetRootPart)
							end
						end)
					end
				end

				task.wait(0.3333333333333333)
			end

			for _, v20 in pairs(Players:GetPlayers()) do
				local character2 = v20.Character

				if not (character2 and character2:FindFirstChild("Humanoid")) then
					continue
				end

				character2.Humanoid.DisplayName = v20.Name
				local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					safeDestroy(humanoidRootPart:FindFirstChild("ObservationToolsUsed")) -- equivalent call inferred; original call site unknown
					safeDestroy(humanoidRootPart:FindFirstChild("ObservationPassives")) -- equivalent call inferred; original call site unknown
				end

				if not _G.AntiMobShowRace(character2) then
					RevealRace(character2, true, true)
				end
			end

			cleanupConnections()
			_G.DestroyObservationObject()
		end)
	elseif p == "Close" then
		ClearConnection()
		v16 = {}
		_G.IsOpenKenHaki = false
		_G.DestroyObservationObject()
		ClearRaceCaches()

		if flag5 then
			local sound = PeoUtils2.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15160004624",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.sfx_is
			sound:Play()
		else
			local sound = PeoUtils2.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15160001293",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.sfx_is
			sound:Play()
		end

		local clone = ReplicatedStorage.Chest.Gui.Circle:Clone()
		clone.Size = UDim2.new(4, 0, 4, 0)
		clone.Parent = localPlayer.PlayerGui.MainGui.StarterFrame
		_G.PU:Dust(clone, 1.5)
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Circular), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		local kenColor = game.Lighting:FindFirstChild("KenColor")

		if kenColor then
			kenColor:Destroy()
		end

		game.Lighting.Blur.Enabled = false
	end
end

spawn(function()
	_G.DestroyObservationObject()
end)
_G.KenHaki = KenHaki
_G.RunSpeedClient = 50
_G.KenhakiDebounce = true
local flag6 = nil
local v19 = true
local zero = Vector2.zero
local v20 = true
local v21 = nil
local lastTime5 = tick()

function Observation()
	if localPlayer.PlayerStats.KenShopValue.Value ~= "KenHaki" or (_G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer)) or not v19 then
		return
	end

	if character.Services.KenHaki.Value <= 0 then
		pcall(function()
			if not localPlayer.PlayerGui.Popup.Frame:FindFirstChild("No Dodge Left") then
				ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("No Dodge Left")
			end
		end)
		return
	end

	v19 = nil

	if kenEvent:InvokeServer() then
		_G.KenHaki("Open")
	else
		_G.KenHaki("Close")
	end

	spawn(function()
		wait(1)
		v19 = true
	end)
end

if UserInputService.GamepadEnabled then
	UserInputService.InputChanged:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			local X = input.Position.X
			local Y = input.Position.Y
			local vector2 = Vector2.new(X, Y)

			if vector2.Magnitude >= 0.9 then
				v20 = true

				if tick() - lastTime5 < 0.25 and v21 then
					if vector2:Dot(zero) >= 0.87 then
						_G.Dash(character)
					end

					v21 = nil
				end

				zero = vector2
			elseif vector2.Magnitude <= 0.75 and v20 then
				v20 = nil
				lastTime5 = tick()

				if not v21 then
					v21 = true
				end
			end
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer) and not character:GetAttribute("IgnoreDash") then
		return
	end

	local flyingVelocity = humanoidRootPart:FindFirstChild("FlyingVelocity", 30)

	if character:findFirstChild("DemonForm") or flyingVelocity or humanoid.WalkSpeed == 0 or humanoid.Sit then
		return
	end

	if input.KeyCode == Enum.KeyCode.ButtonA then
		_G.Geppo()
	end

	if input.KeyCode == Enum.KeyCode.ButtonR3 then
		lastTime2 = tick()
	end

	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.ButtonL3 then
		lastTime = tick()
	end

	if input.KeyCode == Enum.KeyCode.Space then
		_G.Geppo()
	end

	if input.KeyCode == Enum.KeyCode.LeftControl then
		_G.Run = not _G.Run
	end

	if input.KeyCode == Enum.KeyCode.Q and not humanoid.Sit and humanoid.WalkSpeed ~= 0 then
		if humanoidRootPart:FindFirstChild("BodyVelocity") then
			return
		else
			_G.Dash(character)
		end
	end

	if (input.KeyCode == Enum.KeyCode.T or input.KeyCode == Enum.KeyCode.DPadDown) and v3 and localPlayer.PlayerStats.BusoShopValue.Value == "BusoHaki" and not (_G.AntiMob() or _G.CheckStunClient(localPlayer) or _G.CheckDoingClient(localPlayer)) then
		v3 = false
		armament:FireServer()
		wait(1)
		v3 = true
	end

	if input.KeyCode == Enum.KeyCode.Y or input.KeyCode == Enum.KeyCode.G then
		Observation()
	end

	if input.KeyCode == Enum.KeyCode.F then
		_G.TeleportSoru()
	end

	if input.KeyCode == Enum.KeyCode.U then
		_G.ConquerorStart()
	end
end)
UserInputService.InputEnded:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.ButtonR3 then
		if tick() - lastTime2 < 1 then
			_G.TeleportSoru()
		else
			_G.ConquerorStart()
		end
	end

	if input.KeyCode == Enum.KeyCode.ButtonL3 then
		if tick() - lastTime <= 0.5 then
			_G.Run = not _G.Run
		elseif flag6 then
			if flag6 then
				flag6 = nil
			end
		else
			local function FindNearestTarget()
				local magnitude = 50
				local v22 = nil

				for _, descendant in pairs(workspace:GetDescendants()) do
					local humanoidRootPart = descendant:FindFirstChild("HumanoidRootPart")
					local humanoid = descendant:FindFirstChild("Humanoid")

					if not (humanoid and humanoidRootPart and humanoidRootPart ~= character.HumanoidRootPart and humanoid.Health > 0) then
						continue
					end

					if not (((workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -50)).Position - humanoidRootPart.Position).Magnitude <= magnitude) then
						continue
					end

					if _G.CheckAllyServer(descendant) or game.Players:GetPlayerFromCharacter(descendant) then
						continue
					end

					magnitude = (humanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
					v22 = descendant
				end

				return v22
			end

			local v22 = FindNearestTarget()

			if v22 then
				flag6 = true
				local clone = ReplicatedStorage.Chest.Gui.LockTarget:Clone()
				clone.Parent = v22
				clone.Adornee = v22

				while flag6 do
					local humanoidRootPart = v22:FindFirstChild("HumanoidRootPart")
					local humanoid = v22:FindFirstChild("Humanoid")

					if humanoid and not (humanoid and humanoid.Health <= 0) and humanoidRootPart then
						workspace.CurrentCamera.CFrame = CFrame.new(
							workspace.CurrentCamera.CFrame.Position,
							humanoidRootPart.Position
						) * CFrame.Angles(-0.23561944901923448, 0, 0)
						RunService.RenderStepped:Wait()
					else
						break
					end
				end

				flag6 = nil
				clone:Destroy()
			end
		end
	end

	if input.KeyCode == Enum.KeyCode.DPadUp then
		_G.Dash(character)
	end

	if input.KeyCode == Enum.KeyCode.DPadLeft then
		Observation()
	end
end)
local kenHaki = script.Parent.KenHaki
local kenOpen = script.Parent.KenOpen

function DiedCloseUI()
	_G.ButtonClicked({
		Frame = nil,
		Button = nil,
		Died = true
	})
end

character.Humanoid.Died:Connect(function()
	if kenHaki.Value >= 1 and kenOpen.Value then
		_G.KenHaki("Close")
	end

	ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("CompassFrame", {
		VisibleType = false,
		Force = true
	})
	ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("LegacyPoseFrame", {
		VisibleType = false,
		Force = true
	})
	DiedCloseUI()

	if workspace:FindFirstChild("OpeRoom" .. localPlayer.Name) then
		ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
			Type = "Fly2",
			Mode = "Stop"
		})
	end
end)

function DeathFXEmit(cFrame)
	if not cFrame then
		return
	end

	local clone = ReplicatedStorage.Chest.Assets.Effects.DeathFX:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 3)
	Utility.EmitParticles(clone)
	local sound = PeoUtils2.CreateSound({
		RollOffMaxDistance = 200,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11597512858",
		Volume = 0.5,
		PlaybackSpeed = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
end

function add(_) end

function check()
	for _, folder in pairs(workspace:GetChildren()) do
		if not (folder:IsA("Folder") and (folder.Name == "Monster" or folder.Name == "PlayerCharacters")) then
			continue
		end

		for _, model in pairs(folder:GetChildren()) do
			if model.Name == "Boss" or model.Name == "Mon" then
				for _, model2 in pairs(model:GetChildren()) do
					if model2:IsA("Model") and model2:FindFirstChild("Humanoid") then
						add(model2)
					end
				end
			end

			if model:IsA("Model") and model:FindFirstChild("Humanoid") then
				add(model)
			end
		end
	end
end

workspace.PlayerCharacters.ChildAdded:Connect(function(model)
	task.wait()

	if model:IsA("Model") and model:WaitForChild("Humanoid", 10) then
		add(model)
	end
end)
workspace.Monster.Mon.ChildAdded:Connect(function(model)
	task.wait()

	if model:IsA("Model") and model:WaitForChild("Humanoid", 10) then
		add(model)
	end
end)

if workspace:FindFirstChild("MOB") then
	workspace.MOB.ChildAdded:Connect(function(model)
		task.wait()

		if model:IsA("Model") and model:WaitForChild("Humanoid", 10) then
			add(model)
		end
	end)
end

workspace.Monster.Boss.ChildAdded:Connect(function(model)
	task.wait()

	if model:IsA("Model") and model:WaitForChild("Humanoid", 10) then
		add(model)
	end
end)
character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local module = require(ReplicatedStorage.Chest.Modules.Weather:WaitForChild("RainyStone"):Clone())
localPlayer:WaitForChild("Danger")
local v22 = ""

for _, part in pairs(workspace.CurrentCamera:GetChildren()) do
	if part:IsA("BasePart") then
		part:Destroy()
	end
end

function disable()
	module:Disable(TweenInfo.new(0.1))
end

function IsInSafezone(p)
	for _, child in pairs(workspace.Safezone:GetChildren()) do
		local v23 = child.CFrame:Inverse() * p.Position
		local v24 = math.abs(child.Size.X / 2)
		local v25 = math.abs(child.Size.Z / 2)

		if math.abs(v23.X) <= v24 and math.abs(v23.Z) <= v25 then
			return true
		end
	end

	return false
end

function IsInSuperSafezone(p)
	for _, child in pairs(workspace.SuperSafeZone:GetChildren()) do
		local v23 = child.CFrame:Inverse() * p.Position
		local v24 = math.abs(child.Size.X / 2)
		local v25 = math.abs(child.Size.Z / 2)

		if math.abs(v23.X) <= v24 and math.abs(v23.Z) <= v25 then
			return true
		end
	end

	return false
end

_G.LastUpdate = 0
localPlayer.Danger.Time.Changed:Connect(function()
	if localPlayer.Danger.Value ~= "Danger" then
		_G.LastUpdate = tick()
	end
end)
local _ = {
	[991117111] = true,
	[394373295] = true,
	[8405402] = true,
	[85696426] = true,
	[759098623] = true,
	[181871761] = true
}
local v23 = {
	Carcer = true,
	Floresco = true,
	HibernusLand = true,
	Torrefacio = true,
	Viridans = true
}
local AreaMusic = require(ReplicatedStorage.Chest.Modules.AreaMusic)
spawn(function()
	local function FadeInTalk(p)
		local findNPCModel = p.FindNPCModel
		local nPCHighlight = findNPCModel:FindFirstChild("NPCHighlight")

		if nPCHighlight then
			nPCHighlight:Destroy()
		end

		local color = Color3.fromRGB(255, 255, 255)

		if findNPCModel:FindFirstChild("Head") and findNPCModel.Head:FindFirstChild("NPCName") and findNPCModel.Head.NPCName:FindFirstChild("TextLabel") then
			color = findNPCModel.Head.NPCName.TextLabel.TextColor3
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "NPCHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = color
		highlight.FillTransparency = 0.8
		highlight.OutlineColor = color
		highlight.Parent = findNPCModel
		local clone = ReplicatedStorage.Chest.Gui.ClickToTalk:Clone()
		clone.TextLabel.Text = "Interact"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.TextLabel.Text = "โต้ตอบ"
		end

		clone.TextLabel.TextTransparency = 1
		clone.TextLabel.TextStrokeTransparency = 0.5
		clone.StudsOffset = createVector(0, 2.5, 0)
		clone.Parent = findNPCModel
		TweenService:Create(clone, TweenInfo.new(0.5), {
			StudsOffset = createVector(0, 1, 0)
		}):Play()
		TweenService:Create(clone.TextLabel, TweenInfo.new(0.5), {
			TextTransparency = 0,
			TextStrokeTransparency = 0
		}):Play()
	end

	local function FadeOutTalk(p)
		local UI = p.UI
		local nPCHighlight = p.FindNPCModel:FindFirstChild("NPCHighlight")

		if nPCHighlight then
			nPCHighlight:Destroy()
		end

		TweenService:Create(UI, TweenInfo.new(0.25), {
			StudsOffset = createVector(0, 2.5, 0)
		}):Play()
		TweenService:Create(UI.TextLabel, TweenInfo.new(0.25), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		_G.PU:Dust(UI, 0.5)
	end

	local function AreaUpdate(p)
		if AreaMusic[p] then
			disable()
			task.wait(0.1)

			if p == "Rainy Stone" then
				module:SetColor(Color3.fromRGB(255, 255, 255))
				module:SetStraightTexture("rbxassetid://1822883048")
				module:SetTopDownTexture("rbxassetid://1822883048")
				module:SetSplashTexture("rbxassetid://1822883048")
				module:Enable(TweenInfo.new(1))
			elseif p == "HydraIslandArea" then
				module:SetColor(Color3.fromRGB(255, 255, 255))
				module:SetStraightTexture("rbxassetid://1822883048")
				module:SetTopDownTexture("rbxassetid://1822856633")
				module:SetSplashTexture("rbxassetid://1822856633")
				module:Enable(TweenInfo.new(1))
			end

			if AreaMusic[p].Music then
				workspace.sfx_is.Music_Area.SoundId = AreaMusic[p].Music
				workspace.sfx_is.Music_Area:Play()
			end

			local soundIdList = AreaMusic[p].SoundIdList

			if soundIdList then
				workspace.sfx_is.Music_Area.SoundId = soundIdList[math.random(1, #soundIdList)]
				workspace.sfx_is.Music_Area:Play()
			end

			if AreaMusic[p].RainSound then
				workspace.sfx_is.Rain.SoundId = AreaMusic[p].RainSound
				workspace.sfx_is.Rain:Play()
			else
				workspace.sfx_is.Rain:Stop()
			end

			if AreaMusic[p].IslandName then
				local _ = AreaMusic[p].IslandName
			end

			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Island Name", { p })
		end
	end

	local v24 = nil
	local thread = nil
	local v25 = {}

	while wait(0.2) do
		local v26 = nil
		task.spawn(function()
			for _, part in pairs(workspace.AllNPC:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local magnitude = (humanoidRootPart.CFrame.p - part.CFrame.p).magnitude
				local model = part:FindFirstChildOfClass("Model")

				if not model then
					continue
				end

				if magnitude < 16 then
					v26 = model
				end

				if magnitude < 12 then
					local clickToTalk = model:FindFirstChild("ClickToTalk")

					if clickToTalk then
						if clickToTalk and (_G.NPCTalk or _G.CheckDoingClient(localPlayer)) then
							FadeOutTalk({
								UI = clickToTalk,
								FindNPCModel = model
							})
						end
					elseif not (_G.NPCTalk or _G.CheckDoingClient(localPlayer)) then
						FadeInTalk({
							FindNPCModel = model
						})
					end
				elseif magnitude >= 12 then
					local clickToTalk = model:FindFirstChild("ClickToTalk")

					if clickToTalk then
						FadeOutTalk({
							UI = clickToTalk,
							FindNPCModel = model
						})
					end
				end
			end
		end)

		if v24 and v26 ~= v24 then
			pcall(function()
				local v27 = v24
				local tween = TweenService:Create(v27.HumanoidRootPart, TweenInfo.new(0.5), {
					CFrame = v27.Parent.CFrame
				})
				v25[v27] = tween
				tween:Play()
				local completedConnection = nil
				completedConnection = tween.Completed:Connect(function()
					wait()
					v25[v27] = nil
					tween = nil

					if completedConnection and completedConnection.Connected then
						completedConnection:Disconnect()
						completedConnection = nil
					end
				end)
			end)
		end

		if v26 then
			if not thread then
				if v25[v24] then
					v25[v24]:Pause()
					v25[v24] = nil
				end

				thread = task.spawn(function()
					while v26 do
						local v27 = task.wait()
						local humanoidRootPart2 = v26:FindFirstChild("HumanoidRootPart")

						if not humanoidRootPart2 then
							break
						end

						local v28 = (humanoidRootPart.Position - humanoidRootPart2.Position).Unit * createVector(
							1,
							0,
							1
						)
						humanoidRootPart2.CFrame = humanoidRootPart2.CFrame:Lerp(
							PeoUtils.CFrameLookAt(humanoidRootPart2.Position, humanoidRootPart2.Position + v28),
							v27 * 3
						)
					end
				end)
			end
		elseif thread then
			task.cancel(thread)
			thread = nil
		end

		v24 = v26
		local vector2 = Vector3.new(humanoidRootPart.Position.X, 30, humanoidRootPart.Position.Z)
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterDescendantsInstances = { workspace.Areas }
		raycastParams2.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(vector2, createVector(0, -3000, 0), raycastParams2)
		local v27 = not raycastResult and "Out" or raycastResult.Instance.Name

		if v22 ~= v27 then
			v22 = v27

			if AreaMusic[v22] and AreaMusic[v22].CustomFog then
				local customFog = AreaMusic[v22].CustomFog
				TweenService:Create(game.Lighting, TweenInfo.new(0.25), {
					FogColor = customFog.FogColor,
					FogStart = customFog.FogStart,
					FogEnd = customFog.FogEnd
				}):Play()
			else
				TweenService:Create(game.Lighting, TweenInfo.new(0.25), {
					FogColor = Color3.fromRGB(0, 170, 255),
					FogStart = 250,
					FogEnd = 2500
				}):Play()
			end

			if v22 == "Out" then
				AreaUpdate("Sea")
			else
				local v28 = v23[v27] and "Japan Island" or v27
				ReplicatedStorage.Chest.Remotes.Events.UnlockIsland:FireServer(v28)
				workspace.sfx_is.OceanWave:Stop()
				AreaUpdate(v22)
			end
		end

		local visible = false
		local superSafeZone = playerGui.MainGui.StarterFrame.StatusEffect.SuperSafeZone
		local safeZone = playerGui.MainGui.StarterFrame.StatusEffect.SafeZone
		local pvPDisabled = playerGui.MainGui.StarterFrame.StatusEffect.PvPDisabled
		local visible2 = IsInSafezone(humanoidRootPart) and true or false

		if tick() - _G.LastUpdate <= _G.DangerTimeClient then
			safeZone.Visible = false
		else
			if not safeZone.Visible and visible2 then
				local safeZone2 = safeZone
				pcall(function()
					if localPlayer.PlayerStats.PVP.Value then
						safeZone2.Size = UDim2.new(1, 0, 1, 0)
						TweenService:Create(
							safeZone2,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
							{
								Size = UDim2.new(2, 0, 2, 0)
							}
						):Play()
					end
				end)
			end

			safeZone.Visible = visible2
		end

		if IsInSuperSafezone(humanoidRootPart) then
			_G.LastUpdate = 0
			visible = true
		end

		if not superSafeZone.Visible and visible then
			local superSafeZone2 = superSafeZone
			pcall(function()
				if localPlayer.PlayerStats.PVP.Value then
					superSafeZone2.Size = UDim2.new(1, 0, 1, 0)
					TweenService:Create(
						superSafeZone2,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = UDim2.new(2, 0, 2, 0)
						}
					):Play()
				end
			end)
		end

		superSafeZone.Visible = visible

		if not localPlayer.PlayerStats.PVP.Value then
			safeZone.Visible = false
			superSafeZone.Visible = false
		end

		pvPDisabled.Visible = not localPlayer.PlayerStats.PVP.Value
		local enabled = false

		for _, part in pairs(workspace:GetChildren()) do
			if not string.find(part.Name, "OpeRoom") then
				continue
			end

			if part:IsA("MeshPart") then
				if (workspace.CurrentCamera.CFrame.Position - part.CFrame.p).Magnitude < part.Size.Z / 2 then
					enabled = true
				end
			elseif part:FindFirstChild("Mesh") and (workspace.CurrentCamera.CFrame.Position - part.CFrame.p).Magnitude < part.Mesh.Scale.Z / 2 then
				enabled = true
			end
		end

		game.Lighting.OpeRoom.Enabled = enabled
	end
end)
turnOffKenHaki.OnClientEvent:Connect(function()
	_G.KenHaki("Close")
end)
local v24 = -4.5
local v25 = {
	Idle = nil,
	Moving = nil,
	Up = nil,
	Down = nil,
	Jump = nil
}
local v26 = {
	Idle = ReplicatedStorage.Chest.Animation.SwimAnimation.Animation,
	Moving = ReplicatedStorage.Chest.Animation.SwimAnimation.test,
	Up = ReplicatedStorage.Chest.Animation.SwimAnimation.Animation,
	Down = ReplicatedStorage.Chest.Animation.SwimAnimation.Animation,
	Jump = ReplicatedStorage.Chest.Animation.SwimAnimation.Jump
}
local v27 = true
local currentCamera2 = workspace.CurrentCamera
local humanoid = character:WaitForChild("Humanoid", 30)
local humanoidRootPart2 = character:WaitForChild("HumanoidRootPart", 30)

function PlayAnimate(p)
	for k, _ in pairs(v25) do
		if k == p then
			continue
		end

		v25[k]:Stop()
		v25[k] = nil
	end

	if v25[p] == nil and not character:FindFirstChild("Buddha") then
		v25[p] = GetAnimator():LoadAnimation(v26[p])
		v25[p]:Play()
	end
end

local track = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.SwimAnim.Idle)
local track2 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.SwimAnim.Forward)
local track3 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.SwimAnim.Jump)
track3.Priority = Enum.AnimationPriority.Movement
local v28 = true
local flag7 = nil
local folder = nil

function FlyVFX(folder2)
	for _, effect in pairs(folder2:GetDescendants()) do
		if not (effect:IsA("Beam") or effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = true
	end
end

UserInputService.JumpRequest:Connect(function()
	if character:GetAttribute("Mounting") then
		ReplicatedStorage.Chest.Remotes.Events.EtcEvent:FireServer({
			Type = "Dismount"
		})
	end

	local swim = humanoidRootPart2:FindFirstChild("Swim")

	if swim and v28 and v24 >= -8.5 and humanoid.Health > 0 then
		v28 = nil
		v27 = false
		swim.Responsiveness = 15
		swim:SetAttribute("Jumping", true)
		task.spawn(function()
			task.wait(0.5)
			swim:SetAttribute("Jumping", nil)
		end)
		swim.Position = createVector(0, 22.5, 0)
		task.spawn(function()
			local clone = ReplicatedStorage.Chest.Etc.JumpWater:Clone()
			_G.PU:Dust(clone, 2)
			clone.CFrame = CFrame.new((Vector3.new(humanoidRootPart2.Position.X, -3, humanoidRootPart2.Position.Z)))
			clone.Parent = workspace.Effects
			local sound = PeoUtils2.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11084044757",
				Volume = 1,
				Name = "Sound"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		track3:Play()
		spawn(function()
			wait(0.15)
			v27 = true
		end)
	end

	wait(0.1)

	if character.Humanoid.Jump and (race == "Sky" or race == "Demon") and not v14 then
		v14 = true
		local track4 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.SkypianFallAnim)
		track4.Priority = Enum.AnimationPriority.Movement
		local track5 = nil

		if flag3 then
			local sky_Race_Model = character:FindFirstChild("Sky_Race_Model")

			if sky_Race_Model and sky_Race_Model:FindFirstChild("AnimationController") then
				track5 = sky_Race_Model.AnimationController:LoadAnimation(sky_Race_Model.FlightAnim)
			end
		end

		if flag4 then
			local demon_V3_1 = character:FindFirstChild("Demon_V3_1")

			if demon_V3_1 and demon_V3_1:FindFirstChild("AnimationController") then
				track5 = demon_V3_1.AnimationController:LoadAnimation(demon_V3_1.FlightAnim)
			end
		end

		local clone = ReplicatedStorage.Chest.Etc["Rush Trail"].Fly:Clone()
		clone.CFrame = CFrame.new(
			character.HumanoidRootPart.Position,
			character.HumanoidRootPart.Position + character.HumanoidRootPart.Velocity
		)
		clone.Parent = workspace.Effects
		local sound = PeoUtils2.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://3308152153",
			Volume = 2,
			Looped = true
		})
		sound.Parent = clone
		ReplicatedStorage.Chest.Remotes.Events.EtcEvent:FireServer({
			Type = "FlyTrail",
			Activate = true
		})

		while character.Humanoid.Jump do
			if not character.UpperTorso:FindFirstChild("SkyFlying") and character.HumanoidRootPart.Velocity.Y <= -70 and not (_G.AntiMobSkill() or _G.CheckDoingClient(localPlayer) or _G.CheckStunClient(localPlayer)) then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = createVector(0, -5, 0)
				bodyVelocity.MaxForce = createVector(10000, 50000, 10000)
				bodyVelocity.Name = "SkyFlying"
				bodyVelocity.Parent = character.UpperTorso

				if not sound.IsPlaying then
					sound:Play()
				end

				ReplicatedStorage.Chest.Remotes.Events.SkyFlyVX:FireServer(true)
			end

			local vectorToWorldSpace = workspace.CurrentCamera.CFrame:VectorToWorldSpace(createVector(0, 0, -2))
			local v29 = not (vectorToWorldSpace.Y < 0) and 0 or math.abs(vectorToWorldSpace.Y * 25)
			local v30 = math.clamp(humanoid.Health / humanoid.MaxHealth * 150, 50, 150)

			if race == "Demon" then
				v30 = math.clamp(humanoid.Health / humanoid.MaxHealth * 200, 50, 200)
			end

			if character.UpperTorso:FindFirstChild("SkyFlying") then
				character.UpperTorso.SkyFlying.Velocity = Vector3.new(0, -10 - v29, 0) + character.HumanoidRootPart.CFrame.LookVector * createVector(
					1,
					0,
					1
				) * v30
				FlyVFX(clone)

				if sound and sound.Parent and not sound.IsPlaying then
					sound:Play()
				end

				clone.CFrame = CFrame.new(
					character.HumanoidRootPart.Position,
					character.HumanoidRootPart.Position + character.HumanoidRootPart.Velocity
				)

				if not track4.IsPlaying then
					track4:Play()
				end

				if track5 and not track5.IsPlaying then
					track5:Play()
				end
			end

			local position = character.HumanoidRootPart.Position
			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterDescendantsInstances = { workspace.Island }
			raycastParams2.FilterType = Enum.RaycastFilterType.Include

			if (workspace:Raycast(position, createVector(0, -7, 0), raycastParams2) or character.HumanoidRootPart.Position.Y <= -1.5) and character.UpperTorso:FindFirstChild("SkyFlying") then
				break
			else
				wait()
			end
		end

		if clone and clone.Parent then
			clone:Destroy()
		end

		if sound and sound.Parent then
			_G.PU:Dust(sound, 1)
			TweenService:Create(sound, TweenInfo.new(0.5), {
				Volume = 0
			}):Play()
		end

		ReplicatedStorage.Chest.Remotes.Events.EtcEvent:FireServer({
			Type = "FlyTrail"
		})

		if character.UpperTorso:FindFirstChild("SkyFlying") then
			ReplicatedStorage.Chest.Remotes.Events.SkyFlyVX:FireServer(false)
			character.UpperTorso.SkyFlying:Destroy()
		end

		v14 = nil

		if track4.IsPlaying then
			track4:Stop()
		end

		if track5 and track5.IsPlaying then
			track5:Stop()
		end
	end
end)
localPlayer.PlayerStats.DFName.Changed:Connect(function()
	character:SetAttribute("SpeedLine", nil)
	_G.StopAnimationLoopingClient(humanoid)

	if localPlayer.PlayerStats.DFName.Value == "IceIce" or localPlayer.PlayerStats.DFName.Value == "MagmaMagma" then
		ReplicatedStorage.Chest.Remotes.Functions.DFPassive:InvokeServer(localPlayer)
	end
end)
local localPlayer2 = game.Players.LocalPlayer
local playerStats = localPlayer2:WaitForChild("PlayerStats", 40)
localPlayer2.PlayerStats:WaitForChild("Accessory", 40)
local humanoidRootPart3 = character:WaitForChild("HumanoidRootPart")
local RunService2 = game:GetService("RunService")
local UserInputService2 = game:GetService("UserInputService")
local touchEnabled = UserInputService2.TouchEnabled
local _ = workspace.CurrentCamera
local HighlightModule = require(ReplicatedStorage.Chest.Modules.HighlightModule)
local flag8 = true
local v29 = true
HighlightModule:Reset()

function _G.GetMouse()
	local hit = mouse.Hit

	if touchEnabled then
		_G.MouseHitMobileUpdate()
		hit = _G.MouseHitMobile
	end

	return hit
end

local flag9 = nil
local v30 = 125
local v31 = 125
local v32 = 250
local clone = nil

function DragonFlyingStop(p)
	character:SetAttribute("SpeedLine", false)
	flag9 = nil
	v31 = 125

	if p then
		local flying = p.Flying or nil
		local flyingGyro = p.FlyingGyro or nil

		if flying and flyingGyro then
			if flying.ClassName == "BodyVelocity" then
				flying.Velocity = Vector3.new()
			elseif flying.ClassName == "LinearVelocity" then
				flying.VectorVelocity = Vector3.new()
			end

			if _G.CheckDoingClient(localPlayer2) and not character:GetAttribute("DragonRotating") then
				flyingGyro.CFrame = CFrame.new(humanoidRootPart3.Position, _G.MouseHit.p)
			elseif UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
				flyingGyro.CFrame = CFrame.new(
					currentCamera2.CFrame.Position,
					currentCamera2.CFrame.Position + currentCamera2.CFrame.LookVector
				)
			end
		end
	end
end

local raycastParams2 = RaycastParams.new()
raycastParams2.FilterDescendantsInstances = {
	workspace.Effects,
	workspace.CharacterWorkshop,
	character,
	workspace.SeaFolder
}
raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
local flag10 = nil

function IsInBossArea()
	for _, child in pairs(workspace.Island:GetChildren()) do
		if (child.Name == "DragonLocation" or child.Name == "SeaDragonLocation") and (child.Position - humanoidRootPart3.Position).Magnitude <= 1562.5 then
			return true
		end
	end
end

function ClearClouds()
	local clouds = workspace.Terrain:FindFirstChild("Clouds")

	if clouds and not clouds:GetAttribute("Destroying") then
		clouds:SetAttribute("Destroying", true)
		TweenService:Create(clouds, TweenInfo.new(3), {
			Cover = 0,
			Color = Color3.fromRGB(0, 0, 0)
		}):Play()
		task.spawn(function()
			wait(3)
			clouds:Destroy()
		end)
	end
end

character.AttributeChanged:Connect(function(p)
	if p ~= "MinkAwakenV3" then
		return
	end

	if character:GetAttribute("MinkAwakenV3") then
		flag2 = true
	else
		flag2 = nil
	end
end)
local v33 = {
	"Allosaurus",
	"Brachiosaurus",
	"Spinosaurus",
	"MammothModel",
	"Dragon",
	"Giraffe",
	"Wolf",
	"Leopard",
	"DemonForm",
	"Phoenix_Model",
	"Pteranodon_KL",
	"Tree_KL",
	"Demon_KL",
	"ToyTrex",
	"Buddha",
	"Snow_Wing"
}
local total = 20
local flag11 = true
RunService2.RenderStepped:Connect(function(dt)
	local image = localPlayer2.PlayerGui and localPlayer2.PlayerGui:FindFirstChild("MainGui") and localPlayer2.PlayerGui.MainGui:FindFirstChild("BaseFrame") and localPlayer2.PlayerGui.MainGui.BaseFrame:FindFirstChild("Frame") and localPlayer2.PlayerGui.MainGui.BaseFrame.Frame:FindFirstChild("Steering") and localPlayer2.PlayerGui.MainGui.BaseFrame.Visible and localPlayer2.PlayerGui.MainGui.BaseFrame.Frame.Steering:FindFirstChild("Image")

	if image then
		if image.Rotation == 360 then
			image.Rotation = 0
		end

		image.Rotation += 40 * dt
	end

	local image2 = localPlayer2.PlayerGui and localPlayer2.PlayerGui:FindFirstChild("MainGui") and localPlayer2.PlayerGui.MainGui:FindFirstChild("BaseFrameOG") and localPlayer2.PlayerGui.MainGui.BaseFrameOG:FindFirstChild("Frame") and localPlayer2.PlayerGui.MainGui.BaseFrameOG.Frame:FindFirstChild("Steering") and localPlayer2.PlayerGui.MainGui.BaseFrameOG.Visible and localPlayer2.PlayerGui.MainGui.BaseFrameOG.Frame.Steering:FindFirstChild("Image")

	if image2 then
		if image2.Rotation == 360 then
			image2.Rotation = 0
		end

		image2.Rotation += 40 * dt
	end

	local seaFolder = workspace:FindFirstChild("SeaFolder")
	local v34

	if seaFolder and seaFolder:FindFirstChild("Sea") then
		local seaDragonLocation = workspace.Island:FindFirstChild("SeaDragonLocation") or workspace.Island:FindFirstChild("CrabLocation") or workspace.Island:FindFirstChild("KrakenLocation")
		local dragonLocation = workspace.Island:FindFirstChild("DragonLocation")
		local dragonLocation2 = workspace.Island:FindFirstChild("DragonLocation") or workspace.Island:FindFirstChild("SeaDragonLocation")

		if seaDragonLocation then
			seaFolder.Sea.Color = Color3.fromRGB(0, 0, 0)
			v34 = 0.85
		else
			seaFolder.Sea.Color = Color3.fromRGB(7, 114, 172)
			v34 = 0.5
		end

		if dragonLocation2 then
			if IsInBossArea() then
				if not workspace.Terrain:FindFirstChild("Clouds") then
					local clouds = Instance.new("Clouds")
					clouds.Cover = 0
					clouds.Color = Color3.fromRGB(0, 0, 0)
					clouds.Parent = workspace.Terrain
					TweenService:Create(clouds, TweenInfo.new(3), {
						Cover = 0.9,
						Color = Color3.fromRGB(0, 0, 0)
					}):Play()
				end
			else
				ClearClouds()
			end
		else
			ClearClouds()
		end

		if dragonLocation then
			if (dragonLocation.Position - humanoidRootPart3.Position).Magnitude <= 3000 and not flag10 then
				flag10 = true
				module:SetColor(Color3.fromRGB(255, 255, 255))
				module:SetStraightTexture("rbxassetid://1822883048")
				module:SetTopDownTexture("rbxassetid://1822883048")
				module:SetSplashTexture("rbxassetid://1822883048")
				module:Enable(TweenInfo.new(1))
			elseif (dragonLocation.Position - humanoidRootPart3.Position).Magnitude > 3000 and flag10 then
				flag10 = nil
				module:Disable(TweenInfo.new(1))
			end
		elseif flag10 then
			flag10 = nil
			module:Disable(TweenInfo.new(1))
		end
	else
		v34 = 0.7
	end

	if humanoid.Sit then
		for _, childName in pairs(v33) do
			if not character:FindFirstChild(childName) then
				continue
			end

			humanoid.Sit = nil
			break
		end
	end

	if humanoidRootPart3.Position.Y < -30 then
		humanoidRootPart3.CFrame = CFrame.new(humanoidRootPart3.CFrame.X, -10, humanoidRootPart3.CFrame.Z)

		if sandWave then
			sandWave.CanCollide = false
		end
	end

	if sandWave then
		sandWave.CanCollide = true
	end

	local child = workspace.Effects:FindFirstChild("Speed Line" .. localPlayer2.Name)

	if character:GetAttribute("SpeedLine") then
		if child then
			if child then
				child.CFrame = currentCamera2.CFrame * CFrame.new(0, -0.5, -10)
			end
		else
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Speedline.cam:Clone()
			clone2.Name = "Speed Line" .. localPlayer2.Name
			clone2.Parent = workspace.Effects
			Utility.ParticleHandler(clone2, true)
		end
	elseif child then
		child:Destroy()
	end

	if humanoidRootPart3.Position.Y <= -2.5 and v27 then
		local v35 = humanoidRootPart3:FindFirstChild("Swim")
		local v36 = humanoidRootPart3:FindFirstChild("SwimGyro")
		local vectorToObjectSpace = CFrame.new(
			currentCamera2.CFrame.Position,
			currentCamera2.CFrame.Position + currentCamera2.CFrame.LookVector * createVector(1, 0, 1)
		):VectorToObjectSpace(humanoid.MoveDirection)
		local dot = ((currentCamera2.CFrame * CFrame.new(vectorToObjectSpace)).Position - currentCamera2.CFrame.Position).Unit:Dot(createVector(
			0,
			1,
			0
		))

		if not v28 then
			v28 = true
		end

		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "TotalDoing"
			folder.Parent = character
		end

		if flag11 then
			flag11 = nil
			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.Etc.JumpWater:Clone()
				_G.PU:Dust(clone2, 2)
				clone2.CFrame = CFrame.new((Vector3.new(humanoidRootPart3.Position.X, -3, humanoidRootPart3.Position.Z)))
				clone2.Parent = workspace.Effects
				local sound = PeoUtils2.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://11084044757",
					Volume = 1,
					Name = "Sound"
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone2
				sound:Play()

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		end

		if not v35 then
			v35 = Instance.new("AlignPosition")
			v35.Name = "Swim"
			v35.ApplyAtCenterOfMass = true
			v35.MaxAxesForce = createVector(0, 1e999, 0)
			v35.Responsiveness = 65
			v35.ForceLimitMode = Enum.ForceLimitMode.PerAxis
			v35.Mode = Enum.PositionAlignmentMode.OneAttachment
			v35.Position = createVector(0, -4.5, 0)
			v35.Attachment0 = humanoidRootPart3:FindFirstChildOfClass("Attachment")
			v35.Parent = humanoidRootPart3
			v24 = -4.5
		end

		if not v36 then
			v36 = Instance.new("BodyGyro")
			v36.Name = "SwimGyro"
			v36.MaxTorque = createVector(10000000000, 10000000000, 0)
			v36.P = 12000
			v36.CFrame = CFrame.new(
				humanoidRootPart3.Position,
				humanoidRootPart3.Position + humanoidRootPart3.CFrame.LookVector * createVector(1, 0, 1)
			)
			v36.Parent = humanoidRootPart3
		end

		if not clone then
			clone = ReplicatedStorage.Chest.Etc.SwimmingPart:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart3.Position,
				humanoidRootPart3.Position + humanoidRootPart3.CFrame.LookVector * createVector(1, 0, 1)
			) + createVector(0, 0.25, 0)
			clone.Parent = workspace.Effects
		end

		if clone then
			clone.CFrame = CFrame.new(
				humanoidRootPart3.Position,
				humanoidRootPart3.Position + humanoidRootPart3.CFrame.LookVector * createVector(1, 0, 1)
			) + createVector(0, 0.25, 0)
		end

		local v37 = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
		local swimmingSound = humanoidRootPart3:FindFirstChild("SwimmingSound")

		if not swimmingSound then
			swimmingSound = PeoUtils2.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11085092673",
				Volume = 1,
				Name = "SwimmingSound"
			})
			swimmingSound.Parent = humanoidRootPart3
			swimmingSound:Play()
		end

		if (humanoid.MoveDirection * createVector(1, 0, 1)).Magnitude <= 0 then
			local _ = humanoidRootPart3.CFrame.LookVector * createVector(1, 0, 1)
		end

		if v37 <= 0 then
			if not track.IsPlaying then
				track:Play(0.2)
			end

			if track2.IsPlaying then
				track2:Stop(0.2)
			end

			if flag7 then
				flag7 = nil
				TweenService:Create(swimmingSound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
			end

			v24 = math.min(v24 + 0.15, -4.5)
			v36.CFrame = CFrame.new(
				humanoidRootPart3.Position,
				humanoidRootPart3.Position + humanoidRootPart3.CFrame.LookVector * createVector(1, 0, 1)
			)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter.Enabled then
					emitter.Enabled = nil
				end
			end
		elseif v37 > 0 then
			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
					continue
				end

				emitter.Enabled = true
			end

			if track.IsPlaying then
				track:Stop(0.2)
			end

			if not track2.IsPlaying then
				track2:Play(0.2)
			end

			if not swimmingSound.IsPlaying then
				swimmingSound:Play()
			end

			if not flag7 then
				flag7 = true
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(swimmingSound, TweenInfo.new(0.5), {
					Volume = 2
				}):Play()
			end

			if dot < -0.5 then
				v24 = math.max(v24 - 0.1, -20)
			elseif dot > 0.3 then
				v24 = math.min(v24 + 0.1, -4.5)
			end

			v36.CFrame = CFrame.new(
				humanoidRootPart3.Position,
				humanoidRootPart3.Position + humanoid.MoveDirection * createVector(1, 0, 1)
			) * CFrame.Angles(math.rad(dot * 45), 0, 0)
		end

		if not v35:GetAttribute("Jumping") then
			v35.Position = Vector3.new(0, math.clamp(v24, -30, -4.5), 0)
		end
	elseif humanoidRootPart3.Position.Y > -2.4 then
		if clone then
			clone:Destroy()
			clone = nil
		end

		if not flag11 then
			flag11 = true
		end

		task.spawn(function()
			local swim = humanoidRootPart3:FindFirstChild("Swim")
			local swimGyro = humanoidRootPart3:FindFirstChild("SwimGyro")

			if folder then
				folder:Destroy()
				folder = nil
			end

			if swim and not swim:GetAttribute("Jumping") then
				swim:Destroy()
			end

			if swimGyro then
				swimGyro:Destroy()
			end

			if track2.IsPlaying then
				track2:Stop(0.2)
			end

			if track.IsPlaying then
				track:Stop(0.2)
			end

			local swimmingSound = humanoidRootPart3:FindFirstChild("SwimmingSound")

			if swimmingSound then
				swimmingSound:Destroy()
			end
		end)
	end

	if seaFolder then
		local renderSea = seaFolder.RenderSea
		local transparency = math.clamp((currentCamera2.CFrame.Position.Y - renderSea.Position.Y) / 150, v34, 1)
		local transparency2 = math.clamp((currentCamera2.CFrame.Position.Y - renderSea.Position.Y) / 150, 0.95, 1)
		renderSea.Texture.Transparency = transparency

		if not currentCamera2:GetAttribute("RenderSea") then
			renderSea.Texture.OffsetStudsU = -humanoidRootPart3.Position.Z + math.sin(tick() / 15) * 95
			renderSea.Texture.OffsetStudsV = humanoidRootPart3.Position.X + math.sin(tick() / 15) * 95
			renderSea.Texture2.Transparency = transparency2
			renderSea.Texture2.OffsetStudsU = -humanoidRootPart3.Position.Z - math.sin(tick() / 15) * 50
			renderSea.Texture2.OffsetStudsV = humanoidRootPart3.Position.X - math.sin(tick() / 15) * 50
			renderSea.CFrame = CFrame.new(
				humanoidRootPart3.Position.X,
				renderSea.Position.Y,
				humanoidRootPart3.Position.Z
			) * CFrame.Angles(0, 0, 1.5707963267948966)
		end
	end

	for _, v35 in pairs(game.Players:GetPlayers()) do
		local playerStats2 = v35:FindFirstChild("PlayerStats")

		if not playerStats2 then
			continue
		end

		local character2 = v35.Character

		if not character2 then
			continue
		end

		local humanoidRootPart4 = character2:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart4 then
			continue
		end

		if (currentCamera2.CFrame.Position - humanoidRootPart4.Position).Magnitude > 1000 then
			if HighlightModule:Get(character2) then
				HighlightModule:Remove(character2)
			end
		else
			local haki = character2:FindFirstChild("Services") and character2.Services:FindFirstChild("Haki")

			if haki then
				if haki:FindFirstChild("ArmamentColor") then
					if haki.Value == 1 then
						if not HighlightModule:Get(character2) then
							local v36 = (playerStats2.FightingStyle.Value == "DarkLeg" or playerStats2.FightingStyle.Value == "Striker") and "Leg" or "Arm"
							local level = v35.Leveling.Armament:GetAttribute("Level") or 1
							local selectLevel = v35.Leveling.Armament:GetAttribute("SelectLevel") or level
							HighlightModule:Add(character2, ArmamentBodyLevel[v36][selectLevel], {
								Color = playerStats2.ArmamentColor,
								ColorName = playerStats2.ArmamentColor
							})
						end
					elseif HighlightModule:Get(character2) then
						HighlightModule:Remove(character2)
					end
				elseif HighlightModule:Get(character2) then
					HighlightModule:Remove(character2)
				end
			end
		end
	end

	HighlightModule:Update()
	local runSpeedClient = 16
	local jumpPower = 50
	local autoRotate = true
	mouse.TargetFilter = workspace.Effects
	local _ = mouse.Hit
	local UserInputService3 = game:GetService("UserInputService")
	local mouseLocation = UserInputService3:GetMouseLocation()
	local viewportPointToRay = currentCamera2:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local v37 = viewportPointToRay.Direction * 10000
	local raycastResult = workspace:Raycast(viewportPointToRay.Origin, v37, raycastParams2)
	local position = viewportPointToRay.Origin + v37

	if raycastResult then
		position = raycastResult.Position
	end

	local cframe = CFrame.new(position)

	if touchEnabled then
		_G.MouseHitMobileUpdate()
		cframe = _G.MouseHitMobile
	end

	_G.MouseHit = cframe

	if flag2 then
		if humanoidRootPart3.Position.Y > -2.5 then
			waterWave.CanCollide = true
		else
			waterWave.CanCollide = false
		end
	else
		waterWave.CanCollide = false
	end

	waterWave.Position = Vector3.new(humanoidRootPart3.Position.X, -3.5, humanoidRootPart3.Position.Z)
	sandWave.Position = Vector3.new(humanoidRootPart3.Position.X, -30, humanoidRootPart3.Position.Z)
	fakeSand.Position = Vector3.new(humanoidRootPart3.Position.X, -30, humanoidRootPart3.Position.Z)
	sea.Position = Vector3.new(humanoidRootPart3.Position.X, -3.35, humanoidRootPart3.Position.Z)

	if _G.Run then
		runSpeedClient = _G.RunSpeedClient
		jumpPower = 50
	end

	if _G.Run and characterUpgradeStats then
		runSpeedClient = _G.RunSpeedClient + characterUpgradeStats.Speed.Value
	end

	if character:FindFirstChild("Buddha") then
		if character.Buddha.Value then
			runSpeedClient += 50
			jumpPower = 120
		else
			jumpPower = 100
		end
	end

	if character:FindFirstChild("SpeedBoost") then
		runSpeedClient += runSpeedClient * 200 / 100
	end

	if character:FindFirstChild("Sprinter") then
		runSpeedClient += runSpeedClient * 400 / 100
	end

	if character:FindFirstChild("IFrame") then
		if not character:GetAttribute("IFrame") then
			character:SetAttribute("IFrame", true)
		end
	elseif character:GetAttribute("IFrame") then
		character:SetAttribute("IFrame", nil)
	end

	total = 20

	if _G.Run then
		task.spawn(function()
			if race == "Sky" and flag3 then
				jumpPower = 75
			end

			if race == "Mink" then
				if flag3 then
					if flag3 then
						runSpeedClient += 20
					end
				else
					runSpeedClient += 10
				end
			end

			if character:FindFirstChild("MammothModel") then
				runSpeedClient += 10
				jumpPower = 0
			elseif character:FindFirstChild("Wolf") then
				runSpeedClient += 25
				jumpPower = 50
			elseif character:FindFirstChild("Leopard") then
				runSpeedClient += 40
				jumpPower = 50
			elseif character:FindFirstChild("ToyTrex") then
				runSpeedClient += 65
				jumpPower = 110
			elseif character:FindFirstChild("Giraffe") then
				runSpeedClient += 20
				jumpPower = 75
			elseif character:FindFirstChild("ShadowBear") then
				runSpeedClient += 45
				jumpPower = 100
			elseif character:FindFirstChild("Spinosaurus") then
				runSpeedClient += 65
				jumpPower = 110
			elseif character:FindFirstChild("Allosaurus") then
				runSpeedClient += 45
				jumpPower = 110
			elseif character:FindFirstChild("Brachiosaurus") then
				runSpeedClient += 25
				jumpPower = 110
			elseif character:FindFirstChild("Tree_KL") then
				runSpeedClient += 90
				jumpPower = 110
			elseif character:FindFirstChild("Demon_KL") then
				runSpeedClient += 90
				jumpPower = 110
			end

			if _G.IsInSafezoneClient(humanoidRootPart3) then
				runSpeedClient /= 1.35
			end
		end)
	else
		task.spawn(function()
			if character:FindFirstChild("ToyTrex") then
				runSpeedClient += 20
				jumpPower = 110
			elseif character:FindFirstChild("Spinosaurus") then
				total += 40
				runSpeedClient += 40
				jumpPower = 110
			elseif character:FindFirstChild("Allosaurus") then
				total += 20
				runSpeedClient += 20
				jumpPower = 110
			elseif character:FindFirstChild("Brachiosaurus") then
				jumpPower = 110
			elseif character:FindFirstChild("Tree_KL") then
				total += 20
				runSpeedClient += 20
				jumpPower = 110
			elseif character:FindFirstChild("Demon_KL") then
				total += 20
				runSpeedClient += 20
				jumpPower = 110
			end
		end)
	end

	if character:FindFirstChild("FasterSpeed") then
		runSpeedClient += 15
	end

	if character:FindFirstChild("AngelGrace_Heal") then
		runSpeedClient += 25
	end

	if character:FindFirstChild("AngelGrace_Damage") then
		runSpeedClient += 35
	end

	if character:FindFirstChild("WolfBerserk") then
		runSpeedClient += 40
	end

	if humanoidRootPart3.Position.Y <= -3.5 and humanoidRootPart3:FindFirstChild("Swim") then
		if race == "Fish" then
			if flag3 then
				if flag3 then
					runSpeedClient += 85
				end
			else
				runSpeedClient += 60
			end

			if character:GetAttribute("FishAwakenV3") then
				runSpeedClient += 50
			end
		elseif race == "Sea Beast" then
			if flag3 then
				if flag3 then
					runSpeedClient += 90
				end
			else
				runSpeedClient += 65
			end

			if character:GetAttribute("SeaBeastAwakenV3") then
				runSpeedClient += 50
			end
		elseif playerStats.Accessory.Value == "Bullitus" then
			runSpeedClient = 40
		elseif _G.Run then
			runSpeedClient = 16
		else
			runSpeedClient = 8
		end

		autoRotate = false
	end

	if character:GetAttribute("MinkAwakenV3") then
		runSpeedClient += 150
	end

	if character:GetAttribute("DemonAwakenV3") and CheckDayNight() == "Night" then
		runSpeedClient += 15
	end

	if (_G.CheckDoingClient(localPlayer2) or _G.CheckStunClient(localPlayer2)) and not character:GetAttribute("MovingSkill") then
		autoRotate = false
	end

	if character:FindFirstChild("Slow") or flag then
		runSpeedClient = 7
		jumpPower = 0
	end

	if character:FindFirstChild("onQuest") then
		runSpeedClient = 6
		jumpPower = 20
	end

	if _G.NPCTalk then
		runSpeedClient = 0
		jumpPower = 0
	end

	if character:FindFirstChild("NoJump") then
		if humanoid.Sit then
			humanoid.Jump = true
		end

		jumpPower = 0
	end

	if _G.CheckDoingClient(localPlayer2) then
		jumpPower = humanoidRootPart3.Position.Y >= -3.5 and 0 or jumpPower
	end

	if workspace:FindFirstChild("Played") and v29 and not localPlayer2.PlayerGui:FindFirstChild("LeePunggLetterBox") then
		local played = workspace.Played
		v29 = nil
		task.spawn(function()
			local clone2 = ReplicatedStorage.Chest.Gui.LeePunggLetterBox:Clone()
			clone2.Parent = localPlayer2.PlayerGui
			local Animated = require(clone2.Animated)
			Animated()
			task.wait(1)
			local currentCamera3 = workspace.CurrentCamera

			if currentCamera3.CameraType == Enum.CameraType.Scriptable then
				currentCamera3.CFrame = character:GetPrimaryPartCFrame() * CFrame.new(0, 3, 5)
				currentCamera3.CameraType = "Custom"
				_G.PU:Dust(played, 0.15)
				_G.PU:Dust(clone2, 0.15)

				for _, folder2 in pairs(workspace:GetChildren()) do
					if folder2:IsA("Folder") and folder2.Name == "Played" then
						folder2:Destroy()
					end
				end

				for _, child2 in pairs(localPlayer2.PlayerGui:GetChildren()) do
					if child2.Name == "LeePunggLetterBox" then
						child2:Destroy()
					end
				end

				v29 = true
				_G.NPCTalk = false
			end
		end)
	end

	task.spawn(function()
		if flag8 then
			flag8 = nil
			wait(1)
			flag8 = true
		end
	end)

	if character:FindFirstChild("NoRotate") then
		autoRotate = false
	end

	if character:FindFirstChild("Comboing") then
		autoRotate = false
		jumpPower = 0
		runSpeedClient = 0
	end

	if character:FindFirstChild("NoMove") then
		jumpPower = 0
		runSpeedClient = 0
		humanoidRootPart3.Velocity = createVector(0, 0, 0)
	end

	if character:FindFirstChild("ToyTrex") then
		jumpPower = character:GetAttribute("IgnoreDash") and 110 or jumpPower
	end

	if humanoid:GetAttribute("CustomRotate") ~= autoRotate then
		humanoid:SetAttribute("CustomRotate", autoRotate)
	end

	if character:GetAttribute("MouseLockOn") then
		humanoid.AutoRotate = false
	else
		humanoid.AutoRotate = autoRotate
	end

	humanoid.WalkSpeed = runSpeedClient
	humanoid.JumpPower = jumpPower
	local flying = humanoidRootPart3:FindFirstChild("Flying") or character:FindFirstChild("LowerTorso") and character.LowerTorso:FindFirstChild("Flying")
	local flyingGyro = humanoidRootPart3:FindFirstChild("FlyingGyro")
	local flyingBP = humanoidRootPart3:FindFirstChild("FlyingBP")
	local v38 = math.clamp(v31 * (humanoid.Health / humanoid.MaxHealth), 100, v32)

	if character:FindFirstChild("Phoenix_Model") or character:FindFirstChild("Snow_Wing") then
		v30 = 75
		v32 = 150
	elseif character:FindFirstChild("Pteranodon_KL") then
		v30 = 75
		v32 = 150
	elseif character:FindFirstChild("Telekinesis_Model") or character:FindFirstChild("Gas_Model") then
		v30 = 75
		v32 = 150
	else
		v30 = 125
		v32 = 250
	end

	if character:GetAttribute("SpeedLine", true) and not flying then
		DragonFlyingStop()
	end

	if flying and flyingGyro then
		local maxForce = createVector(0, 0, 0)
		local v39 = "MaxForce"

		if flying.ClassName == "BodyVelocity" then
			maxForce = flying.MaxForce
		elseif flying.ClassName == "LinearVelocity" then
			maxForce = flying.MaxAxesForce
			v39 = "MaxAxesForce"
		end

		local moveDirection = humanoid.MoveDirection

		if not character:GetAttribute("CustomFlyingMoving") then
			if moveDirection.Magnitude == 0 then
				DragonFlyingStop({
					Flying = flying,
					FlyingGyro = flyingGyro
				})
			else
				local function DragonMoving(_)
					if flag9 then
						if flag9 then
							if v31 < v32 then
								v31 += 0.3
							else
								v31 = v32
							end

							v38 = math.clamp(v31 * (humanoid.Health / humanoid.MaxHealth), v30, v32)
						end
					else
						flag9 = true
						v38 = math.clamp(v31 * (humanoid.Health / humanoid.MaxHealth), v30, v32)
					end

					if v32 <= v38 and not character:GetAttribute("SpeedLine") then
						character:SetAttribute("SpeedLine", true)
					end

					local v40 = (currentCamera2.CFrame * CFrame.new((CFrame.new(
						currentCamera2.CFrame.p,
						currentCamera2.CFrame.p + Vector3.new(
							currentCamera2.CFrame.lookVector.x,
							0,
							currentCamera2.CFrame.lookVector.z
						)
					):VectorToObjectSpace(humanoid.MoveDirection)))).p - currentCamera2.CFrame.p
					local unit = v40.Unit

					if flyingBP and flyingBP.Parent then
						local raycastResult2 = workspace:Raycast(
							humanoidRootPart3.Position,
							createVector(0, -15, 0),
							raycastParams
						)
						local v41 = humanoidRootPart3.Position + createVector(0, -15, 0)

						if raycastResult2 and unit.Y < 0 then
							local position2 = raycastResult2.Position
							flying[v39] = Vector3.new(maxForce.X, 0, maxForce.Z)
							flyingBP.MaxForce = createVector(0, 10000000, 0)
							flyingBP.Position = Vector3.new(0, position2.Y + 14, 0)
							unit *= createVector(1, 0, 1)
						elseif v41.Y < -3.35 and unit.Y < 0 then
							flying[v39] = Vector3.new(maxForce.X, 0, maxForce.Z)
							flyingBP.MaxForce = createVector(0, 10000000, 0)
							flyingBP.Position = createVector(0, 14, 0)
							unit *= createVector(1, 0, 1)
						else
							flying[v39] = Vector3.new(maxForce.X, maxForce.X, maxForce.Z)
							flyingBP.MaxForce = createVector(0, 0, 0)
						end
					end

					flying[v39] = Vector3.new(maxForce.X, maxForce.X, maxForce.Z)
					local v41 = unit * (v38 + (character:GetAttribute("FlyBoost") or 0))

					if flying.ClassName == "BodyVelocity" then
						flying.Velocity = v41
					elseif flying.ClassName == "LinearVelocity" then
						flying.VectorVelocity = v41
					end

					local cframe2 = CFrame.new(currentCamera2.CFrame.Position, currentCamera2.CFrame.Position + v40) * CFrame.Angles(
						0,
						0,
						0
					)

					if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
						cframe2 = CFrame.new(
							currentCamera2.CFrame.Position,
							currentCamera2.CFrame.Position + currentCamera2.CFrame.LookVector
						)
					end

					flyingGyro.CFrame = cframe2
					humanoidRootPart3.AssemblyAngularVelocity = createVector(0, 0, 0)
				end

				if _G.CheckDoingClient(localPlayer2) or _G.CheckStunClient(localPlayer2) or _G.NPCTalk then
					if character:GetAttribute("MovingSkill") then
						DragonMoving()
					else
						DragonFlyingStop()

						if flying.ClassName == "BodyVelocity" then
							flying.Velocity = Vector3.new()
						elseif flying.ClassName == "LinearVelocity" then
							flying.VectorVelocity = Vector3.new()
						end

						flyingGyro.CFrame = CFrame.new(humanoidRootPart3.Position, _G.MouseHit.p)
					end
				else
					DragonMoving()
				end
			end
		end
	end

	if character:FindFirstChild("SpiritFolder") then
		task.spawn(function()
			local _ = character.SpiritFolder
			local child2 = workspace.Effects:FindFirstChild("SunPet " .. localPlayer2.Name)
			local child3 = workspace.Effects:FindFirstChild("CloudPet " .. localPlayer2.Name)

			if child2 and child2:FindFirstChild("RootPart") and child2.RootPart:FindFirstChild("BodyPosition") and child2.RootPart:FindFirstChild("BodyGyro") and not _G.SunCUsing then
				child2.RootPart.BodyPosition.Position = (humanoidRootPart3.CFrame * CFrame.new(-6.5, 0, 2)).Position
				child2.RootPart.BodyGyro.CFrame = humanoidRootPart3.CFrame
			end

			if child3 and child3:FindFirstChild("RootPart") and child3.RootPart:FindFirstChild("BodyPosition") and child3.RootPart:FindFirstChild("BodyGyro") and not _G.CloudXUsing then
				child3.RootPart.BodyPosition.Position = (humanoidRootPart3.CFrame * CFrame.new(7, 3, 2)).Position
				child3.RootPart.BodyGyro.CFrame = humanoidRootPart3.CFrame
			end
		end)
	end

	if character:FindFirstChild("PrototypeFolder") then
		task.spawn(function()
			local child2 = workspace.Effects:FindFirstChild("Prototype " .. localPlayer2.Name)

			if child2 and child2:FindFirstChild("RootPart") and child2.RootPart:FindFirstChild("BodyPosition") and child2.RootPart:FindFirstChild("BodyGyro") then
				local position2 = (humanoidRootPart3.CFrame * child2.RootPart.Controller.Value * CFrame.new(-4, 0, 0)).Position

				if child2.RootPart.Controller.Value == CFrame.new(0, 0, 0) then
					position2 += Vector3.new(0, math.sin(tick() * 1.75), 0)
				end

				child2.RootPart.BodyPosition.Position = position2
				child2.RootPart.BodyGyro.CFrame = humanoidRootPart3.CFrame
			end
		end)
	end

	WindModule:Update(dt)
end)
ReplicatedStorage.Chest.Remotes.Events.InvisibleArmamentNeon.OnClientEvent:Connect(function(p)
	local targetCharacter = p.TargetCharacter

	if not targetCharacter then
		return
	end

	local invisible = p.Invisible

	if invisible then
		task.delay(0.01, function()
			if _G.AntiMobShowRace(targetCharacter) then
				ClearRaceCaches()
			end
		end)
	end

	local child = workspace.CharacterWorkshop:FindFirstChild(targetCharacter.Name .. "'s Outline")

	if not child then
		return
	end

	if targetCharacter then
		if invisible then
			for _, part in pairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end
		else
			for _, part in pairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 0
				end
			end
		end
	end
end)
ReplicatedStorage.Chest.Animation:WaitForChild("CustomAnimations")
local customAnimations = ReplicatedStorage.Chest.Animation.CustomAnimations

repeat
	wait(0.1)
until customAnimations:FindFirstChild("Standard")

local animation = localPlayer2.PlayerStats.Animation
local track4 = GetAnimator():LoadAnimation(customAnimations[animation.Value].WalkAnim)
local track5 = GetAnimator():LoadAnimation(customAnimations[animation.Value].RunAnim)
local track6 = GetAnimator():LoadAnimation(customAnimations[animation.Value].IdleAnim)
local track7 = GetAnimator():LoadAnimation(customAnimations[animation.Value].JumpAnim)
local track8 = GetAnimator():LoadAnimation(customAnimations[animation.Value].FallAnim)
local track9 = GetAnimator():LoadAnimation(customAnimations[animation.Value].LandedAnim)
local track10 = GetAnimator():LoadAnimation(customAnimations[animation.Value].SitAnim)
local track11 = GetAnimator():LoadAnimation(customAnimations[animation.Value].ClimbAnim)
local track12 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.MountAnimation)
track4.Priority = Enum.AnimationPriority.Core
track5.Priority = Enum.AnimationPriority.Core
track6.Priority = Enum.AnimationPriority.Core
track7.Priority = Enum.AnimationPriority.Core
track8.Priority = Enum.AnimationPriority.Core
track10.Priority = Enum.AnimationPriority.Core
track9.Priority = Enum.AnimationPriority.Movement
local v34 = 0
local v35 = "Idle"
local v36 = nil
local lastTime6 = tick()
local lastTime7 = tick()
local name = nil
local v37 = { "IdleAnim", "RunAnim", "WalkAnim" }

function CheckCustomWepAnim(instance)
	for _, attributeName in pairs(v37) do
		if instance:GetAttribute(attributeName) then
			return true
		end
	end
end

local track13 = nil
local track14 = nil
local connections = {}

function ClearAnimationEvents()
	for _, connection in pairs(connections) do
		if typeof(connection) == "RBXScriptConnection" and connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(connections)
end

function UpdateNewAnim(instance)
	if instance.Name == "Buddha" and instance.Parent then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		return
	end

	if instance.Name == "Buddha" and not instance.Parent then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		return
	end

	if _G.AntiMobSkill() then
		if humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated) then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		end
	elseif not humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated) then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
	end

	local tool = character:FindFirstChildOfClass("Tool")
	local toyTrex = character:FindFirstChild("ToyTrex") or character:FindFirstChild("Rubber Third Form") or character:FindFirstChild("Spinosaurus") or character:FindFirstChild("Allosaurus") or character:FindFirstChild("Brachiosaurus") or character:FindFirstChild("Tree_KL") or character:FindFirstChild("Demon_KL")

	if not (tool or humanoid.Sit or character:GetAttribute("Mounting")) then
		for _, v38 in pairs(humanoid:GetPlayingAnimationTracks()) do
			if v38.Name == "Animation" then
				v38:Stop()
			elseif v7[v38.Name] then
				v38:Stop()
			end
		end
	end

	if tool and tool:GetAttribute("CustomAnim") and not toyTrex then
		for _, v38 in pairs(humanoid:GetPlayingAnimationTracks()) do
			if v38.Name == "PhoenixFullIdle" then
				v38:Stop()
			end
		end

		if character:FindFirstChild("AnimationScript") then
			return
		end

		if name ~= tool.Name and tool:GetAttribute("CustomAnim") then
			name = tool.Name
			local customWeaponAnim = ReplicatedStorage.Chest.Animation.CustomWeaponAnims[tool:GetAttribute("CustomAnim")]
			ClearAnimationEvents()

			if v36 then
				v36:Stop()
				v36 = nil
			end

			if track13 then
				track13:Stop()
				track13 = nil
			end

			if ReplicatedStorage.Chest.Animation.CustomWeaponAnims[tool:GetAttribute("CustomAnim")]:GetAttribute("CustomDash") then
				character:SetAttribute("CustomDash", tool:GetAttribute("CustomAnim"))
			end

			if customWeaponAnim:FindFirstChild("JumpAnim") then
				track7 = GetAnimator():LoadAnimation(customWeaponAnim.JumpAnim)
				track7.Priority = Enum.AnimationPriority.Core
			end

			if customWeaponAnim:FindFirstChild("FallAnim") then
				track8 = GetAnimator():LoadAnimation(customWeaponAnim.FallAnim)
				track8.Priority = Enum.AnimationPriority.Core
			end

			if customWeaponAnim:FindFirstChild("LandedAnim") then
				track9 = GetAnimator():LoadAnimation(customWeaponAnim.LandedAnim)
				track4.Priority = Enum.AnimationPriority.Movement
			end

			track4 = GetAnimator():LoadAnimation(customWeaponAnim.WalkAnim)
			track6 = GetAnimator():LoadAnimation(customWeaponAnim.IdleAnim)
			track5 = GetAnimator():LoadAnimation(customWeaponAnim.RunAnim)
			track4.Priority = Enum.AnimationPriority.Core
			track6.Priority = Enum.AnimationPriority.Core
			track5.Priority = Enum.AnimationPriority.Core
			wait()
			UpdateAnimation()
		end
	elseif toyTrex then
		if name ~= toyTrex.Name then
			name = toyTrex.Name

			if track13 then
				track13:Stop()
				track13 = nil
			end

			ClearAnimationEvents()

			if v36 then
				v36:Stop()
				v36 = nil
			end

			character:SetAttribute("CustomDash", nil)
			local name2 = toyTrex.Name

			if name2 == "Rubber Third Form" then
				track4 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.Rubber.Walk)
				track5 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.Rubber.Run)
				track6 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.Rubber.Idle)
			else
				track4 = GetAnimator():LoadAnimation(script.CustomAnimations[toyTrex.Name].Walk)
				track5 = GetAnimator():LoadAnimation(script.CustomAnimations[toyTrex.Name].Run)
				track6 = GetAnimator():LoadAnimation(script.CustomAnimations[toyTrex.Name].Idle)
				track7 = GetAnimator():LoadAnimation(script.CustomAnimations[toyTrex.Name].Jump)
				track8 = GetAnimator():LoadAnimation(script.CustomAnimations[toyTrex.Name].Fall)

				if script.CustomAnimations[toyTrex.Name]:FindFirstChild("Landed") then
					track9 = GetAnimator():LoadAnimation(script.CustomAnimations[toyTrex.Name].Landed)
				end

				track4.Priority = Enum.AnimationPriority.Core
				track5.Priority = Enum.AnimationPriority.Core
				track6.Priority = Enum.AnimationPriority.Core
				track7.Priority = Enum.AnimationPriority.Core
				track8.Priority = Enum.AnimationPriority.Core
				track4.Priority = Enum.AnimationPriority.Core
				track6.Priority = Enum.AnimationPriority.Core
				track5.Priority = Enum.AnimationPriority.Core

				if name2 == "Allosaurus" or name2 == "Spinosaurus" or name2 == "Brachiosaurus" then
					local function AllosaurFootstep(p)
						if p ~= "Footstep" then
							return
						end

						local sound = PeoUtils.CreateSound({
							RollOffMaxDistance = 150,
							RollOffMinDistance = 25,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://136465486548292",
							PlaybackSpeed = 1.25,
							Volume = 0.01
						})
						sound.Parent = humanoidRootPart3
						sound:Play()
						PeoUtils:Dust(sound, 1)
					end

					table.insert(connections, track4.KeyframeReached:Connect(AllosaurFootstep))
					table.insert(connections, track5.KeyframeReached:Connect(AllosaurFootstep))
				end
			end

			wait()
			UpdateAnimation()
		end
	elseif tool and tool:GetAttribute("LegacyFruit") then
		if track13 then
			track13:Stop()
			track13 = nil
		end

		track13 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.FruitHandling)
		track13.Priority = Enum.AnimationPriority.Movement
		track13:Play()
	elseif tool and tool:GetAttribute("Fish") then
		if track14 then
			track14:Stop()
			track14 = nil
		end

		local v38 = MaterialList[tool.Name]

		if v38 and v38.Fish and v38.FishSize then
			track14 = GetAnimator():LoadAnimation(ReplicatedStorage.Chest.Animation.HoldingFishAnims[v38.FishSize])
			track14:Play()

			if v38.FishSize == "XL" then
				flag = true
			end
		end
	else
		if track13 then
			track13:Stop()
			track13 = nil
		end

		if track14 then
			track14:Stop()
			track14 = nil
		end

		if flag then
			flag = nil
		end

		if name then
			name = nil

			if v36 then
				v36:Stop()
				v36 = nil
			end

			character:SetAttribute("CustomDash", nil)
			track4 = GetAnimator():LoadAnimation(customAnimations[animation.Value].WalkAnim)
			track5 = GetAnimator():LoadAnimation(customAnimations[animation.Value].RunAnim)
			track6 = GetAnimator():LoadAnimation(customAnimations[animation.Value].IdleAnim)
			track7 = GetAnimator():LoadAnimation(customAnimations[animation.Value].JumpAnim)
			track8 = GetAnimator():LoadAnimation(customAnimations[animation.Value].FallAnim)
			track9 = GetAnimator():LoadAnimation(customAnimations[animation.Value].LandedAnim)
			track4.Priority = Enum.AnimationPriority.Core
			track5.Priority = Enum.AnimationPriority.Core
			track6.Priority = Enum.AnimationPriority.Core
			track7.Priority = Enum.AnimationPriority.Core
			track8.Priority = Enum.AnimationPriority.Core
			wait()
			UpdateAnimation()
		end
	end
end

character.ChildAdded:Connect(UpdateNewAnim)
character.ChildRemoved:Connect(UpdateNewAnim)

function SetPoseAnimationSpeed(p)
	if not (v35 == "Climbing" and v36) then
		return
	end

	if p == 0 then
		v36:AdjustSpeed(0)
		return
	end

	local v38 = p < 0 and -1 or 1
	v36:AdjustSpeed(v38)
end

function OnClimbing(p)
	v35 = "Climbing"
	PlayAnimation("Climbing", 0.25, 1)
	SetPoseAnimationSpeed(p)
end

function OnRunning(p)
	local v38 = (humanoid.MoveDirection * createVector(1, 0, 1)).Magnitude * p

	if (v38 or p) > 0 and (v38 or p) < total then
		v35 = "Walking"
		PlayAnimation("Walking", 0.25, 1.4)
	elseif (v38 or p) > 0 and total <= (v38 or p) then
		v35 = "Running"
		PlayAnimation("Running", 0.25, 1.17)
	elseif (v38 or p) <= 0 then
		v35 = "Idle"
		PlayAnimation("Idle", 0.25, 1)
	end
end

function OnJumping()
	v35 = "Jumping"

	if track9.IsPlaying then
		track9:Stop()
	end

	v34 = 0.31
	PlayAnimation("Jumping", 0.25, 1)
end

function OnFreeFall()
	if v34 <= 0 then
		PlayAnimation("FreeFalling", 0.35, 1)
	end

	v35 = "FreeFalling"
end

local v38 = nil

function OnSeated(p)
	if p then
		local seatPart = humanoid.SeatPart

		if seatPart and seatPart:IsA("VehicleSeat") then
			return
		end

		PlayAnimation("Seating", 0.1, 1)
		v35 = "Seating"
	elseif v38 then
		v38:Stop()
		v38 = nil
	end
end

function GetAnimationTrack(p)
	if p == "Idle" then
		return track6
	end

	if p == "Seating" then
		if character:GetAttribute("Mounting") then
			return track12
		end

		return track10
	elseif p == "Walking" then
		return track4
	elseif p == "Running" then
		return track5
	elseif p == "Jumping" then
		return track7
	elseif p == "Climbing" then
		return track11
	elseif p == "FreeFalling" then
		return track8
	end
end

function PlayAnimation(p, p2, p3)
	local v39 = GetAnimationTrack(p)

	if v36 == v39 then
		if v36 == v39 then
			if v36 and not v36.IsPlaying then
				v36:Play()
			end

			if v36 and (p == "Walking" or p == "Running") then
				local v40 = 16

				if p == "Running" then
					local v41 = character:FindFirstChild("Leopard") and 60 or character:FindFirstChild("Tree_KL") and 128 or character:FindFirstChild("Demon_KL") and 128 or 30
					v40 = (character:FindFirstChild("ToyTrex") or character:FindFirstChild("Spinosaurus") or character:FindFirstChild("Allosaurus") or character:FindFirstChild("Brachiosaurus")) and 70 or v41
				elseif p == "Walking" then
					if character:FindFirstChild("ToyTrex") then
						v40 = 60
					elseif character:FindFirstChild("Spinosaurus") then
						v40 = 50
					elseif character:FindFirstChild("Allosaurus") then
						v40 = 40
					elseif character:FindFirstChild("Tree_KL") then
						v40 = 40
					elseif character:FindFirstChild("Demon_KL") then
						v40 = 40
					else
						v40 = v40
					end
				end

				local v41 = character:FindFirstChild("Buddha") and 0.35 or 4
				v36:AdjustSpeed((math.min(humanoid.WalkSpeed / v40, v41)))
			end
		end
	else
		if v36 then
			v36:Stop(p2)
		end

		v36 = v39
		v36:Play()
		v36:AdjustSpeed(p3)
	end
end

function UpdateAnimation()
	if v34 > 0 then
		v34 -= tick() - lastTime6
	end

	lastTime6 = tick()

	if v35 == "Idle" then
		PlayAnimation("Idle", 0.25, 1)
	elseif v35 == "Walking" then
		PlayAnimation("Walking", 0.25, 1.4)
	elseif v35 == "Running" then
		PlayAnimation("Running", 0.25, 1.17)
	elseif v35 == "FreeFalling" and v34 <= 0 then
		PlayAnimation("FreeFalling", 0.35, 1)
	elseif v35 == "Seating" and (humanoid.SeatPart or character:GetAttribute("Mounting")) then
		PlayAnimation("Seating", 0.1, 1)
	end
end

function StopAllAnims()
	track4:Stop()
	track5:Stop()
	track6:Stop()
	track7:Stop()
	track8:Stop()
	track4 = GetAnimator():LoadAnimation(customAnimations[animation.Value].WalkAnim)
	track5 = GetAnimator():LoadAnimation(customAnimations[animation.Value].RunAnim)
	track6 = GetAnimator():LoadAnimation(customAnimations[animation.Value].IdleAnim)
	track7 = GetAnimator():LoadAnimation(customAnimations[animation.Value].JumpAnim)
	track8 = GetAnimator():LoadAnimation(customAnimations[animation.Value].FallAnim)
	track9 = GetAnimator():LoadAnimation(customAnimations[animation.Value].LandedAnim)
	track4.Priority = Enum.AnimationPriority.Core
	track5.Priority = Enum.AnimationPriority.Core
	track6.Priority = Enum.AnimationPriority.Core
	track7.Priority = Enum.AnimationPriority.Core
	track8.Priority = Enum.AnimationPriority.Core
	track9.Priority = Enum.AnimationPriority.Movement
	OnRunning(humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed)
end

humanoid.Running:Connect(OnRunning)
humanoid.Jumping:Connect(OnJumping)
humanoid.FreeFalling:Connect(OnFreeFall)
humanoid.Seated:Connect(OnSeated)
humanoid.Climbing:Connect(OnClimbing)
humanoid.StateChanged:Connect(function(_, p)
	if p == Enum.HumanoidStateType.Landed then
		if tick() - lastTime7 > 1 then
			track9:Play()
			task.spawn(function()
				local position = humanoidRootPart3.Position
				local v39 = humanoidRootPart3.Position * createVector(0, -5, 0)
				local raycastParams3 = RaycastParams.new()
				raycastParams3.FilterDescendantsInstances = { workspace.Island, workspace.Ships }
				raycastParams3.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(position, v39, raycastParams3)

				if raycastResult and raycastResult.Instance then
					local v40

					if character:FindFirstChild("Allosaurus") or character:FindFirstChild("Tree_KL") or character:FindFirstChild("Demon_KL") then
						v40 = 5
					elseif character:FindFirstChild("Spinosaurus") then
						v40 = 10
					elseif character:FindFirstChild("Brachiosaurus") then
						v40 = 12.5
					else
						v40 = 1
					end

					local clone2 = ReplicatedStorage.Chest.Etc.SmokeLanding:Clone()

					if v40 > 1 then
						clone2:ScaleTo(v40)
					end

					clone2:PivotTo(CFrame.new(raycastResult.Position + raycastResult.Normal, raycastResult.Position) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0))
					clone2.Parent = workspace.Effects

					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					_G.PU:Dust(clone2, 2)
				end

				wait(0.27)
				track9:Stop(0.3)
			end)
		end
	elseif p == Enum.HumanoidStateType.Freefall then
		lastTime7 = tick()
	end
end)
playerStats.Animation.Changed:Connect(function()
	wait()
	StopAllAnims()
end)

while character.Parent do
	UpdateAnimation()
	task.wait(0.1)
end