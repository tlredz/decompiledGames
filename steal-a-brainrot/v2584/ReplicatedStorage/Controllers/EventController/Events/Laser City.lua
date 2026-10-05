local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local LaserCity = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Shake = require(ReplicatedStorage.Packages.Shake)
local Net = require(ReplicatedStorage.Packages.Net)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Laser City/Burst")
local maid = Trove.new()
local v = Shake.new()
v.Frequency = 0.25
v.Amplitude = 0.2
v.FadeInTime = 0.1
v.FadeOutTime = 0.2
v.PositionInfluence = createVector(0.15, 0.15, 0.15)
v.RotationInfluence = createVector(1, 1, 1)
local v2 = Shake.new()
v2.Frequency = 0.06666666666666667
v2.Amplitude = 0.04
v2.Sustain = true
v2.PositionInfluence = createVector(0.75, 0.75, 0.75)
v2.RotationInfluence = createVector(1.25, 0.25, 0.25)

function LaserCity.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	local sky = Lighting:FindFirstChildOfClass("Sky")

	if sky then
		sky.Parent = script
		maid:Add(function()
			sky.Parent = Lighting
		end)
	end

	local laserCitySky = script:FindFirstChild("LaserCitySky")

	if laserCitySky then
		local clone_2 = maid:Clone(laserCitySky)
		clone_2.Parent = Lighting
	end

	local burst = script:FindFirstChild("Burst")

	if burst and burst:IsA("BasePart") then
		maid:Add(remoteEvent.OnClientEvent:Connect(function(p: string)
			ClientEventUtils.playBurst(burst, p, { ReplicatedStorage.Sounds.Events["Laser City"].BeamDirectHit })
		end))
	end

	local cFrame = nil
	maid:Add(RunService.Heartbeat:Connect(function()
		if not cFrame then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			currentCamera.CFrame = cFrame
		end

		cFrame = nil
	end))
	ReplicatedStorage:SetAttribute("LaserCityEvent", true)
	SoundController:UpdateOST()
	EffectController:Run("LaserCityEvent", "GrassRecolor")
	EffectController:Run("LaserCityEvent", "WallRecolor")
	EffectController:Run("LaserCityEvent", "WallBottomRecolor")
	maid:Add(function()
		ReplicatedStorage:SetAttribute("LaserCityEvent", nil)
		SoundController:UpdateOST()
		EffectController:Stop("LaserCityEvent", "GrassRecolor")
		EffectController:Stop("LaserCityEvent", "WallRecolor")
		EffectController:Stop("LaserCityEvent", "WallBottomRecolor")
	end)
	local script2 = script
	local clone = maid:Clone(script2.LaserCityMap)
	clone.Parent = workspace
	local laserCaylus = clone.LaserCaylus
	local caylus = laserCaylus:FindFirstChild("Caylus")
	local animator = caylus and caylus:FindFirstChildWhichIsA("Animator", true)

	if animator then
		local track = animator:LoadAnimation(script2.CaylusAnimation)
		maid:Add(track, "Stop")
		maid:Add(track)
		track:Play()
	end

	local upperTorso = caylus and caylus:FindFirstChild("UpperTorso", true)
	local head = caylus and caylus:FindFirstChild("Head", true)
	local waist = caylus and caylus:FindFirstChild("Waist", true)
	local neck = caylus and caylus:FindFirstChild("Neck", true)
	local C0

	if waist and waist:IsA("Motor6D") then
		C0 = waist.C0
	else
		C0 = nil
	end

	local C02

	if neck and neck:IsA("Motor6D") then
		C02 = neck.C0
	else
		C02 = nil
	end

	maid:Add(function()
		if waist and waist:IsA("Motor6D") and C0 then
			waist.C0 = C0
		end

		if neck and neck:IsA("Motor6D") and C02 then
			neck.C0 = C02
		end
	end)
	local impact = laserCaylus.Impact
	local pivot = impact:GetPivot()
	impact.BeamEffect:Play()
	maid:Add(Observers.observeTag("LaserCityImpact", function(instance)
		local maid2 = maid:Extend()
		maid2:AttachToInstance(instance)
		local v3 = maid2:Add(v:Clone())
		v3:Start()
		v3:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Camera.Value + 1, function(position, data)
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			if not cFrame then
				cFrame = currentCamera.CFrame
			end

			currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
		end)
		local v4 = maid2:Add(v2:Clone())
		v4:Start()
		v4:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Camera.Value + 1, function()
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local v5, v6 = v4:Update()
			local v7 = math.clamp(
				1 - math.max(0, (currentCamera.CFrame.Position - instance.Position).Magnitude - 25) / 75,
				0,
				1
			)
			local v8 = v7 * v7

			if v8 < 0.01 then
				return
			end

			if not cFrame then
				cFrame = currentCamera.CFrame
			end

			local v9 = v5 * v8
			local v10 = v6 * v8
			currentCamera.CFrame *= CFrame.new(v9) * CFrame.Angles(v10.X, v10.Y, v10.Z)
		end)
		local postSimulationConnection = RunService.PostSimulation:Connect(function()
			impact:PivotTo(instance:GetPivot())
			local position = instance.Position

			if waist and waist:IsA("Motor6D") and upperTorso and upperTorso:IsA("BasePart") and C0 then
				local vectorToObjectSpace = upperTorso.CFrame:VectorToObjectSpace((position - upperTorso.Position).Unit)
				local v5 = math.clamp(
					math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z),
					-0.6108652381980153,
					0.6108652381980153
				)
				local v6 = math.clamp(math.asin(vectorToObjectSpace.Y), -0.3490658503988659, 0.3490658503988659)
				waist.C0 = waist.C0:Lerp(C0 * CFrame.Angles(v6 * 0.35, v5 * 0.55, 0), 0.15)
			end

			if neck and neck:IsA("Motor6D") and head and head:IsA("BasePart") and C02 then
				local vectorToObjectSpace = head.CFrame:VectorToObjectSpace((position - head.Position).Unit)
				local v5 = math.clamp(
					math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z),
					-1.3089969389957472,
					1.3089969389957472
				)
				local v6 = math.clamp(math.asin(vectorToObjectSpace.Y), -0.7853981633974483, 0.7853981633974483)
				neck.C0 = neck.C0:Lerp(C02 * CFrame.Angles(v6 * 0.9, v5, 0), 0.15)
			end
		end)
		return function()
			postSimulationConnection:Disconnect()
			maid2:Destroy()
			impact:PivotTo(pivot)

			if waist and waist:IsA("Motor6D") and C0 then
				waist.C0 = C0
			end

			if neck and neck:IsA("Motor6D") and C02 then
				neck.C0 = C02
			end
		end
	end, { workspace }))
	maid:Add(Observers.observeTag("HideInLaserCity", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
end

function LaserCity.OnStop(_)
	maid:Destroy()
end

function LaserCity.OnLoad(_) end

return LaserCity