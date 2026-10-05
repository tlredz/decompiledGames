local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("Players")
local Debris = game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local SolarFlare = {}
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Net)
local Shake = require(ReplicatedStorage.Packages.Shake)
require(ReplicatedStorage.Shared.ShakePresets)
local name = script.Name
local maid = Trove.new()
local solarFlareBeam = ReplicatedStorage.Models.Events["Solar Flare"].SolarFlareBeam
local clone = solarFlareBeam:Clone()
local solarFlare = workspace.Events["Solar Flare"]
local v = solarFlare.MapFloor.Position.Y - solarFlare.MapFloor.Size.Y / 2
local isJumpLTMServer = ServerData.IsJumpLTMServer()
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back)
local color = Color3.fromRGB(49, 49, 49)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local currentCamera = workspace.CurrentCamera
local cFrame = nil
local v2 = Shake.new()
v2.Frequency = 0.25
v2.Amplitude = 0.2
v2.FadeInTime = 0.1
v2.FadeOutTime = 0.2
v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
v2.RotationInfluence = createVector(1, 1, 1)
local v3 = Shake.new()
v3.Frequency = 0.06666666666666667
v3.Amplitude = 0.04
v3.Sustain = true
v3.PositionInfluence = createVector(0.75, 0.75, 0.75)
v3.RotationInfluence = createVector(1.25, 0.25, 0.25)

function SolarFlare.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local v4 = true
	maid:Add(function()
		v4 = false
	end)
end

function SolarFlare.OnStop(_)
	maid:Destroy()
end

function SolarFlare.OnLoad(_)
	for _, child in solarFlareBeam:GetChildren() do
		if child.Name ~= "BeamEnd" and child.Name ~= "Hitbox" then
			child:Destroy()
		end
	end

	for _, child in solarFlareBeam.BeamEnd:GetChildren() do
		if child.Name ~= "MainAttachment" then
			child:Destroy()
		end
	end

	local part = Instance.new("Part")
	part.Name = "SolarFlareTrail"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = createVector(5, 5, 5)
	part.Color = color
	part.Transparency = 0.4
	part.Material = Enum.Material.Concrete
	maid:Add(RunService.Heartbeat:Connect(function()
		debug.profilebegin("Solar Flare:Camera CFrame Update")

		if cFrame then
			currentCamera.CFrame = cFrame
			cFrame = nil
		end

		debug.profileend()
	end))
	local v4 = {}
	Observers.observeTag("SolarFlareBase", function(instance)
		local systemId = instance:GetAttribute("SystemId")

		if not systemId then
			warn("[Solar Flare Client] Base missing SystemId attribute")
			return
		end

		local maid2 = maid:Extend()
		local v5 = {
			base = instance,
			trove = maid2,
			numBeams = instance:GetAttribute("NumBeams") or 1,
			maxBeams = instance:GetAttribute("MaxBeams") or 4,
			height = (instance:GetAttribute("SpawnPosition") or instance.Position).Y
		}
		v4[systemId] = v5

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateBeamCount()
			v5.numBeams = instance:GetAttribute("NumBeams") or v5.numBeams
		end

		maid2:Add(instance:GetAttributeChangedSignal("NumBeams"):Connect(updateBeamCount))
		updateBeamCount() -- equivalent call inferred; original call site unknown
		return function()
			v4[systemId] = nil
			maid2:Destroy()
		end
	end, { solarFlare })
	Observers.observeTag("SolarFlareHitbox", function(part2)
		local systemId = part2:GetAttribute("SystemId")

		if not systemId then
			warn("[Solar Flare Client] Hitbox missing SystemId attribute")
			return
		end

		local v5 = nil

		while not v5 and ReplicatedStorage:GetAttribute("SolarFlareEvent") do
			v5 = v4[systemId]

			if not v5 then
				task.wait()
			end
		end

		if not v5 then
			return
		end

		local maid2 = v5.trove:Extend()
		maid2:AttachToInstance(part2)
		local numBeams = v5.numBeams
		local v6 = maid2:Add(clone.Beam1:Clone())
		v6:PivotTo(part2:GetPivot())
		v6.Anchored = false
		v6.Name = `Beam{numBeams}`
		v6.BeamEffect:Play()
		local v7 = maid2:Add(Instance.new("WeldConstraint"))
		v7.Part0 = v6
		v7.Part1 = part2
		v7.Parent = v6
		local _ = (numBeams - 1) * 6.283185307179586 / 4
		local beamStartAttachment = v6.BeamStartAttachment
		local v8 = maid2:Add(clone.BeamEnd.Beam1Attachment:Clone())
		v8.Name = `Beam{numBeams}Attachment`
		local v9 = {}

		for _, beam in v8:GetChildren() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Attachment0 = beamStartAttachment

			if v5.numBeams == 0 then
				continue
			end

			v9[beam] = {
				Width0 = beam.Width0,
				Width1 = beam.Width1
			}
			beam.Width0 = 0
			beam.Width1 = 0
		end

		v8.Parent = v5.base
		v6.Parent = solarFlare

		for k, v10 in v9 do
			local v11 = maid2:Add(TweenService:Create(k, tweenInfo, v10))
			v11.Completed:Once(function()
				v11:Destroy()
			end)
			v11:Play()
		end

		local v10 = maid2:Add(v2:Clone())
		v10:Start()
		v10:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Camera.Value + 1, function(position, data)
			if not cFrame then
				cFrame = currentCamera.CFrame
			end

			currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
		end)

		local function createTrail(position: Vector3)
			local v11 = maid2:Add(part:Clone())
			local v12

			if isJumpLTMServer then
				v12 = position.Y - 1
			else
				v12 = v - 1
			end

			v11.CFrame = CFrame.new(position.X, v12, position.Z) * CFrame.Angles(
				math.random() * 6.283185307179586,
				0,
				math.random() * 6.283185307179586
			)
			Debris:AddItem(v11, 0.9)
			v11.Parent = solarFlare
			local v13 = maid2:Add(TweenService:Create(v11, tweenInfo2, {
				Transparency = 1
			}))
			v13.Completed:Once(function()
				v13:Destroy()
			end)
			v13:Play()
		end

		math.random(1, 100000)
		local v11 = maid2:Add(v3:Clone())
		v11:Start()
		v11:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Camera.Value + 1, function()
			local v12, v13 = v11:Update()
			local v14 = math.clamp(
				1 - math.max(0, (currentCamera.CFrame.Position - part2.Position).Magnitude - 25) / 75,
				0,
				1
			)
			local v15 = v14 * v14

			if v15 < 0.01 then
				return
			end

			if not cFrame then
				cFrame = currentCamera.CFrame
			end

			local v16 = v12 * v15
			local v17 = v13 * v15
			currentCamera.CFrame *= CFrame.new(v16) * CFrame.Angles(v17.X, v17.Y, v17.Z)
		end)
		local position = part2.Position
		maid2:Add(RunService.PostSimulation:Connect(function()
			debug.profilebegin("Solar Flare:Trail")
			local position2 = part2.Position

			if (position2 - position).Magnitude >= 1.5 then
				createTrail(position2)
				position = position2
			end

			debug.profileend()
		end))
		return function()
			maid2:Destroy()
		end
	end, { solarFlare })
end

return SolarFlare