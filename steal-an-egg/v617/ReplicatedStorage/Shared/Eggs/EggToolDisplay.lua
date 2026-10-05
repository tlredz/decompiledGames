local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local EggRenderer = require(script.Parent.EggRenderer)
local Log = require(ReplicatedStorage.Packages.Log)
local ParasiteVisual = require(script.Parent.ParasiteVisual)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
require(script.Parent.Types)
local v = Log.new()
local EggToolDisplay = {}
EggToolDisplay.__index = EggToolDisplay
EggToolDisplay.__class = "EggToolDisplay"

function EggToolDisplay.new(tool, p)
	t.strict(t.instanceIsA("Tool"))(tool)
	local self = setmetatable({}, EggToolDisplay)
	self._trove = Trove.new()
	self._tool = tool
	self._renderResult = EggRenderer.RenderVisual(p, tool)
	self:_init()
	v:AtDebug():Log((`Attached egg tool display for {p.UID}`))
	return self
end

local function getStringAttribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "string" and attribute ~= "" then
		return attribute
	end

	return nil
end

local function positionModel(_tool, _renderResult)
	local handle = _tool:WaitForChild("Handle")
	assert(handle:IsA("BasePart"), (`Missing egg tool handle for {_tool:GetFullName()}`))
	local model = _renderResult.Model
	local pivot = model:GetPivot()
	local v2, v3 = ModelBounds(model)
	local objectSpace = (v2 * CFrame.new(0, v3.Y * -0.5, v3.Z * 0.1)):ToObjectSpace(pivot)
	model:PivotTo(handle.CFrame * objectSpace)
	return handle
end

function EggToolDisplay.IsEggTool(instance)
	t.strict(t.instanceIsA("Tool"))(instance)
	return instance:GetAttribute("ItemType") == "AssetEgg"
end

function EggToolDisplay.GetToolUid(instance)
	t.strict(t.instanceIsA("Tool"))(instance)
	local UID = instance:GetAttribute("UID")

	if typeof(UID) == "string" and UID ~= "" then
		return UID
	end

	return nil
end

function EggToolDisplay:Destroy()
	self._trove:Destroy()
end

function EggToolDisplay:SyncParasite(flag: boolean?)
	ParasiteVisual.Attach(self._renderResult.Model, flag)
end

function EggToolDisplay:_init()
	self._trove:Add(self._renderResult.Model)
	local part = positionModel(self._tool, self._renderResult)
	local visiblePart = self._renderResult.VisibleParts[1]
	local v3

	if part.Anchored then
		v3 = Instance.new("Motor6D")
		v3.C0 = visiblePart.CFrame:ToObjectSpace(part.CFrame)
	else
		v3 = Instance.new("WeldConstraint")
	end

	v3.Part0 = visiblePart
	v3.Part1 = part
	v3.Parent = visiblePart
	self._trove:Add(v3)
end

return EggToolDisplay