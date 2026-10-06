local createVector = vector.create

local function HasCaster(data)
	local v = not (data.Finished or data.Fighter.Destroyed)

	if v then
		if data.Model.Parent == nil then
			return false
		else
			return data.HRP.Parent ~= nil
		end
	end

	return v
end

local function HasTarget(data)
	local v = not (data.Finished or data.Fighter.Destroyed)

	if v then
		if data.Model.Parent == nil then
			v = false
		else
			v = data.HRP.Parent ~= nil
		end
	end

	if not v then
		return v
	end

	if data.Fighter.Target == data.Enemy and data.Enemy ~= nil then
		v = not data.Enemy.Destroyed

		if v then
			if data.EnemyHRP == nil then
				return false
			else
				return data.EnemyHRP.Parent ~= nil
			end
		end
	else
		return false
	end

	return v
end

local function PrepareEffect(instance, folder)
	instance:Disable(folder)
	local v = 0

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false

			if instance.LowMode then
				descendant.Transparency = 1
			end
		elseif descendant:IsA("ParticleEmitter") then
			v = math.max(v, descendant.Lifetime.Max)
		end
	end

	return v + 0.1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HandPosition(data)
	local rightGripAttachment = data.Hand:FindFirstChild("RightGripAttachment")
	return (rightGripAttachment and rightGripAttachment.WorldPosition or data.Hand.Position) + data.HRP.CFrame:VectorToWorldSpace(createVector(
		0,
		0,
		-0.8
	) * data.Scale)
end

local function CreateBall(instance, p: string, position: Vector3, p2: number)
	local clone = instance:Clone(p)

	if not clone then
		return
	end

	PrepareEffect(instance, clone)
	local scale = clone:GetScale()
	local appliedScale = scale * p2 * instance.Scale
	clone:ScaleTo(appliedScale)
	clone:PivotTo(CFrame.new(position))
	instance:Cache(clone)
	instance:Enable(clone)
	return {
		Model = clone,
		BaseScale = scale,
		AppliedScale = appliedScale
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MoveBall(p, state, position: Vector3, p2: number)
	if not state then
		return
	end

	local appliedScale = state.BaseScale * p2 * p.Scale

	if state.AppliedScale ~= appliedScale then
		state.AppliedScale = appliedScale
		state.Model:ScaleTo(appliedScale)
	end

	state.Model:PivotTo(CFrame.new(position))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyBall(instance, p: string)
	local v = instance[p]

	if not v then
		return
	end

	instance:Destroy(v.Model)
	instance[p] = nil
end

local function Explode(instance, name: string, position: Vector3, p: number)
	local clone = instance:Clone(name)

	if not clone then
		return
	end

	local track = instance:Track(Instance.new("Model"))
	track.Name = name
	clone.Parent = track
	track.PrimaryPart = clone
	instance:Untrack(clone)
	local prepareEffect = PrepareEffect(instance, track)
	track:ScaleTo(p * instance.Scale)
	track:PivotTo(CFrame.new(position))
	instance:Cache(track)
	instance:Emit(track)
	instance:Debris(track, prepareEffect)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Shake(object, vector2: Vector3, amplitude: number, fadeOutTime: number)
	local shake = object:Shake({
		Position = vector2,
		MaxDistance = 100,
		Amplitude = amplitude,
		Frequency = 0.05,
		FadeOutTime = fadeOutTime
	})

	if shake then
		table.insert(object.Shakes, shake)
	end
end

local function UpdateOrbit(object, p: number)
	local v = p * p * (3 - p * 2)
	local lerped = (object.HRP.CFrame * CFrame.new(0, 2 * object.Scale, 0)).Position:Lerp(HandPosition(object), v)
	local v2 = 10 * object.Scale * (1 - v)
	local v3 = p * 3.141592653589793 * 2
	local vectorToWorldSpace = object.HRP.CFrame:VectorToWorldSpace(Vector3.new(math.cos(v3), 0, (math.sin(v3))) * v2)
	local v4 = v * -0.85 + 1
	MoveBall(object, object.BlueBall, lerped + vectorToWorldSpace, v4) -- equivalent call inferred; original call site unknown
	MoveBall(object, object.RedBall, lerped - vectorToWorldSpace, v4) -- equivalent call inferred; original call site unknown
end

local function UpdateProjectile(object, p: number)
	local v = not (object.Finished or object.Fighter.Destroyed)

	if v then
		if object.Model.Parent == nil then
			v = false
		else
			v = object.HRP.Parent ~= nil
		end
	end

	if v then
		if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
			v = not object.Enemy.Destroyed

			if v then
				if object.EnemyHRP == nil then
					v = false
				else
					v = object.EnemyHRP.Parent ~= nil
				end
			end
		else
			v = false
		end
	end

	if v then
		local position = object.EnemyHRP.Position
		object.GoalPosition = Vector3.new(position.X, object.LaunchPosition.Y, position.Z)
	end

	local lerped = object.LaunchPosition:Lerp(object.GoalPosition, p)
	local v2 = p * 0.85 + 0.15
	MoveBall(object, object.PurpleBall, lerped, v2) -- equivalent call inferred; original call site unknown
end

local function UpdateFade(object, p: number)
	local v = p * p * (3 - p * 2)
	MoveBall(object, object.PurpleBall, object.EndPosition, 1 - v * 0.95) -- equivalent call inferred; original call site unknown

	for _, fadeItem in object.PurpleBall.FadeItems do
		if fadeItem.Instance:IsA("BasePart") then
			fadeItem.Instance.Transparency = fadeItem.Transparency + (1 - fadeItem.Transparency) * v
		elseif fadeItem.Instance:IsA("PointLight") then
			fadeItem.Instance.Brightness = fadeItem.Brightness * (1 - v)
		else
			local numberSequenceKeypoints = {}

			for _, keypoint in fadeItem.Transparency.Keypoints do
				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(
						keypoint.Time,
						keypoint.Value + (1 - keypoint.Value) * v,
						keypoint.Envelope * (1 - v)
					)
				)
			end

			fadeItem.Instance.Transparency = NumberSequence.new(numberSequenceKeypoints)
		end
	end

	if p >= 1 then
		DestroyBall(object, "PurpleBall") -- equivalent call inferred; original call site unknown
		object.Stage = 6
	end
