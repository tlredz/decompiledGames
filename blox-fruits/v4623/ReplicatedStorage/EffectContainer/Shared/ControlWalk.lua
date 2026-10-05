local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local VisualHelper = require(script.VisualHelper)
require(script.MathHelper)
require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("FX"))
local models = ReplicatedStorage.Assets.Models
local hexagonsWalk = workspace.Terrain:FindFirstChild("Hexagons-Walk") or Instance.new("Folder", workspace.Terrain)
hexagonsWalk.Name = "Hexagons-Walk"
local v = models.Hexagon.Main.Size.X / 2 + 3
local _ = 1.7320508075688772 * v
local v2 = {
	{ 1, 0 },
	{ 1, -1 },
	{ 0, -1 },
	{ -1, 0 },
	{ -1, 1 },
	{ 0, 1 }
}
local v3 = v * 0.25

local function WorldToHex(vector2: Vector3)
	return vector2.X * 0.6666666666666666 / v, (vector2.X * -0.3333333333333333 + vector2.Z * 0.5773502691896257) / v
end

local function CubeRound(p, p2, p3)
	local v4 = math.round(p)
	local v5 = math.round(p2)
	local v6 = math.round(p3)
	local v7 = math.abs(v4 - p)
	local v8 = math.abs(v5 - p2)
	local v9 = math.abs(v6 - p3)

	if v8 < v7 and v9 < v7 then
		return -v5 - v6, v5, v6
	end

	if v9 < v8 then
		return v4, -v4 - v6, v6
	end

	return v4, v5, -v4 - v5
end

local function AxialRound(p, p2)
	local v5, _, v6 = CubeRound(p, -p - p2, p2)
	return v5, v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HexToWorld(p, p2, p3)
	return (Vector3.new(v * (1.5 * p), p3, v * (1.7320508075688772 * (p2 + p / 2))))
end

local function HexKey(p, p2)
	return p .. ":" .. p2
end

local part = Instance.new("Part", workspace.Terrain)
part.Anchored = true
part.Size = vector.create(10, 0.1, 10)
part.Transparency = 1
part.CanTouch = false
part.CanQuery = false
local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetHexagon()
	local v6 = table.remove(v4, 1)

	if v6 then
		return v6[1]
	end

	return models.Hexagon:Clone()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReturnHexagon(instance)
	task.spawn(function()
		instance.Parent = script
		instance:ScaleTo(1)
		task.wait()
		table.insert(v4, { instance, os.clock() + 20 })
	end)
end

task.spawn(function()
	while task.wait(5) do
		local v6 = {}

		for _, v7 in ipairs(v4) do
			if v7[2] < os.clock() then
				v7[1]:Destroy()
			else
				table.insert(v6, v7)
			end
		end

		v4 = v6
		local now = os.clock()

		for k, v7 in pairs(v5) do
			if v7 < now then
				v5[k] = nil
			end
		end
	end
end)

local function TrySpawnHex(p, p2, p3)
	local v6 = p .. ":" .. p2
	local now = os.clock()

	if v5[v6] and now < v5[v6] then
		return
	end

	v5[v6] = now + 0.6
	CreateHexagon(CFrame.new((Vector3.new(v * (1.5 * p), p3, v * (1.7320508075688772 * (p2 + p / 2))))))
end

function CreateHexagon(cframe: CFrame)
	local hexagon = GetHexagon() -- equivalent call inferred; original call site unknown
	hexagon:PivotTo(cframe * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 1.5707963267948966, 0))
	hexagon.Parent = hexagonsWalk
	VisualHelper:EmitAll(hexagon.Main.Emit)
	task.delay(0.4, function()
		VisualHelper:TweenScale(hexagon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), 0.01)
		task.wait(0.35)
		ReturnHexagon(hexagon) -- equivalent call inferred; original call site unknown
	end)
end

return function(data)
	local humanoidRootPart = data.HumanoidRootPart
	local position = data.Position
	local v6 = not data.RespectHeight and -3.8 or position.Y or -3.8
	local v7 = position.X * 0.6666666666666666 / v
	local v8 = (position.X * -0.3333333333333333 + position.Z * 0.5773502691896257) / v
	local v10, _, v11 = CubeRound(v7, -v7 - v8, v8)
	local hexToWorld = HexToWorld(v10, v11, v6) -- equivalent call inferred; original call site unknown
	TrySpawnHex(v10, v11, v6)

	for _, v13 in ipairs(v2) do
		local v14 = v10 + v13[1]
		local v15 = v11 + v13[2]
		local hexToWorld2 = HexToWorld(v14, v15, v6) -- equivalent call inferred; original call site unknown
		local v17 = (hexToWorld + hexToWorld2) * 0.5
		local unit = (hexToWorld2 - hexToWorld).Unit

		if (position - v17):Dot(unit) > -v3 then
			TrySpawnHex(v14, v15, v6)
		end
	end

	if humanoidRootPart == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		part.CFrame = CFrame.new(humanoidRootPart.Position.X, v6, humanoidRootPart.Position.Z)
	end
end