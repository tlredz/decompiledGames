local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local HttpService = game:GetService("HttpService")
local v = require3(script.InstanceSerializer)
local v2 = require3(script["roblox-buff-dyn"])
return {
	deserialize = function(stringValue)
		local v3

		if stringValue:IsA("StringValue") then
			v3 = stringValue.Value
		else
			v3 = require3(stringValue)
		end

		local jSONDecode = HttpService:JSONDecode(v3)
		local decoded = v2.decode(jSONDecode)
		local childrenByName = {}

		for _, child in stringValue:GetChildren() do
			childrenByName[child.Name] = child
		end

		return v.deserialize(decoded, childrenByName)
	end
}