end

local function UpdateContinuation(object, p: number)
	MoveBall(object, object.PurpleBall, object.ImpactPosition:Lerp(object.EndPosition, p), 1) -- equivalent call inferred; original call site unknown

	if p >= 1 then
		object.Stage = 5
		object.FadeStarted = os.clock()
		object.PurpleBall.FadeItems = {}

		for _, descendant in object.PurpleBall.Model:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				table.insert(object.PurpleBall.FadeItems, {
					Instance = descendant,
					Transparency = descendant.Transparency
				})
			elseif descendant:IsA("PointLight") then
				table.insert(object.PurpleBall.FadeItems, {
					Instance = descendant,
					Brightness = descendant.Brightness
				})
			end

			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			end
		end
	end
end

local function Cleanup(object)
	object.Finished = true

	if object.MotionConnection then
		object.MotionConnection:Disconnect()
		object.MotionConnection = nil
	end

	for _, shake in object.Shakes do
		shake:Stop()
	end

	table.clear(object.Shakes)

	if object.Stage < 3 then
		object:StopSounds()
	end

	if object.Animation.IsPlaying then
		object.Animation:Stop(0)
	end

	if object.ReturnOffset and object.Fighter.Offset and object.Fighter.Offset.Parent then
		object.Fighter.Offset.Value = object.ReturnOffset
	end

	DestroyBall(object, "BlueBall") -- equivalent call inferred; original call site unknown
	DestroyBall(object, "RedBall") -- equivalent call inferred; original call site unknown
	DestroyBall(object, "PurpleBall") -- equivalent call inferred; original call site unknown
end

