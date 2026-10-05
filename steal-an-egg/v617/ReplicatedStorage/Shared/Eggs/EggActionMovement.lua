local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))

local function fn(cframe)
	if typeof(cframe) ~= "CFrame" then
		return false
	end

	for _, v in ipairs({ cframe:GetComponents() }) do
		if not intersection(v) then
			return false
		end
	end

	return true
end

local BulkPartMotion = require(ReplicatedStorage.Client.BulkPartMotion)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = {}
local EggActionMovement = {}

local function newModelState(instance)
	local primaryPart = instance.PrimaryPart
	t.strict(t.instanceIsA("BasePart"))(primaryPart)
	primaryPart.Anchored = true
	local maid = Trove.new()
	local components = {}

	for k, v3 in { primaryPart } do
		components[k] = BulkPartMotion.Register(v3)
	end

	maid:Add(function()
		for _, v3 in components do
			v3:Destroy()
		end
	end)
	local v3 = {
		Parts = { primaryPart },
		Components = components,
		Trove = maid
	}
	v[instance] = v3
	maid:Connect(instance.Destroying, function()
		EggActionMovement.Remove(instance)
	end)
	return v3
end

function EggActionMovement.SetPivot(instance, cframe: CFrame)
	t.strict(t.instanceIsA("Model"))(instance)
	t.strict(fn)(cframe)
	local v2 = v[instance] or newModelState(instance)
	local pivot = instance:GetPivot()

	for k, part in v2.Parts do
		local objectSpace = pivot:ToObjectSpace(part.CFrame)
		v2.Components[k]:SetCFrame(cframe * objectSpace)
	end
end

function EggActionMovement.Remove(p)
	t.strict(t.instanceIsA("Model"))(p)
	local v2 = v[p]

	if v2 == nil then
		return
	end

	v[p] = nil
	v2.Trove:Destroy()
end

return EggActionMovement