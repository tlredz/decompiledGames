local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage.Effect)
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
local Sound = require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local color = Color3.fromRGB(64, 68, 92)
local color2 = Color3.fromRGB(104, 108, 132)
local color3 = Color3.fromRGB(255, 244, 190)
local color4 = Color3.fromRGB(255, 196, 60)
local colors = {}
local sizes = {}
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function remember(p)
	if colors[p] == nil then
		colors[p] = p.Color
	end

	if sizes[p] == nil then
		sizes[p] = p.Size
	end
end

local function sparkPart(p)
	local v6 = v2[p]

	if v6 and v6.Parent then
		return v6
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopFade(p)
	local v6 = v4[p]

	if v6 then
		pcall(task.cancel, v6)
		v4[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeIn(p)
	stopFade(p) -- equivalent call inferred; original call site unknown
	v4[p] = task.spawn(function()
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.9 and p.Parent do
			p.LocalTransparencyModifier = 1 - (os.clock() - lastTime) / 0.9
			RunService.RenderStepped:Wait()
		end

		if p.Parent then
			p.LocalTransparencyModifier = 0
		end

		v4[p] = nil
	end)
end

local function startRumble(p)
	if v5[p] then
		return
	end

	pcall(function()
		local v6 = Sound:Play("LowerSkyBonusMomentSFX.Cloud_Rumble_Indicator_Loop_01", p)
		v6.Looped = true
		v5[p] = v6
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopRumble(p)
	local v6 = v5[p]
	v5[p] = nil

	if v6 then
		pcall(function()
			Sound:FadeOut(v6, 0.8)
		end)
	end
end

local function resetVisuals()
	for _, v6 in v4 do
		pcall(task.cancel, v6)
	end

	v4 = {}

	for k in v5 do
		stopRumble(k) -- equivalent call inferred; original call site unknown
	end

	for k, color5 in colors do
		if not k.Parent then
			continue
		end

		k.Color = color5
		k.LocalTransparencyModifier = 0
	end

	for k, size in sizes do
		if k.Parent then
			k.Size = size
		end
	end

	colors = {}
	sizes = {}
	v = {}
	v2 = {}
	v3 = {}
end

local function boltsInside(part, p: number, color5: Color3, color6: Color3, duration: number)
	local v6 = part.Size * 0.5

	local function pointInside()
		return part.Position + Vector3.new(
			(math.random() - 0.5) * 2 * v6.X * 0.8,
			(math.random() - 0.5) * 2 * v6.Y * 0.8,
			(math.random() - 0.5) * 2 * v6.Z * 0.8
		)
	end

	for _ = 1, p do
		Effect.new("Lightning.Beam"):play({
			Origin = pointInside(),
			Target = pointInside(),
			Color = color5,
			LayerColor = color6,
			Segments = 5,
			Variance = 1.3,
			Size = 0.45,
			LayerSize = 1.2,
			Curvy = true,
			Duration = duration,
			FadeOut = duration * 0.5
		})
	end
end

local function lightningSpread(p, p2: number)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	local v6 = p.Size * 0.5

	local function inside()
		return p.Position + Vector3.new(
			(math.random() - 0.5) * 2 * v6.X * 0.9,
			(math.random() - 0.5) * 2 * v6.Y * 0.9,
			(math.random() - 0.5) * 2 * v6.Z * 0.9
		)
	end

	for _ = 1, p2 do
		Lightning.new({
			Lifetime = 0.15 + math.random() * 0.2,
			DrawType = "Singular",
			Colors = {
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, color4)
			},
			Sizes = {
				{
					Size = 0.08,
					Time = 0
				},
				{
					Size = 0.5,
					Time = 0.5
				},
				{
					Size = 0,
					Time = 1
				}
			},
			Transparencies = {
				{
					Transparency = 0,
					Time = 0
				},
				{
					Transparency = 0,
					Time = 1
				}
			},
			Points = {
				Start = {
					Position = inside()
				},
				End = {
					Position = inside()
				}
			},
			ArcSize = {
				Min = 2,
				Max = 6
			},
			ChangesSegmentOffset = true,
			OffsetChangePercent = {
				EqualOrBelow = 0.15,
				Bounds = { 0, 1 }
			}
		})
	end
end

local function darken(p)
	remember(p) -- equivalent call inferred; original call site unknown
	TweenService:Create(p, TweenInfo.new(1), {
		Color = color2
	}):Play()
end

local function lighten(p)
	local color5 = colors[p]

	if color5 and p.Parent then
		TweenService:Create(p, TweenInfo.new(1.2), {
			Color = color5
		}):Play()
	end
end

local function flash(p)
	if not v[p] then
		return
	end

	local v6 = v2[p]

	if v6 then
		if not v6.Parent then
			v6 = p
		end
	else
		v6 = p
	end

	if not v6.Parent then
		return
	end

	local v7 = colors[v6] or v6.Color
	TweenService:Create(v6, TweenInfo.new(0.1), {
		Color = color
	}):Play()
	lightningSpread(v6, 10)
	task.delay(0.22, function()
		if v6.Parent then
			local color5

			if v[p] then
				local v9 = p
				local v10 = v2[v9]

				if v10 then
					if not v10.Parent then
						v10 = v9
					end
				else
					v10 = v9
				end

				if v10 == v6 then
					color5 = color2
				else
					color5 = v7
				end
			else
				color5 = v7
			end

			TweenService:Create(v6, TweenInfo.new(0.45), {
				Color = color5
			}):Play()
		end
	end)
end

local function growPiece(part)
	remember(part) -- equivalent call inferred; original call site unknown
	local size = sizes[part]
	part.Size = size * 0.55
	TweenService:Create(part, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = size
	}):Play()
