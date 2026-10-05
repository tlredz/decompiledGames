local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local usernamesById = {}
local v = {}
local v2 = false
local UserNames = {
	Changed = simplesignal.new()
}

local function read()
	while next(v) ~= nil do
		local v3 = {}

		for k in v do
			table.insert(v3, k)

			if #v3 == 200 then
				break
			end
		end

		local success, userInfosByUserIdsAsync = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, v3)

		if success then
			for _, v4 in userInfosByUserIdsAsync do
				usernamesById[v4.Id] = v4.Username
			end

			for _, v4 in v3 do
				v[v4] = nil

				if usernamesById[v4] ~= nil then
					continue
				end

				local success2, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, v4)
				local v5 = usernamesById

				if not success2 then
					nameFromUserIdAsync = tostring(v4)
				end

				v5[v4] = nameFromUserIdAsync
			end

			UserNames.Changed:Fire()
		else
			task.wait(10)
		end
	end

	v2 = false
end

function UserNames.Get(p: number)
	if usernamesById[p] ~= nil then
		return usernamesById[p]
	end

	v[p] = true

	if not v2 then
		v2 = true
		task.defer(read)
	end

	return "..."
end

return UserNames