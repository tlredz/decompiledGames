local TweenService = game:GetService("TweenService")
local StaticLightning = {}
local random = Random.new()
local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.Locked = true
part.CastShadow = false
part.Name = "BoltPart"
part.Material = Enum.Material.Neon
part.Color = Color3.new(1, 1, 1)
part.Transparency = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function QuadBezier(position1: Vector3, curveCenter: Vector3, position2: Vector3, p: number)
	return position1:Lerp(curveCenter, p):Lerp(curveCenter:Lerp(position2, p), p)
end

local v = nil

function StaticLightning.CreateBolt(instance)
	local position1 = instance.Position1
	local position2 = instance.Position2

	if not (position1 and position2) then
		error("Missing positions data")
	end

	local partCount = instance.PartCount or 10
	local curveCenter = instance.CurveCenter or (position1 + position2) / 2
	local minRadius = instance.MinRadius or 1
	local maxRadius = instance.MaxRadius or 2
	local partPool = instance.PartPool or {}
	local color = instance.Color or Color3.new(1, 1, 1)
	local parent = instance.Parent or workspace
	local thickness = instance.Thickness or 0.2
	local fn = type(thickness) == "number" and function()
		return thickness
	end or thickness
	local v2 = {}

	for i = 0, partCount do
		local v3 = i ~= 0 and i ~= partCount
		local quadBezier = QuadBezier(position1, curveCenter, position2, i / partCount) -- equivalent call inferred; original call site unknown

		if v3 then
			quadBezier += random:NextUnitVector() * random:NextNumber(minRadius, maxRadius)
		end

		v2[i] = quadBezier
	end

	local result = {}

	for i = 0, partCount - 1 do
		local v3 = table.remove(partPool, 1) or part:Clone()

		if color then
			v3.Color = color
		end

		local v4 = v2[i]
		local v5 = v2[i + 1]
		local magnitude = (v4 - v5).Magnitude
		local v6 = fn(i / partCount)
		v3.Size = Vector3.new(v6, v6, magnitude)
		v3.Parent = parent
		local cframe = CFrame.lookAt((v4 + v5) / 2, v5)

		if v then
			table.insert(v[1], v3)
			table.insert(v[2], cframe)
		else
			v = {
				{ v3 },
				{ cframe }
			}
			task.defer(function()
				workspace:BulkMoveTo(v[1], v[2], Enum.BulkMoveMode.FireCFrameChanged)
				v = nil
			end)
		end

		table.insert(result, v3)
	end

	return result
end

function StaticLightning.ThicknessFade(p: number, p2: number, p3, p4)
	local v2 = p3 or Enum.EasingStyle.Linear
	local v3 = p4 or Enum.EasingDirection.Out
	return function(p5)
		local v4 = p2 - p
		return p + TweenService:GetValue(1 - p5, v2, v3) * v4
	end
end

return StaticLightning