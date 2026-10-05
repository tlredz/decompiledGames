local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.Utils)

local function toUserId(player)
	if typeof(player) == "Instance" and player:IsA("Player") then
		return player.UserId
	end

	if typeof(player) == "number" then
		return player
	end

	if typeof(player) == "string" then
		local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, player)

		if success and userIdFromNameAsync then
			return userIdFromNameAsync
		end
	end
end

local function checkRank(p: number, p2: number)
	local success, result = pcall(function()
		local GroupService = game:GetService("GroupService")
		local groupsAsync = GroupService:GetGroupsAsync(p)

		for _, v2 in groupsAsync do
			if v2.Id == p2 then
				return v2.Rank
			end
		end
	end)

	if success then
		return result
	end
end

local function groupPermission(p: string)
	return function(player)
		local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

		if not fFlag or type(fFlag) ~= "table" then
			return false
		end

		local v2 = fFlag[p]

		if not v2 then
			return false
		end

		local success, result = pcall(function()
			if typeof(player) == "Instance" and player:IsA("Player") then
				return v2 <= player:GetRankInGroupAsync(game.CreatorId)
			end

			local userId = player

			if typeof(userId) == "Instance" and userId:IsA("Player") then
				userId = userId.UserId
			elseif typeof(userId) ~= "number" then
				if typeof(userId) == "string" then
					local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
					userId = success2 and userIdFromNameAsync or nil
				else
					userId = nil
				end
			end

			if not userId then
				return false
			end

			local creatorId = game.CreatorId
			local success2, result2 = pcall(function()
				local GroupService = game:GetService("GroupService")
				local groupsAsync = GroupService:GetGroupsAsync(userId)

				for _, v3 in groupsAsync do
					if v3.Id == creatorId then
						return v3.Rank
					end
				end
			end)

			if not success2 then
				result2 = nil
			end

			return v2 <= result2
		end)
		return success == true and result == true
	end
end

local function list(value, p: string?)
	return function(userId)
		if p then
			local v2 = p

			if not (function(player)
				local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

				if not fFlag or type(fFlag) ~= "table" then
					return false
				end

				local v3 = fFlag[v2]

				if not v3 then
					return false
				end

				local success, result = pcall(function()
					if typeof(player) == "Instance" and player:IsA("Player") then
						return v3 <= player:GetRankInGroupAsync(game.CreatorId)
					end

					local userId2 = player

					if typeof(userId2) == "Instance" and userId2:IsA("Player") then
						userId2 = userId2.UserId
					elseif typeof(userId2) ~= "number" then
						if typeof(userId2) == "string" then
							local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId2)
							userId2 = success2 and userIdFromNameAsync or nil
						else
							userId2 = nil
						end
					end

					if not userId2 then
						return false
					end

					local creatorId = game.CreatorId
					local success2, result2 = pcall(function()
						local GroupService = game:GetService("GroupService")
						local groupsAsync = GroupService:GetGroupsAsync(userId2)

						for _, v4 in groupsAsync do
							if v4.Id == creatorId then
								return v4.Rank
							end
						end
					end)

					if not success2 then
						result2 = nil
					end

					return v3 <= result2
				end)
				return success == true and result == true
			end)(userId) then
				return false
			end
		end

		if typeof(userId) == "Instance" and userId:IsA("Player") then
			userId = userId.UserId
		elseif typeof(userId) ~= "number" then
			if typeof(userId) == "string" then
				local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
				userId = success and userIdFromNameAsync or nil
			else
				userId = nil
			end
		end

		if not userId then
			return false
		end

		if type(value) == "table" then
			return table.find(value, userId) ~= nil
		end

		if type(value) == "string" then
			local fFlag = v.FFlag.GetFFlag(value)

			if type(fFlag) == "table" then
				return table.find(fFlag, userId) ~= nil
			end
		end

		return false
	end
end

local function authorize(role: string, authorize2)
	return {
		Role = role,
		Authorize = authorize2
	}
end

