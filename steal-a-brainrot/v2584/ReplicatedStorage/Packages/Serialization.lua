game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Squash = require(ReplicatedStorage.Packages.Squash)
local T = Squash.T
local _ = Squash.uint
local vlq = Squash.vlq()
local boolean = Squash.boolean()
local string = Squash.string()
local number = Squash.number(4)
local _ = Squash.Vector2
local array = Squash.array
local map = Squash.map
local opt = Squash.opt
local record = Squash.record
local v = { "boolean", "number" }
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
				local v2 = Squash[typeName]

				if not v2 then
					error((`not found for {typeName}`))
				end

				if typeof(v2) == "function" or typeName == "string" then
					local v3

					if typeName ~= "string" then
						v3 = table.find(v, typeName) and 8 or Squash.number(8)
					end

					v2 = v2(v3)
				end

				v2.ser(p, items)
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
				local v2 = Squash[des]

				if not v2 then
					error((`not found for {des}`))
				end

				if typeof(v2) ~= "function" and des ~= "string" then
					return v2.des(p)
				end

				local v3

				if des ~= "string" then
					v3 = table.find(v, des) and 8 or Squash.number(8)
				end

				v2 = v2(v3)
				return v2.des(p)
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