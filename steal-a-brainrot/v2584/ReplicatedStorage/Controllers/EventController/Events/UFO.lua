local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Lighting")
require(ReplicatedStorage.Shared.EventTypes)
local Net = require(ReplicatedStorage.Packages.Net)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local UFO = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Shared.VFX)
local UFO2 = ReplicatedStorage.Models.Events.UFO.UFO
local remoteEvent = Net:RemoteEvent("EventService/UFO/AbductionBurst")
local remoteEvent2 = Net:RemoteEvent("EventService/UFO/Spawned")
local maid = Trove.new()

local function playUFOSpawnFX()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 10000
	screenGui.Name = "UFO_SpawnFlash"
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	screenGui.Parent = playerGui
	local tween = CreateTween(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.4
	}, false)
	local tween2 = CreateTween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	}, false)
	tween:Play()
	tween.Completed:Once(function()
		tween2:Play()
		tween2.Completed:Once(function()
			screenGui:Destroy()
		end)
	end)
	local clone = ShakePresets.BumpS:Clone()
	clone.Sustain = true
	local v3 = ShakePresets.BindShakeToCamera(clone, workspace.CurrentCamera)
	clone:Start()
	task.delay(0.3, function()
		clone:StopSustain()
		task.delay(0.2, function()
			clone:Destroy()
			v3()
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createUFOVisuals()
	local maid2 = maid:Extend()
	maid2:Add(Observers.observeTag("GalaxyUFO", function(part)
		if not part:IsA("BasePart") then
			return nil
		end

		local maid3 = maid2:Extend()
		local clone = maid3:Clone(UFO2)

		for _, part2 in clone:GetDescendants() do
			if part2:IsA("BasePart") then
				part2.Anchored = true
			end
		end

		local clone2 = ReplicatedStorage.Sounds.Events.UFO.Flying:Clone()
		clone2.Parent = part
		clone2:Play()
		clone.Parent = workspace
		local beamPart = clone:FindFirstChild("BeamPart", true)
		local att0 = beamPart and beamPart:FindFirstChild("att0")
		local att1 = beamPart and beamPart:FindFirstChild("att1")

		if not (beamPart and att0 and att1 and att0:IsA("Attachment") and att1:IsA("Attachment")) then
			maid3:Destroy()
			return nil
		end

		local beams = {}

		for _, beam in att1:GetChildren() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Attachment0 = att0
			beam.Attachment1 = att1
			beam.Enabled = false
			table.insert(beams, beam)
		end

		local position = att1.Position
		local v = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopTween()
			if v then
				v:Cancel()
				v = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setBeams(enabled: boolean)
			for _, v2 in beams do
				v2.Enabled = enabled
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tweenAtt1(position2: Vector3, duration: number)
			stopTween() -- equivalent call inferred; original call site unknown
			v = CreateTween(att1, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
				Position = position2
			})
			return v
		end

		local function setState(beamState: string)
			if beamState == "down" then
				local clone3 = ReplicatedStorage.Sounds.Events.UFO.Abducting:Clone()
				clone3.Parent = part
				clone3:Play()
				setBeams(true) -- equivalent call inferred; original call site unknown
				att1.Position = att0.Position
				stopTween() -- equivalent call inferred; original call site unknown
				v = CreateTween(att1, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					Position = position
				})
			elseif beamState == "off" then
				local v2 = tweenAtt1(att0.Position, 0.5) -- equivalent call inferred; original call site unknown

				if v2 then
					v2.Completed:Wait()
				end

				setBeams(false) -- equivalent call inferred; original call site unknown
				att1.Position = position
			end
		end

		maid3:Add(part:GetAttributeChangedSignal("BeamState"):Connect(function()
			local beamState = part:GetAttribute("BeamState")

			if typeof(beamState) == "string" then
				setState(beamState)
			end
		end))
		maid3:Add(RunService.PostSimulation:Connect(function()
			debug.profilebegin("UFO:MoveUFO")

			if clone.PrimaryPart == nil or part.Parent == nil then
				maid3:Destroy()
			else
				clone:PivotTo(part.CFrame)
			end

			debug.profileend()
		end))
		maid3:Add(stopTween)
		maid3:Add(task.spawn(function()
			local beamState = part:GetAttribute("BeamState")

			if typeof(beamState) == "string" then
				setState(beamState)
				return
			end

			setBeams(false) -- equivalent call inferred; original call site unknown
			att1.Position = position
		end))
		return function()
			maid3:Destroy()
		end
	end))
end

function UFO.OnStart(_)
	createUFOVisuals() -- equivalent call inferred; original call site unknown
	maid:Add(remoteEvent.OnClientEvent:Connect(function(vector: Vector3)
		ClientEventUtils.playBurst(script.Effects.ufoemit, vector, { ReplicatedStorage.Sounds.Events.UFO.Burst })
	end))
	maid:Add(remoteEvent2.OnClientEvent:Connect(function(_: Vector3)
		playUFOSpawnFX()
	end))
	ReplicatedStorage:SetAttribute("UFOEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("UFOEvent", nil)
		CycleController:Update()
		SoundController:UpdateOST()
	end)
end

function UFO.OnStop(_)
	maid:Destroy()
end

function UFO.OnLoad(_) end

return UFO