end

local function popPiece(part)
	stopFade(part) -- equivalent call inferred; original call site unknown
	TweenService:Create(part, TweenInfo.new(0.35), {
		Transparency = 1,
		Size = part.Size * 0.4
	}):Play()
end

local function restoreCloud(part)
	v3[part] = nil
	v2[part] = nil

	if not part.Parent then
		return
	end

	remember(part) -- equivalent call inferred; original call site unknown

	if colors[part] then
		part.Color = colors[part]
	end

	part.Size = sizes[part] * 0.25
	TweenService:Create(part, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = sizes[part]
	}):Play()
	fadeIn(part) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rollNextFlash()
	return os.clock() + 3 + math.random() * 3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startFlashing()
	if thread then
		return
	end

	thread = task.spawn(function()
		while true do
			task.wait(0.5)
			local now = os.clock()

			for k in v do
				if not (k.Parent and (v3[k] or 0) <= now) then
					continue
				end

				v3[k] = rollNextFlash()
				flash(k)
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopFlashing()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

local function isPart(part)
	return typeof(part) == "Instance" and part:IsA("BasePart")
end

local ElectricFightingTeacher = {}

function ElectricFightingTeacher.OnLoad(_)
	resetVisuals()
	startFlashing() -- equivalent call inferred; original call site unknown
end

ElectricFightingTeacher.RemoteEvents = {
	Charge = function(_, part, part2)
		local v6

		if typeof(part) == "Instance" then
			v6 = part:IsA("BasePart")
		else
			v6 = false
		end

		if not v6 then
			return
		end

		remember(part) -- equivalent call inferred; original call site unknown
		local v7

		if typeof(part2) == "Instance" then
			v7 = part2:IsA("BasePart")
		else
			v7 = false
		end

		if v7 then
			remember(part2) -- equivalent call inferred; original call site unknown
			v2[part] = part2
		end

		if not v[part] then
			v[part] = true
			v3[part] = os.clock() + 1
			local v9 = v2[part]

			if v9 then
				if not v9.Parent then
					v9 = part
				end
			else
				v9 = part
			end

			darken(v9)

			if v5[part] then
				return
			else
				pcall(function()
					local v10 = Sound:Play("LowerSkyBonusMomentSFX.Cloud_Rumble_Indicator_Loop_01", part)
					v10.Looped = true
					v5[part] = v10
				end)
			end
		end
	end,
	Discharge = function(_, part)
		local v6

		if typeof(part) == "Instance" then
			v6 = part:IsA("BasePart")
		else
			v6 = false
		end

		if not (v6 and v[part]) then
			return
		end

		local v7 = v2[part]

		if v7 then
			if not v7.Parent then
				v7 = part
			end
		else
			v7 = part
		end

		v[part] = nil
		v3[part] = nil
		stopRumble(part) -- equivalent call inferred; original call site unknown
		lighten(v7)
	end,
	Split = function(_, part, items, part2)
		local v6

		if typeof(part) == "Instance" then
			v6 = part:IsA("BasePart")
		else
			v6 = false
		end

		if not v6 or typeof(items) ~= "table" then
			return
		end

		for _, part3 in items do
			local v7

			if typeof(part3) == "Instance" then
				v7 = part3:IsA("BasePart")
			else
				v7 = false
			end

			if v7 then
				growPiece(part3)
			end
		end

		local v7

		if typeof(part2) == "Instance" then
			v7 = part2:IsA("BasePart")
		else
			v7 = false
		end

		if v7 then
			remember(part2) -- equivalent call inferred; original call site unknown
			v2[part] = part2
		end

		if v[part] then
			local v9 = v2[part]

			if v9 then
				if not v9.Parent then
					v9 = part
				end
			else
				v9 = part
			end

			lightningSpread(v9, 5)
			flash(part)
		end
	end,
	Pop = function(_, part)
		local v6

		if typeof(part) == "Instance" then
			v6 = part:IsA("BasePart")
		else
			v6 = false
		end

		if v6 then
			popPiece(part)
		end
	end,
	Break = function(_, part, part2, p)
		local v6

		if typeof(part) == "Instance" then
			v6 = part:IsA("BasePart")
		else
			v6 = false
		end

		if not v6 then
			return
		end

		if p == true then
			local v7

			if typeof(part2) == "Instance" then
				v7 = part2:IsA("BasePart")
			else
				v7 = false
			end

			if v7 then
				if not part2.Parent then
					part2 = part
				end
			else
				part2 = part
			end

			boltsInside(part2, 6, color3, color4, 0.45)
			lightningSpread(part2, 16)
		end

		v[part] = nil
		v2[part] = nil
		v3[part] = nil
		stopRumble(part) -- equivalent call inferred; original call site unknown
	end,
	Restore = function(_, part)
		local v6

		if typeof(part) == "Instance" then
			v6 = part:IsA("BasePart")
		else
			v6 = false
		end

		if v6 then
			restoreCloud(part)
		end
	end,
	Clear = function(_)
		stopFlashing() -- equivalent call inferred; original call site unknown
		resetVisuals()
	end
}

function ElectricFightingTeacher.OnComplete(_, _, _)
	stopFlashing() -- equivalent call inferred; original call site unknown
	resetVisuals()
end

return ElectricFightingTeacher