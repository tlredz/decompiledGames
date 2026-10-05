local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local SubBiomeCycle = require(ReplicatedStorage.Shared.Util.SubBiomeCycle)
local v = {
	Waterfalls = 10,
	Lavafalls = 4
}
local v2 = {
	Water = 2,
	Lava = 0.8
}
return {
	Start = function()
		local world = Workspace:WaitForChild("World", 30)
		assert(world ~= nil, "Workspace.World is required")
		local areas = world:WaitForChild("Areas", 30)
		assert(areas ~= nil, "Workspace.World.Areas is required")
		local lightDark = areas:WaitForChild("LightDark", 30)
		assert(lightDark ~= nil, "Workspace.World.Areas.LightDark is required")
		local bounds = lightDark:WaitForChild("Bounds", 30)
		local v3

		if bounds == nil then
			v3 = false
		else
			v3 = bounds:IsA("BasePart")
		end

		assert(v3, "LightDark.Bounds must be a BasePart")
		local subBiomes = ReplicatedStorage.Assets.VFX:WaitForChild("SubBiomes", 30)
		assert(subBiomes ~= nil, "ReplicatedStorage.Assets.VFX.SubBiomes is required")
		local build = world:WaitForChild("Build", 30)
		assert(build ~= nil, "Workspace.World.Build is required")
		local zone12Props = build:WaitForChild("Props", 30):WaitForChild("Zone12Props", 30)
		assert(zone12Props ~= nil, "Workspace.World.Build.Props.Zone12Props is required")
		local subBiomeBuilds = ReplicatedStorage.Assets:WaitForChild("SubBiomeBuilds", 30)
		assert(subBiomeBuilds ~= nil, "ReplicatedStorage.Assets.SubBiomeBuilds is required")

		local function zoneFloorParts()
			local lightDarkZone = build:FindFirstChild("LightDarkZone")
			local _1

			if lightDarkZone ~= nil then
				_1 = lightDarkZone:FindFirstChild("1")
			end

			local BOTTOMS

			if _1 ~= nil then
				BOTTOMS = _1:FindFirstChild("BOTTOMS")
			end

			if BOTTOMS == nil then
				return nil
			end

			local parts = {}

			for _, part in BOTTOMS:GetChildren() do
				assert(part:IsA("BasePart"), (`LightDarkZone.1.BOTTOMS.{part.Name} must be a BasePart`))
				table.insert(parts, part)
			end

			if #parts > 0 then
				return parts
			end

			return nil
		end

		local folder = Instance.new("Folder")
		folder.Name = "LightDarkSubBiomeVfx"
		folder.Parent = Workspace
		local childrenByName = {}

		for _, v4 in { zone12Props, subBiomeBuilds } do
			for _, child in v4:GetChildren() do
				childrenByName[child.Name] = child
			end
		end

		local id = nil
		local v4 = {}

		local function emitterPoints()
			local v5 = math.max(bounds.Size.X - 110, 1)
			local v6 = bounds.CFrame.Position.Y + bounds.Size.Y * 0.5 + 14
			local vectors = {}

			for i = 1, 9 do
				local vector = Vector3.new(-v5 * 0.5 + v5 * ((i - 0.5) / 9), 0, 0)
				local position = (bounds.CFrame * CFrame.new(vector)).Position
				vectors[i] = Vector3.new(position.X, v6, position.Z)
			end

			return vectors
		end

		local function collectScrollingTextures(folder2)
			table.clear(v4)

			if folder2 == nil then
				return
			end

			for _, part in folder2:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				local v5 = v[part.Name]
				local v6 = v2[part.Name]

				if not (v5 ~= nil or v6 ~= nil) then
					continue
				end

				local count = 0

				for _, texture in part:GetChildren() do
					if not texture:IsA("Texture") then
						continue
					end

					local speed

					if v5 == nil then
						count += 1
						speed = v6 * (count == 1 and 1 or 0.55)
					else
						speed = v5 * (texture.Transparency <= 0.5 and 1 or 0.55)
					end

					table.insert(v4, {
						texture = texture,
						speed = speed
					})
				end
			end
		end

		local function scrollTextures()
			local serverTimeNow = Workspace:GetServerTimeNow()

			for _, v5 in v4 do
				v5.texture.OffsetStudsV = -(serverTimeNow * v5.speed) % v5.texture.StudsPerTileV
			end
		end

		local function rebuildVfx(activeAt)
			folder:ClearAllChildren()
			local vfx = activeAt.Vfx

			if vfx == nil then
				return
			end

			local child = subBiomes:FindFirstChild(vfx)
			assert(child ~= nil, (`No sub-biome VFX named "{vfx}" in ReplicatedStorage.Assets.VFX.SubBiomes`))

			for _, position in emitterPoints() do
				local clone = child:Clone()
				clone:PivotTo(CFrame.new(position))
				clone.Parent = folder
			end
		end

		local function showProps(activeAt)
			local v5 = zoneFloorParts()

			if v5 == nil then
				return false
			end

			local hidesZoneFloor = activeAt.HidesZoneFloor == true

			for _, v6 in v5 do
				v6.LocalTransparencyModifier = hidesZoneFloor and 1 or 0
			end

			local props = activeAt.Props

			if props == nil then
				table.clear(v4)
				return true
			end

			assert(
				childrenByName[props] ~= nil,
				(`No biome build named "{props}" under Build.Props.Zone12Props or Assets.SubBiomeBuilds`)
			)

			for k, v6 in childrenByName do
				local parent

				if k == props then
					parent = zone12Props
				else
					parent = subBiomeBuilds
				end

				v6.Parent = parent
			end

			collectScrollingTextures(childrenByName[props])
			return true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function parkAll()
			for _, v5 in childrenByName do
				v5.Parent = subBiomeBuilds
			end

			folder:ClearAllChildren()
			table.clear(v4)
		end

		local function step()
			local serverTimeNow = Workspace:GetServerTimeNow()

			if SubBiomeCycle.RevealPhaseAt("Light Dark", serverTimeNow) == "Sealed" then
				id = nil
				parkAll() -- equivalent call inferred; original call site unknown
			else
				local activeAt = SubBiomeCycle.ActiveAt("Light Dark", serverTimeNow)

				if activeAt == nil then
					return
				end

				if activeAt.Id ~= id then
					if not showProps(activeAt) then
						return
					end

					id = activeAt.Id
					rebuildVfx(activeAt)
				end
			end
		end

		if not SubBiomeCycle.IsRotating("Light Dark") then
			return
		end

		RunService.RenderStepped:Connect(scrollTextures)

		while true do
			step()
			task.wait(AreaEggCycle.SchedulePollSeconds)
		end
	end
}