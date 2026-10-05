local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local Config = require(script.Parent.Config)
require(script.Parent.Types)

local function resolveTemplate(instance)
	if typeof(instance) == "Instance" then
		return instance
	end

	return InstanceUtils.getPotentialInstance(ReplicatedStorage, instance)
end

local function describeTemplate(p)
	if typeof(p) == "string" then
		return p
	end

	return p:GetFullName()
end

local function prepareClone(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
	end

	if folder:IsA("BasePart") then
		folder.Anchored = true
		folder.CanCollide = false
		folder.CanTouch = false
		folder.CanQuery = false
		folder.CastShadow = false
	end
end

local function getLocalAliveRoot()
	local localPlayer = Players.LocalPlayer
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function pivotOrb(instance, cframe: CFrame)
	instance:PivotTo(cframe)
end

local function scaleOrb(data, p: number)
	local v = math.max(p, 0.01)
	local instance = data.instance

	if instance:IsA("BasePart") and data.baseSize then
		instance.Size = data.baseSize * v
	elseif instance:IsA("Model") then
		instance:ScaleTo(data.baseScale * v)
	end
end

return {
	start = function(data)
		assert(RunService:IsClient(), "floatingOrbWins.Client.start is client-only")
		local resolved = Config.resolve(data.config)
		local logger = data.logger
		local orbTemplate = resolved.orbTemplate

		if typeof(orbTemplate) ~= "Instance" then
			orbTemplate = InstanceUtils.getPotentialInstance(ReplicatedStorage, orbTemplate)
		end

		local v

		if orbTemplate == nil then
			v = false
		else
			v = orbTemplate:IsA("BasePart") or orbTemplate:IsA("Model")
		end

		if logger and not v then
			local orbTemplate2 = resolved.orbTemplate

			if typeof(orbTemplate2) ~= "string" then
				orbTemplate2 = orbTemplate2:GetFullName()
			end

			logger:warn((`floatingOrbWins: orb template "{orbTemplate2}" is missing or not a BasePart/Model — orbs will not appear`))
		end

		local model = Instance.new("Model")
		model.Name = "FloatingOrbWins"
		model.Parent = data.parent or Workspace
		local v2 = {}
		local total = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyOrb(p: string)
			local v3 = v2[p]

			if v3 then
				v2[p] = nil
				v3.instance:Destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function completeCollect(p: string)
			destroyOrb(p) -- equivalent call inferred; original call site unknown
			data.requestCollect(p)
		end

		local function stepIdle(state, localAliveRoot)
			local v3 = math.sin((total + state.phase) * resolved.idleBobSpeed) * resolved.idleBobStuds
			local v4 = (total + state.phase) * resolved.idleSpinSpeed
			state.instance:PivotTo(CFrame.new(state.basePosition + Vector3.new(0, v3, 0)) * CFrame.Angles(0, v4, 0))

			if localAliveRoot and (localAliveRoot.Position - state.basePosition).Magnitude <= resolved.triggerRadiusStuds then
				state.collecting = true
				state.floatElapsed = 0
				state.collectStart = state.instance:GetPivot().Position
				state.collectTarget = localAliveRoot.Position
			end
		end

		local function stepCollecting(k: string, state, dt: number, localAliveRoot)
			state.floatElapsed += dt
			local v3 = math.min(1, state.floatElapsed / resolved.floatDurationSeconds)
			local value = TweenService:GetValue(v3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			local collectTarget

			if localAliveRoot then
				collectTarget = localAliveRoot.Position + createVector(0, 1.5, 0)
			else
				collectTarget = state.collectTarget
			end

			state.collectTarget = collectTarget
			local lerped = state.collectStart:Lerp(collectTarget, value)
			local v4 = (total + state.phase) * resolved.collectSpinSpeed
			local v5 = math.max(1 + (resolved.endScale - 1) * value, 0.01)
			local instance = state.instance

			if instance:IsA("BasePart") and state.baseSize then
				instance.Size = state.baseSize * v5
			elseif instance:IsA("Model") then
				instance:ScaleTo(state.baseScale * v5)
			end

			state.instance:PivotTo(CFrame.new(lerped) * CFrame.Angles(0, v4, 0))

			if v3 >= 1 then
				completeCollect(k) -- equivalent call inferred; original call site unknown
			end
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			total += dt
			local localAliveRoot = getLocalAliveRoot()

			for k, v3 in v2 do
				if v3.collecting then
					stepCollecting(k, v3, dt, localAliveRoot)
				else
					stepIdle(v3, localAliveRoot)
				end
			end
		end)
		return {
			stop = function()
				renderSteppedConnection:Disconnect()
				table.clear(v2)
				model:Destroy()
			end,
			handleSpawn = function(p: string, position: Vector3)
				if not v or v2[p] then
					return
				end

				local clone = orbTemplate:Clone()
				clone.Name = "FloatingOrbWin"
				prepareClone(clone)
				clone.Parent = model
				clone:PivotTo((CFrame.new(position)))
				local size

				if clone:IsA("BasePart") then
					clone.Size *= resolved.orbScale
					size = clone.Size
				end

				local scale

				if clone:IsA("Model") then
					clone:ScaleTo(clone:GetScale() * resolved.orbScale)
					scale = clone:GetScale()
				else
					scale = 1
				end

				v2[p] = {
					instance = clone,
					basePosition = position,
					baseSize = size,
					baseScale = scale,
					collecting = false,
					floatElapsed = 0,
					phase = math.random() * 3.141592653589793 * 2,
					collectStart = position,
					collectTarget = position
				}
			end,
			handleDespawn = function(p: string)
				destroyOrb(p) -- equivalent call inferred; original call site unknown
			end
		}
	end
}