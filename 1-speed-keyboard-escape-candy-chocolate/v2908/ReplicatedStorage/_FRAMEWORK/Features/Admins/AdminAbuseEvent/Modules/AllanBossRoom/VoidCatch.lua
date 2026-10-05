local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Interpolate = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Interpolate)
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function getLocalCharacterParts()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if character then
		return character, humanoidRootPart, (character:FindFirstChildOfClass("Humanoid"))
	end

	return character, humanoidRootPart, nil
end

local function isWithinSafeMargin(voidTrigger, position: Vector3, safeMarginStuds: number)
	local pointToObjectSpace = voidTrigger.CFrame:PointToObjectSpace(position)
	local halfSize = voidTrigger.Size / 2
	local vector2 = Vector3.new(
		math.clamp(pointToObjectSpace.X, -halfSize.X, halfSize.X),
		math.clamp(pointToObjectSpace.Y, -halfSize.Y, halfSize.Y),
		(math.clamp(pointToObjectSpace.Z, -halfSize.Z, halfSize.Z))
	)
	return (position - voidTrigger.CFrame:PointToWorldSpace(vector2)).Magnitude <= safeMarginStuds
end

return {
	start = function(data)
		assert(RunService:IsClient(), "AllanBossRoom.VoidCatch.start is client-only")
		local logger = data.logger
		local v = {}
		local v2 = false
		local v3 = nil
		local touchedConnection = nil
		local v4 = false
		local lastTime = os.clock()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getStandingTarget()
			local v5 = v[1]

			if v5 then
				return v5.position
			end

			return nil
		end

		local function teleportBackToLastStanding()
			local character = Players.LocalPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			local standingTarget = getStandingTarget() -- equivalent call inferred; original call site unknown

			if v2 or not (character and humanoidRootPart and humanoid and standingTarget) then
				return
			end

			local v5 = assert(character, "AllanBossRoom.VoidCatch: local character went missing mid-catch")
			local v6 = assert(
				humanoidRootPart,
				"AllanBossRoom.VoidCatch: local HumanoidRootPart went missing mid-catch"
			)
			local v7 = assert(standingTarget, "AllanBossRoom.VoidCatch: no standing position recorded mid-catch")
			v2 = true

			if data.onCaught then
				data.onCaught()
			end

			v6.AssemblyLinearVelocity = createVector(0, 0, 0)
			v6.AssemblyAngularVelocity = createVector(0, 0, 0)
			local anchored = v6.Anchored
			v6.Anchored = true
			task.spawn(function()
				local v8 = v5
				local v9 = v6
				local v10 = v7
				local position = v9.Position
				local rotation = v8:GetPivot().Rotation
				local v11 = math.max(26, Vector3.new(v10.X - position.X, 0, v10.Z - position.Z).Magnitude * 0.45)
				local v12 = position + createVector(0, 1, 0) * v11
				local v13 = v10 + createVector(0, 1, 0) * v11
				local lastTime2 = os.clock()

				while v8.Parent and v9.Parent do
					local v14 = math.clamp((os.clock() - lastTime2) / 0.8, 0, 1)
					local value = TweenService:GetValue(v14, tweenInfo.EasingStyle, tweenInfo.EasingDirection)
					local cubicBezier = Interpolate.cubicBezier(position, v12, v13, v10, value)
					v8:PivotTo(CFrame.new(cubicBezier) * rotation)

					if v14 >= 1 then
						break
					else
						RunService.RenderStepped:Wait()
					end
				end

				if v9.Parent then
					v9.AssemblyLinearVelocity = createVector(0, 0, 0)
					v9.AssemblyAngularVelocity = createVector(0, 0, 0)
					v9.Anchored = anchored
				end

				table.clear(v)

				if v9.Parent then
					table.insert(v, {
						time = os.clock(),
						position = v9.Position
					})
				end

				v2 = false
			end)
		end

		local function onTriggerTouched(instance)
			local character = Players.LocalPlayer.Character

			if character ~= nil and instance:IsDescendantOf(character) then
				teleportBackToLastStanding()
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local voidTrigger = data.getVoidTrigger()
			local character = Players.LocalPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if not v2 and humanoidRootPart and humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
				local v5

				if voidTrigger == nil then
					v5 = false
				else
					v5 = isWithinSafeMargin(voidTrigger, humanoidRootPart.Position, data.safeMarginStuds)
				end

				if not v5 then
					local now = os.clock()
					table.insert(v, {
						time = now,
						position = humanoidRootPart.Position
					})

					while #v > 1 and now - v[1].time > data.standingHistorySeconds do
						table.remove(v, 1)
					end
				end
			end

			if touchedConnection and v3 and not v3.Parent then
				if logger then
					logger:warn((`VoidCatch: connected trigger '{v3:GetFullName()}' left the workspace, reconnecting`))
				end

				touchedConnection:Disconnect()
				touchedConnection = nil
				v3 = nil
			end

			if not touchedConnection then
				if voidTrigger then
					v3 = voidTrigger
					touchedConnection = voidTrigger.Touched:Connect(onTriggerTouched)
				elseif logger and not v4 and os.clock() - lastTime > 15 then
					v4 = true
					logger:warn("VoidCatch: could not resolve the VoidTrigger part after 15s — check Config.voidTriggerPath and the map's Scriptables folder")
				end
			end
		end)
		return {
			stop = function()
				heartbeatConnection:Disconnect()

				if touchedConnection then
					touchedConnection:Disconnect()
					touchedConnection = nil
				end

				v3 = nil
			end
		}
	end
}