local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local module = require("./Items/GliderController")
local module2 = require("./SettingsController")
local remoteFunction = Net:RemoteFunction("TimeTrials/Request")
local remoteEvent = Net:RemoteEvent("TimeTrials/Unload")
local remoteEvent2 = Net:RemoteEvent("TimeTrials/End")
local timeTrials = workspace:WaitForChild("TimeTrials", 1e999)
local TimeTrialController = {
	ActiveTrialName = nil,
	ActiveTrialStreamed = nil,
	ActiveTrialFolder = nil,
	ActiveTrialTimer = 0,
	PlayingMusic = nil
}

function TimeTrialController.Start(_)
	for _, moduleScript in script.Components:GetChildren() do
		require(moduleScript)
	end

	RunService.Heartbeat:Connect(function(dt)
		if not TimeTrialController.ActiveTrialFolder or localPlayer.GameplayPaused then
			return
		end

		local startZone = TimeTrialController.ActiveTrialFolder:FindFirstChild("StartZone")

		if startZone and localPlayer.Character and localPlayer:DistanceFromCharacter(startZone.Position) < startZone.Size.X / 2 then
			return
		end

		local endZone = TimeTrialController.ActiveTrialFolder:FindFirstChild("EndZone")

		if module:IsInAir() then
			TimeTrialController.ActiveTrialTimer += dt
		else
			local v

			if endZone and localPlayer.Character and localPlayer:DistanceFromCharacter(endZone.Position) < endZone.Size.X then
				v = not endZone:GetAttribute("RequireSection") or TimeTrialController:IsSectionLoaded(endZone:GetAttribute("RequireSection"))
			else
				v = false
			end

			print("Trial ended: Player touched the ground")
			TimeTrialController:EndTrial(TimeTrialController.ActiveTrialName, v)

			if v then
				module:UnequipGlider()
				local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				end

				local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")

				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end
	end)
end

function TimeTrialController.StartTrial(_, activeTrialName: string)
	local child = timeTrials:FindFirstChild(activeTrialName)

	if not child then
		warn((`Unknown TimeTrial "{activeTrialName}"`))
		return
	end

	if TimeTrialController.ActiveTrialName then
		print("a trial is already active")
		return
	end

	TimeTrialController.ActiveTrialName = activeTrialName
	TimeTrialController.ActiveTrialFolder = child
	TimeTrialController.ActiveTrialTimer = 0

	if child:FindFirstChild("LoadedSections") then
		child:FindFirstChild("LoadedSections"):ClearAllChildren()
	end

	if remoteFunction:InvokeServer(activeTrialName) then
		if not TimeTrialController.ActiveTrialName then
			print("cancel")
			return
		end

		local clone = child:WaitForChild("StreamSections"):Clone()
		remoteEvent:FireServer(activeTrialName)
		TimeTrialController.ActiveTrialStreamed = clone
		clone:PivotTo(CFrame.identity)

		for _, descendant in clone:GetDescendants() do
			if not descendant:GetAttribute("_TrialTags") then
				continue
			end

			for _, tag in descendant:GetAttribute("_TrialTags"):split(";;") do
				descendant:AddTag(tag)
			end
		end

		TimeTrialController:LoadSection("1")
		print("loaded trial", activeTrialName)
	else
		TimeTrialController.ActiveTrialName = nil
		TimeTrialController.ActiveTrialFolder = nil
		print("loading rejected by server")
	end
end

function TimeTrialController:LoadSection(childName: string)
	if not TimeTrialController.ActiveTrialStreamed then
		warn("Attempt to load trial section with no active trial:", childName)
		return
	end

	local child = TimeTrialController.ActiveTrialStreamed:FindFirstChild(childName)

	if child then
		child.Parent = TimeTrialController.ActiveTrialFolder:FindFirstChild("LoadedSections")

		if child:GetAttribute("Music") then
			local child2 = ReplicatedStorage.resources.sounds.music:WaitForChild(child:GetAttribute("Music"))

			if child2 ~= TimeTrialController.PlayingMusic then
				TweenService:Create(game.SoundService.music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Volume = 0
				}):Play()
				child2.Volume = 0
				child2:Play()

				if TimeTrialController.PlayingMusic then
					TweenService:Create(TimeTrialController.PlayingMusic, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						Volume = 0,
						Playing = false
					}):Play()
					child2.TimePosition = TimeTrialController.PlayingMusic.TimePosition
				end

				TweenService:Create(child2, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Volume = 0.4
				}):Play()
				TimeTrialController.PlayingMusic = child2
			end
		end
	end
end

function TimeTrialController:IsSectionLoaded(childName: string)
	if not TimeTrialController.ActiveTrialFolder then
		return false
	end

	local loadedSections = TimeTrialController.ActiveTrialFolder:FindFirstChild("LoadedSections")

	if loadedSections and loadedSections:FindFirstChild(childName) then
		return true
	end

	return false
end

function TimeTrialController:EndTrial(p: string, flag: boolean)
	if TimeTrialController.ActiveTrialName ~= p then
		print("cant end trial", TimeTrialController.ActiveTrialStreamed, TimeTrialController.ActiveTrialName)
		return
	end

	if not TimeTrialController.ActiveTrialStreamed then
		flag = false
	end

	local loadedSections = TimeTrialController.ActiveTrialFolder and TimeTrialController.ActiveTrialFolder:FindFirstChild("LoadedSections")

	if loadedSections then
		loadedSections:ClearAllChildren()
	end

	if TimeTrialController.ActiveTrialStreamed then
		TimeTrialController.ActiveTrialStreamed:Destroy()
		TimeTrialController.ActiveTrialStreamed = nil
	end

	TimeTrialController.ActiveTrialName = nil
	TimeTrialController.ActiveTrialFolder = nil

	if flag then
		ReplicatedStorage.events.anno_localthought:Fire((`Challenge complete! ({math.round(TimeTrialController.ActiveTrialTimer * 100) / 100} seconds)`))
	end

	if TimeTrialController.PlayingMusic then
		TweenService:Create(game.SoundService.music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = game.SoundService.music:GetAttribute("DefaultVolume") * (module2:GetSettingValue("musicVolume") / 100)
		}):Play()
		TweenService:Create(TimeTrialController.PlayingMusic, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0,
			Playing = false
		}):Play()
		TimeTrialController.PlayingMusic = nil
	end

	remoteEvent2:FireServer(p, flag, TimeTrialController.ActiveTrialTimer)
	TimeTrialController.ActiveTrialTimer = 0
end

return TimeTrialController