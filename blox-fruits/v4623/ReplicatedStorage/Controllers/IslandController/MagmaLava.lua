local RunService = game:GetService("RunService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = {}
local v2 = {}
local v3 = 0
local MagmaLava = {
	LoadForLocations = { "Magma Village" },
	Maid = Maid.new()
}

local function flowFor(p)
	if p == Enum.NormalId.Top or p == Enum.NormalId.Bottom then
		return 1.6, 0.9
	end

	return 0.45, -2.1
end

local function trackTexture(texture)
	if v2[texture] then
		return
	end

	local parent = texture.Parent

	if not (parent and parent:IsA("BasePart")) then
		return
	end

	local face = texture.Face
	local flowU, flowV

	if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
		flowU = 1.6
		flowV = 0.9
	else
		flowU = 0.45
		flowV = -2.1
	end

	local position = parent.Position
	local phase = (position.X * 0.041 + position.Y * 0.093 + position.Z * 0.067 + texture.Face.Value * 1.13) % 6.283185307179586
	v2[texture] = true
	table.insert(v, {
		texture = texture,
		baseU = texture.OffsetStudsU,
		baseV = texture.OffsetStudsV,
		offsetU = texture.OffsetStudsU,
		offsetV = texture.OffsetStudsV,
		flowU = flowU,
		flowV = flowV,
		phase = phase
	})
end

local function step(p: number)
	v3 = (v3 + p) % 17.951958020513104
	local v4 = v3 * 0.35

	for i = #v, 1, -1 do
		local v5 = v[i]
		local texture = v5.texture

		if texture.Parent == nil then
			v2[texture] = nil
			table.remove(v, i)
		else
			local studsPerTileU = texture.StudsPerTileU
			local studsPerTileV = texture.StudsPerTileV

			if not (studsPerTileU <= 0 or studsPerTileV <= 0) then
				v5.offsetU = (v5.offsetU + v5.flowU * p) % studsPerTileU
				v5.offsetV = (v5.offsetV + v5.flowV * p) % studsPerTileV
				local v6 = v4 + v5.phase
				texture.OffsetStudsU = (v5.offsetU + math.sin(v6) * 0.8) % studsPerTileU
				texture.OffsetStudsV = (v5.offsetV + math.cos(v6) * 0.8) % studsPerTileV
			end
		end
	end
end

local function restoreAll()
	for _, v4 in v do
		local texture = v4.texture

		if texture.Parent == nil then
			continue
		end

		texture.OffsetStudsU = v4.baseU
		texture.OffsetStudsV = v4.baseV
	end

	table.clear(v)
	table.clear(v2)
	v3 = 0
end

function MagmaLava.RegionEntered(p)
	local maid = p.Maid
	maid:GiveTask(task.spawn(function()
		local magma = workspace:WaitForChild("Map"):WaitForChild("Magma", 30)

		if not magma then
			return
		end

		local lava = magma:WaitForChild("Lava", 30)

		if not lava then
			return
		end

		for _, texture in lava:GetDescendants() do
			if texture:IsA("Texture") then
				trackTexture(texture)
			end
		end

		maid:GiveTask(lava.DescendantAdded:Connect(function(texture)
			if texture:IsA("Texture") then
				trackTexture(texture)
			end
		end))
		RunService:BindToRenderStep(
			"IslandController.MagmaVillage.MagmaLava",
			Enum.RenderPriority.Camera.Value + 1,
			step
		)
		maid:GiveTask(function()
			RunService:UnbindFromRenderStep("IslandController.MagmaVillage.MagmaLava")
		end)
	end))
end

function MagmaLava.RegionLeaving(_)
	restoreAll()
end

return MagmaLava