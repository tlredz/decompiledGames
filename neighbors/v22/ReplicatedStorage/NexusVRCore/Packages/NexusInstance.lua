local v = {
	"__call",
	"__concat",
	"__unm",
	"__add",
	"__sub",
	"__mul",
	"__div",
	"__idiv",
	"__mod",
	"__pow",
	"__tostring",
	"__eq",
	"__lt",
	"__le",
	"__gc",
	"__len",
	"__iter"
}
local TypedEvent = require(script:WaitForChild("Event"):WaitForChild("TypedEvent"))
local NexusInstance = {
	TypedEvent = TypedEvent
}

function NexusInstance:ToInstance()
	function self.new(...)
		local changed = TypedEvent.new()
		local v3 = {}
		local transformFunctions = {}
		local propertyTransformFunctions = {}
		local onAnyPropertyChangedFunctions = {}
		local onPropertyChangedFunctions = {}
		local hiddenPropertyChanges = {}
		local hiddenNextPropertyChanges = {}
		local propertyChangedEvents = {}
		local v12 = {
			__index = function(_, p2: string)
				local v13 = v3[p2]

				if v13 ~= nil then
					return v13
				end

				local v14 = NexusInstance[p2]

				if v14 == nil then
					return self[p2]
				end

				return v14
			end,
			__newindex = function(p2, p3: string, p4)
				for _, v13 in transformFunctions do
					p4 = v13(p3, p4)
				end

				if propertyTransformFunctions[p3] then
					for _, v13 in propertyTransformFunctions[p3] do
						p4 = v13(p4)
					end
				end

				if p2[p3] == p4 then
					return
				end

				v3[p3] = p4

				for _, v13 in onAnyPropertyChangedFunctions do
					v13(p3, p4)
				end

				local v13 = onPropertyChangedFunctions[p3]

				if v13 then
					for _, v14 in v13 do
						v14(p4)
					end
				end

				if hiddenNextPropertyChanges[p3] then
					hiddenNextPropertyChanges[p3] = nil
					return
				end

				if hiddenPropertyChanges[p3] then
					return
				end

				p2.Changed:Fire(p3)
				local v14 = propertyChangedEvents[p3]

				if v14 then
					v14:Fire()
				end
			end
		}

		for _, v13 in v do
			v12[v13] = self[v13]
		end

		local object = setmetatable({
			Changed = changed,
			BaseClass = self,
			Events = { changed },
			TransformFunctions = transformFunctions,
			PropertyTransformFunctions = propertyTransformFunctions,
			OnAnyPropertyChangedFunctions = onAnyPropertyChangedFunctions,
			OnPropertyChangedFunctions = onPropertyChangedFunctions,
			HiddenPropertyChanges = hiddenPropertyChanges,
			HiddenNextPropertyChanges = hiddenNextPropertyChanges,
			PropertyChangedEvents = propertyChangedEvents
		}, v12)
		local __new = self.__new

		if __new then
			__new(object, ...)
		end

		return object
	end

	return self
end

function NexusInstance:CreateEvent()
	local v2 = TypedEvent.new()
	table.insert(self.Events, v2)
	return v2
end

function NexusInstance.AddGenericPropertyTransform(p, callback)
	table.insert(p.TransformFunctions, callback)
end

function NexusInstance.AddPropertyTransform(p, p2, callback)
	if not p.PropertyTransformFunctions[p2] then
		p.PropertyTransformFunctions[p2] = {}
	end

	table.insert(p.PropertyTransformFunctions[p2], callback)
end

function NexusInstance.OnAnyPropertyChanged(p, callback)
	table.insert(p.OnAnyPropertyChangedFunctions, callback)
end

function NexusInstance.OnPropertyChanged(p, p2: string, callback)
	if not p.OnPropertyChangedFunctions[p2] then
		p.OnPropertyChangedFunctions[p2] = {}
	end

	table.insert(p.OnPropertyChangedFunctions[p2], callback)
end

function NexusInstance.HidePropertyChanges(p, p2: string)
	p.HiddenPropertyChanges[p2] = true
end

function NexusInstance.HideNextPropertyChange(p, p2: string)
	p.HiddenNextPropertyChanges[p2] = true
end

function NexusInstance:GetPropertyChangedSignal(p: string)
	if not self.PropertyChangedEvents[p] then
		self.PropertyChangedEvents[p] = self:CreateEvent()
	end

	return self.PropertyChangedEvents[p]
end

function NexusInstance:Destroy()
	local destroy = self.BaseClass.Destroy

	if destroy then
		destroy(self)
	end

	task.defer(function()
		for _, event in self.Events do
			event:Destroy()
		end

		self.Events = {}
	end)
end

return NexusInstance