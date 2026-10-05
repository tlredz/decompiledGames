local import = _G.import("event")
local import2 = _G.import("romodel")
local element = _G.import("viewImports"):get("basic").Element
local model = import2.model(element)
local object = setmetatable({}, {
	__mode = "k"
})

function model.init(data)
	return {
		EventNames = data.EventNames or {},
		OnEvent = data.OnEvent,
		RemoteEventNames = data.RemoteEventNames or {},
		OnRemote = data.OnRemote,
		ReactiveChildren = {}
	}
end

function model:ClearReactiveChildren()
	if not self.ReactiveChildren then
		return
	end

	for _, v in pairs(self.ReactiveChildren) do
		v:Destroy()
	end

	self.ReactiveChildren = nil
end

function model:apply(callback, p2, p3)
	if not callback then
		return
	end

	local v, reactiveChildren = callback(self, p2, p3)
	self.ReactiveChildren = reactiveChildren
	import2.apply(self, v, reactiveChildren)
end

function model:spawn()
	local v = {}
	object[self] = v

	if self.OnEvent then
		for _, eventName in ipairs(self.EventNames) do
			if v[eventName] then
				import.disconnect(v[eventName])
			end

			self:apply(self.OnEvent, eventName)
			local v2 = eventName
			v[eventName] = import.connect(eventName, function(...)
				self:apply(self.OnEvent, v2, { ... })
			end)
		end
	end

	if self.OnRemote then
		for _, remoteEventName in ipairs(self.RemoteEventNames) do
			local v2 = "remote:" .. remoteEventName

			if v[v2] then
				import.disconnect(v[v2])
			end

			self:apply(self.OnRemote, remoteEventName)
			local v3 = remoteEventName
			v[v2] = import.remoteConnect(remoteEventName, function(p)
				self:apply(self.OnRemote, v3, p)
			end)
		end
	end
end

function model.despawn(p)
	local v = object[p]

	if not v then
		return
	end

	for _, v2 in pairs(v) do
		import.disconnect(v2)
	end

	object[p] = nil
end

return {
	Reactive = model
}