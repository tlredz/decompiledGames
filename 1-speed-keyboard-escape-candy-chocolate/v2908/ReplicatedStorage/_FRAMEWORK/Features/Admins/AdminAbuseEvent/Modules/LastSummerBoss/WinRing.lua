local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local VFXUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VFXUtils)
local cframe = CFrame.Angles(3.141592653589793, 0, 0)

local function assertPositiveFinite(value: number, p: string)
	local v

	if type(value) == "number" and value > 0 then
		v = value < 1e999
	else
		v = false
	end

	assert(v, (`WinRing {p} must be a finite number greater than zero`))
end

local function createMotionLayers(p: number)
	local random = Random.new(p)
	local result = {}

	for i = 1, 5 do
		table.insert(result, {
			amplitude = 1 / i,
			xFrequency = random:NextNumber(0.35, 0.8) * (i * 0.1 + 1),
			zFrequency = random:NextNumber(0.35, 0.8) * (i * 0.1 + 1)
		})
	end

	return result
end

local function evaluateMovement(data, p: number)
	local v = math.max(0, p - data.startedAt) * data.speed
	local total = 0
	local total2 = 0
	local total3 = 0

	for _, layer in data.layers do
		total += math.sin(v * layer.xFrequency) * layer.amplitude
		total2 += math.sin(v * layer.zFrequency) * layer.amplitude
		total3 += layer.amplitude
	end

	local halfSurfaceSize = data.surfaceSize / 2
	return data.surfaceCenter + Vector3.new(total / total3 * halfSurfaceSize.X, 0, total2 / total3 * halfSurfaceSize.Z)
end

local function isLocalCharacterInside(position: Vector3, radius: number)
	local localPlayer = Players.LocalPlayer
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		local v = humanoidRootPart.Position - position
		return Vector3.new(v.X, 0, v.Z).Magnitude <= radius
	else
		return false
	end
end

local function setVisible(folder, flag: boolean)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = flag and 0 or 1
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		end
	end
end

local function applyWinMultiplierText(p, p2: number)
	if p2 == 1 then
		return
	end

	local potentialInstance = InstanceUtils.getPotentialInstance(p, "Root/BillboardGui/Top/TextLabel")

	if potentialInstance then
		potentialInstance.Text = `x{p2} WINS`
	end
end

local function playSpawnEffect(clone)
	local potentialInstance = InstanceUtils.getPotentialInstance(clone, "Root/Attachment")

	if not potentialInstance then
		return
	end

	VFXUtils.emitAttachment(potentialInstance)
	local potentialInstance2 = InstanceUtils.getPotentialInstance(
		ReplicatedStorage,
		"AdminAbuse/LastSummerBoss/SFX/MagicAppear"
	)

	if potentialInstance2 then
		local clone2 = potentialInstance2:Clone()
		Debris:AddItem(clone2, 6)
		clone2.PlaybackSpeed = 1
		clone2.RollOffMinDistance = 60
		clone2.RollOffMaxDistance = 250
		clone2.RollOffMode = Enum.RollOffMode.InverseTapered
		clone2.Parent = potentialInstance
		clone2:Play()
	end

	local pointLight = potentialInstance:FindFirstChild("PointLight")

	if pointLight then
		pointLight.Brightness = 50
		pointLight.Enabled = true
		TweenService:Create(pointLight, TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 1
		}):Play()
	end
end

