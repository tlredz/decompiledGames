local insert = table.insert
local find = table.find
local remove = table.remove
local typeof2 = typeof
local clear = table.clear
local repeatedCompile = require(script.repeatedCompile)
local FayeUtility = require(script.Parent.Parent.Misc.FayeUtility)
local Compilers = {}

function Compilers.SetTo(p, _, p2)
	if p2.Value ~= nil and p2.Value.Set ~= nil then
		p2.Value:Set(p)
	end
end

function Compilers.YieldSafe(data, p, p2, callback)
	local cleanThread = data.CleanThread or data.Thread
	local thread = nil
	local v = false

	local function fn()
		local func, v2 = p2.func(cleanThread, data.Instance)
		v = true

		if func ~= nil then
			if p == nil or FayeUtility.tof(p) == FayeUtility.numbertxt then
				if v2 == nil then
					callback(
						data,
						(FayeUtility.tof(func) ~= FayeUtility.tabletxt or func.__type ~= nil or not func) and { func } or func
					)
				else
					callback(data, {
						[func] = v2
					})
				end
			else
				callback(data, {
					[p] = func
				})
			end
		end

		if thread ~= nil and cleanThread ~= nil then
			FayeUtility.RemoveFromThread(cleanThread, thread)
		end
	end

	thread = p2.DelayTime ~= nil and task.delay(p2.DelayTime, fn) or task.spawn(fn)

	if cleanThread ~= nil and v == false then
		if cleanThread._isCleanAncestor then
			local parentThread = cleanThread

			while parentThread ~= nil and not parentThread._hc do
				parentThread = parentThread.ParentThread
			end

			cleanThread = parentThread or cleanThread
		end

		FayeUtility.AddToThread(cleanThread, thread)
	end
end

function Compilers.Instance(data, _, object, _, _)
	local props = object.Props
	local thread = data.Thread
	local cleanThread = data.CleanThread

	if props ~= nil then
		if cleanThread ~= nil and cleanThread ~= thread and (object.Props.OnClean == nil and object.Props.CleanDelay == nil or cleanThread._isCleanAncestor) then
			if thread.Remove then
				thread:Remove(object)
			else
				local index = find(thread, object)

				if index ~= nil then
					remove(thread, index)
				end
			end

			if cleanThread.Add then
				cleanThread:Add(object)
			else
				insert(cleanThread, object)
			end

			object.CleanThread = cleanThread
		end

		if props.Parent == nil then
			props.Parent = data.Instance
		end

		object:Compile()
	end
end

function Compilers.OnChanged(data, propertyName, callback, p, p2)
	local instance = data.Instance
	local cleanThread = data.CleanThread or data.Thread

	if p2 == true then
		local v, v2 = callback(instance, instance[propertyName])

		if v ~= nil then
			repeatedCompile(propertyName, v, v2, p, data)
		end
	end

	local propertyChangedSignal = instance:GetPropertyChangedSignal(propertyName)

	local function fn()
		if (cleanThread.ParentThread ~= nil or not cleanThread.IsActive) and not cleanThread.ParentThread.IsActive then
			return
		end

		local v, v2 = callback(instance, instance[propertyName])

		if v ~= nil then
			repeatedCompile(propertyName, v, v2, p, data)
		end
	end

	if not FayeUtility.ConnectToEntity(data, propertyChangedSignal, fn) then
		FayeUtility.Connect(propertyChangedSignal, fn, cleanThread)
	end
end

Compilers.GetSignal = require(script.GetSignal)

function Compilers.EventCompiler(data, p, callback, p2)
	local cleanThread = data.CleanThread or data.Thread
	local instance = data.Instance
	local v = instance[p]

	local function fn(...)
		if (cleanThread.ParentThread ~= nil or not cleanThread.IsActive) and not cleanThread.ParentThread.IsActive then
			return
		end

		local v2, v3 = callback(instance, ...)

		if v2 ~= nil then
			repeatedCompile(p, v2, v3, p2, data)
		end
	end

	if not FayeUtility.ConnectToEntity(data, v, fn) then
		FayeUtility.Connect(v, fn, cleanThread)
	end
end

Compilers.Signal = require(script.CompileSignal)
Compilers.Iterate = require(script.CompileIterate)
Compilers.State = require(script.CompileState)
Compilers.SpecialThread = require(script.CompileSpecialThread)

function Compilers.DelayProperty(p, p2, data, callback)
	local init = data.Init
	local toCompile = data.ToCompile

	if init ~= nil then
		if typeof2(init) == FayeUtility.tabletxt and init.__type == nil then
			callback(p, init)
			clear(init)
		else
			callback(p, {
				[p2] = init
			})
		end
	end

	task.delay(data.Time, function()
		if p ~= nil and p.Instance ~= nil then
			if typeof2(toCompile) == FayeUtility.tabletxt and toCompile.__type == nil then
				callback(p, toCompile)
				clear(toCompile)
			else
				callback(p, {
					[p2] = toCompile
				})
			end

			toCompile = nil
		end
	end)
end

Compilers.Animation = require(script.CompileAnimations)
Compilers.Lerp = require(script.CompileLerp)
Compilers.Value = require(script.CompileValue)
return Compilers