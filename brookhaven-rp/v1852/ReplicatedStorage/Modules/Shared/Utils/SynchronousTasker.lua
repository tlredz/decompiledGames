local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
return {
	new = function()
		local flag = false
		local v2 = {}
		local v3 = Signal.new()

		local function run()
			if flag then
				return
			end

			flag = true

			while true do
				local v4 = table.remove(v2, 1)

				if not v4 then
					break
				end

				local v5 = table.pack(v4.Runner():await())
				v3:Fire(v4.UUID, table.unpack(v5))
			end

			flag = false
		end

		return {
			ScheduleTask = function(_, runner)
				local GUID = HttpService:GenerateGUID(false)
				local v4 = Promise.new(function(callback2, callback3, _)
					local connection = nil
					connection = v3:Connect(function(p, p2, ...)
						if p == GUID then
							connection:Disconnect()
							connection = nil

							if p2 then
								callback2(...)
							else
								callback3(...)
							end
						end
					end)
				end)
				table.insert(v2, {
					Runner = runner,
					UUID = GUID
				})

				if not flag then
					task.defer(run)
				end

				return v4
			end,
			GetRemainingTaskCount = function(_)
				return #v2
			end
		}
	end
}