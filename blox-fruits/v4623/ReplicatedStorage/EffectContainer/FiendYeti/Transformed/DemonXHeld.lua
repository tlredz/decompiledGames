local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
game:GetService("RunService")
local random = Random.new()
local FX = require(ReplicatedStorage.FX)
local _ = FX:WaitForChild("YetiEffects").X_Tr
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

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
	local _ = data.player
	local origin = data.Origin
	local root = data.Root

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 2500 then
		return
	end

	local function emitWithDelay(emitter)
		local emitDelay = emitter:GetAttribute("EmitDelay")

		if emitDelay then
			task.delay(emitDelay, function()
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end)
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local function emitWithDelayDescendants(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitWithDelay(emitter)
			end
		end
	end

	local function AkumaChargeup()
		local clone = script.Akuma:Clone()
		task.delay(4, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
		clone.Parent = workspace._WorldOrigin
		clone = clone.AkumaYeti
		heartbeatLoopFor2(4, function()
			clone.CFrame = CFrame.new(root.Position)
		end)
		clone.Light.PointLight.Range = clone.Parent:GetScale() * 2
		emitWithDelayDescendants(clone)
		task.spawn(function()
			local function hermite(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number)
				local v = p * p
				local v2 = v * p
				local v3 = v2 * 2 - v * 3 + 1
				local v4 = v2 - v * 2 + p
				local v5 = v2 * -2 + v * 3
				local v6 = v2 - v
				return v3 * vector2 + v4 * vector4 + v5 * vector3 + v6 * vector5
			end

			-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
			local function smooth(p: number)
				return p * p * (3 - p * 2)
			end

			local v = 240 * clone.Parent:GetScale()
			local v2 = 0.65 * v
			local v3 = 1.35 * v

			for i = 1, 30 do
				local clone2 = script.Akuma.AkumaYeti.Script.TrailPartChargeup:Clone()
				clone2.Trail.Enabled = true
				clone2.Parent = workspace._WorldOrigin
				task.delay(4 + random:NextNumber(-0.4, 0.8), function()
					if clone2 and clone2.Parent then
						clone2:Destroy()
					end
				end)
				local v5 = random:NextUnitVector() * v
				local v6 = root.Position + v5
				local v7 = root.Position - v6
				local vector2 = v7 / math.max(v7.Magnitude, 0.001)
				local cross = vector2:Cross(random:NextUnitVector())
				local v8 = cross.Magnitude < 0.001 and createVector(0, 1, 0) or cross.Unit
				local v9 = (vector2 + v8 * random:NextNumber(-1.2, 1.2) + Vector3.new(
					0,
					random:NextNumber(-0.6, 1.4),
					0
				)).Unit * random:NextNumber(v2, v3)
				local v10 = (vector2 + v8 * random:NextNumber(-1, 1) + Vector3.new(0, random:NextNumber(-0.4, 1), 0)).Unit * random:NextNumber(
					v2,
					v3
				)
				clone2.CFrame = CFrame.lookAt(v6, v6 + v9)
				local v14 = i
				local v15 = clone2
				local v16 = clone2
				heartbeatLoopFor2(0.4 + random:NextNumber(-0.08, 0.12), function(p, p2, p3)
					local v17 = smooth(p3)
					local position = root.Position
					local v21 = v17 * v17
					local v22 = v21 * v17
					local v23 = v22 * 2 - v21 * 3 + 1
					local v24 = v22 - v21 * 2 + v17
					local v25 = v22 * -2 + v21 * 3
					local v26 = v22 - v21
					local v27 = v23 * v6 + v24 * v9 + v25 * position + v26 * v10
					local v28 = math.sin(p2 * 0 + v14) * 0
					local cframe = CFrame.fromAxisAngle((v9 + v10).Unit, p2 * 0)
					local v29 = math.clamp(v17 + p, 0, 1)
					local v33 = v29 * v29
					local v34 = v33 * v29
					local v35 = v34 * 2 - v33 * 3 + 1
					local v36 = v34 - v33 * 2 + v29
					local v37 = v34 * -2 + v33 * 3
					local v38 = v34 - v33
					local v39 = v35 * v6 + v36 * v9 + v37 * position + v38 * v10 - v27

					if v39.Magnitude < 0.001 then
						v39 = v10
					end

					local unit = v39.Unit
					local cross2 = unit:Cross(createVector(0, 1, 0))
					local vector3 = cross2.Magnitude < 0.001 and createVector(1, 0, 0) or cross2.Unit
					local unit2 = vector3:Cross(unit).Unit
					local v40 = v27 + (vector3 * v28 + unit2 * (v28 * 0.4))
					v15.CFrame = cframe * CFrame.lookAt(v40, v40 + unit)
					v15.Trail.Transparency = NumberSequence.new(p3)
				end, function()
					v16.Trail.Transparency = NumberSequence.new(1)
				end)
			end
		end)
	end

	AkumaChargeup()
end