local v3 = {
	276557820,
	813163219,
	2678001507,
	207355228,
	5080868749
}
local v4 = nil
local v6 = { 5098885657, 4946842593 }
local v7 = "DEVELOPER"
local v9 = {
	45385291,
	71017424,
	932083,
	4041424790
}
local v10 = "DEVELOPER"
local v12 = { 92313341 }
local v13 = "ADMIN"
local v15 = "DEVELOPER"
local v16 = nil
local v17 = "SuperAdmins"
local v19 = "ADMIN"
local v20 = "MODERATOR"
local v21 = "SUPPORT"
local v22 = "TESTER"
return table.freeze({
	List = {
		None = {},
		Tester = {},
		Support = { "ModLogs.Read", "DuelsHistory.Read" },
		Mod = {
			"ModLogs.Read",
			"DuelsHistory.Read",
			"Data.Read",
			"Tester",
			"Session.*",
			"Moderation.TradeBan",
			"Inventory.Read",
			"Trading.Read",
			"TradeHistory.Read",
			"Transactions.Read",
			"Leaderboards.Read"
		},
		Admin = { "Mod", "Moderation.*", "Inventory.Read" },
		SuperAdmin = { "Admin", "RAPHistory.ViewHourly" },
		Dev = { "SuperAdmin", "Inventory.Write", "Session.Save" },
		LeadAdmin = { "Dev", "Trade.ResetPIN", "RAPHistory.Delete" },
		ActualDeveloper = { "Dev", "ExistCounter.Read", "Trade.ResetPIN" },
		LeadTester = {
			"Dev",
			"ExistCounter.Read",
			"Inventory.TradeLock",
			"Trade.ResetPIN",
			"RAPHistory.Delete",
			"Inventory.GrantTokens"
		},
		Lead = {
			"*",
			"Dev",
			"Inventory.Write",
			"ExistCounter.Read",
			"Data.Write",
			"Trade.ResetPIN",
			"RAPHistory.Delete",
			"Inventory.GrantTokens"
		}
	},
	Authorization = {
		{
			Role = "Lead",
			Authorize = function(userId)
				if v4 then
					local v6 = v4

					if not (function(player)
						local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

						if not fFlag or type(fFlag) ~= "table" then
							return false
						end

						local v7 = fFlag[v6]

						if not v7 then
							return false
						end

						local success, result = pcall(function()
							if typeof(player) == "Instance" and player:IsA("Player") then
								return v7 <= player:GetRankInGroupAsync(game.CreatorId)
							end

							local userId2 = player

							if typeof(userId2) == "Instance" and userId2:IsA("Player") then
								userId2 = userId2.UserId
							elseif typeof(userId2) ~= "number" then
								if typeof(userId2) == "string" then
									local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId2)
									userId2 = success2 and userIdFromNameAsync or nil
								else
									userId2 = nil
								end
							end

							if not userId2 then
								return false
							end

							local creatorId = game.CreatorId
							local success2, result2 = pcall(function()
								local GroupService = game:GetService("GroupService")
								local groupsAsync = GroupService:GetGroupsAsync(userId2)

								for _, v8 in groupsAsync do
									if v8.Id == creatorId then
										return v8.Rank
									end
								end
							end)

							if not success2 then
								result2 = nil
							end

							return v7 <= result2
						end)
						return success == true and result == true
					end)(userId) then
						return false
					end
				end

				if typeof(userId) == "Instance" and userId:IsA("Player") then
					userId = userId.UserId
				elseif typeof(userId) ~= "number" then
					if typeof(userId) == "string" then
						local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
						userId = success and userIdFromNameAsync or nil
					else
						userId = nil
					end
				end

				if not userId then
					return false
				end

				if type(v3) == "table" then
					return table.find(v3, userId) ~= nil
				end

				if type(v3) == "string" then
					local fFlag = v.FFlag.GetFFlag(v3)

					if type(fFlag) == "table" then
						return table.find(fFlag, userId) ~= nil
					end
				end

				return false
			end
		},
		{
			Role = "LeadTester",
			Authorize = function(userId)
				if v7 then
					local v9 = v7

					if not (function(player)
						local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

						if not fFlag or type(fFlag) ~= "table" then
							return false
						end

						local v10 = fFlag[v9]

						if not v10 then
							return false
						end

						local success, result = pcall(function()
							if typeof(player) == "Instance" and player:IsA("Player") then
								return v10 <= player:GetRankInGroupAsync(game.CreatorId)
							end

							local userId2 = player

							if typeof(userId2) == "Instance" and userId2:IsA("Player") then
								userId2 = userId2.UserId
							elseif typeof(userId2) ~= "number" then
								if typeof(userId2) == "string" then
									local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId2)
									userId2 = success2 and userIdFromNameAsync or nil
								else
									userId2 = nil
								end
							end

							if not userId2 then
								return false
							end

							local creatorId = game.CreatorId
							local success2, result2 = pcall(function()
								local GroupService = game:GetService("GroupService")
								local groupsAsync = GroupService:GetGroupsAsync(userId2)

								for _, v11 in groupsAsync do
									if v11.Id == creatorId then
										return v11.Rank
									end
								end
							end)

							if not success2 then
								result2 = nil
							end

							return v10 <= result2
						end)
						return success == true and result == true
					end)(userId) then
						return false
					end
				end

				if typeof(userId) == "Instance" and userId:IsA("Player") then
					userId = userId.UserId
				elseif typeof(userId) ~= "number" then
					if typeof(userId) == "string" then
						local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
						userId = success and userIdFromNameAsync or nil
					else
						userId = nil
					end
				end

				if not userId then
					return false
				end

				if type(v6) == "table" then
					return table.find(v6, userId) ~= nil
				end

				if type(v6) == "string" then
					local fFlag = v.FFlag.GetFFlag(v6)

					if type(fFlag) == "table" then
						return table.find(fFlag, userId) ~= nil
					end
				end

				return false
			end
		},
		{
			Role = "ActualDeveloper",
			Authorize = function(userId)
				if v10 then
					local v12 = v10

					if not (function(player)
						local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

						if not fFlag or type(fFlag) ~= "table" then
							return false
						end

						local v13 = fFlag[v12]

						if not v13 then
							return false
						end

						local success, result = pcall(function()
							if typeof(player) == "Instance" and player:IsA("Player") then
								return v13 <= player:GetRankInGroupAsync(game.CreatorId)
							end

							local userId2 = player

							if typeof(userId2) == "Instance" and userId2:IsA("Player") then
								userId2 = userId2.UserId
							elseif typeof(userId2) ~= "number" then
								if typeof(userId2) == "string" then
									local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId2)
									userId2 = success2 and userIdFromNameAsync or nil
								else
									userId2 = nil
								end
							end

							if not userId2 then
								return false
							end

							local creatorId = game.CreatorId
							local success2, result2 = pcall(function()
								local GroupService = game:GetService("GroupService")
								local groupsAsync = GroupService:GetGroupsAsync(userId2)

								for _, v14 in groupsAsync do
									if v14.Id == creatorId then
										return v14.Rank
									end
								end
							end)

							if not success2 then
								result2 = nil
							end

							return v13 <= result2
						end)
						return success == true and result == true
					end)(userId) then
						return false
					end
				end

				if typeof(userId) == "Instance" and userId:IsA("Player") then
					userId = userId.UserId
				elseif typeof(userId) ~= "number" then
					if typeof(userId) == "string" then
						local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
						userId = success and userIdFromNameAsync or nil
					else
						userId = nil
					end
				end

				if not userId then
					return false
				end

				if type(v9) == "table" then
					return table.find(v9, userId) ~= nil
				end

				if type(v9) == "string" then
					local fFlag = v.FFlag.GetFFlag(v9)

					if type(fFlag) == "table" then
						return table.find(fFlag, userId) ~= nil
					end
				end

				return false
			end
		},
		{
			Role = "LeadAdmin",
			Authorize = function(userId)
				if v13 then
					local v15 = v13

					if not (function(player)
						local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

						if not fFlag or type(fFlag) ~= "table" then
							return false
						end

						local v16 = fFlag[v15]

						if not v16 then
							return false
						end

						local success, result = pcall(function()
							if typeof(player) == "Instance" and player:IsA("Player") then
								return v16 <= player:GetRankInGroupAsync(game.CreatorId)
							end

							local userId2 = player

							if typeof(userId2) == "Instance" and userId2:IsA("Player") then
								userId2 = userId2.UserId
							elseif typeof(userId2) ~= "number" then
								if typeof(userId2) == "string" then
									local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId2)
									userId2 = success2 and userIdFromNameAsync or nil
								else
									userId2 = nil
								end
							end

							if not userId2 then
								return false
							end

							local creatorId = game.CreatorId
							local success2, result2 = pcall(function()
								local GroupService = game:GetService("GroupService")
								local groupsAsync = GroupService:GetGroupsAsync(userId2)

								for _, v17 in groupsAsync do
									if v17.Id == creatorId then
										return v17.Rank
									end
								end
							end)

							if not success2 then
								result2 = nil
							end

							return v16 <= result2
						end)
						return success == true and result == true
					end)(userId) then
						return false
					end
				end

				if typeof(userId) == "Instance" and userId:IsA("Player") then
					userId = userId.UserId
				elseif typeof(userId) ~= "number" then
					if typeof(userId) == "string" then
						local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
						userId = success and userIdFromNameAsync or nil
					else
						userId = nil
					end
				end

				if not userId then
					return false
				end

				if type(v12) == "table" then
					return table.find(v12, userId) ~= nil
				end

				if type(v12) == "string" then
					local fFlag = v.FFlag.GetFFlag(v12)

					if type(fFlag) == "table" then
						return table.find(fFlag, userId) ~= nil
					end
				end

				return false
			end
		},
		{
			Role = "Dev",
			Authorize = function(player)
				local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

				if not fFlag or type(fFlag) ~= "table" then
					return false
				end

				local v23 = fFlag[v15]

				if not v23 then
					return false
				end

				local success, result = pcall(function()
					if typeof(player) == "Instance" and player:IsA("Player") then
						return v23 <= player:GetRankInGroupAsync(game.CreatorId)
					end

					local userId = player

					if typeof(userId) == "Instance" and userId:IsA("Player") then
						userId = userId.UserId
					elseif typeof(userId) ~= "number" then
						if typeof(userId) == "string" then
							local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
							userId = success2 and userIdFromNameAsync or nil
						else
							userId = nil
						end
					end

					if not userId then
						return false
					end

					local creatorId = game.CreatorId
					local success2, result2 = pcall(function()
						local GroupService = game:GetService("GroupService")
						local groupsAsync = GroupService:GetGroupsAsync(userId)

						for _, v24 in groupsAsync do
							if v24.Id == creatorId then
								return v24.Rank
							end
						end
					end)

					if not success2 then
						result2 = nil
					end

					return v23 <= result2
				end)
				return success == true and result == true
			end
		},
		{
			Role = "SuperAdmin",
			Authorize = function(userId)
				if v16 then
					local v19 = v16

					if not (function(player)
						local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

						if not fFlag or type(fFlag) ~= "table" then
							return false
						end

						local v20 = fFlag[v19]

						if not v20 then
							return false
						end

						local success, result = pcall(function()
							if typeof(player) == "Instance" and player:IsA("Player") then
								return v20 <= player:GetRankInGroupAsync(game.CreatorId)
							end

							local userId2 = player

							if typeof(userId2) == "Instance" and userId2:IsA("Player") then
								userId2 = userId2.UserId
							elseif typeof(userId2) ~= "number" then
								if typeof(userId2) == "string" then
									local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId2)
									userId2 = success2 and userIdFromNameAsync or nil
								else
									userId2 = nil
								end
							end

							if not userId2 then
								return false
							end

							local creatorId = game.CreatorId
							local success2, result2 = pcall(function()
								local GroupService = game:GetService("GroupService")
								local groupsAsync = GroupService:GetGroupsAsync(userId2)

								for _, v21 in groupsAsync do
									if v21.Id == creatorId then
										return v21.Rank
									end
								end
							end)

							if not success2 then
								result2 = nil
							end

							return v20 <= result2
						end)
						return success == true and result == true
					end)(userId) then
						return false
					end
				end

				if typeof(userId) == "Instance" and userId:IsA("Player") then
					userId = userId.UserId
				elseif typeof(userId) ~= "number" then
					if typeof(userId) == "string" then
						local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
						userId = success and userIdFromNameAsync or nil
					else
						userId = nil
					end
				end

				if not userId then
					return false
				end

				if type(v17) == "table" then
					return table.find(v17, userId) ~= nil
				end

				if type(v17) == "string" then
					local fFlag = v.FFlag.GetFFlag(v17)

					if type(fFlag) == "table" then
						return table.find(fFlag, userId) ~= nil
					end
				end

				return false
			end
		},
		{
			Role = "Admin",
			Authorize = function(player)
				local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

				if not fFlag or type(fFlag) ~= "table" then
					return false
				end

				local v23 = fFlag[v19]

				if not v23 then
					return false
				end

				local success, result = pcall(function()
					if typeof(player) == "Instance" and player:IsA("Player") then
						return v23 <= player:GetRankInGroupAsync(game.CreatorId)
					end

					local userId = player

					if typeof(userId) == "Instance" and userId:IsA("Player") then
						userId = userId.UserId
					elseif typeof(userId) ~= "number" then
						if typeof(userId) == "string" then
							local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
							userId = success2 and userIdFromNameAsync or nil
						else
							userId = nil
						end
					end

					if not userId then
						return false
					end

					local creatorId = game.CreatorId
					local success2, result2 = pcall(function()
						local GroupService = game:GetService("GroupService")
						local groupsAsync = GroupService:GetGroupsAsync(userId)

						for _, v24 in groupsAsync do
							if v24.Id == creatorId then
								return v24.Rank
							end
						end
					end)

					if not success2 then
						result2 = nil
					end

					return v23 <= result2
				end)
				return success == true and result == true
			end
		},
		{
			Role = "Mod",
			Authorize = function(player)
				local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

				if not fFlag or type(fFlag) ~= "table" then
					return false
				end

				local v23 = fFlag[v20]

				if not v23 then
					return false
				end

				local success, result = pcall(function()
					if typeof(player) == "Instance" and player:IsA("Player") then
						return v23 <= player:GetRankInGroupAsync(game.CreatorId)
					end

					local userId = player

					if typeof(userId) == "Instance" and userId:IsA("Player") then
						userId = userId.UserId
					elseif typeof(userId) ~= "number" then
						if typeof(userId) == "string" then
							local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
							userId = success2 and userIdFromNameAsync or nil
						else
							userId = nil
						end
					end

					if not userId then
						return false
					end

					local creatorId = game.CreatorId
					local success2, result2 = pcall(function()
						local GroupService = game:GetService("GroupService")
						local groupsAsync = GroupService:GetGroupsAsync(userId)

						for _, v24 in groupsAsync do
							if v24.Id == creatorId then
								return v24.Rank
							end
						end
					end)

					if not success2 then
						result2 = nil
					end

					return v23 <= result2
				end)
				return success == true and result == true
			end
		},
		{
			Role = "Support",
			Authorize = function(player)
				local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

				if not fFlag or type(fFlag) ~= "table" then
					return false
				end

				local v23 = fFlag[v21]

				if not v23 then
					return false
				end

				local success, result = pcall(function()
					if typeof(player) == "Instance" and player:IsA("Player") then
						return v23 <= player:GetRankInGroupAsync(game.CreatorId)
					end

					local userId = player

					if typeof(userId) == "Instance" and userId:IsA("Player") then
						userId = userId.UserId
					elseif typeof(userId) ~= "number" then
						if typeof(userId) == "string" then
							local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
							userId = success2 and userIdFromNameAsync or nil
						else
							userId = nil
						end
					end

					if not userId then
						return false
					end

					local creatorId = game.CreatorId
					local success2, result2 = pcall(function()
						local GroupService = game:GetService("GroupService")
						local groupsAsync = GroupService:GetGroupsAsync(userId)

						for _, v24 in groupsAsync do
							if v24.Id == creatorId then
								return v24.Rank
							end
						end
					end)

					if not success2 then
						result2 = nil
					end

					return v23 <= result2
				end)
				return success == true and result == true
			end
		},
		{
			Role = "Tester",
			Authorize = function(player)
				local fFlag = v.FFlag.GetFFlag("ChatPermissionsGroupRanks")

				if not fFlag or type(fFlag) ~= "table" then
					return false
				end

				local v23 = fFlag[v22]

				if not v23 then
					return false
				end

				local success, result = pcall(function()
					if typeof(player) == "Instance" and player:IsA("Player") then
						return v23 <= player:GetRankInGroupAsync(game.CreatorId)
					end

					local userId = player

					if typeof(userId) == "Instance" and userId:IsA("Player") then
						userId = userId.UserId
					elseif typeof(userId) ~= "number" then
						if typeof(userId) == "string" then
							local success2, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, userId)
							userId = success2 and userIdFromNameAsync or nil
						else
							userId = nil
						end
					end

					if not userId then
						return false
					end

					local creatorId = game.CreatorId
					local success2, result2 = pcall(function()
						local GroupService = game:GetService("GroupService")
						local groupsAsync = GroupService:GetGroupsAsync(userId)

						for _, v24 in groupsAsync do
							if v24.Id == creatorId then
								return v24.Rank
							end
						end
					end)

					if not success2 then
						result2 = nil
					end

					return v23 <= result2
				end)
				return success == true and result == true
			end
		},
		{
			Role = "None",
			Authorize = function()
				return true
			end
		}
	}
})