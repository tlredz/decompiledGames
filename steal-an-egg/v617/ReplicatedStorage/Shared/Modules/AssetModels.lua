local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
local Assets = require(ReplicatedStorage.Data.Assets)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local t = require(ReplicatedStorage.Packages.t)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local assetModels = ReplicatedStorage.AssetModels
local v = {}
local scalesByChildName = {}
local AssetModels = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function asModel(p, childName: string)
	local model = assert(p, (`the AssetModels folder holds nothing named {childName}`))
	assert(model:IsA("Model"), (`AssetModels.{childName} is a {model.ClassName}, not a Model`))
	return model
end

local function present(childName: string)
	local model = assetModels:FindFirstChild(childName)

	if model then
		model = assert(model, (`the AssetModels folder holds nothing named {childName}`))
		assert(model:IsA("Model"), (`AssetModels.{childName} is a {model.ClassName}, not a Model`))
	end

	return model
end

local function awaited(childName: string, value: number?)
	return asModel(assetModels:WaitForChild(childName, value or 30), childName)
end

function AssetModels.Resolve(childName: string)
	t.strict(t.string)(childName)

	if Constants.IS_CLIENT then
		return asModel(assetModels:WaitForChild(childName, 30), childName)
	else
		local model = assetModels:FindFirstChild(childName)

		if model then
			model = assert(model, (`the AssetModels folder holds nothing named {childName}`))
			assert(model:IsA("Model"), (`AssetModels.{childName} is a {model.ClassName}, not a Model`))
		end

		return model
	end
end

local function measure(p: string)
	t.strict(t.string)(p)
	local v2 = assert(AssetModels.Resolve(p), (`no template replicated for {p}`))
	local primaryPart = v2.PrimaryPart or v2:FindFirstChild("HumanoidRootPart")
	local v3

	if primaryPart == nil then
		v3 = false
	else
		v3 = primaryPart:IsA("BasePart")
	end

	assert(v3, (`the {p} template has no root part`))
	local scale = v2:GetScale()
	assert(scale > 0, (`the {p} template is scaled to {scale}, which is not usable`))
	local v4, size = ModelBounds(v2)
	local v6 = v4.Position - Vector3.new(0, size.Y * 0.5, 0)
	return {
		RelativeCFrame = (primaryPart.CFrame.Rotation + v6):ToObjectSpace(v4),
		Size = size,
		TemplateScale = scale
	}
end

function AssetModels.GetVisibleBoundsData(p: string)
	t.strict(t.string)(p)
	local selected = v[p] or measure(p)
	v[p] = selected
	return selected
end

function AssetModels.Await(childName: string, value: number?)
	t.strict(t.string)(childName)
	t.strict(t.optional(t.number))(value)
	return asModel(assetModels:WaitForChild(childName, value or 30), childName)
end

function AssetModels.GetAssetModelIfReplicated(childName: string)
	t.strict(t.string)(childName)
	local model = assetModels:FindFirstChild(childName)

	if model then
		model = assert(model, (`the AssetModels folder holds nothing named {childName}`))
		assert(model:IsA("Model"), (`AssetModels.{childName} is a {model.ClassName}, not a Model`))
	end

	return model
end

function AssetModels.SyncScaleFor(childName: string)
	t.strict(t.string)(childName)
	local model = Assets.Directory[childName] and assetModels:FindFirstChild(childName)

	if model then
		model = assert(model, (`the AssetModels folder holds nothing named {childName}`))
		assert(model:IsA("Model"), (`AssetModels.{childName} is a {model.ClassName}, not a Model`))
	end

	if model then
		scalesByChildName[childName] = model:GetScale()
	end
end

function AssetModels.GetBaseModelScale(p: string)
	t.strict(t.string)(p)
	local v2 = assert(Assets.Directory[p], (`unknown asset species {p}`))
	return scalesByChildName[p] or v2.BaseModelScale
end

function AssetModels.SyncAllScales()
	for k in pairs(Assets.Directory) do
		AssetModels.SyncScaleFor(k)
	end
end

function AssetModels.GetAssetModelsFolder()
	return assetModels
end

local function clearQueryFlagsOverFrames(p)
	task.spawn(function()
		local v2 = { p }
		local v3 = os.clock() + 0.002
		local v4 = 1
		local count = 0

		while v4 <= #v2 do
			local part = v2[v4]
			v2[v4] = nil
			v4 += 1

			if part:IsA("BasePart") then
				part.CanQuery = false
				part.CanTouch = false
			end

			for _, child in part:GetChildren() do
				v2[#v2 + 1] = child
			end

			count += 1

			if not (count >= 64) then
				continue
			end

			count = 0

			if not (v3 <= os.clock()) then
				continue
			end

			heartbeat:Wait()
			v3 = os.clock() + 0.002
		end
	end)
end

if Constants.IS_SERVER then
	task.spawn(function()
		local v2 = { assetModels }
		local v3 = os.clock() + 0.002
		local v4 = 1
		local count = 0

		while v4 <= #v2 do
			local part = v2[v4]
			v2[v4] = nil
			v4 += 1

			if part:IsA("BasePart") then
				part.CanQuery = false
				part.CanTouch = false
			end

			for _, child in part:GetChildren() do
				v2[#v2 + 1] = child
			end

			count += 1

			if not (count >= 64) then
				continue
			end

			count = 0

			if not (v3 <= os.clock()) then
				continue
			end

			heartbeat:Wait()
			v3 = os.clock() + 0.002
		end
	end)
	AssetModels.SyncAllScales()
end

return AssetModels