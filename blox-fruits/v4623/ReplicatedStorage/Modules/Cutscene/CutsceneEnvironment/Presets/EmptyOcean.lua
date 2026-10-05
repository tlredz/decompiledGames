local createVector = vector.create
local v = {
	Collection = game:GetService("CollectionService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage")
}
require(script.Parent.Parent.Parent.Types)
local v2 = {
	findWater = function(instance)
		local localWater = instance:FindFirstChild("LocalWater;")
		assert(localWater and localWater:IsA("BasePart"), "EmptyOcean water is unavailable")
		return localWater
	end,
	build = function(parent)
		local assets = v.ReplicatedStorage:FindFirstChild("Assets") or v.ReplicatedStorage:WaitForChild("Assets", 5)
		local water = assets and assets:FindFirstChild("Water;")
		assert(water and water:IsA("BasePart"), "ReplicatedStorage.Assets[Water;] is unavailable")
		local clone = water:Clone()
		parent:SetAttribute("WaterHeight", -10000)
		clone.Name = "LocalWater;"
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.CastShadow = false
		clone.CFrame = CFrame.new(0, -10000.35, 0)
		local v3 = clone:FindFirstChild("Texture")

		if not (v3 and v3:IsA("Texture")) then
			if v3 then
				v3:Destroy()
			end

			v3 = Instance.new("Texture")
			v3.Name = "Texture"
			v3.Parent = clone
		end

		v3.Texture = "rbxassetid://9667785886"
		v3.Face = Enum.NormalId.Top
		v3.Transparency = 0.5
		v3.Color3 = Color3.fromRGB(255, 255, 255)
		v3.StudsPerTileU = 300
		v3.StudsPerTileV = 300
		local v4 = clone:FindFirstChildWhichIsA("SpecialMesh")

		if not v4 then
			v4 = Instance.new("SpecialMesh")
			v4.MeshType = Enum.MeshType.Brick
			v4.Parent = clone
		end

		v4.Scale = createVector(50000, 1, 50000)
		clone.Parent = parent
		v.Collection:AddTag(clone, "WaterEffect")
	end
}

function v2.create()
	local localCinematicWaterHeight = nil
	local v3 = nil
	local identity = CFrame.identity
	return {
		Name = "EmptyOcean",
		Build = v2.build,
		Loaded = function(instance)
			local water = v2.findWater(instance)
			localCinematicWaterHeight = workspace:GetAttribute("LocalCinematicWaterHeight")
			v3 = water.Position.Y + 0.35
			identity = instance:GetPivot().Rotation
			workspace:SetAttribute("LocalCinematicWaterHeight", v3)
		end,
		Update = function(instance, _: number)
			local currentCamera = workspace.CurrentCamera
			local v4 = v3

			if not currentCamera or v4 == nil then
				return
			end

			local position = currentCamera.CFrame.Position
			instance:PivotTo(CFrame.new(position.X, v4 - 0.35, position.Z) * identity)
		end,
		Unloaded = function(_)
			if v3 ~= nil and workspace:GetAttribute("LocalCinematicWaterHeight") == v3 then
				workspace:SetAttribute("LocalCinematicWaterHeight", localCinematicWaterHeight)
			end

			localCinematicWaterHeight = nil
			v3 = nil
		end
	}
end

return table.freeze(v2)