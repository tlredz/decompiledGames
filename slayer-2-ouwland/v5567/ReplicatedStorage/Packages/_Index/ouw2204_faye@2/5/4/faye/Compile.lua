local typeof2 = typeof
local find = string.find
local sub = string.sub
local v = {
	Value = true,
	Lerp = true
}
local insert = table.insert
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Compilers = require(script.Compilers)
local UseCompilePassRecursiveness = require(script.Parent.Misc.UseCompilePassRecursiveness)
local v2 = {}
local Recursive

Recursive = function(data, p, object)
	if p.Before then
		local typeName = typeof2(p.Before)

		if typeName == "function" then
			local before2, v3 = p.Before(data.Instance)

			if before2 ~= nil then
				UseCompilePassRecursiveness(Recursive, before2, v3, data, data.CleanThread or data.Thread)
			end
		elseif typeName == "table" then
			Recursive(data, p.Before, object)
		end
	end

	local instance = data.Instance
	local v3 = nil

	for k, valueBase in p do
		if not (k ~= "After" and k ~= "Before") then
			continue
		end

		local typeName = typeof2(valueBase)
		local typeName2 = typeof2(k)

		if typeName2 == "string" and typeName ~= "table" and typeName ~= "function" and typeName ~= "Instance" and (Compilers[k] == nil or v[k]) and sub(
			k,
			1,
			2
		) ~= "On" then
			instance[k] = valueBase
		else
			local v4

			if typeName2 ~= "table" then
				v4 = Compilers[k] or nil
			end

			if v4 and not v[k] then
				if k == "GetSignal" then
					v3 = v3 == nil and {} or v3
					insert(v3, { "GetSignal", valueBase })
				else
					v4(data, k, valueBase, Recursive)
				end
			elseif typeName == "Instance" then
				if typeName2 == "number" then
					valueBase.Parent = instance

					if object ~= nil then
						if object.Add == nil then
							local instance2 = Instance
							insert(instance2, valueBase)
						else
							object:Add(valueBase)
						end
					end
				elseif valueBase:IsA("ValueBase") then
					Compilers.Value(data, k, valueBase)
				end
			elseif typeName == "table" then
				local v5 = valueBase.__type and (ValueClasses[valueBase.__type] and "Value" or valueBase.__type)

				if v5 and Compilers[v5] then
					Compilers[v5](data, k, valueBase, Recursive)
				else
					Recursive(data, valueBase, object)
				end
			elseif typeName2 == "table" and Compilers[k.__type] then
				Compilers[k.__type](data, k, valueBase, Recursive)
			elseif typeName == "function" and typeName2 == "number" then
				local v5, v6 = valueBase(instance)

				if v5 then
					UseCompilePassRecursiveness(Recursive, v5, v6, data, data.CleanThread or data.Thread)
				end
			elseif find(k, "OnChanged", 1, true) then
				v3 = v3 == nil and {} or v3
				insert(v3, { k, valueBase })
			else
				local className = instance.ClassName
				local v5 = v2[className]

				if v5 == nil then
					v5 = {}
					v2[className] = v5
				end

				local v6 = v5[k]

				if v6 == nil then
					v6 = typeof2(instance[k]) == "RBXScriptSignal"
					v5[k] = v6
				end

				if v6 then
					Compilers.EventCompiler(data, k, valueBase, Recursive)
				elseif typeName == "function" then
					local v7 = valueBase(instance)

					if v7 ~= nil then
						instance[k] = v7
					end
				else
					instance[k] = valueBase
				end
			end
		end
	end

	if v3 ~= nil then
		for _, v4 in v3 do
			local v5 = v4[1]
			local v6 = v4[2]

			if v5 == "GetSignal" then
				Compilers.GetSignal(data, "GetSignal", v6, Recursive)
			else
				local v8 = sub(v5, 1, find(v5, "OnChanged", 1, true) - 1)
				local v9 = find(v5, "OnChangedInit", 1, true) ~= nil
				Compilers.OnChanged(data, v8, v6, Recursive, v9)
			end
		end
	end

	if p.After then
		local typeName = typeof2(p.After)

		if typeName == "function" then
			local after2, v4 = p.After(data.Instance)

			if after2 ~= nil then
				UseCompilePassRecursiveness(Recursive, after2, v4, data, data.CleanThread or data.Thread)
			end
		elseif typeName == "table" then
			Recursive(data, p.After, object)
		end
	end
end

return function(p, p2, ...)
	Recursive(p, p2, ...)
end