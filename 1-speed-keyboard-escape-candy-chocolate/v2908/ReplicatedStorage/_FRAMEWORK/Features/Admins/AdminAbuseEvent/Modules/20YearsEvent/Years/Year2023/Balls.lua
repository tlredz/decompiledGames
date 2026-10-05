local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local BallMotion = require(script.Parent.BallMotion)
local Config = require(script.Parent.Config)
local Fling = require(script.Parent.Fling)
require(script.Parent.Types)

local function getLiveBody(player)
	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and humanoid.Health > 0 then
		return humanoidRootPart, humanoid
	end

	return nil, nil
end

return {
	start = function(p)
		local remotes = p.remotes
		local v = Fling.start()
		local v2 = {}
		local random = Random.new()
		local count = 0

		local function isHittable(p2, p3)
			return p2 ~= p3 and not v.isImmune(p2)
		end

		local function findTarget(player, humanoidRootPart)
			local lookVector = humanoidRootPart.CFrame.LookVector
			local targetRangeStuds = Config.targetRangeStuds
			local v3 = nil
			local v4 = nil

			for _, v5 in Players:GetPlayers() do
				local character = v5.Character
				local humanoidRootPart2

				if character then
					humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
				end

				local humanoid

				if character then
					humanoid = character:FindFirstChildOfClass("Humanoid")
				end

				if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart") and humanoid and humanoid.Health > 0) then
					humanoidRootPart2 = nil
				end

				if not humanoidRootPart2 then
					continue
				end

				local v6

				if v5 == player then
					v6 = false
				else
					v6 = not v.isImmune(v5)
				end

				if not v6 then
					continue
				end

				local v7 = humanoidRootPart2.Position - humanoidRootPart.Position
				local magnitude = v7.Magnitude

				if not (magnitude > 0 and magnitude <= targetRangeStuds and lookVector:Dot(v7 / magnitude) >= Config.targetConeDot) then
					continue
				end

				v4 = humanoidRootPart2
				v3 = v5
				targetRangeStuds = magnitude
			end

			return v3, v4
		end

		local function findHit(state)
			for _, v3 in Players:GetPlayers() do
				local character = v3.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				local humanoid

				if character then
					humanoid = character:FindFirstChildOfClass("Humanoid")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and humanoid.Health > 0) then
					humanoidRootPart = nil
					humanoid = nil
				end

				if not humanoidRootPart then
					continue
				end

				local v4

				if v3 == state.shooter then
					v4 = false
				else
					v4 = not v.isImmune(v3)
				end

				if v4 and (humanoidRootPart.Position - state.position).Magnitude <= Config.hitRadiusStuds then
					return v3, humanoidRootPart, humanoid
				end
			end

			return nil, nil, nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function endBall(p2: number)
			v2[p2] = nil
			remotes.ballEnded:fireAll(p2)
		end

		local function stepBall(k: number, state, dt: number)
			local humanoidRootPart

			if state.target then
				local character = state.target.Character

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				local humanoid

				if character then
					humanoid = character:FindFirstChildOfClass("Humanoid")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and humanoid.Health > 0) then
					humanoidRootPart = nil
				end
			end

			local position = state.position
			state.age += dt
			local positionAt = BallMotion.positionAt
			local flight = state.flight
			local age = state.age
			local v3

			if humanoidRootPart then
				v3 = humanoidRootPart.Position
			end

			state.position = positionAt(flight, age, v3)
			local hit, v4, v5 = findHit(state)

			if hit then
				v.fling(hit, v4, v5, state.position - position)

				if state.shooter.Parent then
					p.awardWin(state.shooter)
				end

				endBall(k) -- equivalent call inferred; original call site unknown
			elseif state.age >= state.flight.duration then
				endBall(k) -- equivalent call inferred; original call site unknown
			end
		end

		local function launch(player)
			local character = player.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and humanoid.Health > 0) then
				humanoidRootPart = nil
			end

			if humanoidRootPart then
				local lookVector = humanoidRootPart.CFrame.LookVector
				local position = humanoidRootPart.Position + lookVector * Config.launchForwardStuds + createVector(
					0,
					1,
					0
				) * Config.launchUpStuds
				local target, v4 = findTarget(player, humanoidRootPart)
				local v5

				if v4 then
					v5 = v4.Position
				else
					v5 = position + lookVector * Config.noTargetRangeStuds
				end

				local plan = BallMotion.plan(position, v5, random)
				count += 1
				v2[count] = {
					shooter = player,
					target = target,
					flight = plan,
					age = 0,
					position = position
				}
				local ballLaunched = remotes.ballLaunched
				local v6 = {
					id = count,
					flight = plan,
					targetUserId = 0,
					serverTime = 0
				}
				local targetUserId

				if target then
					targetUserId = target.UserId
				end

				v6.targetUserId = targetUserId
				v6.serverTime = Workspace:GetServerTimeNow()
				ballLaunched:fireAll(v6)
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			for k, v3 in v2 do
				stepBall(k, v3, dt)
			end
		end)
		return {
			launch = launch,
			stop = function()
				heartbeatConnection:Disconnect()
				table.clear(v2)
				v.stop()
			end
		}
	end
}