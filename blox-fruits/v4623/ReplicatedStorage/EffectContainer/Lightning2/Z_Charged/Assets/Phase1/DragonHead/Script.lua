local createVector = vector.create
local RunService = game:GetService("RunService")
local rootPart = script.Parent:WaitForChild("RootPart")
local controller = rootPart:WaitForChild("Controller")
local bones = {}

for _, bone in ipairs(rootPart:GetChildren()) do
	if bone:IsA("Bone") and bone ~= controller then
		table.insert(bones, bone)
	end
end

table.sort(bones, function(a, b)
	return (tonumber(a.Name:match("%d+")) or 0) > (tonumber(b.Name:match("%d+")) or 0)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function getControllerWorldCFrame()
	return controller.WorldCFrame * CFrame.new(0, -1.5, -4) * CFrame.Angles(1.5707963267948966, 3.141592653589793, 0)
end

local v = {}

for _ = 1, #bones * 2 do
	table.insert(v, getControllerWorldCFrame())
end

local lastTime = os.clock()
RunService.RenderStepped:Connect(function(dt)
	local v2 = math.min(dt, 0.03333333333333333)
	table.insert(v, 1, getControllerWorldCFrame())
	v[#v] = nil

	for i, v3 in ipairs(bones) do
		local v4 = i * 2
		local v5 = math.clamp(#v - v4 + 1, 1, #v)
		local v6 = v[v5] + createVector(0, 1, 0) * math.sin((os.clock() - lastTime) * 24 + v5 / 11 * 3.141592653589793) * 6
		local worldCFrame = v3.WorldCFrame
		v3.WorldCFrame = worldCFrame:Lerp(
			v6,
			v2 * math.clamp((worldCFrame.Position - v6.Position).Magnitude * 30, 5, 60)
		)
	end
end)