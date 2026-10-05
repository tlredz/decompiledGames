if not script:IsDescendantOf(workspace) then
	return
end

local RunService = game:GetService("RunService")
local v = {}

for _, model in script.Parent.Decor.FloatingIslands:GetChildren() do
	if model:IsA("Model") then
		table.insert(v, {
			model = model,
			origin = model:GetPivot(),
			phase = math.random() * 3.141592653589793 * 2
		})
	end
end

local descendants = script.Parent:QueryDescendants("BasePart[Name=LightFlash]")
local v2 = -1
RunService.Heartbeat:Connect(function()
	local now = os.clock()

	for _, v3 in v do
		local v4 = math.sin(now * 0.5 + v3.phase) * 7.5
		local v5 = v3.origin + Vector3.new(0, v4, 0)

		if v3.model.Name == "BrokenRing" then
			v5 *= CFrame.Angles(0, now * -0.06544984694978735, 0)
		end

		v3.model:PivotTo(v5)
	end

	local v3 = workspace:GetServerTimeNow() % 5.9
	local v4 = 0

	if not (v3 < 3) then
		if v3 < 3.9 then
			v4 = (v3 - 2 - 1) % 0.3 < 0.15 and 1 or v4
		else
			v4 = (1 - math.cos((v3 - 2 - 1 - 0.8999999999999999) / 2 * 3.141592653589793 * 2 * 2)) / 2
		end
	end

	if v4 ~= v2 then
		v2 = v4
		local transparency = (1 - v4) * 0.9

		for _, descendant in descendants do
			descendant.Transparency = transparency
		end
	end
end)