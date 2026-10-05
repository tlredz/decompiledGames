local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCFinaleAdminAbuseConfig = require(script.Parent.WCFinaleAdminAbuseConfig)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local SoccerGoalsClient = {}
local v = {}
local v2 = {}
local v3 = {}
local v4 = nil
local v5 = false
local maid = Janitor.new()

local function getBallTemplate()
	local wCFinaleAdminAbuse = adminAbuse:FindFirstChild("WCFinaleAdminAbuse")

	if not wCFinaleAdminAbuse then
		warn("[WCFinaleAdminAbuse] SoccerGoalsClient: RS.AdminAbuse.WCFinaleAdminAbuse folder not found (Studio asset folder missing)")
		return nil
	end

	local assets = wCFinaleAdminAbuse:FindFirstChild("Assets")

	if not assets then
		warn("[WCFinaleAdminAbuse] SoccerGoalsClient: RS.AdminAbuse.WCFinaleAdminAbuse.Assets not found")
		return nil
	end

	local soccerBall = assets:FindFirstChild("SoccerBall")

	if not soccerBall then
		warn("[WCFinaleAdminAbuse] SoccerGoalsClient: RS.AdminAbuse.WCFinaleAdminAbuse.Assets.SoccerBall not found")
	end

	return soccerBall
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBallPosition(instance)
	if instance:IsA("Model") then
		local primaryPart = instance.PrimaryPart

		if primaryPart then
			return primaryPart.Position
		end

		return instance:GetPivot().Position
	elseif instance:IsA("BasePart") then
		return instance.Position
	else
		return createVector(0, 0, 0)
	end
end

local function moveBallTo(instance, position: Vector3)
	if instance:IsA("Model") then
		instance:PivotTo(CFrame.new(position))
	elseif instance:IsA("BasePart") then
		instance.CFrame = CFrame.new(position)
	end
end

local function setBallTransparency(folder, transparency: number)
	if folder:IsA("BasePart") then
		folder.Transparency = transparency
	elseif folder:IsA("Model") then
		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = transparency
			end
		end
	end
end

local function playKickAnim(character)
	local kickAnimId = WCFinaleAdminAbuseConfig.SoccerGoals.kickAnimId

	if type(kickAnimId) ~= "string" or kickAnimId == "" then
		print("[WCFinaleAdminAbuse][SoccerGoals] playKickAnim: skipped (kickAnimId empty in config — Studio hasn't set one yet)")
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		warn("[WCFinaleAdminAbuse][SoccerGoals] playKickAnim: no Humanoid/Animator on", character:GetFullName())
		return
	end

	local success, result = pcall(function()
		local animation = Instance.new("Animation")
		animation.AnimationId = kickAnimId
		return animator:LoadAnimation(animation)
	end)

	if not (success and result) then
		warn("[WCFinaleAdminAbuse][SoccerGoals] playKickAnim: LoadAnimation failed for", kickAnimId, result)
		return
	end

	result.Priority = Enum.AnimationPriority.Action
	result:Play()
	print("[WCFinaleAdminAbuse][SoccerGoals] playKickAnim: playing", kickAnimId)
end

local function screenShake(p: number, p2: number)
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	task.spawn(function()
		local total = 0

		while total < p do
			total += task.wait()
			local v6 = 1 - total / p
			humanoid.CameraOffset = Vector3.new(math.sin(total * 43) * v6 * p2, math.sin(total * 29) * v6 * p2, 0)
		end

		humanoid.CameraOffset = createVector(0, 0, 0)
	end)
end

local function playExplosion(result)
	local emitters = {}

	for _, emitter in result:GetChildren() do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "Explosions" then
			table.insert(emitters, emitter)
		end
	end

	for _, emitter in emitters do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Explosions") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(30)
	end
end

local function bezierPoint(ballPosition: Vector3, vector2: Vector3, vector3: Vector3, p: number)
	return ballPosition:Lerp(vector2, p):Lerp(vector2:Lerp(vector3, p), p)
end

local function travelToTarget(result, position: Vector3, fn)
	local ballPosition = getBallPosition(result) -- equivalent call inferred; original call site unknown
	local vector2 = Vector3.new(math.random() * 2 - 1, 0, math.random() * 2 - 1)
	local unit = (vector2.Magnitude < 0.001 and createVector(1, 0, 0) or vector2).Unit
	local soccerGoals = WCFinaleAdminAbuseConfig.SoccerGoals
	local v6 = ballPosition:Lerp(position, 0.5) + unit * soccerGoals.curveSideOffsetStuds + Vector3.new(
		0,
		soccerGoals.curveHeightStuds,
		0
	)
	local v7 = soccerGoals.travelDurationMinSec + math.random() * (soccerGoals.travelDurationMaxSec - soccerGoals.travelDurationMinSec)
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		if not (result and result.Parent) then
			heartbeatConnection:Disconnect()
			return
		end

		total += dt
		local v8 = math.clamp(total / v7, 0, 1)
		moveBallTo(result, bezierPoint(ballPosition, v6, position, v8))

		if v8 >= 1 then
			heartbeatConnection:Disconnect()
			fn()
		end
	end)
	return heartbeatConnection
end

local spawnBallAtSlot

