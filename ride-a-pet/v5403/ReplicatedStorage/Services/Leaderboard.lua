local services = game.ReplicatedStorage.Services
local Player = require(services.Player)
game:GetService("DataStoreService")
local leaderboardContent = script:WaitForChild("LeaderboardContent")

-- equivalent calls inferred from this helper; original call sites unknown
local function DecompressFromLeaderboard(value)
	if value <= 0 then
		return 0
	end

	return (math.floor(10 ^ (value / 1000000)))
end

local function FormatNumber(p)
	local v = {
		"",
		"K",
		"M",
		"B",
		"T",
		"Qa",
		"Qi"
	}
	local v2 = 1

	while p >= 1000 and v2 < #v do
		p /= 1000
		v2 += 1
	end

	if v2 == 1 then
		return (tostring((math.floor(p))))
	end

	local v3 = string.format("%.1f", p)
	return string.gsub(v3, "%.0$", "") .. v[v2]
end

return {
	UpdateLeaderboard = function(_, object, instance, options)
		local v = options or {}
		local awardBadge = v.AwardBadge
		local enlargeStatue = v.EnlargeStatue
		local success, result = pcall(function()
			local scrollingFrame = instance:FindFirstChild("Leaderboard") and instance.Leaderboard:FindFirstChild("SurfaceGui") and instance.Leaderboard.SurfaceGui:FindFirstChildOfClass("ScrollingFrame")

			if not scrollingFrame then
				return
			end

			local rigSpawn = instance:FindFirstChild("RigSpawn")
			local currentPage = object:GetSortedAsync(false, 50):GetCurrentPage()
			local v2 = 1

			for _, frame in ipairs(scrollingFrame:GetChildren()) do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end

			for _, v3 in ipairs(currentPage) do
				local key = tonumber(v3.key)

				if key < 0 then
					continue
				end

				if awardBadge then
					awardBadge(key)
				end

				local decompressFromLeaderboard = DecompressFromLeaderboard(v3.value) -- equivalent call inferred; original call site unknown
				local text = FormatNumber(decompressFromLeaderboard)

				if decompressFromLeaderboard == 0 then
					continue
				end

				local nameFromUserIdAsync = "Unknown Player"
				local v6 = key
				pcall(function()
					nameFromUserIdAsync = game.Players:GetNameFromUserIdAsync(v6)
				end)
				local parent = nil

				if v2 == 1 and key and rigSpawn then
					parent = Player:SpawnRig(key, rigSpawn)
					local idleAnimation = v.IdleAnimation

					if idleAnimation then
						parent:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator"):LoadAnimation(idleAnimation):Play()
					end

					if enlargeStatue == true then
						task.spawn(function()
							parent:WaitForChild("Head")
							task.wait(1)
							local clone = script:WaitForChild("AceHighlight"):Clone()
							clone.Parent = parent
							parent:ScaleTo(2)
							local clone_2 = script:WaitForChild("TopPlayer"):Clone()
							clone_2.Parent = parent:WaitForChild("Head")
							local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
							humanoidRootPart.Anchored = true
						end)
					end
				end

				local clone = leaderboardContent:Clone()

				if clone:FindFirstChild("UserName") then
					clone.UserName.Text = nameFromUserIdAsync
				end

				if clone:FindFirstChild("UserPos") then
					clone.UserPos.Text = tostring(v2)
				end

				if clone:FindFirstChild("Score") then
					clone.Score.Text = text
				end

				if clone:FindFirstChild("ProfilePicture") then
					clone.ProfilePicture.Image = Player:FetchPlayerPFP(key)
				end

				clone.Parent = scrollingFrame
				v2 += 1
			end
		end)

		if not success then
			warn("Leaderboard Error: " .. tostring(result))
		end
	end
}