return {
	Setup = function(object)
		object.Stage = 0
		object.Scale = object.Model:GetScale()
		object.LowMode = object.Omni.Data.Settings["Low Mode"] == true
		object.Hand = object.Model:FindFirstChild("RightHand")
		object.Shakes = {}
		object:OnCleanup(function()
			Cleanup(object)
		end)

		if not object.Hand then
			return
		end

		if object.Fighter.Offset then
			object.ReturnOffset = object.Fighter.Offset.Value
			object.Fighter.Offset.Value = object.ReturnOffset + Vector3.new(0, 0, 8 * object.Scale)
		end

		object.MotionConnection = object.Omni.Services.RunService.RenderStepped:Connect(function()
			local v = object
			local v2 = not (v.Finished or v.Fighter.Destroyed)

			if v2 then
				if v.Model.Parent == nil then
					v2 = false
				else
					v2 = v.HRP.Parent ~= nil
				end
			end

			if not v2 then
				object:CleanupAll()
				return
			end

			if object.Stage < 3 then
				local v3 = object
				local v4 = not (v3.Finished or v3.Fighter.Destroyed)

				if v4 then
					if v3.Model.Parent == nil then
						v4 = false
					else
						v4 = v3.HRP.Parent ~= nil
					end
				end

				if v4 then
					if v3.Fighter.Target == v3.Enemy and v3.Enemy ~= nil then
						v4 = not v3.Enemy.Destroyed

						if v4 then
							if v3.EnemyHRP == nil then
								v4 = false
							else
								v4 = v3.EnemyHRP.Parent ~= nil
							end
						end
					else
						v4 = false
					end
				end

				if not v4 then
					object:CleanupAll()
					return
				end
			end

			if not object.Animation.IsPlaying then
				object:CleanupAll()
			elseif object.Stage == 0 then
				UpdateOrbit(object, 0)
			elseif object.Stage == 1 then
				UpdateOrbit(object, math.clamp((object.Animation.TimePosition - object.MixStarted) / 0.433334, 0, 1))
			elseif object.Stage == 2 then
				local purpleBall = object.PurpleBall
				local handPosition = HandPosition(object) -- equivalent call inferred; original call site unknown
				MoveBall(object, purpleBall, handPosition, 0.15) -- equivalent call inferred; original call site unknown
			elseif object.Stage == 3 then
				UpdateProjectile(
					object,
					math.clamp((object.Animation.TimePosition - object.ReleasedAt) / 0.10000000000000009, 0, 1)
				)
			elseif object.Stage == 4 then
				UpdateContinuation(object, math.clamp((os.clock() - object.HitAt) / 0.25, 0, 1))
			elseif object.Stage == 5 then
				UpdateFade(object, math.clamp((os.clock() - object.FadeStarted) / 0.3, 0, 1))
			end
		end)
	end,
	OnMarker = {
		BlueBall = function(object)
			local v = not (object.Finished or object.Fighter.Destroyed)

			if v then
				if object.Model.Parent == nil then
					v = false
				else
					v = object.HRP.Parent ~= nil
				end
			end

			if v then
				if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
					v = not object.Enemy.Destroyed

					if v then
						if object.EnemyHRP == nil then
							v = false
						else
							v = object.EnemyHRP.Parent ~= nil
						end
					end
				else
					v = false
				end
			end

			if not v or not object.Hand or object.BlueBall or object.Stage ~= 0 then
				return
			end

			object:Sound("Blue")
			local position = (object.HRP.CFrame * CFrame.new(10 * object.Scale, 2 * object.Scale, 0)).Position
			object.BlueBall = CreateBall(object, "BlueBall", position, 1)
			Explode(object, "BlueExplosion", position, 1)
		end,
		RedBall = function(object)
			local v = not (object.Finished or object.Fighter.Destroyed)

			if v then
				if object.Model.Parent == nil then
					v = false
				else
					v = object.HRP.Parent ~= nil
				end
			end

			if v then
				if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
					v = not object.Enemy.Destroyed

					if v then
						if object.EnemyHRP == nil then
							v = false
						else
							v = object.EnemyHRP.Parent ~= nil
						end
					end
				else
					v = false
				end
			end

			if not v or not object.Hand or object.RedBall or object.Stage ~= 0 then
				return
			end

			object:Sound("Red")
			local position = (object.HRP.CFrame * CFrame.new(-10 * object.Scale, 2 * object.Scale, 0)).Position
			object.RedBall = CreateBall(object, "RedBall", position, 1)
			Explode(object, "RedExplosion", position, 1)
		end,
		MixStart = function(object)
			local v = not (object.Finished or object.Fighter.Destroyed)

			if v then
				if object.Model.Parent == nil then
					v = false
				else
					v = object.HRP.Parent ~= nil
				end
			end

			if v then
				if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
					v = not object.Enemy.Destroyed

					if v then
						if object.EnemyHRP == nil then
							v = false
						else
							v = object.EnemyHRP.Parent ~= nil
						end
					end
				else
					v = false
				end
			end

			if not v or not object.BlueBall or not object.RedBall or object.Stage ~= 0 then
				return
			end

			object.Stage = 1
			object.MixStarted = object.Animation.TimePosition
			object:Sound("Mix")
		end,
		MixEnd = function(object)
			local v = not (object.Finished or object.Fighter.Destroyed)

			if v then
				if object.Model.Parent == nil then
					v = false
				else
					v = object.HRP.Parent ~= nil
				end
			end

			if v then
				if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
					v = not object.Enemy.Destroyed

					if v then
						if object.EnemyHRP == nil then
							v = false
						else
							v = object.EnemyHRP.Parent ~= nil
						end
					end
				else
					v = false
				end
			end

			if not v or object.Stage ~= 1 then
				return
			end

			object.Stage = 2
			object:Sound("Purple")
			UpdateOrbit(object, 1)
			DestroyBall(object, "BlueBall") -- equivalent call inferred; original call site unknown
			DestroyBall(object, "RedBall") -- equivalent call inferred; original call site unknown
			local position = HandPosition(object) -- equivalent call inferred; original call site unknown
			object.PurpleBall = CreateBall(object, "PurpleBall", position, 0.15)
			Explode(object, "PurpleExplosion", position, 0.15)
			Shake(object, position, 1.5, 0.25) -- equivalent call inferred; original call site unknown
			object:Impact({
				Position = position,
				MaxDistance = 100,
				TintColor = Color3.fromRGB(170, 40, 255),
				Brightness = 0.05,
				Contrast = 0.4,
				Saturation = 0.1,
				HoldTime = 0.06,
				Duration = 0.18
			})
		end,
		Release = function(object)
			local v = not (object.Finished or object.Fighter.Destroyed)

			if v then
				if object.Model.Parent == nil then
					v = false
				else
					v = object.HRP.Parent ~= nil
				end
			end

			if v then
				if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
					v = not object.Enemy.Destroyed

					if v then
						if object.EnemyHRP == nil then
							v = false
						else
							v = object.EnemyHRP.Parent ~= nil
						end
					end
				else
					v = false
				end
			end

			if not v or not object.PurpleBall or object.Stage ~= 2 then
				return
			end

			object.Stage = 3
			object.ReleasedAt = object.Animation.TimePosition
			object.LaunchPosition = HandPosition(object)
			object.ProjectileOrigin = Vector3.new(object.HRP.Position.X, object.LaunchPosition.Y, object.HRP.Position.Z)
			local v2 = object.HRP.CFrame.LookVector * createVector(1, 0, 1)
			object.LaunchDirection = v2.Magnitude > 0.001 and v2.Unit or createVector(0, 0, -1)
			object.GoalPosition = object.EnemyHRP.Position
			object:Sound("Launch")
			local v3 = not (object.Finished or object.Fighter.Destroyed)

			if v3 then
				if object.Model.Parent == nil then
					v3 = false
				else
					v3 = object.HRP.Parent ~= nil
				end
			end

			if v3 then
				if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
					v3 = not object.Enemy.Destroyed

					if v3 then
						if object.EnemyHRP == nil then
							v3 = false
						else
							v3 = object.EnemyHRP.Parent ~= nil
						end
					end
				else
					v3 = false
				end
			end

			if v3 then
				local position = object.EnemyHRP.Position
				object.GoalPosition = Vector3.new(position.X, object.LaunchPosition.Y, position.Z)
			end

			local lerped = object.LaunchPosition:Lerp(object.GoalPosition, 0)
			MoveBall(object, object.PurpleBall, lerped, 0.15) -- equivalent call inferred; original call site unknown
			Shake(object, object.LaunchPosition, 3, 0.35) -- equivalent call inferred; original call site unknown
		end
	},
	Steps = {
		{
			Time = 2,
			Run = function(object)
				local v = not (object.Finished or object.Fighter.Destroyed)

				if v then
					if object.Model.Parent == nil then
						v = false
					else
						v = object.HRP.Parent ~= nil
					end
				end

				if not v or not object.PurpleBall or object.Stage ~= 3 then
					return
				end

				object.Stage = 4
				object:Sound("Explosion")
				object:Sound("ExplosionBody")
				local v2 = not (object.Finished or object.Fighter.Destroyed)

				if v2 then
					if object.Model.Parent == nil then
						v2 = false
					else
						v2 = object.HRP.Parent ~= nil
					end
				end

				if v2 then
					if object.Fighter.Target == object.Enemy and object.Enemy ~= nil then
						v2 = not object.Enemy.Destroyed

						if v2 then
							if object.EnemyHRP == nil then
								v2 = false
							else
								v2 = object.EnemyHRP.Parent ~= nil
							end
						end
					else
						v2 = false
					end
				end

				if v2 then
					local position = object.EnemyHRP.Position
					object.GoalPosition = Vector3.new(position.X, object.LaunchPosition.Y, position.Z)
				end

				local lerped = object.LaunchPosition:Lerp(object.GoalPosition, 1)
				MoveBall(object, object.PurpleBall, lerped, 1) -- equivalent call inferred; original call site unknown
				object.ImpactPosition = object.GoalPosition
				object.HitAt = os.clock()
				local v3 = object.ImpactPosition - object.ProjectileOrigin
				local v4 = math.max(75, v3.Magnitude)
				local unit = v3.Magnitude > 0.001 and v3.Unit or object.LaunchDirection
				object.EndPosition = object.ProjectileOrigin + unit * v4
				local impactPosition = object.ImpactPosition
				Explode(object, "PurpleExplosion", impactPosition, 1)
				Shake(object, impactPosition, 4.5, 0.45) -- equivalent call inferred; original call site unknown
				object:Blur({
					Position = impactPosition,
					MaxDistance = 100,
					Size = 20,
					InTime = 0.03,
					HoldTime = 0.05,
					OutTime = 0.2
				})
				object:Impact({
					Position = impactPosition,
					MaxDistance = 100,
					TintColor = Color3.fromRGB(145, 0, 255),
					Brightness = 0.1,
					Contrast = 0.8,
					Saturation = 0.2,
					HoldTime = 0.12,
					Duration = 0.35
				})
			end
		}
	}
}