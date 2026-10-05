local createVector = vector.create
local ScrambleDroneMotion = require(game.ReplicatedStorage.Shared.Util.ScrambleDroneMotion)
return {
	new = function(instance, instance2, parent)
		local clone = instance2:Clone()
		local parts = {}
		local hitbox = clone:FindFirstChild("Hitbox")

		if hitbox then
			hitbox:Destroy()
		end

		clone.Name = "DroneVisual_" .. tostring(instance:GetAttribute("ScrambleDroneId"))

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = part == clone.PrimaryPart
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.LocalTransparencyModifier = 1
			table.insert(parts, part)
		end

		local v = ScrambleDroneMotion.Read(instance)

		if v then
			clone:PivotTo(v.From)
		end

		clone.Parent = parent
		local v2 = {
			Rig = clone,
			Root = clone.PrimaryPart,
			Tracks = {},
			State = ScrambleDroneMotion.Read(instance),
			LastAnimation = nil,
			Visible = false,
			Transparency = 1
		}
		local animator = clone.AnimationController.Animator

		for _, animation in clone.Animations:GetChildren() do
			if not animation:IsA("Animation") then
				continue
			end

			local success, result = pcall(animator.LoadAnimation, animator, animation)

			if success then
				result.Looped = animation.Name == "Idle" or animation.Name == "Walk"
				local action4

				if animation.Name == "Death" then
					action4 = Enum.AnimationPriority.Action4
				elseif animation.Name == "Attack" then
					action4 = Enum.AnimationPriority.Action
				else
					action4 = Enum.AnimationPriority.Movement
				end

				result.Priority = action4
				v2.Tracks[animation.Name] = result
			else
				warn("[Scramble] animation failed", animation.AnimationId, result)
			end
		end

		local hitbox2 = instance:FindFirstChild("Hitbox")

		local function latchDeath(state)
			if v2.Dead then
				return
			end

			v2.Dead = true
			v2.Velocity = createVector(0, 0, 0)
			local v3 = v2
			v2.Recoil = createVector(0, 0, 0)
			v3.RecoilVelocity = createVector(0, 0, 0)
			local animationAt

			if state and state.Name == "Death" then
				animationAt = state.AnimationAt
			else
				animationAt = workspace:GetServerTimeNow()
			end

			local cFrame = v2.Root.CFrame
			v2.State = {
				Name = "Death",
				At = animationAt,
				AnimationAt = animationAt,
				Duration = instance2.Animations.Death:GetAttribute("Duration") or 3,
				From = cFrame,
				To = cFrame
			}
		end

		local function acceptState(state)
			if state and state.Name == "Death" or instance:GetAttribute("DroneState") == "Death" or hitbox2 and (hitbox2:GetAttribute("Health") or 1) <= 0 then
				latchDeath(state)
			elseif not v2.Dead and state and (not v2.State or state.At >= v2.State.At) then
				v2.State = state
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function readState()
			acceptState(ScrambleDroneMotion.Read(instance))
		end

		function v2:ReceiveHit(p)
			local decoded = ScrambleDroneMotion.Decode(p)
			acceptState(decoded)

			if self.Dead or not decoded or self.State and decoded.At < self.State.At then
				return
			end

			if decoded.Name == "Knockback" and decoded.At ~= self.LastImpactAt then
				self.LastImpactAt = decoded.At
				local v3 = decoded.To.Position - decoded.From.Position
				local vector2 = Vector3.new(v3.X, 0, v3.Z)

				if vector2.Magnitude > 0.01 then
					local cross = (createVector(0, 1, 0)):Cross(vector2.Unit)
					local recoilVelocity = (self.RecoilVelocity or createVector(0, 0, 0)) + cross * 3.3

					if recoilVelocity.Magnitude > 4.8 then
						recoilVelocity = recoilVelocity.Unit * 4.8
					end

					self.RecoilVelocity = recoilVelocity
				end
			end
		end

		v2.Connection = instance:GetAttributeChangedSignal("DroneMotion"):Connect(readState)
		v2.DeathConnection = instance:GetAttributeChangedSignal("DroneState"):Connect(readState)
		v2.HealthConnection = hitbox2 and hitbox2:GetAttributeChangedSignal("Health"):Connect(readState)
		readState() -- equivalent call inferred; original call site unknown

		function v2:Step(p, lastStepAt: number, visible: boolean)
			local state2 = self.State
			local v3

			if visible and state2 and state2.Name == "Death" then
				local v4 = math.clamp(
					(lastStepAt - state2.AnimationAt - state2.Duration) / ScrambleDroneMotion.DeathFadeSeconds,
					0,
					1
				)
				v3 = v4 * v4 * (3 - v4 * 2)
			else
				v3 = visible and 0 or 1
			end

			if self.Transparency ~= v3 then
				self.Transparency = v3

				for _, v4 in parts do
					v4.LocalTransparencyModifier = v3
				end
			end

			local presented = ScrambleDroneMotion.Pose(state2, p, lastStepAt)
			local v4 = math.max(0, lastStepAt - (self.LastStepAt or lastStepAt))
			self.LastStepAt = lastStepAt

			if state2 and state2.Name == "Death" then
				self.Presented = presented
				self.Velocity = createVector(0, 0, 0)
			elseif visible and self.Visible and self.Presented and not (v4 > 0.25) then
				local v5 = self.Presented.Position - presented.Position
				local velocity = self.Velocity or createVector(0, 0, 0)
				local v6 = velocity + v5 * 12
				local v7 = math.exp(v4 * -12)
				local v8 = presented.Position + (v5 + v6 * v4) * v7
				self.Velocity = (velocity - v6 * 12 * v4) * v7
				local lerped = self.Presented.Rotation:Lerp(presented.Rotation, 1 - v7)
				self.Presented = CFrame.new(v8) * lerped
				presented = self.Presented
			else
				self.Presented = presented
				self.Velocity = createVector(0, 0, 0)
			end

			if self.Dead or not (visible and v4 <= 0.25) then
				self.Recoil = createVector(0, 0, 0)
				self.RecoilVelocity = createVector(0, 0, 0)
			else
				local recoil = self.Recoil or createVector(0, 0, 0)
				local recoilVelocity = self.RecoilVelocity or createVector(0, 0, 0)
				local v5 = recoilVelocity + recoil * 11
				local v6 = math.exp(v4 * -11)
				local recoil2 = (recoil + v5 * v4) * v6
				self.RecoilVelocity = (recoilVelocity - v5 * 11 * v4) * v6
				self.Recoil = recoil2
				local magnitude = recoil2.Magnitude

				if magnitude > 0.0001 then
					presented = CFrame.new(presented.Position) * CFrame.fromAxisAngle(
						recoil2.Unit,
						(math.min(magnitude, 0.20943951023931956))
					) * presented.Rotation
				end
			end

			local v5 = (not state2 or state2.Name == "Knockback") and "Idle" or (state2.Name == "Chase" or state2.Name == "Return") and "Walk" or state2.Name
			local lastAnimation

			if v5 == "Idle" or v5 == "Walk" then
				lastAnimation = v5
			else
				lastAnimation = v5 .. ":" .. tostring(not state2 and 0 or state2.AnimationAt or 0)
			end

			if visible then
				if self.LastAnimation ~= lastAnimation then
					for k, track in self.Tracks do
						if k ~= v5 then
							track:Stop(0.12)
						end
					end

					local track = self.Tracks[v5]

					if track then
						track:Play(0.12, 1, 1)
						self.SyncTrack = track
						local v8

						if state2 then
							v8 = state2.AnimationAt or lastStepAt
						else
							v8 = lastStepAt
						end

						local v9 = math.max(0, lastStepAt - v8)

						if track.Length > 0 then
							self.SyncTrack = nil
							local timePosition

							if track.Looped then
								timePosition = v9 % track.Length
							else
								timePosition = math.min(v9, (math.max(0, track.Length - 0.02)))
							end

							track.TimePosition = timePosition
						end
					end

					self.LastAnimation = lastAnimation
				end
			elseif self.Visible then
				for _, track in self.Tracks do
					track:Stop(0)
				end

				self.LastAnimation = nil
			end

			local syncTrack = self.SyncTrack

			if visible and syncTrack and syncTrack.Length > 0 then
				local v8

				if state2 then
					v8 = state2.AnimationAt or lastStepAt
				else
					v8 = lastStepAt
				end

				local v9 = math.max(0, lastStepAt - v8)
				local timePosition

				if syncTrack.Looped then
					timePosition = v9 % syncTrack.Length
				else
					timePosition = math.min(v9, (math.max(0, syncTrack.Length - 0.02)))
				end

				syncTrack.TimePosition = timePosition
				self.SyncTrack = nil
			end

			self.Visible = visible
			local death = self.Tracks.Death

			if not visible or v5 ~= "Death" or not (death and death.Length > 0 and lastStepAt - state2.AnimationAt >= death.Length - 0.08) then
				return presented
			end

			if not death.IsPlaying then
				death:Play(0, 1, 1)
			end

			death.TimePosition = math.max(0, death.Length - 0.03)
			death:AdjustSpeed(0)
			return presented
		end

		function v2:Destroy()
			self.Connection:Disconnect()
			self.DeathConnection:Disconnect()

			if self.HealthConnection then
				self.HealthConnection:Disconnect()
			end

			for _, track in self.Tracks do
				track:Stop(0)
				track:Destroy()
			end

			self.Rig:Destroy()
		end

		return v2
	end
}