local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Parent.Parent.Promise)
local WaitFor = {
	Error = {
		Unparented = "Unparented",
		ParentChanged = "ParentChanged"
	}
}

local function PromiseWatchAncestry(instance, p)
	return Promise.race({ p, Promise.fromEvent(instance.AncestryChanged, function(_, p2)
			return p2 == nil
		end):andThen(function()
			return Promise.reject(WaitFor.Error.Unparented)
		end) })
end

function WaitFor.Child(instance, childName: string, value: number?)
	local child = instance:FindFirstChild(childName)

	if child then
		return Promise.resolve(child)
	end

	return PromiseWatchAncestry(instance, Promise.fromEvent(instance.ChildAdded, function(p)
		return p.Name == childName
	end):timeout(value or 120))
end

function WaitFor.ChildWhichIsA(instance, className: string, value: number?)
	local firstChildWhichIsA = instance:FindFirstChildWhichIsA(className)

	if firstChildWhichIsA then
		return Promise.resolve(firstChildWhichIsA)
	end

	return PromiseWatchAncestry(instance, Promise.fromEvent(instance.ChildAdded, function(instance2)
		return instance2:IsA(className)
	end):timeout(value or 120))
end

function WaitFor.Children(p, list, p2: number?)
	local v = table.create(#list)

	for i, v2 in ipairs(list) do
		v[i] = WaitFor.Child(p, v2, p2)
	end

	return Promise.all(v):andThen(function(list2)
		for _, v2 in ipairs(list2) do
			if v2.Parent ~= p then
				return Promise.reject(WaitFor.Error.ParentChanged)
			end
		end

		return list2
	end)
end

function WaitFor.Descendant(instance, childName: string, value: number?)
	local child = instance:FindFirstChild(childName, true)

	if child then
		return Promise.resolve(child)
	end

	return PromiseWatchAncestry(instance, Promise.fromEvent(instance.DescendantAdded, function(p)
		return p.Name == childName
	end):timeout(value or 120))
end

function WaitFor.Descendants(ancestor, list, p: number?)
	local v = table.create(#list)

	for i, v2 in ipairs(list) do
		v[i] = WaitFor.Descendant(ancestor, v2, p)
	end

	return Promise.all(v):andThen(function(list2)
		for _, v2 in ipairs(list2) do
			if not v2:IsDescendantOf(ancestor) then
				return Promise.reject(WaitFor.Error.ParentChanged)
			end
		end

		return list2
	end)
end

function WaitFor.PrimaryPart(instance, value: number?)
	local primaryPart = instance.PrimaryPart

	if primaryPart then
		return Promise.resolve(primaryPart)
	end

	return PromiseWatchAncestry(instance, Promise.fromEvent(instance:GetPropertyChangedSignal("PrimaryPart"), function()
		primaryPart = instance.PrimaryPart
		return primaryPart ~= nil
	end):andThen(function()
		return primaryPart
	end):timeout(value or 120))
end

function WaitFor.ObjectValue(p, value: number?)
	local value2 = p.Value

	if value2 then
		return Promise.resolve(value2)
	end

	return PromiseWatchAncestry(p, Promise.fromEvent(p.Changed, function(p2)
		value2 = p2
		return value2 ~= nil
	end):andThen(function()
		return value2
	end):timeout(value or 120))
end

function WaitFor.Custom(callback, value: number?)
	local v = callback()

	if v == nil then
		return Promise.new(function(callback2, _, callback3)
			local heartbeatConnection = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function OnDone()
				heartbeatConnection:Disconnect()
			end

			local function Update()
				local v2 = callback()

				if v2 ~= nil then
					OnDone() -- equivalent call inferred; original call site unknown
					callback2(v2)
				end
			end

			heartbeatConnection = RunService.Heartbeat:Connect(Update)
			callback3(OnDone)
		end):timeout(value or 120)
	end

	return Promise.resolve(v)
end

return WaitFor