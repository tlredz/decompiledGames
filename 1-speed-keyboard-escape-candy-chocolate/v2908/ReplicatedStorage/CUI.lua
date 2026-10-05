local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Signal"))
require(script.Types)
local CUI = {
	Signal = Signal
}
local v = {}
local v2 = {}
local class = {}
class.__index = class
CUI.ComponentManager = class

function class.new(contentFrame, parent, retrieveWidth)
	return (setmetatable({
		LayoutOrder = 0,
		Parent = parent,
		ContentFrame = contentFrame,
		ComponentPool = {},
		RetrieveWidth = retrieveWidth
	}, class))
end

local function add(state, p: string, callback, callback2)
	local v3

	if type(callback) ~= "function" then
		v3 = callback
	end

	if type(callback) == "function" then
		callback2 = callback
	end

	while v3 == nil or state.ComponentPool[v3] ~= nil do
		v3 = HttpService:GenerateGUID(false)
	end

	local v4 = assert(CUI.AllComponents[p], ("Unknown CUI component '%s'"):format(p)).new(state, v3)
	v4:OnCreate()
	v4:SetLayoutOrder(state.LayoutOrder)
	state.LayoutOrder += 1
	state.ComponentPool[v3] = v4

	if callback2 then
		callback2(v4)
	end

	state.Parent:UpdateHeight()
	return v4
end

local function addComponent(p: string)
	return function(p2, p3, callback)
		return (add(p2, p, p3, callback))
	end
end

local v3 = "Box"

function class.AddBox(p, p2, callback)
	return (add(p, v3, p2, callback))
end

local v4 = "Button"

function class.AddButton(p, p2, callback)
	return (add(p, v4, p2, callback))
end

local v5 = "Checkbox"

function class.AddCheckbox(p, p2, callback)
	return (add(p, v5, p2, callback))
end

local v6 = "Dropdown"

function class.AddDropdown(p, p2, callback)
	return (add(p, v6, p2, callback))
end

local v7 = "BigDropdown"

function class.AddBigDropdown(p, p2, callback)
	return (add(p, v7, p2, callback))
end

local v8 = "Field"

function class.AddField(p, p2, callback)
	return (add(p, v8, p2, callback))
end

local v9 = "NumberField"

function class.AddNumberField(p, p2, callback)
	return (add(p, v9, p2, callback))
end

local v10 = "ShortenedNumberField"

function class.AddShortenedNumberField(p, p2, callback)
	return (add(p, v10, p2, callback))
end

local v11 = "NumberRangeField"

function class.AddNumberRangeField(p, p2, callback)
	return (add(p, v11, p2, callback))
end

local v12 = "Vector2Field"

function class.AddVector2Field(p, p2, callback)
	return (add(p, v12, p2, callback))
end

local v13 = "Vector3Field"

function class.AddVector3Field(p, p2, callback)
	return (add(p, v13, p2, callback))
end

local v14 = "CFrameField"

function class.AddCFrameField(p, p2, callback)
	return (add(p, v14, p2, callback))
end

local v15 = "List"

function class.AddList(p, p2, callback)
	return (add(p, v15, p2, callback))
end

local v16 = "Slider"

function class.AddSlider(p, p2, callback)
	return (add(p, v16, p2, callback))
end

local v17 = "Split"

function class.AddSplit(p, p2, callback)
	return (add(p, v17, p2, callback))
end

local v18 = "Tab"

function class.AddTab(p, p2, callback)
	return (add(p, v18, p2, callback))
end

local v19 = "Text"

function class.AddText(p, p2, callback)
	return (add(p, v19, p2, callback))
end

local v20 = "Title"

function class.AddTitle(p, p2, callback)
	return (add(p, v20, p2, callback))
end

local v21 = "Viewport"

function class.AddViewport(p, p2, callback)
	return (add(p, v21, p2, callback))
end

local v22 = "Graph"

function class.AddGraph(p, p2, callback)
	return (add(p, v22, p2, callback))
end

local v23 = "SequenceEditor"

function class.AddSequenceEditor(p, p2, callback)
	return (add(p, v23, p2, callback))
end

local v24 = "Color"

function class.AddColor(p, p2, callback)
	return (add(p, v24, p2, callback))
end

local v25 = "Image"

