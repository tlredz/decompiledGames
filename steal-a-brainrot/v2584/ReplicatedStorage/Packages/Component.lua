local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)
local Symbol = require(script.Parent.Symbol)
local Trove = require(script.Parent.Trove)
local isServer = RunService:IsServer()
local v = { workspace, game:GetService("Players") }
local symbol = Symbol("Ancestors")
local symbol2 = Symbol("InstancesToComponents")
local symbol3 = Symbol("LockConstruct")
local symbol4 = Symbol("Components")
local symbol5 = Symbol("Trove")
local symbol6 = Symbol("Extensions")
local symbol7 = Symbol("ActiveExtensions")
local symbol8 = Symbol("Starting")
local symbol9 = Symbol("Started")
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function NextRenderName()
	count += 1
	return "ComponentRender" .. tostring(count)
end

local function InvokeExtensionFn(p, p2: string)
	for _, v11 in ipairs(p[symbol7]) do
		local v12 = v11[p2]

		if type(v12) == "function" then
			v12(p)
		end
	end
end

local function ShouldConstruct(self)
	for _, v11 in ipairs(self[symbol7]) do
		local shouldConstruct = v11.ShouldConstruct

		if type(shouldConstruct) == "function" and not shouldConstruct(self) then
			return false
		end
	end

	return true
end

