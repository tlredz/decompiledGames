local createVector = vector.create
local RunService = game:GetService("RunService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = {
	{
		period = 140,
		direction = -1
	},
	{
		period = 200,
		direction = 1
	}
}
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local v2 = {}
local countsByName = {}
local v3 = {}
local parts = {}
local v4 = {}
local MagmaClouds = {
	LoadForLocations = { "Magma Village" },
	Maid = Maid.new()
}

local function trackPart(p)
	local v5 = object[p]

	if v5 then
		return v5
	end

	local cFrame = p.CFrame
	object[p] = cFrame
	local position = cFrame.Position
	object2[p] = (position.X * 0.37 + position.Y * 0.05 + position.Z * 0.13) % 6.283185307179586
	return cFrame
end

local function ringHeight(model)
	local total = 0
	local count = 0

	for _, part in model:GetChildren() do
		if not (part:IsA("BasePart") and part.Name == "cloudfix") then
			continue
		end

		total += part.Position.Y
		count += 1
	end

	if count == 0 then
		return nil
	end

	return total / count
end

local function waitForRingModels(magma)
	local v5 = os.clock() + 30

	while true do
		local result = {}

		for _, model in magma:GetChildren() do
			if not (model:IsA("Model") and model.Name == "Clouds") then
				continue
			end

			local height = ringHeight(model)

			if height then
				table.insert(result, {
					model = model,
					height = height
				})
			end
		end

		if #result >= #v or v5 <= os.clock() then
			table.sort(result, function(a, b)
				return a.height < b.height
			end)
			return result
		else
			task.wait(0.25)
		end
	end
end

local function refreshRing(state)
	table.clear(state.parts)
	local v5 = createVector(0, 0, 0)

	for _, part in state.model:GetChildren() do
		if not (part:IsA("BasePart") and part.Name == "cloudfix") then
			continue
		end

		table.insert(state.parts, part)
		local cFrame = object[part]

		if not cFrame then
			cFrame = part.CFrame
			object[part] = cFrame
			local position = cFrame.Position
			object2[part] = (position.X * 0.37 + position.Y * 0.05 + position.Z * 0.13) % 6.283185307179586
		end

		v5 += cFrame.Position
	end

	local count = #state.parts

	if count == 0 then
		return
	end

	if (countsByName[state.name] or 0) < count then
		countsByName[state.name] = count
		v2[state.name] = v5 / count
	end

	state.center = v2[state.name] or v5 / count
end

local function stepAll()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v5 = serverTimeNow % 25.132741228718345 * 0.25
	table.clear(parts)
	table.clear(v4)

	for _, v6 in v3 do
		if #v6.parts == 0 then
			continue
		end

		local v7 = v6.direction * 6.283185307179586 * (serverTimeNow % v6.period / v6.period)
		local v8 = CFrame.new(v6.center) * CFrame.Angles(0, v7, 0) * CFrame.new(-v6.center)

		for _, part in v6.parts do
			local v9 = object[part]

			if not (part.Parent ~= nil and v9 ~= nil) then
				continue
			end

			local v10 = math.sin(v5 + (object2[part] or 0)) * 2
			table.insert(parts, part)
			table.insert(v4, v8 * CFrame.new(0, v10, 0) * v9)
		end
	end

	if #parts > 0 then
		workspace:BulkMoveTo(parts, v4, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

local function restoreAll()
	for k, cFrame in object do
		if k.Parent ~= nil and cFrame ~= nil then
			k.CFrame = cFrame
		end
	end

	table.clear(v3)
	table.clear(parts)
	table.clear(v4)
end

function MagmaClouds.RegionEntered(p)
	table.clear(v3)
	p.Maid:GiveTask((task.spawn(function()
		local magma = workspace:WaitForChild("Map"):WaitForChild("Magma", 30)

		if not magma then
			return
		end

		for k, v5 in waitForRingModels(magma) do
			local v6 = v[k]

			if not v6 then
				break
			end

			local model = v5.model
			local v7 = {
				name = `Clouds{k}`,
				model = model,
				parts = {},
				center = createVector(0, 0, 0),
				period = v6.period,
				direction = v6.direction
			}
			refreshRing(v7)
			table.insert(v3, v7)
			p.Maid:GiveTask(model.ChildAdded:Connect(function()
				refreshRing(v7)
			end))
			local v9 = v7
			p.Maid:GiveTask(model.ChildRemoved:Connect(function()
				refreshRing(v9)
			end))
		end

		if #v3 == 0 then
			return
		end

		p.Maid:GiveTask(RunService.PreAnimation:Connect(stepAll))
	end)))
end

function MagmaClouds.RegionLeaving(_)
	restoreAll()
end

return MagmaClouds