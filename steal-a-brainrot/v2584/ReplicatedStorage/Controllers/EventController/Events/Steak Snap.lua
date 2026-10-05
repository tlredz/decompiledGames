local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local SkullEmojiEffectController = require(ReplicatedStorage.Controllers.SkullEmojiEffectController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ViewportWindow = require(script.ViewportWindow)
local name = script.Name
local maid = Trove.new()
local maid2 = Trove.new()

local function spawnGroundCrack(cFrame: CFrame)
	maid2:Clean()
	local adornee = maid2:Add(Instance.new("Part"))
	adornee.Anchored = true
	adornee.CanCollide = false
	adornee.CanQuery = false
	adornee.CanTouch = false
	adornee.Transparency = 1
	adornee.Size = createVector(40, 0.01, 40)
	adornee.CFrame = cFrame
	adornee.Parent = workspace
	local v2 = maid2:Add(Instance.new("SurfaceGui"))
	v2.Name = "SurfaceGui"
	v2.Active = false
	v2.ClipsDescendants = true
	v2.Face = Enum.NormalId.Top
	v2.LightInfluence = 1
	v2.MaxDistance = 1000
	v2.PixelsPerStud = 200
	v2.ResetOnSpawn = false
	v2.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	v2.ToolPunchThroughDistance = 0.01
	v2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	v2.Adornee = adornee
	v2.Parent = Players.LocalPlayer.PlayerGui
	local v3 = ViewportWindow.bindToSurfaceGui(v2)
	v3.viewportFrame.LightColor = Color3.new(0, 0, 0)
	local clone = maid2:Clone(script.Objects)
	clone.Parent = v3.viewportFrame
	local formatted = `SteakCrackPortal_{HttpService:GenerateGUID(false)}`
	RunService:BindToRenderStep(formatted, Enum.RenderPriority.Character.Value, function()
		if adornee.Parent and v2.Parent then
			clone:PivotTo(adornee.CFrame)
			ViewportWindow.render(v3)
		end
	end)
	maid2:Add(function()
		RunService:UnbindFromRenderStep(formatted)
	end)
	maid2:Add(task.delay(300, function()
		maid2:Destroy()
	end))
end

local SteakSnap = {}

function SteakSnap.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeftFor(p: number)
		return activeEventData.startedAt + p - workspace:GetServerTimeNow()
	end

	local clone = ShakePresets.BumpS:Clone()
	clone.Amplitude = 0.5
	clone.Sustain = true
	local v = maid:Add(ShakePresets.BindShakeToCamera(clone, workspace.CurrentCamera))
	maid:Add(task.delay(1, function()
		clone:Start()
	end))
	local clone_2 = maid:Clone(script.Part)
	clone_2.Parent = workspace
	local clone2 = maid:Clone(script.Steak)
	clone2.Parent = workspace
	local clone3 = maid:Clone(script.Sound)
	clone3.Parent = clone2.HumanoidRootPart
	clone3:Play()
	local cFrame = script.StartCFrame.CFrame
	local cFrame2 = script.EndCFrame.CFrame
	clone2:PivotTo(cFrame)
	clone2:ScaleTo(1)
	local animator = clone2.Humanoid.Animator
	local track = animator:LoadAnimation(script.WalkAnimation)
	track.Looped = true
	maid:Add(track, "Stop")
	maid:Add(track)
	track:Play()
	local track2 = animator:LoadAnimation(script.SnapAnimation)
	track2.Looped = false
	maid:Add(track2, "Stop")
	maid:Add(track2)
	local postSimulationConnection = nil
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		local v2 = math.clamp((workspace:GetServerTimeNow() - activeEventData.startedAt) / 5, 0, 1)
		clone2:PivotTo(cFrame:Lerp(cFrame2, v2))
		clone2:ScaleTo((math.lerp(1, 6.95, v2)))
		clone.Amplitude = math.lerp(0.5, 3, v2)

		if v2 >= 1 then
			postSimulationConnection:Disconnect()
		end
	end)
	maid:Add(postSimulationConnection)
	maid:Add(task.delay(calculateTimeLeftFor(5), function()
		track:Stop()
		track2:Play()
	end))
	local v2 = maid:Add(Observers.observeTag("HideInSteakSnap", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(task.delay(calculateTimeLeftFor(6.300000000000001), function()
		maid:Remove(v)
		local clone4 = ShakePresets.Explosion:Clone()
		clone4.Amplitude = 8
		clone4.SustainTime = math.max(0, 2.5 - clone4.FadeInTime - clone4.FadeOutTime)
		ShakePresets.BindShakeToCamera(clone4, workspace.CurrentCamera)
		clone4:Start()
		spawnGroundCrack(CFrame.new(-410.424, -9.3, -61.83))
	end))
	maid:Add(task.delay(calculateTimeLeftFor(6.3500000000000005), function()
		SkullEmojiEffectController:Play(1, "Lower")
	end))
	maid:Add(task.delay(calculateTimeLeftFor(6.4), function()
		EffectController:Activate("Blink")
		maid:Add(task.delay(0.35, function()
			maid:Remove(clone2)
			maid:Remove(v2)
		end))
	end))
end

function SteakSnap.OnStop(_)
	maid:Destroy()
end

function SteakSnap.OnLoad(_) end

return SteakSnap