local function GetActiveExtensions(self, list)
	local result = table.create(#list)
	local flag = true

	for _, v11 in ipairs(list) do
		local shouldExtend = v11.ShouldExtend

		if type(shouldExtend) ~= "function" or shouldExtend(self) then
			table.insert(result, v11)
		else
			flag = false
		end
	end

	if flag then
		return list
	end

	return result
end

local Component = {}
Component.__index = Component

function Component.new(data)
	local class = {}
	class.__index = class

	function class.__tostring()
		return "Component<" .. data.Tag .. ">"
	end

	class[symbol] = data.Ancestors or v
	class[symbol2] = {}
	class[symbol4] = {}
	class[symbol3] = {}
	class[symbol5] = Trove.new()
	class[symbol6] = data.Extensions or {}
	class[symbol9] = false
	class.Tag = data.Tag
	class.Started = class[symbol5]:Construct(Signal)
	class.Stopped = class[symbol5]:Construct(Signal)
	setmetatable(class, Component)
	class:_setup()
	return class
end

function Component._instantiate(p, instance)
	local self = setmetatable({}, p)
	self.Instance = instance
	self[symbol7] = GetActiveExtensions(self, p[symbol6])

	if not ShouldConstruct(self) then
		return nil
	end

	InvokeExtensionFn(self, "Constructing")

	if type(self.Construct) == "function" then
		self:Construct()
	end

	InvokeExtensionFn(self, "Constructed")
	return self
end

function Component:_setup()
	local v11 = {}

	local function StartComponent(object2)
		object2[symbol8] = coroutine.running()
		InvokeExtensionFn(object2, "Starting")
		object2:Start()

		if object2[symbol8] == nil then
			return
		end

		InvokeExtensionFn(object2, "Started")
		local v12 = typeof(object2.HeartbeatUpdate) == "function"
		local v13 = typeof(object2.SteppedUpdate) == "function"
		local v14 = typeof(object2.RenderSteppedUpdate) == "function"

		if v12 then
			object2._heartbeatUpdate = RunService.Heartbeat:Connect(function(dt)
				debug.profilebegin("Component:HeartbeatUpdate")
				object2:HeartbeatUpdate(dt)
				debug.profileend()
			end)
		end

		if v13 then
			object2._steppedUpdate = RunService.Stepped:Connect(function(_, dt)
				debug.profilebegin("Component:SteppedUpdate")
				object2:SteppedUpdate(dt)
				debug.profileend()
			end)
		end

		if v14 and not isServer then
			if object2.RenderPriority then
				object2._renderName = NextRenderName()
				RunService:BindToRenderStep(object2._renderName, object2.RenderPriority, function(p)
					debug.profilebegin("Component:RenderSteppedUpdate")
					object2:RenderSteppedUpdate(p)
					debug.profileend()
				end)
			else
				object2._renderSteppedUpdate = RunService.RenderStepped:Connect(function(dt)
					debug.profilebegin("Component:RenderSteppedUpdate")
					object2:RenderSteppedUpdate(dt)
					debug.profileend()
				end)
			end
		end

		object2[symbol9] = true
		object2[symbol8] = nil
		self.Started:Fire(object2)
	end

	local function StopComponent(object2)
		if object2[symbol8] then
			local v12 = object2[symbol8]

			if coroutine.status(v12) == "normal" then
				task.defer(function()
					pcall(function()
						task.cancel(v12)
					end)
				end)
			else
				pcall(function()
					task.cancel(v12)
				end)
			end

			object2[symbol8] = nil
		end

		if object2._heartbeatUpdate then
			object2._heartbeatUpdate:Disconnect()
		end

		if object2._steppedUpdate then
			object2._steppedUpdate:Disconnect()
		end

		if object2._renderSteppedUpdate then
			object2._renderSteppedUpdate:Disconnect()
		elseif object2._renderName then
			RunService:UnbindFromRenderStep(object2._renderName)
		end

		InvokeExtensionFn(object2, "Stopping")
		object2:Stop()
		InvokeExtensionFn(object2, "Stopped")
		self.Stopped:Fire(object2)
	end

	local function SafeConstruct(p, p2)
		if self[symbol3][p] ~= p2 then
			return nil
		end

		local _instantiate = self:_instantiate(p)

		if self[symbol3][p] == p2 then
			return _instantiate
		end

		return nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function TryConstructComponent(instance)
		if self[symbol2][instance] then
			return
		end

		local v12 = (self[symbol3][instance] or 0) + 1
		self[symbol3][instance] = v12
		task.defer(function()
			local v13 = instance
			local v14 = v12
			local v15

			if self[symbol3][v13] == v14 then
				v15 = self:_instantiate(v13)

				if self[symbol3][v13] ~= v14 then
					v15 = nil
				end
			else
				v15 = nil
			end

			if not v15 then
				return
			end

			self[symbol2][instance] = v15
			table.insert(self[symbol4], v15)
			task.defer(function()
				if self[symbol2][instance] == v15 then
					StartComponent(v15)
				end
			end)
		end)
	end

	local function TryDeconstructComponent(p)
		local v12 = self[symbol2][p]

		if not v12 then
			return
		end

		self[symbol2][p] = nil
		self[symbol3][p] = nil
		local v13 = self[symbol4]
		local index = table.find(v13, v12)

		if index then
			local count2 = #v13
			v13[index] = v13[count2]
			v13[count2] = nil
		end

		if v12[symbol9] or v12[symbol8] then
			task.spawn(StopComponent, v12)
		end
	end

	local function StartWatchingInstance(instance)
		if v11[instance] then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function IsInAncestorList()
			for _, ancestor in ipairs(self[symbol]) do
				if instance:IsDescendantOf(ancestor) then
					return true
				end
			end

			return false
		end

		v11[instance] = self[symbol5]:Connect(instance.AncestryChanged, function(_, p)
			if p then
				-- equivalent call inferred; original call site unknown
				if IsInAncestorList() then
					local v12 = instance

					if self[symbol2][v12] then
						return
					end

					local v13 = (self[symbol3][v12] or 0) + 1
					self[symbol3][v12] = v13
					task.defer(function()
						local v14 = v12
						local v15 = v13
						local v16

						if self[symbol3][v14] == v15 then
							v16 = self:_instantiate(v14)

							if self[symbol3][v14] ~= v15 then
								v16 = nil
							end
						else
							v16 = nil
						end

						if not v16 then
							return
						end

						self[symbol2][v12] = v16
						table.insert(self[symbol4], v16)
						task.defer(function()
							if self[symbol2][v12] == v16 then
								StartComponent(v16)
							end
						end)
					end)
					return
				end
			end

			TryDeconstructComponent(instance)
		end)

		-- equivalent call inferred; original call site unknown
		if IsInAncestorList() then
			TryConstructComponent(instance) -- equivalent call inferred; original call site unknown
		end
	end

	local function InstanceTagged(p)
		StartWatchingInstance(p)
	end

	local function InstanceUntagged(p)
		local v12 = v11[p]

		if v12 then
			v11[p] = nil
			self[symbol5]:Remove(v12)
		end

		TryDeconstructComponent(p)
	end

	self[symbol5]:Connect(CollectionService:GetInstanceAddedSignal(self.Tag), InstanceTagged)
	self[symbol5]:Connect(CollectionService:GetInstanceRemovedSignal(self.Tag), InstanceUntagged)
	local tagged = CollectionService:GetTagged(self.Tag)

	for _, v12 in ipairs(tagged) do
		task.defer(InstanceTagged, v12)
	end
end

function Component.GetAll(p)
	return p[symbol4]
end

function Component:FromInstance(p2)
	return self[symbol2][p2]
end

function Component:WaitForInstance(p, value: number?)
	local v11 = self:FromInstance(p)

	if v11 and v11[symbol9] then
		return Promise.resolve(v11)
	end

	return Promise.fromEvent(self.Started, function(p2)
		local selected = p2.Instance == p

		if selected then
			v11 = p2
		end

		return selected
	end):andThen(function()
		return v11
	end):timeout(type(value) ~= "number" and 60 or value)
end

function Component:Construct() end

function Component:Start() end

function Component:Stop() end

function Component.GetComponent(p, p2)
	return p2[symbol2][p.Instance]
end

function Component:Destroy()
	self[symbol5]:Destroy()
end

return Component