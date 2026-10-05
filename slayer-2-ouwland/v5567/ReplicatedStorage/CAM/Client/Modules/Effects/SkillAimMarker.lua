local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage:FindFirstChild("Assets")
assert(assets, "Assets folder missing.")
local aim_part_thing = assets:FindFirstChild("aim_part_thing")
assert(aim_part_thing, "aim_part_thing missing.")
local ground_aim_effect = assets:FindFirstChild("ground_aim_effect")
assert(ground_aim_effect, "ground_aim_effect missing.")
local ground_aim_beam = assets:FindFirstChild("ground_aim_beam")
assert(ground_aim_beam, "ground_aim_beam missing.")
local debree = workspace:FindFirstChild("Debree")
assert(debree, "debree folder not found")
local skillAimMarker = debree:FindFirstChild("SkillAimMarker")
assert(skillAimMarker, "SkillAimMarker folder missing")

function Bezier_Curve_beam_curve_calc(vector2: Vector3, vector3: Vector3, p: number)
	local midpoint = (vector2 + vector3) / 2
	local vector4 = vector.create(midpoint.x, midpoint.y + p, midpoint.z)
	return
		vector4 * 0.6666666666666666 + vector2 * 0.3333333333333333,
		vector4 * 0.6666666666666666 + vector3 * 0.3333333333333333
end

local SkillAimMarker = {}
SkillAimMarker.__index = SkillAimMarker

local function applyEmitterOverrides(particleEmitter, emitter)
	if not emitter then
		return
	end

	for k, item in emitter do
		local v = k
		local v2 = item

		if pcall(function()
			particleEmitter[v] = v2
		end) then
			continue
		end

		warn((`AimMarker: Failed to set emitter property {k}`))
	end
end

local function getOptionsToggle(p)
	if p == nil then
		return nil, false
	end

	if type(p) == "boolean" then
		return nil, p
	end

	return p, true
end

local function resolveParent(p, p2)
	return p or p2
end

function SkillAimMarker.new(options)
	local self = setmetatable({
		_isactive = true
	}, SkillAimMarker)
	local v = options or {}
	local parent = v.Parent or skillAimMarker
	self._parent = parent
	local dot = v.Dot
	local v2

	if dot == nil then
		v2 = false
		dot = nil
	elseif type(dot) == "boolean" then
		v2 = dot
		dot = nil
	else
		v2 = true
	end

	if v2 then
		local clone = aim_part_thing:Clone()
		clone.Parent = dot and dot.Parent or parent
		self._marker = clone
		local center2 = clone:FindFirstChild("center2")

		if center2 then
			local color = dot and dot.Color
			local radius = dot and dot.Radius

			if center2:IsA("ParticleEmitter") then
				if color then
					center2.Color = ColorSequence.new(color)
				end

				if radius then
					center2.Size = NumberSequence.new(radius * 2)
				end

				center2:Emit(1)
			elseif center2:IsA("BasePart") then
				if color then
					center2.Color = color
				end

				if radius then
					local v3 = radius * 2
					center2.Size = Vector3.new(v3, center2.Size.Y, v3)
				end
			end
		end
	end

	local ground = v.Ground
	local v3

	if ground == nil then
		ground = nil
		v3 = false
	elseif type(ground) == "boolean" then
		v3 = ground
		ground = nil
	else
		v3 = true
	end

	local cFrame

	if ground then
		cFrame = ground.CFrame or nil
	end

	if ground_aim_effect == nil then
		v3 = false
	end

	if v3 then
		local clone = ground_aim_effect:Clone()
		clone.Parent = ground and ground.Parent or parent
		self._ground = clone
		local particleEmitter = clone:FindFirstChildWhichIsA("ParticleEmitter", true)

		if particleEmitter then
			if ground then
				if ground.Radius then
					particleEmitter.Size = NumberSequence.new(ground.Radius)
				end

				if ground.Color then
					if typeof(ground.Color) == "ColorSequence" then
						particleEmitter.Color = ground.Color
					else
						particleEmitter.Color = ColorSequence.new(ground.Color)
					end
				end

				if ground.LifeTime then
					if type(ground.LifeTime) == "number" then
						particleEmitter.Lifetime = NumberRange.new(ground.LifeTime)
					else
						particleEmitter.Lifetime = ground.LifeTime
					end
				end
			end

			applyEmitterOverrides(particleEmitter, ground and ground.Emitter)
			local v4 = not ground and 1 or ground.EmitCount or 1
			local emitGap = ground and ground.EmitGap

			if v4 <= 1 or not emitGap or emitGap <= 0 then
				particleEmitter:Emit(v4)
			else
				task.spawn(function()
					for i = 1, v4 do
						particleEmitter:Emit(1)

						if i < v4 then
							task.wait(emitGap)
						end
					end
				end)
			end
		end

		if cFrame then
			clone:PivotTo(cFrame)
		end
	end

	local groundCircle = v.GroundCircle
	local v4

	if groundCircle == nil then
		groundCircle = nil
		v4 = false
	elseif type(groundCircle) == "boolean" then
		v4 = groundCircle
		groundCircle = nil
	else
		v4 = true
	end

	local cFrame2

	if groundCircle then
		cFrame2 = groundCircle.CFrame or nil
	end

	if ground_aim_effect == nil then
		v4 = false
	end

	if v4 then
		local clone = ground_aim_effect:Clone()
		clone.Parent = groundCircle and groundCircle.Parent or parent
		self._circle = clone
		local particleEmitter = clone:FindFirstChildWhichIsA("ParticleEmitter", true)

		if groundCircle and particleEmitter then
			if groundCircle.Radius then
				particleEmitter.Size = NumberSequence.new(groundCircle.Radius)
			end

			if groundCircle.Color then
				if typeof(groundCircle.Color) == "Color3" then
					particleEmitter.Color = ColorSequence.new(groundCircle.Color)
				else
					particleEmitter.Color = groundCircle.Color
				end
			end
		end

		if particleEmitter then
			particleEmitter.Enabled = false
			particleEmitter:Emit(particleEmitter:GetAttribute("EmitCount") or 1)
		end

		if cFrame2 then
			clone:PivotTo(cFrame2)
		end
	end

	local highlight = v.Highlight
	local v5

	if highlight == nil then
		v5 = false
		highlight = nil
	elseif type(highlight) == "boolean" then
		v5 = highlight
		highlight = nil
	else
		v5 = true
	end

	if v5 then
		local highlight2 = Instance.new("Highlight")
		highlight2.FillColor = highlight and highlight.FillColor or Color3.fromRGB(180, 180, 255)
		highlight2.DepthMode = highlight and highlight.DepthMode or Enum.HighlightDepthMode.Occluded
		highlight2.OutlineColor = highlight and highlight.OutlineColor or Color3.fromRGB(196, 225, 255)
		highlight2.FillTransparency = not highlight and 0.85 or highlight.FillTransparency or 0.85
		highlight2.OutlineTransparency = not highlight and 0 or highlight.OutlineTransparency or 0
		local parent2 = highlight and highlight.Parent or parent
		highlight2.Parent = parent2
		self._highlight = highlight2
		self._highlightParent = parent2
	end

	local beam = v.Beam
	local v6

	if beam == nil then
		v6 = false
		beam = nil
	elseif type(beam) == "boolean" then
		v6 = beam
		beam = nil
	else
		v6 = true
	end

	if not v6 or beam.Part0 == nil or beam.Part1 == nil then
		return self
	end

	local clone = ground_aim_beam:Clone()
	self._beam = {
		Beam = clone,
		At1 = Instance.new("Attachment"),
		At2 = Instance.new("Attachment"),
		height = beam.Height or 30
	}

	if beam.Properties ~= nil then
		if beam.Properties.Color ~= nil then
			beam.Properties.Color = ColorSequence.new(beam.Properties.Color)
		end

		for k, property in beam.Properties do
			clone[k] = property
		end
	end

	self._beam.At1.Parent = beam.Part0

	if beam.C0 then
		self._beam.At1.CFrame = beam.C0
	end

	self._beam.At2.Parent = beam.Part1

	if beam.C1 then
		self._beam.At2.CFrame = beam.C1
	end

	clone.Parent = beam.Parent or parent or beam.Part0
	clone.Attachment0 = self._beam.At1
	clone.Attachment1 = self._beam.At2
	return self
