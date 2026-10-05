local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Promise)
local v2 = {
	301,
	302,
	303,
	304,
	305,
	306,
	500,
	501,
	502,
	503,
	504,
	505
}
return table.freeze({
	dataStoreRetry = function(callback, value: number?)
		return v.new(function(callback2, callback3)
			local v3 = value or 6
			local v4 = nil

			for i = 1, v3 do
				local v5 = table.pack(pcall(callback))

				if v5[1] == true then
					return callback2(table.unpack(v5, 2))
				end

				v4 = v5[2]
				local v6 = tonumber(string.match(v4, "^(%d+)"))

				if v6 == nil or not table.find(v2, v6) then
					return callback3(v4)
				else
					task.wait(2 ^ (i - 1))
				end
			end

			return callback3((`DataStore error: too many retries ({v3}). Last error: {v4}`))
		end)
	end,
	waitForBudget = function(p, p2: number)
		return v.new(function(callback, callback2, callback3)
			local flag = false
			callback3(function()
				flag = true
			end)

			while DataStoreService:GetRequestBudgetForRequestType(p) < p2 and not flag do
				task.wait(0.1)
			end

			if flag then
				callback2()
			else
				callback()
			end
		end)
	end
})