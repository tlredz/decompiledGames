local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.new(1, 1, 1)
local Combat = require(script.Parent:WaitForChild("Combat"))
local damageCounter = module.Services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("DamageCounter")
local flag = false
local v = Combat.IsMobile() and 12 or 24
local v2 = {}
local v3 = {}
local Damage = {}

local function GetCounter()
	local v4 = table.remove(v3)

	if v4 then
		return v4
	end

	local clone = damageCounter:Clone()
	local UI = clone.UI
	local value = UI.Value
	UI.Enabled = false
	clone.Parent = workspace.Cache
	return {
		Instance = clone,
		UI = UI,
		Value = value,
		UID = value.UID,
		Scale = value.UIScale
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReleaseCounter(p)
	p.UI.Enabled = false
	table.insert(v3, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEvictableIndex(flag2: boolean)
	for k, v4 in v2 do
		if not v4.IsOwn then
			return k
		end
	end

	if flag2 then
		return 1
	end

	return nil
end

function Damage.PopUp(vector2: Vector3, p: number, color2: Color3, flag2: boolean?)
	if module.Data.Settings["Hide Damage Popups"] == true then
		return
	end

	local isOwn = flag2 == true

	if not (isOwn or Combat.IsNear(vector2)) then
		return
	end

	if v <= #v2 then
		local evictableIndex = GetEvictableIndex(isOwn) -- equivalent call inferred; original call site unknown

		if not evictableIndex then
			return
		end

		ReleaseCounter(table.remove(v2, evictableIndex)) -- equivalent call inferred; original call site unknown
	end

	local counter = GetCounter()
	local endPosition = vector2 + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
	local formatted = module.Utils.Number:Format((math.abs((math.floor(p)))))
	counter.Color = color2
	counter.IsOwn = isOwn
	counter.StartTime = tick()
	counter.StartPosition = vector2
	counter.EndPosition = endPosition
	counter.MiddlePosition = module.Utils.Math.Lerp(vector2, endPosition, 0.5) + createVector(0, 5, 0)
	counter.GoalOrientation = math.random(-180, 180)
	counter.Value.Text = formatted
	counter.Value.Rotation = 0
	counter.Scale.Scale = 0
	counter.UID.Text = formatted
	counter.UID.TextColor3 = color
	counter.Instance.Position = vector2
	counter.UI.Enabled = true
	table.insert(v2, counter)
	Damage.Update()
end

function Damage._Update()
	local now = tick()

	for i = #v2, 1, -1 do
		local v4 = v2[i]
		local v5 = math.clamp((now - v4.StartTime) / 1, 0, 1)

		if v5 == 1 then
			table.remove(v2, i)
			ReleaseCounter(v4) -- equivalent call inferred; original call site unknown
		else
			if v5 < 0.5 then
				local scale = v5 * 2
				local v7 = math.clamp((scale - 0.5) / 0.5, 0, 1)
				v4.Scale.Scale = scale

				if v7 > 0 then
					v4.UID.TextColor3 = color:Lerp(v4.Color, v7)
				end
			else
				local v6 = (v5 - 0.5) * 2
				v4.Scale.Scale = 1 - v6
				v4.Value.Rotation = v4.GoalOrientation * v6
			end

			v4.Instance.Position = module.Utils.Math.QuadraticBezier(
				v4.StartPosition,
				v4.MiddlePosition,
				v4.EndPosition,
				v5
			)
		end
	end
end

function Damage.Update()
	if flag or #v2 == 0 then
		return
	end

	flag = true
	module.Libs.ThreadSaver.New(function()
		while #v2 > 0 do
			Damage._Update()
			task.wait()
		end

		flag = false
	end)
end

function Damage.Destroy()
	for _, v4 in v2 do
		v4.Instance:Destroy()
	end

	for _, v4 in v3 do
		v4.Instance:Destroy()
	end

	table.clear(v2)
	table.clear(v3)
end

script.Destroying:Connect(Damage.Destroy)
return Damage