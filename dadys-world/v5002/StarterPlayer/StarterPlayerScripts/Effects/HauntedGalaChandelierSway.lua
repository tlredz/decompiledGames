local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = {}

local function trackChandelier(model)
	if v[model] or not model:IsA("Model") then
		return
	end

	local pivot = model:GetPivot()
	local hangHeight = model:GetAttribute("HangHeight")

	if type(hangHeight) ~= "number" then
		local _, v2 = model:GetBoundingBox()
		hangHeight = pivot.Position.Y + v2.Y / 2
	end

	local cframe = CFrame.new(pivot.Position.X, hangHeight, pivot.Position.Z)
	v[model] = {
		offset = cframe:Inverse() * pivot,
		anchor = cframe,
		tilt = math.rad(0.6 + math.random() * 1.4),
		rate = 6.283185307179586 / (4 + math.random() * 4),
		crossRate = 0.55 + math.random() * 0.29999999999999993,
		phase = math.random() * 3.141592653589793 * 2,
		crossPhase = math.random() * 3.141592653589793 * 2,
		direction = math.random() < 0.5 and -1 or 1
	}
end

local function forget(p)
	v[p] = nil
end

for _, v2 in ipairs(CollectionService:GetTagged("HauntedGalaChandelier")) do
	trackChandelier(v2)
end

CollectionService:GetInstanceAddedSignal("HauntedGalaChandelier"):Connect(trackChandelier)
CollectionService:GetInstanceRemovedSignal("HauntedGalaChandelier"):Connect(forget)
RunService.RenderStepped:Connect(function()
	local v2 = time()

	for k, v3 in pairs(v) do
		if k.Parent then
			local v4 = math.sin(v2 * v3.rate + v3.phase) * v3.tilt
			local v5 = math.sin(v2 * v3.rate * v3.crossRate + v3.crossPhase) * v3.tilt * v3.direction
			k:PivotTo(v3.anchor * CFrame.Angles(v5, 0, v4) * v3.offset)
		else
			v[k] = nil
		end
	end
end)