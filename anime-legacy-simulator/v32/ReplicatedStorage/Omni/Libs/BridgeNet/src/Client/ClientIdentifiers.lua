local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local v = nil
local v2 = {}
local v3 = {}
local v4 = {}
local ClientIdentifiers = {}

function ClientIdentifiers.start()
	v = wallyInstanceManager.waitForInstance(script.Parent.Parent.Parent, "identifierStorage", 1)

	for k, v5 in v:GetAttributes() do
		v2[k] = v5
		v3[v5] = k
		ClientIdentifiers.loadIdentifier(k, v5)
	end

	v.AttributeChanged:Connect(function(attributeName: string)
		local attribute = v:GetAttribute(attributeName)

		if attribute then
			v2[attributeName] = attribute
			v3[attribute] = attributeName
			ClientIdentifiers.loadIdentifier(attributeName, attribute)
		else
			local v5 = v2[attributeName]
			v2[attributeName] = nil
			v3[v5] = nil
		end
	end)
	ClientIdentifiers.ref("NIL_VALUE", 3, false)
	ClientIdentifiers.ref("REQUEST", 3, false)
end

function ClientIdentifiers.loadIdentifier(p: string, p2: string)
	if not v4[p] then
		return
	end

	local v5 = {}

	for k, callback in v4[p] do
		task.spawn(callback, p2)
		table.insert(v5, k)
	end

	for _, v6 in v5 do
		table.remove(v4[p], v6)
	end
end

function ClientIdentifiers.waitForIdentifier(p: string, value: number, flag: boolean)
	local v6 = v2[p]

	if v6 then
		return v6
	end

	if not v4[p] then
		v4[p] = {}
	end

	local thread = coroutine.running()
	table.insert(v4[p], thread)
	task.delay(value or 1, function()
		if table.find(v4[p], thread) then
			Output.fatal((`reached max wait time for {flag and "bridge" or "identifier"} {p}, broke yield. Did you forget to implement it on the server?`))
		end
	end)
	return coroutine.yield()
end

function ClientIdentifiers.ref(p: string, value: number?, flag: boolean)
	Output.typecheck("string", "ReferenceIdentifier", "identifierName", p)

	if value ~= nil then
		Output.typecheck("number", "ReferenceIdentifier", "maxWaitTime", value)
	end

	local v6 = v2[p]

	if v6 then
		return v6
	end

	return ClientIdentifiers.waitForIdentifier(p, value or 1, flag)
end

function ClientIdentifiers.deser(value)
	Output.fatalAssert(typeof(value) == "string", string.format("Deserialize takes string, got %*", (typeof(value))))
	return v3[value]
end

function ClientIdentifiers.ser(value)
	Output.fatalAssert(typeof(value) == "string", string.format("Serialize takes string, got %*", (typeof(value))))
	return v2[value]
end

return ClientIdentifiers