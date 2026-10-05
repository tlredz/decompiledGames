local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ServerScriptService")
game:GetService("ReplicatedStorage")
local v = require3(script.Parent.Squash)
local T = v.T
local _ = v.uint
local vlq = v.vlq()
local boolean = v.boolean()
local string = v.string()
local number = v.number(4)
local _ = v.Vector2
local array = v.array
local map = v.map
local opt = v.opt
local record = v.record
local v2 = { "boolean", "number" }
local any

any = function()
	return {
		ser = function(p, items)
			local typeName = typeof(items)

			if typeName == "nil" then
				string.ser(p, "nil")
			elseif typeName == "table" then
				local count = 0

				for k, item in items do
					count += 1
					any().ser(p, k)
					any().ser(p, item)
				end

				vlq.ser(p, count)
				string.ser(p, "table")
			else
				local v3 = v[typeName]

				if not v3 then
					error((`not found for {typeName}`))
				end

				if typeof(v3) == "function" or typeName == "string" then
					local v4

					if typeName ~= "string" then
						v4 = table.find(v2, typeName) and 8 or v.number(8)
					end

					v3 = v3(v4)
				end

				v3.ser(p, items)
				string.ser(p, typeName)
			end
		end,
		des = function(p)
			local des = string.des(p)

			if des == "nil" then
				return nil
			end

			if des == "table" then
				local result = {}

				for _ = 1, vlq.des(p) do
					local des2 = any().des(p)
					result[any().des(p)] = des2
				end

				return result
			else
				local v3 = v[des]

				if not v3 then
					error((`not found for {des}`))
				end

				if typeof(v3) ~= "function" and des ~= "string" then
					return v3.des(p)
				end

				local v4

				if des ~= "string" then
					v4 = table.find(v2, des) and 8 or v.number(8)
				end

				v3 = v3(v4)
				return v3.des(p)
			end
		end
	}
end

return record({
	Information = T(record({
		Looped = T(boolean),
		Length = T(vlq),
		FPS = T(opt(vlq))
	})),
	Compiled = T(array(record({
		Path = record({
			InstanceNames = T(array(string)),
			InstanceTypes = T(array(string)),
			ItemType = T(string)
		}),
		Props = T(opt(map(string, record({
			Default = T(any()),
			Static = T(opt(boolean)),
			Sequence = T(array(record({
				Ease = T(opt(record({
					Params = record({
						Direction = T(opt(string)),
						Overshoot = T(opt(number)),
						Amplitude = T(opt(number)),
						Period = T(opt(number))
					}),
					Type = T(string)
				}))),
				Time = T(vlq),
				Value = T(any())
			})))
		}))))
	})))
})