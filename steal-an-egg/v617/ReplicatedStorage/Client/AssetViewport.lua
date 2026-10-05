local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local directory = Assets.Directory
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local Trove = require(ReplicatedStorage.Packages.Trove)
local AssetModels = require(ReplicatedStorage.Shared.Modules.AssetModels)
local t = require(ReplicatedStorage.Packages.t)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local unit = (createVector(-1, 0, -1)).Unit
local color = Color3.fromRGB(300, 300, 300)
local strict = t.strict(t.instanceIsA("GuiObject"))
local strict2 = t.strict(t.instanceIsA("Model"))
local strict3 = t.strict(t.Instance)
local strict4 = t.strict(t.CFrame)
local strict5 = t.strict(t.Vector3)
local strict6 = t.strict(t.number)
local strict7 = t.strict(t.string)
local AssetViewport = {}

local function raise(p: string, p2, parent, flag: boolean?)
	local v2 = Trove.new()
	v2:Add(p2)

	if flag then
		local worldModel = Instance.new("WorldModel")
		worldModel.Parent = parent
		v2:Add(worldModel)
		p2.Parent = worldModel
		local v3 = AssetViewport.LoopIdle(p, p2)

		if v3 ~= nil then
			v2:Add(v3)
		end
	else
		p2.Parent = parent
	end

	local camera = Instance.new("Camera")
	camera.FieldOfView = 50
	camera.Parent = parent
	parent.CurrentCamera = camera
	v2:Add(camera)
	local v3, v4 = ModelBounds(p2)
	local v5 = math.max(v4.X, v4.Y, v4.Z)
	local v6 = v5 * 0.5 / 0.5773502691896257 * 0.75
	local v7 = v3.Position + Vector3.new(0, -0.15000000000000002 * v4.Y, 0)
	local position = (v3 * CFrame.new(unit * (v6 + v5 * 0.7))).Position
	camera.CFrame = CFrame.new(position, v7)
	v2:AttachToInstance(parent)
	return v2, camera, p2
end

function AssetViewport.Mount(parent)
	strict(parent)
	local viewportFrame = Instance.new("ViewportFrame")
	local zIndex = parent.ZIndex + 1
	viewportFrame.Name = "AssetViewport"
	viewportFrame.ZIndex = zIndex
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	viewportFrame.BackgroundTransparency = 1
	local uDim = UDim2.fromScale(0.5, 0.5)
	local uDim2 = UDim2.fromScale(1, 1)
	viewportFrame.Position = uDim
	viewportFrame.Size = uDim2
	viewportFrame.Parent = parent
	viewportFrame.LightColor = color
	viewportFrame.Ambient = color
	return viewportFrame
end

function AssetViewport.LoopIdle(p: string, instance)
	strict7(p)
	strict2(instance)
	local idle = directory[p].Animations.Idle
	local animator = instance:FindFirstChildWhichIsA("Animator", true)

	if idle == nil or animator == nil or instance:GetAttribute("AnimationsDisabled") == true then
		return nil
	end

	local track = animator:LoadAnimation(idle)
	track.Looped = true
	track:Play(0)
	return track
end

function AssetViewport.ShowModel(instance, viewportFrame)
	strict2(instance)
	assert(viewportFrame:IsA("ViewportFrame"), "ShowModel requires a ViewportFrame")
	local v2, v3, v4 = raise("", instance:Clone(), viewportFrame, false)
	local cframe, v5 = ModelBounds(v4)
	local vectorToWorldSpace = cframe:VectorToWorldSpace((createVector(-1, 0.25, -1)).Unit)
	local cframe2 = CFrame.lookAt(createVector(0, 0, 0), -vectorToWorldSpace)
	local absoluteSize = viewportFrame.AbsoluteSize
	local v6 = not (absoluteSize.X > 0 and absoluteSize.Y > 0) and 1 or absoluteSize.X / absoluteSize.Y
	local v7 = math.tan((math.rad(v3.FieldOfView * 0.5)))
	local v8 = v7 * v6
	local v9 = 0

	for _, v10 in { -1, 1 } do
		for _, v11 in { -1, 1 } do
			for _, v12 in { -1, 1 } do
				local vectorToObjectSpace = cframe2:VectorToObjectSpace((cframe:VectorToWorldSpace(Vector3.new(
					v5.X * v10,
					v5.Y * v11,
					v5.Z * v12
				) * 0.5)))
				v9 = math.max(
					v9,
					vectorToObjectSpace.Z + math.abs(vectorToObjectSpace.X) / v8,
					vectorToObjectSpace.Z + math.abs(vectorToObjectSpace.Y) / v7
				)
			end
		end
	end

	v3.CFrame = CFrame.lookAt(cframe.Position + vectorToWorldSpace * math.max(0.5, v9 * 1.1), cframe.Position)
	return v2, v3, v4
end

function AssetViewport.ShowAsset(assetId: string, parent, flag: boolean?)
	local assetModelIfReplicated = AssetModels.GetAssetModelIfReplicated(assetId)

	if assetModelIfReplicated then
		return raise(assetId, assetModelIfReplicated:Clone(), parent, flag)
	end

	v:AtWarning():Log("No replicated model to put in a viewport", {
		AssetId = assetId
	})
	return Trove.new(), nil, nil
end

function AssetViewport.ShowItem(p, parent, p3: number, flag: boolean?)
	assert(AssetItem.AssetItemData(p))
	strict3(parent)
	strict6(p3)
	local clone = table.clone(p)
	clone.Scale = 1
	local v2, v3, v4 = raise(p.Category, ItemDisplay.CreateActiveModel(nil, clone, true, true), parent, flag)
	ItemDisplay.ApplyModelScale(v4, p.Category, p3)
	return v2, v3, v4
end

function AssetViewport.Orbit(cframe: CFrame, position: Vector3, p: number, p2: number)
	strict4(cframe)
	strict5(position)
	strict6(p)
	strict6(p2)
	local cframe2 = CFrame.new(position)
	local v2 = cframe2 * CFrame.Angles(p2, p, 0) * cframe2:ToObjectSpace(cframe)
	return CFrame.lookAt(v2.Position, position)
end

function AssetViewport:AimOrbit(cframe: CFrame, vector2: Vector3, p2: number, p3: number)
	strict3(self)
	self.CFrame = AssetViewport.Orbit(cframe, vector2, p2, p3)
end

function AssetViewport:AimLocalOrbit(cframe: CFrame, vector2: Vector3, p2: number, p3: number, p4: number, p5: number)
	strict3(self)
	strict4(cframe)
	strict5(vector2)
	strict6(p2)
	strict6(p3)
	strict6(p4)
	strict6(p5)
	local vectorToWorldSpace = CFrame.Angles(0, p4, 0):VectorToWorldSpace((Vector3.new(0, 0, -p2)))
	local vector3 = Vector3.new(0, p3 + math.tan(p5) * p2, 0)
	self.CFrame = CFrame.lookAt(
		vector2 + cframe:VectorToWorldSpace(vectorToWorldSpace + vector3),
		vector2,
		cframe.UpVector
	)
end

return AssetViewport