function class.AddImage(p, p2, callback)
	return (add(p, v25, p2, callback))
end

local v26 = "Separator"

function class.AddSeparator(p, p2, callback)
	return (add(p, v26, p2, callback))
end

local v27 = "Expandable"

function class.AddExpandable(p, p2, callback)
	return (add(p, v27, p2, callback))
end

local v28 = "RichtextEditor"

function class.AddRichtextEditor(p, p2, callback)
	return (add(p, v28, p2, callback))
end

local v29 = "Time"

function class.AddTime(p, p2, callback)
	return (add(p, v29, p2, callback))
end

function class.Remove(p, p2: string)
	local v30 = p.ComponentPool[p2]

	if v30 then
		p.ComponentPool[p2] = nil
		v30:Destroy()
	end

	return p
end

function class._RemoveOnly(p, p2: string)
	p.ComponentPool[p2] = nil
	v[p2] = nil
end

function class.Get(p, p2: string)
	return p.ComponentPool[p2]
end

function class.FindFirstByType(p, p2: string)
	for _, v30 in p.ComponentPool do
		if CUI.IsComponentType(v30, p2) then
			return v30
		end
	end

	return nil
end

function class:GetAll()
	return self.ComponentPool
end

function class:GetComponentsHeight()
	local total = 0

	for _, v30 in self.ComponentPool do
		if v30:GetVisible() then
			total += v30:GetHeight()
		end
	end

	return total
end

function class:GetWidth()
	if self.RetrieveWidth then
		return self.RetrieveWidth()
	end

	return self.Parent:GetWidth()
end

local class2 = {}
class2.__index = class2
CUI.ComponentContainer = class2

function class2.new(ID: string, UI)
	local self = setmetatable({
		ID = ID,
		UI = UI,
		IsDestroyed = false,
		OnUpdateHeight = Signal.new(),
		OnUpdateWidth = Signal.new()
	}, class2)
	self.Components = class.new(self.UI, self)
	self:_setup()
	return self
end

function class2:_setup()
	task.spawn(function()
		local X = self.UI.AbsoluteSize.X

		while not self.IsDestroyed do
			task.wait()
			local X2 = self.UI.AbsoluteSize.X

			if X2 ~= X then
				self.OnUpdateWidth:Fire(X2)
			end

			X = X2
		end
	end)
end

function class2:UpdateHeight()
	self.OnUpdateHeight:Fire(self.Components:GetComponentsHeight())
	return self
end

function class2.GetMainContainer(p)
	return p
end

function class2.GetZIndex(p)
	return p.UI.ZIndex
end

function class2:GetHeight()
	return self.UI.Size.Y.Offset
end

function class2.GetDepth(_)
	return 0
end

function class2:GetWidth()
	return self.UI.AbsoluteSize.X
end

function class2:Destroy()
	self.IsDestroyed = true
	self.OnUpdateHeight:DisconnectAll()
	self.OnUpdateWidth:DisconnectAll()

	for _, v30 in self.Components:GetAll() do
		v30:Destroy()
	end
end

function CUI.DefineComponent(p: string, p2)
	v[p] = p2
end

function CUI.GetComponent(p: string)
	return v[p]
end

function CUI:IsComponentType(p2: string)
	return self and self.__componentName == p2
end

function CUI.CreateComponentContainer(p)
	return class2.new(HttpService:GenerateGUID(false), p)
end

function CUI.Clear()
	for _, v30 in v do
		v30:Destroy()
	end

	table.clear(v)
end

local Components = require(script.Components)
CUI.AllComponents = Components(CUI)
local Window = require(script.Window)
local window = Window(CUI)

function CUI.GetWindow(p: string, value: number?, callback)
	local v31 = v2[p] == nil
	local v32 = v2[p] or window.new(p)
	v2[p] = v32

	function v32._OnDestroy()
		v2[p] = nil
	end

	v32:SetXSize(value or 200)

	if not v31 then
		return v32
	end

	v32:SetTitle(p)
	local screenSize = v32:GetScreenSize()

	if screenSize.X > 0 and screenSize.Y > 0 then
		v32:SetPositionWithAnchor(screenSize.X / 2, screenSize.Y / 2, Vector2.new(0.5, 0.5))
	end

	if callback then
		callback(v32)
	end

	return v32
end

return CUI