end

local cframe = CFrame.Angles(0, 1.5707963267948966, 0)

function SkillAimMarker:Update(options)
	local v = options or {}
	local _marker = self._marker
	local v2 = options ~= nil

	if _marker and v2 and v.position ~= nil then
		_marker:PivotTo(CFrame.new(v.position))
	end

	if self._circle and v2 and v.groundCircleCFrame ~= nil then
		self._circle:PivotTo(v.groundCircleCFrame)
	end

	local _highlight = self._highlight

	if _highlight then
		local target

		if v2 then
			target = v.target or nil
		end

		_highlight.Adornee = target

		if target and target.Parent then
			_highlight.Parent = target
		else
			_highlight.Parent = self._highlightParent or self._parent
		end
	end

	local _beam = self._beam

	if _beam then
		local startpos = v.startpos or _beam.startpos
		local goalpos = v.goalpos or _beam.goalpos
		local height = v.height or _beam.height
		_beam.startpos = startpos
		_beam.goalpos = goalpos
		_beam.height = height

		if v.startpos ~= nil or v.goalpos ~= nil or v.height then
			local v3, v4 = Bezier_Curve_beam_curve_calc(startpos, goalpos, height)
			_beam.Beam.CurveSize0 = (v3 - startpos).Magnitude
			_beam.Beam.CurveSize1 = (v4 - goalpos).Magnitude
			_beam.At1.WorldCFrame = CFrame.new(startpos, v3) * cframe
			_beam.At2.WorldCFrame = CFrame.new(goalpos, v4) * cframe:Inverse()
			return
				_beam.At1.WorldPosition,
				(_beam.At1.WorldCFrame * CFrame.new(_beam.Beam.CurveSize0, 0, 0)).p,
				(_beam.At2.WorldCFrame * CFrame.new(-_beam.Beam.CurveSize1, 0, 0)).p,
				_beam.At2.WorldPosition
		end
	end
end

function SkillAimMarker:Destroy()
	local _marker = self._marker

	if _marker then
		_marker:Destroy()
		self._marker = nil
	end

	local _ground = self._ground

	if _ground then
		_ground:Destroy()
		self._ground = nil
	end

	local _circle = self._circle

	if _circle then
		_circle:Destroy()
		self._circle = nil
	end

	local _highlight = self._highlight

	if _highlight then
		_highlight:Destroy()
		self._highlight = nil
	end

	self._isactive = nil

	if self._beam then
		self._beam.Beam:Destroy()
		self._beam.At1:Destroy()
		self._beam.At2:Destroy()
		self._beam = nil
	end
end

return SkillAimMarker