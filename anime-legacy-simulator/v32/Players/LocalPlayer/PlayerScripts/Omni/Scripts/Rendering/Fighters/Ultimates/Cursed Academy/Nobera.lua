local createVector = vector.create
local cframe = CFrame.Angles(1.5707963267948966, 0, 0)

local function PrepareEffect(folder, anchored: boolean)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, part in descendants do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = anchored
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopNailMotion(p)
	if p.NailMotion then
		p.NailMotion:Disconnect()
		p.NailMotion = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyNail(instance)
	StopNailMotion(instance) -- equivalent call inferred; original call site unknown

	if instance.Nail then
		instance:Destroy(instance.Nail)
		instance.Nail = nil
	end
end

local function HasTarget(p)
	local v

	if p.Enemy == nil then
		return false
	else
		v = not p.Enemy.Destroyed

		if v then
			if p.EnemyHRP == nil then
				return false
			else
				return p.EnemyHRP.Parent ~= nil
			end
		end
	end

	return v
end

local function MoveNail(state, p: number, callback)
	StopNailMotion(state) -- equivalent call inferred; original call site unknown
	local lastTime = os.clock()
	state.NailMotion = state.Omni.Services.RunService.RenderStepped:Connect(function()
		if not state.Fighter.Destroyed and state.Animation.IsPlaying then
			local v = state
			local v2

			if v.Enemy == nil then
				v2 = false
			else
				v2 = not v.Enemy.Destroyed

				if v2 then
					if v.EnemyHRP == nil then
						v2 = false
					else
						v2 = v.EnemyHRP.Parent ~= nil
					end
				end
			end

			if v2 and state.Nail and state.Nail.Parent then
				local v3 = math.clamp((os.clock() - lastTime) / p, 0, 1)
				callback(v3)

				if v3 >= 1 then
					StopNailMotion(state) -- equivalent call inferred; original call site unknown
				end

				return
			end
		end

		DestroyNail(state) -- equivalent call inferred; original call site unknown
	end)
end

local function GetEffectLifetime(folder)
	local v = 0

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			v = math.max(v, emitter.Lifetime.Max)
		end
	end

	return v + 0.1
end

local Nobera = {}

function Nobera.Setup(instance)
	instance.LeftHand = instance.Model:FindFirstChild("LeftHand")
	instance.EffectScale = instance.Model:GetScale()
	local rightHand = instance.Model:FindFirstChild("RightHand")

	if not rightHand then
		return
	end

	local clone = instance:Clone("Hammer")

	if not clone then
		return
	end

	PrepareEffect(clone, false)
	clone:ScaleTo(clone:GetScale() * instance.EffectScale)
	clone:PivotTo(rightHand.CFrame)
	instance:AttachToModel(clone)
	instance:Weld(rightHand, clone.PrimaryPart)
	instance.Hammer = clone
end

Nobera.OnMarker = {
	NailUp = function(instance)
		if instance.LeftHand then
			local v

			if instance.Enemy == nil then
				v = false
			else
				v = not instance.Enemy.Destroyed

				if v then
					if instance.EnemyHRP == nil then
						v = false
					else
						v = instance.EnemyHRP.Parent ~= nil
					end
				end
			end

			if v and not instance.NailRaised then
				instance.NailRaised = true
				instance:Sound("Nail")
				local clone = instance:Clone("Nail")

				if not clone then
					return
				end

				PrepareEffect(clone, true)
				clone:ScaleTo(clone:GetScale() * instance.EffectScale)
				instance:Disable(clone)
				local leftGripAttachment = instance.LeftHand:FindFirstChild("LeftGripAttachment")
				local worldPosition = leftGripAttachment and leftGripAttachment.WorldPosition or instance.LeftHand.Position
				local pointToWorldSpace = instance.HRP.CFrame:PointToWorldSpace(createVector(0.3586, 0.3593, -2.9267) * instance.EffectScale)
				local v2 = (worldPosition + pointToWorldSpace) / 2 + createVector(0, 1.25, 0) * instance.EffectScale
				clone:PivotTo(CFrame.new(worldPosition))
				instance:Cache(clone)
				instance.Nail = clone
				instance:Enable(clone)
				clone.Destroying:Connect(function()
					StopNailMotion(instance) -- equivalent call inferred; original call site unknown
				end)
				MoveNail(instance, 0.48333333333333334, function(p)
					local lerped = worldPosition:Lerp(v2, p):Lerp(v2:Lerp(pointToWorldSpace, p), p)
					clone:PivotTo(CFrame.new(lerped))
				end)
			end
		end
	end,
	NailHit = function(object)
		if object.Nail and object.Hammer then
			local v

			if object.Enemy == nil then
				v = false
			else
				v = not object.Enemy.Destroyed

				if v then
					if object.EnemyHRP == nil then
						v = false
					else
						v = object.EnemyHRP.Parent ~= nil
					end
				end
			end

			if v and not object.NailLaunched then
				object.NailLaunched = true
				object:Sound("Hammer")
				local model = object.Hammer:FindFirstChild("Model")
				local position = model and model.Position or object.Nail:GetPivot().Position
				object.GoalPosition = object.EnemyHRP.Position

				local function Update(p)
					object.GoalPosition = object.EnemyHRP.Position
					local lerped = position:Lerp(object.GoalPosition, p)
					local v2 = object.GoalPosition - position
					local cframe2 = v2.Magnitude > 0.001 and CFrame.lookAt(createVector(0, 0, 0), v2) or CFrame.identity
					object.Nail:PivotTo(CFrame.new(lerped) * cframe2 * cframe)
				end

				Update(0)
				MoveNail(object, 0.1, Update)
			end
		end
	end,
	Hit = function(instance)
		if not instance.Nail or not instance.NailLaunched or instance.Exploded then
			return
		end

		instance.Exploded = true
		local v

		if instance.Enemy == nil then
			v = false
		else
			v = not instance.Enemy.Destroyed

			if v then
				if instance.EnemyHRP == nil then
					v = false
				else
					v = instance.EnemyHRP.Parent ~= nil
				end
			end
		end

		if v then
			instance:Sound("Resonance")
			local position = instance.EnemyHRP.Position
			DestroyNail(instance) -- equivalent call inferred; original call site unknown
			local clone = instance:Clone("Hit")

			if not clone then
				return
			end

			PrepareEffect(clone, true)
			clone:PivotTo(CFrame.new(position))
			instance:Cache(clone)
			instance:Emit(clone)
			instance:Debris(clone, (GetEffectLifetime(clone)))
			instance:Shake({
				Position = instance.Origin.Position,
				Amplitude = 2,
				Frequency = 0.05,
				FadeOutTime = 0.25
			})
			instance:Impact({
				Position = instance.Origin.Position,
				Duration = 0.25,
				TintColor = Color3.fromRGB(32, 208, 252)
			})
			instance:Blur({
				Position = instance.Origin.Position,
				Size = 20
			})
		else
			DestroyNail(instance) -- equivalent call inferred; original call site unknown
		end
	end
}

function Nobera.Cleanup(instance)
	DestroyNail(instance) -- equivalent call inferred; original call site unknown
end

return Nobera