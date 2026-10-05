local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local zFieryCharge = FX:WaitForChild("TigerEffects").ZFieryCharge
local _ = FX:WaitForChild("TigerEffects").SlashPart
local _ = workspace._WorldOrigin

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

return function(data)
	local player = data.player
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local hrp = data.hrp
	local _ = data.amount or 3

	if not (hrp and hrp.Parent:IsDescendantOf(workspace)) then
		return
	end

	local clone = zFieryCharge.Attachment2:Clone()
	Util.SetParentOverrideWithColor(clone, hrp, player, "LeopardFruitVFXColor")
	task.delay(0.5, function()
		clone:Destroy()
	end)
	emitAll(clone)
	Util.Sound:Play("Tiger.ChargeUpZ", hrp, nil, 1 + math.random(45, 55) / 100, 0.2)
	local clone2 = zFieryCharge.Light2:Clone()
	Util.SetParentOverrideWithColor(clone2, hrp, player, "LeopardFruitVFXColor")
	task.delay(0.5, function()
		clone2:Destroy()
	end)
	local pointLight = clone2.PointLight
	pointLight.Brightness = 8
	pointLight.Range = 0
	pointLight.Enabled = true
	TweenService:Create(pointLight, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Range = 15
	}):Play()
	task.wait(0.15)
	TweenService:Create(pointLight, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0
	}):Play()
end