local createVector = vector.create

local function HasTarget(object)
	local v = not (object.Finished or object.Fighter.Destroyed)

	if not v then
		return v
	end

	if object.Model.Parent == nil or object.HRP.Parent == nil or object.Fighter.Target ~= object.Enemy or object.Enemy == nil then
		return false
	else
		v = not object.Enemy.Destroyed

		if v then
			if object.EnemyHRP == nil then
				return false
			else
				return object.EnemyHRP.Parent ~= nil
			end
		end
	end

	return v
end

local function EmitEffect(instance, p: string, cframe: CFrame)
	local clone = instance:Clone(p)

	if not clone then
		return
	end

	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)
	local v = 0

	for _, instance2 in descendants do
		if instance2:IsA("BasePart") then
			instance2.Anchored = true
			instance2.CanCollide = false
			instance2.CanTouch = false
			instance2.CanQuery = false
		elseif instance2:IsA("ParticleEmitter") then
			v = math.max(v, instance2.Lifetime.Max)
		end
	end

	clone:PivotTo(cframe)
	instance:Disable(clone)
	instance:Cache(clone)
	instance:Emit(clone)
	instance:Debris(clone, v + 0.1)
end

local function EmitClap(object)
	local leftHand = object.Model:FindFirstChild("LeftHand")
	local rightHand = object.Model:FindFirstChild("RightHand")
	local v = leftHand and rightHand and (leftHand.Position + rightHand.Position) / 2 or object.HRP.Position
	EmitEffect(object, "Clap", CFrame.new(v))
end

local function PositionFighter(object)
	local position = object.EnemyHRP.Position
	local v = object.EnemyHRP.CFrame.LookVector * createVector(1, 0, 1)
	local v2 = position + (v.Magnitude > 0.001 and v.Unit or createVector(0, 0, -1)) * object.Distance + createVector(
		0,
		1,
		0
	) * object.Height
	local cframe = CFrame.lookAt(v2, (Vector3.new(position.X, v2.Y, position.Z)))
	object.Model:PivotTo(cframe * object.RootToPivot)
end

local function LockMovement(object)
	if object.MovementLocked then
		return
	end

	object.ReturnPivot = object.Model:GetPivot()
	object.RootToPivot = object.HRP.CFrame:ToObjectSpace(object.ReturnPivot)
	object.WasAnchored = object.HRP.Anchored
	object.PositionEnabled = object.Fighter.PosAligner and object.Fighter.PosAligner.Enabled
	object.RotationEnabled = object.Fighter.RotAligner and object.Fighter.RotAligner.Enabled
	object.MovementLocked = true

	if object.Fighter.PosAligner then
		object.Fighter.PosAligner.Enabled = false
	end

	if object.Fighter.RotAligner then
		object.Fighter.RotAligner.Enabled = false
	end

	object.HRP.Anchored = true
	object.HRP.AssemblyLinearVelocity = createVector(0, 0, 0)
	object.HRP.AssemblyAngularVelocity = createVector(0, 0, 0)
end

local function Cleanup(object)
	object.Finished = true

	if object.MotionConnection then
		object.MotionConnection:Disconnect()
		object.MotionConnection = nil
	end

	if object.Stage < 4 then
		object:StopSounds()
	end

	if object.Animation.IsPlaying then
		object.Animation:Stop(0)
	end

	if not object.MovementLocked then
		return
	end

	object.MovementLocked = false

	if object.Model.Parent and object.HRP.Parent then
		object.Model:PivotTo(object.ReturnPivot)
		object.HRP.AssemblyLinearVelocity = createVector(0, 0, 0)
		object.HRP.AssemblyAngularVelocity = createVector(0, 0, 0)
		object.HRP.Anchored = object.WasAnchored
	end

	if object.Fighter.PosAligner and object.Fighter.PosAligner.Parent then
		object.Fighter.PosAligner.Enabled = object.PositionEnabled
	end

	if object.Fighter.RotAligner and object.Fighter.RotAligner.Parent then
		object.Fighter.RotAligner.Enabled = object.RotationEnabled
	end
end

return {
	Setup = function(object)
		object.Stage = 0
		object.EffectScale = object.Model:GetScale()
		object:OnCleanup(function()
			Cleanup(object)
		end)
		object.MotionConnection = object.Omni.Services.RunService.Heartbeat:Connect(function()
			if HasTarget(object) and object.Animation.IsPlaying then
				if object.MovementLocked then
					PositionFighter(object)
				end
			else
				object:CleanupAll()
			end
		end)
	end,
	OnMarker = {
		ClapBack = function(object)
			if not HasTarget(object) or object.Stage ~= 0 then
				return
			end

			object.Stage = 1
			object:Sound("Clap")
			EmitClap(object)
			LockMovement(object)
			object.Distance = -6 * object.EffectScale
			object.Height = 0
			PositionFighter(object)
		end,
		ClapUp = function(object)
			if not HasTarget(object) or object.Stage ~= 2 then
				return
			end

			object.Stage = 3
			object:Sound("Clap")
			EmitClap(object)
			object.Distance = 2.5 * object.EffectScale
			object.Height = 5 * object.EffectScale
			PositionFighter(object)
		end,
		Hit = function(object)
			if not HasTarget(object) or object.Stage ~= 1 and object.Stage ~= 3 then
				return
			end

			object.Stage += 1
			object:Sound("Hit")
			local position = object.EnemyHRP.Position
			local v = position - object.HRP.Position
			local cframe = v.Magnitude > 0.001 and CFrame.lookAt(position, position + v) or CFrame.new(position)
			EmitEffect(object, "Hit", cframe)
			object:Shake({
				Position = object.Origin.Position,
				Amplitude = 3,
				Frequency = 0.05,
				FadeOutTime = 0.25
			})
			object:Impact({
				Position = object.Origin.Position,
				Duration = 0.5,
				TintColor = Color3.fromRGB(252, 0, 0)
			})
			object:Blur({
				Position = object.Origin.Position,
				Size = 20
			})
		end
	}
}