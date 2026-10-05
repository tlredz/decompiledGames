local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Promise)
local v2 = {
	"TotalRequestsOverLimit",
	"InternalError",
	"RequestThrottled",
	"PartitionRequestsOverLimit",
	"Throttled",
	"Timeout"
}
return table.freeze({
	hashMapRetry = function(callback, value: number?)
		return v.new(function(callback2, callback3, callback4)
			local v3 = nil

			for i = 1, value or 6 do
				if callback4() then
					return callback3("HashMap error: operation cancelled")
				end

				local v4 = table.pack(pcall(callback))

				if v4[1] == true then
					return callback2(table.unpack(v4, 2))
				end

				v3 = v4[2]
				local v5 = false

				for _, v7 in v2 do
					if not v3:find(v7, 1, true) then
						continue
					end

					v5 = true
					break
				end

				if not v5 then
					return callback3((`HashMap error: {v3}`))
				end

				if not callback4() then
					task.wait(2 ^ (i - 1))
				end
			end

			if callback4() then
				return callback3("HashMap error: operation cancelled")
			end

			return callback3((`HashMap error: too many retries ({value}). Last error: {v3}`))
		end)
	end
})