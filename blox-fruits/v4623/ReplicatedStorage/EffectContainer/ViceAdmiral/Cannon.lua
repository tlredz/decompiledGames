local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local currentCamera = workspace.CurrentCamera
local cframe = CFrame.Angles(0, -1.5707963267948966, 0)
local model = nil

local function getTemplate()
	if model and model.Parent then
		return model
	end

	model = script:FindFirstChildWhichIsA("Model") or script.Parent and script.Parent:FindFirstChildWhichIsA("Model")
	return model
end

local function easeOutBack(p: number)
	return (p - 1) ^ 3 * 2.70158 + 1 + (p - 1) ^ 2 * 1.70158
end

local function easeOutQuad(p: number)
	return 1 - (1 - p) * (1 - p)
end

local function lerpPivot(clone, cframe2: CFrame, cframe3: CFrame, p: number, callback)
	local total = 0

	while total < p do
		if not clone.Parent then
			return
		end

		local v = math.clamp(total / p, 0, 1)

		if callback then
			v = callback(v) or v
		end

		clone:PivotTo(cframe2:Lerp(cframe3, v))
		total += RunService.Heartbeat:Wait()
	end

	if clone.Parent then
		clone:PivotTo(cframe3)
	end
end

return function(data)
	local hole = data.hole
	local impact = data.impact

	if typeof(hole) ~= "CFrame" or typeof(impact) ~= "Vector3" then
		return
	end

	if not (model and model.Parent) then
		model = script:FindFirstChildWhichIsA("Model") or script.Parent and script.Parent:FindFirstChildWhichIsA("Model")
	end

	local v = model

	if not v then
		warn("[Vice Admiral] Cannon effect: no Model found under the effect module")
		return
	end

	if (hole.Position - currentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local emergeTime = data.emergeTime or 0.5
	local aimTime = data.aimTime or 0.35
	local fireDelay = data.fireDelay or 0.15
	local target = data.target
	local spread = data.spread or createVector(0, 0, 0)
	local position = hole.Position

	-- equivalent calls inferred from this helper; original call sites unknown
	local function currentImpact()
		if target and target.Parent then
			return target.Position + spread
		end

		return impact
	end

	local function mount(cframe2: CFrame, p: number)
		return cframe2 * CFrame.new(0, 0, -p) * cframe
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function aimCFat(vector2: Vector3)
		return CFrame.new(position, vector2)
	end

	local vector2 = Vector3.new(impact.X, position.Y, impact.Z)

	if (vector2 - position).Magnitude < 0.1 then
		vector2 = position + hole.LookVector
	end

	local v2 = aimCFat(vector2) -- equivalent call inferred; original call site unknown
	local clone = v:Clone()
	clone:ScaleTo(0.8)
	local transparenciesByPart = {}

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		transparenciesByPart[part] = part.Transparency
		part.Transparency = 1
	end

	clone:PivotTo(v2 * CFrame.new(0, 0, 7) * cframe)
	clone.Parent = _WorldOrigin
	sound:Play("GroundSmash", position)

	for k, transparency in pairs(transparenciesByPart) do
		TweenService:Create(k, TweenInfo.new(emergeTime), {
			Transparency = transparency
		}):Play()
	end

	task.spawn(function()
		lerpPivot(clone, v2 * CFrame.new(0, 0, 7) * cframe, v2 * CFrame.new(0, 0, -2) * cframe, emergeTime, easeOutBack)
		local total = 0

		while total < aimTime do
			if not clone.Parent then
				return
			end

			local v4 = currentImpact() -- equivalent call inferred; original call site unknown
			clone:PivotTo(CFrame.new(position, v4) * CFrame.new(0, 0, -2) * cframe)
			total += RunService.Heartbeat:Wait()
		end

		task.wait(fireDelay)
		local v3 = currentImpact() -- equivalent call inferred; original call site unknown
		local v4 = CFrame.new(position, v3) * CFrame.new(0, 0, -2) * cframe
		lerpPivot(clone, v4, v4 * CFrame.new(0, 0, 1.2), 0.06, nil)
		lerpPivot(clone, v4 * CFrame.new(0, 0, 1.2), v4, 0.22, easeOutQuad)
		task.wait(1)

		if not clone.Parent then
			return
		end

		lerpPivot(clone, v4, v2 * CFrame.new(0, 0, -2) * cframe, 0.25, easeOutQuad)
		lerpPivot(clone, v2 * CFrame.new(0, 0, -2) * cframe, v2 * CFrame.new(0, 0, 7) * cframe, 0.35, easeOutQuad)
		clone:Destroy()
	end)
end