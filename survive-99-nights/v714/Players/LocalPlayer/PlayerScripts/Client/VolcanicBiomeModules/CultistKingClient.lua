local createVector = vector.create
local CultistKingClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- equivalent calls inferred from this helper; original call sites unknown
local function Tween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	tween:Destroy()
end

local values = script.Values

function SpawnCultistKingEffects(p, cFrame)
	local clone = ReplicatedStorage.Assets.Particles.CultistKingSpawn:Clone()
	local sphereEmitter = clone:WaitForChild("SphereEmitter")
	sphereEmitter:SetAttribute("Default_Size", sphereEmitter.Size)
	local invertedSphereEmitter = clone:WaitForChild("InvertedSphereEmitter")
	local emitters = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		table.insert(emitters, emitter)
	end

	local parts = {}

	for _, part in pairs(clone.VfxParts:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		part:SetAttribute("Default_Size", part.Size)
		part:SetAttribute("Default_Transparency", part.Transparency)
		part.Size = createVector(0, 0, 0)
		part.CFrame = cFrame
		part.Parent = workspace.Particles
		table.insert(parts, part)
	end

	clone.Parent = workspace.Particles
	sphereEmitter.GlowLight.Brightness = 0
	sphereEmitter.Size = createVector(0, 0, 0)
	local v = cFrame or sphereEmitter.CFrame
	sphereEmitter:PivotTo(v)
	sphereEmitter.Parent = workspace.Particles
	invertedSphereEmitter:PivotTo(v)
	invertedSphereEmitter.Parent = workspace.Particles
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local value = values.SpinSphereMultiplier.Value

		for _, v2 in pairs(parts) do
			local spinVelocity = v2:GetAttribute("SpinVelocity")

			if spinVelocity ~= nil then
				v2.CFrame = v2.CFrame:ToWorldSpace(CFrame.Angles(0, math.rad(spinVelocity * value * dt), 0))
			end
		end
	end)
	local v2 = p - workspace:GetServerTimeNow()
	local tweenInfo = TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

	for _, v3 in pairs(parts) do
		Tween(v3, tweenInfo, {
			Size = v3:GetAttribute("Default_Size"),
			Transparency = v3:GetAttribute("Default_Transparency")
		}) -- equivalent call inferred; original call site unknown
	end

	for _, v3 in pairs(emitters) do
		if string.find(v3.Name, "Constant_") ~= nil then
			local rate = v3.Rate
			v3.Rate = 0
			v3.Enabled = true
			Tween(v3, tweenInfo, {
				Rate = rate
			}) -- equivalent call inferred; original call site unknown
		end

		if string.find(v3.Name, "Start_") == nil then
			continue
		end

		local emitCount = v3:GetAttribute("EmitCount")
		local emitDelay = v3:GetAttribute("EmitDelay")
		local emitDuration = v3:GetAttribute("EmitDuration")
		local v4 = emitCount == nil and 0 or emitCount
		local v5 = emitDelay == nil and 0 or emitDelay
		local v6 = emitDuration == nil and 0 or emitDuration
		local v7 = v3
		task.delay(v5, function()
			v7:Emit(v4)

			if v6 ~= 0 then
				v7.Enabled = true
				task.delay(v6, function()
					v7.Enabled = false
				end)
			end
		end)
	end

	Tween(sphereEmitter.GlowLight, tweenInfo, {
		Brightness = 1.5
	}) -- equivalent call inferred; original call site unknown
	Tween(
		values.SpinSphereMultiplier,
		TweenInfo.new(v2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
		{
			Value = 1.75
		}
	) -- equivalent call inferred; original call site unknown
	Tween(sphereEmitter, tweenInfo, {
		Size = sphereEmitter:GetAttribute("Default_Size")
	}) -- equivalent call inferred; original call site unknown
	task.wait(v2)
	heartbeatConnection:Disconnect()
	task.delay(0, function()
		Tween(
			sphereEmitter.GlowLight,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				Brightness = 5
			}
		) -- equivalent call inferred; original call site unknown
		task.wait(0.25)
		Tween(
			sphereEmitter.GlowLight,
			TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
			{
				Brightness = 0
			}
		) -- equivalent call inferred; original call site unknown
	end)

	for _, v4 in pairs(emitters) do
		if string.find(v4.Name, "Constant_") ~= nil then
			v4.Enabled = false
		end

		if string.find(v4.Name, "Burst_") == nil then
			continue
		end

		local emitCount = v4:GetAttribute("EmitCount")
		local emitDelay = v4:GetAttribute("EmitDelay")
		local emitDuration = v4:GetAttribute("EmitDuration")
		local v5 = emitCount == nil and 0 or emitCount
		local v6 = emitDelay == nil and 0 or emitDelay
		local v7 = emitDuration == nil and 0 or emitDuration
		local v8 = v4
		task.delay(v6, function()
			v8:Emit(v5)

			if v7 ~= 0 then
				v8.Enabled = true
				task.delay(v7, function()
					v8.Enabled = false
				end)
			end
		end)
	end

	for _, v4 in pairs(parts) do
		Tween(v4, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			Size = v4:GetAttribute("Default_Size") * 2,
			Transparency = 1
		}) -- equivalent call inferred; original call site unknown
	end

	task.spawn(function()
		wait(3)

		if clone then
			clone:Destroy()
		end
	end)
end

Client.Events.CultistKingParticles:Connect(function(p, p2)
	SpawnCultistKingEffects(p, p2)
end)

function CultistKingClient.Init() end

return CultistKingClient