local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	[-1] = "rbxassetid://91427587664035",
	[-2] = "rbxassetid://94602959628846",
	[-3] = "rbxassetid://87976244184907",
	[-4] = "rbxassetid://89585827248259"
}
local userThumbnailAsyncs = {}

local function fetchThumbnailAsync(p: number, p2, p3)
	if p and not (p <= 0) then
		if (p2 == nil or p2 == Enum.ThumbnailType.HeadShot) and (p3 == nil or p3 == Enum.ThumbnailSize.Size420x420) and userThumbnailAsyncs[p] then
			return true, userThumbnailAsyncs[p]
		end

		local success, userThumbnailAsync = pcall(
			Players.GetUserThumbnailAsync,
			Players,
			p,
			p2 or Enum.ThumbnailType.HeadShot,
			p3 or Enum.ThumbnailSize.Size420x420
		)

		if success and (p2 == nil or p2 == Enum.ThumbnailType.HeadShot) and (p3 == nil or p3 == Enum.ThumbnailSize.Size420x420) then
			userThumbnailAsyncs[p] = userThumbnailAsync
		end

		return success, success and userThumbnailAsync or "rbxassetid://10730799514"
	else
		local selected = p and v[p]

		if selected then
			return true, selected
		end

		return false, "rbxassetid://10730799514"
	end
end

local function applyThumbnailAsync(p, p2: number, options)
	local v2 = options or {}
	local image = (v2.thumbnailType == nil or v2.thumbnailType == Enum.ThumbnailType.HeadShot) and (v2.thumbnailSize == nil or v2.thumbnailSize == Enum.ThumbnailSize.Size420x420) and (userThumbnailAsyncs[p2] or v[p2])

	if image then
		p.Image = image
		return
	end

	p.Image = v2.placeholder or "rbxassetid://10730799514"
	task.spawn(function()
		local v4, image2 = fetchThumbnailAsync(p2, v2.thumbnailType, v2.thumbnailSize)

		if v4 and p.Parent then
			p.Image = image2
		end
	end)
end

require(ReplicatedStorage.Packages.Observers).observePlayer(function(p)
	task.spawn(function()
		local userId = p.UserId
		local userThumbnailAsync, success

		if userId and not (userId <= 0) then
			if userThumbnailAsyncs[userId] then
				userThumbnailAsync = userThumbnailAsyncs[userId]
				success = true
			else
				success, userThumbnailAsync = pcall(
					Players.GetUserThumbnailAsync,
					Players,
					userId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size420x420
				)

				if success then
					userThumbnailAsyncs[userId] = userThumbnailAsync
				end

				if not (success and userThumbnailAsync) then
					userThumbnailAsync = "rbxassetid://10730799514"
				end
			end
		else
			userThumbnailAsync = userId and v[userId]

			if userThumbnailAsync then
				success = true
			else
				success = false
				userThumbnailAsync = "rbxassetid://10730799514"
			end
		end

		if success then
			userThumbnailAsyncs[p.UserId] = userThumbnailAsync
		end
	end)
end)

local function fetchLocalPlayerThumbnailAsync()
	return fetchThumbnailAsync(Players.LocalPlayer.UserId)
end

return {
	DefaultPlaceholder = "rbxassetid://10730799514",
	fetchAsync = fetchThumbnailAsync,
	applyAsync = applyThumbnailAsync,
	fetchLocalPlayerAsync = fetchLocalPlayerThumbnailAsync
}