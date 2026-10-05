local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local ParticleTween = require(ReplicatedStorage.CAM.Global.ParticleTween)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)

local function flingPart(clone)
	local v = math.random(1, 3) * (math.random(1, 2) == 1 and -1 or 1) * 10
	local v2 = math.random(1, 3) * (math.random(1, 2) == 1 and -1 or 1) * 10
	local v3 = math.random(1, 3) * (math.random(1, 2) == 1 and -1 or 1) * 10
	clone.AssemblyLinearVelocity = Vector3.new(v, v2, v3)
	clone.AssemblyAngularVelocity = Vector3.new(v * 0.125, v2 * 0.125, v3 * 0.125)
end

local function shootAndRestore(items, folder)
	local transparencies = {}

	for _, item in items do
		transparencies[item] = item.Transparency
		local clone = item:Clone()

		if clone ~= nil then
			for _, descendant in clone:GetDescendants() do
				if not (descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("Constraint")) then
					continue
				end

				descendant:Destroy()
			end

			clone.Anchored = false
			clone.Parent = folder
			flingPart(clone)
		end

		item.Transparency = 1
	end

	task.delay(gameSettings.TreeDestructionRespawnTime, function()
		for k, transparency in transparencies do
			k.Transparency = transparency
		end
	end)
end

return function(p)
	if p == nil then
		return
	end

	local others = p.Others
	local bush = p.Bush

	if others == nil and bush == nil then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "TreeDestructionFolder"
	folder.Parent = workspace.Debree

	if bush ~= nil then
		local v = {}

		for _, v2 in bush do
			if typeof(v2) == "Instance" and v2.Parent ~= nil then
				table.insert(v, v2)
			end
		end

		if #v > 0 then
			shootAndRestore(v, folder)
		end
	end

	for _, v in others or {} do
		if not (typeof(v) == "Instance" and v.Parent ~= nil) then
			continue
		end

		local parts = {}

		for _, part in v:GetChildren() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end

		shootAndRestore(parts, folder)
		local extentsSize = v:GetExtentsSize()
		local vector2 = Vector3.new(extentsSize.X, 0, extentsSize.Z)

		if vector2.Magnitude < 2 then
			continue
		end

		local raycastResult = workspace:Raycast(v:GetPivot().Position, createVector(0, -50, 0), raycastParams)

		if not (raycastResult ~= nil and raycastResult.Instance ~= nil) then
			continue
		end

		local position = raycastResult.Position
		local v2 = (vector2.Magnitude / 90) ^ 2
		local clone = script["LinesEnableFalling0.25s"]:Clone()
		clone.Position = position + Vector3.new(0, clone.Size.Y / 2, 0)
		clone.Parent = folder
		clone.Sound.Volume = clone.Sound.Volume * math.clamp(0.5 + v2, 0.5, 1)
		clone.Sound:Play()
		local clone2 = script["GroundDustCloud/Leaves"]:Clone()
		clone2.Position = position
		clone2.Parent = folder
		ParticleTween:ResizeParticlesNoTween(clone, v2)
		ParticleTween:ResizeParticlesNoTween(clone2, v2)
		vfxUtility.EnableAll(clone, true, 0.25)
		vfxUtility.EmitAll(clone2.Raycast)
		vfxUtility.EmitAll(clone2.AtlasDust, {
			color = raycastResult.Instance.Color
		})
	end

	DebrisModule:AddItem(folder, 4)
end