spawnBallAtSlot = function(instance)
	if not v5 then
		print("[WCFinaleAdminAbuse][SoccerGoals] spawnBallAtSlot skipped (_running=false):", instance:GetFullName())
		return
	end

	if v2[instance] then
		return
	end

	local v6 = v[instance]

	if not v6 then
		warn(
			"[WCFinaleAdminAbuse][SoccerGoals] spawnBallAtSlot: locationPart not in _slots at all (scan never registered it):",
			instance:GetFullName()
		)
		return
	end

	if not v6.Parent then
		warn(("[WCFinaleAdminAbuse][SoccerGoals] spawnBallAtSlot: target '%s' for %s was destroyed/unparented after scan (was valid at scan time)"):format(
			v6.Name,
			instance:GetFullName()
		))
		return
	end

	local ballTemplate = getBallTemplate()

	if not ballTemplate then
		return
	end

	local success, result = pcall(function()
		return ballTemplate:Clone()
	end)

	if not (success and result) then
		warn("[WCFinaleAdminAbuse][SoccerGoals] spawnBallAtSlot: template clone failed for", instance:GetFullName())
		return
	end

	moveBallTo(result, instance.Position)
	result.Parent = workspace
	v2[instance] = result
	local flag = false
	local touchedConnection = nil

	local function handleTouch(instance2)
		local character = Players.LocalPlayer.Character

		if not (character and instance2:IsDescendantOf(character)) or flag then
			return
		end

		flag = true

		if touchedConnection then
			touchedConnection:Disconnect()
		end

		v2[instance] = nil
		maid:Add(result)
		v3[instance] = task.delay(WCFinaleAdminAbuseConfig.SoccerGoals.respawnDelaySec, function()
			v3[instance] = nil
			spawnBallAtSlot(instance)
		end)
		playKickAnim(character)
		maid:Add((travelToTarget(result, v6.Position, function()
			if not (result and result.Parent) then
				warn("[WCFinaleAdminAbuse][SoccerGoals] ball missing/destroyed before arrival fx could play")
				return
			end

			setBallTransparency(result, 1)
			playExplosion(result)
			local character2 = Players.LocalPlayer.Character
			local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local v8 = 0.3
				local v9 = 0.25
				task.spawn(function()
					local total = 0

					while total < v8 do
						total += task.wait()
						local v10 = 1 - total / v8
						humanoid.CameraOffset = Vector3.new(
							math.sin(total * 43) * v10 * v9,
							math.sin(total * 29) * v10 * v9,
							0
						)
					end

					humanoid.CameraOffset = createVector(0, 0, 0)
				end)
			end

			if v4 then
				v4:FireServer()
			else
				warn("[WCFinaleAdminAbuse][SoccerGoals] no remote set — goal will not be reported to server")
			end

			local thread = task.delay(WCFinaleAdminAbuseConfig.SoccerGoals.fadeOutSec, function()
				pcall(function()
					result:Destroy()
				end)
			end)
			maid:Add(function()
				pcall(task.cancel, thread)
			end)
		end)))
	end

	if result:IsA("Model") then
		local primaryPart = result.PrimaryPart

		if primaryPart then
			touchedConnection = primaryPart.Touched:Connect(handleTouch)
		else
			warn(
				"[WCFinaleAdminAbuse][SoccerGoals] SoccerBall Model has no PrimaryPart set — Touched will never fire, ball is untouchable:",
				result:GetFullName()
			)
		end
	elseif result:IsA("BasePart") then
		touchedConnection = result.Touched:Connect(handleTouch)
	end
end

function SoccerGoalsClient.init(p)
	v4 = p
end

function SoccerGoalsClient.scan(instance)
	table.clear(v)
	local scriptables = instance:FindFirstChild("Scriptables")

	if not scriptables then
		warn("[WCFinaleAdminAbuse][SoccerGoals] scan: Scriptables not found under", instance:GetFullName())
		return
	end

	local ballLocations = scriptables:FindFirstChild("BallLocations")

	if not ballLocations then
		warn("[WCFinaleAdminAbuse][SoccerGoals] scan: BallLocations not found under", scriptables:GetFullName())
		return
	end

	local children = ballLocations:GetChildren()
	print(("[WCFinaleAdminAbuse][SoccerGoals] scan: BallLocations has %d children"):format(#children))

	for _, part in ipairs(children) do
		if part:IsA("BasePart") then
			local objectValue = part:FindFirstChildWhichIsA("ObjectValue")
			local value = objectValue and objectValue.Value

			if value and value:IsA("BasePart") then
				v[part] = value
				print(("[WCFinaleAdminAbuse][SoccerGoals] scan: %s -> target %s"):format(
					part:GetFullName(),
					value:GetFullName()
				))
			else
				warn(("[WCFinaleAdminAbuse][SoccerGoals] scan: %s has no valid ObjectValue target"):format(part:GetFullName()))
			end
		else
			warn(
				"[WCFinaleAdminAbuse][SoccerGoals] scan: non-BasePart child ignored:",
				part:GetFullName(),
				part.ClassName
			)
		end
	end

	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	print(("[WCFinaleAdminAbuse][SoccerGoals] scan complete: %d valid slot(s)"):format(count))
end

function SoccerGoalsClient.spawnAll()
	v5 = true
	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	print(("[WCFinaleAdminAbuse][SoccerGoals] spawnAll: spawning into %d slot(s)"):format(count))

	if count == 0 then
		warn("[WCFinaleAdminAbuse][SoccerGoals] spawnAll: _slots is empty — scan() found nothing, no balls will appear")
	end

	for k in pairs(v) do
		spawnBallAtSlot(k)
	end
end

function SoccerGoalsClient.stop()
	v5 = false

	for _, v6 in pairs(v3) do
		pcall(task.cancel, v6)
	end

	table.clear(v3)

	for _, v6 in pairs(v2) do
		local v7 = v6
		pcall(function()
			v7:Destroy()
		end)
	end

	table.clear(v2)
	table.clear(v)
	maid:Cleanup()
	v4 = nil
end

return SoccerGoalsClient