return {
	new = function(data)
		assert(RunService:IsClient(), "WinRing.new can only be called on the client")
		assert(typeof(data.position) == "Vector3", "WinRing.new requires a Vector3 position")
		local winRing = ReplicatedStorage.AdminAbuse.LastSummerBoss.Assets:FindFirstChild("WinRing")
		assert(winRing and winRing:IsA("Model"), "LastSummerBoss.Assets.WinRing must be a Model")
		local cylinder = winRing:FindFirstChild("Cylinder")
		assert(cylinder and cylinder:IsA("BasePart"), "LastSummerBoss.Assets.WinRing.Cylinder must be a BasePart")
		local rotation

		if data.mountedOnCeiling then
			rotation = winRing:GetPivot().Rotation * cframe
		else
			rotation = winRing:GetPivot().Rotation
		end

		local v = math.max(cylinder.Size.X, cylinder.Size.Z) / 2
		local v2

		if type(v) == "number" and v > 0 then
			v2 = v < 1e999
		else
			v2 = false
		end

		assert(v2, "WinRing template radius must be a finite number greater than zero")
		assert(
			InstanceUtils.getPotentialInstance(winRing, "Root/BillboardGui/Bottom/ProgressBar/Bar"),
			"LastSummerBoss.Assets.WinRing progress bar was not found"
		)
		local radius = data.radius or v
		local v3 = radius
		local v4

		if type(v3) == "number" and v3 > 0 then
			v4 = v3 < 1e999
		else
			v4 = false
		end

		assert(v4, "WinRing radius must be a finite number greater than zero")
		local fillDurationSeconds = data.fillDurationSeconds
		local v5

		if type(fillDurationSeconds) == "number" and fillDurationSeconds > 0 then
			v5 = fillDurationSeconds < 1e999
		else
			v5 = false
		end

		assert(v5, "WinRing fill duration must be a finite number greater than zero")
		local depleteDurationSeconds = data.depleteDurationSeconds
		local v6

		if type(depleteDurationSeconds) == "number" and depleteDurationSeconds > 0 then
			v6 = depleteDurationSeconds < 1e999
		else
			v6 = false
		end

		assert(v6, "WinRing deplete duration must be a finite number greater than zero")
		local winMultiplier = data.winMultiplier
		local v7

		if type(winMultiplier) == "number" and winMultiplier > 0 then
			v7 = winMultiplier < 1e999
		else
			v7 = false
		end

		assert(v7, "WinRing win multiplier must be a finite number greater than zero")
		assert(type(data.onWin) == "function", "WinRing.new requires an onWin callback")
		local fillDurationSeconds2 = data.fillDurationSeconds
		local depleteDurationSeconds2 = data.depleteDurationSeconds
		local onWin = data.onWin
		local position = data.position
		local v8 = nil
		local v9 = 0
		local flag = false
		local clone = winRing:Clone()
		clone.Name = "WinRing"
		local winMultiplier2 = data.winMultiplier
		local v10 = winMultiplier2 ~= 1 and InstanceUtils.getPotentialInstance(clone, "Root/BillboardGui/Top/TextLabel")

		if v10 then
			v10.Text = `x{winMultiplier2} WINS`
		end

		local cylinder2 = clone:FindFirstChild("Cylinder")
		local potentialInstance = InstanceUtils.getPotentialInstance(clone, "Root/BillboardGui/Bottom/ProgressBar/Bar")
		local v11 = radius * 2
		cylinder2.Size = Vector3.new(v11, cylinder2.Size.Y, radius * 2)
		clone:PivotTo(CFrame.new(position) * rotation)
		clone.Parent = Workspace
		setVisible(clone, false)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyTransform()
			cylinder2.Size = Vector3.new(radius * 2, cylinder2.Size.Y, radius * 2)
			clone:PivotTo(CFrame.new(position) * rotation)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyWinProgress()
			local size = potentialInstance.Size
			potentialInstance.Size = UDim2.new(v9, 0, size.Y.Scale, size.Y.Offset)
		end

		applyWinProgress() -- equivalent call inferred; original call site unknown
		return {
			instance = clone,
			resize = function(value: number)
				local v12

				if type(value) == "number" and value > 0 then
					v12 = value < 1e999
				else
					v12 = false
				end

				assert(v12, "WinRing radius must be a finite number greater than zero")
				radius = value
				applyTransform() -- equivalent call inferred; original call site unknown
			end,
			setPosition = function(vector: Vector3)
				assert(typeof(vector) == "Vector3", "WinRing.setPosition requires a Vector3")
				v8 = nil
				position = vector
				applyTransform() -- equivalent call inferred; original call site unknown
			end,
			getPosition = function()
				return position
			end,
			startMovement = function(vector: Vector3, vector2: Vector3, startedAt: number, p2: number, speed: number)
				assert(typeof(vector) == "Vector3", "WinRing.startMovement requires a surface center")
				assert(typeof(vector2) == "Vector3", "WinRing.startMovement requires a surface size")
				local v12

				if type(speed) == "number" and speed > 0 then
					v12 = speed < 1e999
				else
					v12 = false
				end

				assert(v12, "WinRing movement speed must be a finite number greater than zero")
				v8 = {
					surfaceCenter = vector,
					surfaceSize = vector2,
					startedAt = startedAt,
					speed = speed,
					layers = createMotionLayers(p2)
				}
			end,
			stopMovement = function()
				v8 = nil
			end,
			update = function(p: number, p2: number)
				local v12 = v8

				if flag or not v12 then
					return
				end

				position = evaluateMovement(v12, p)
				applyTransform() -- equivalent call inferred; original call site unknown
				local v13

				if isLocalCharacterInside(position, radius) then
					v13 = math.max(0, p2) / fillDurationSeconds2
				else
					v13 = -math.max(0, p2) / depleteDurationSeconds2
				end

				v9 = math.clamp(v9 + v13, 0, 1)
				applyWinProgress() -- equivalent call inferred; original call site unknown

				if v9 >= 1 then
					v9 = 0
					applyWinProgress() -- equivalent call inferred; original call site unknown
					onWin()
				end
			end,
			Spawn = function(flag2: boolean?)
				if flag then
					return
				end

				setVisible(clone, true)

				if flag2 ~= false then
					playSpawnEffect(clone)
				end
			end,
			destroy = function()
				if flag then
					return
				end

				flag = true
				v8 = nil
				clone:Destroy()
			end
		}
	end
}