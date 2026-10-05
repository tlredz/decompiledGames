local Players = game:GetService("Players")
local AvatarPortraits = {}
AvatarPortraits.__index = AvatarPortraits
local v = {}
local count = 0

local function request(avatarUserId, fn)
	local v2 = v[avatarUserId]

	if v2 and v2.image then
		fn(v2.image)
		return
	end

	if v2 and v2.pending then
		table.insert(v2.waiters, fn)
		return
	end

	if v2 and os.clock() < v2.retryAt then
		return
	end

	if count >= 64 then
		table.clear(v)
		count = 0
	end

	local v3 = {
		pending = true,
		waiters = { fn },
		retryAt = 0
	}
	v[avatarUserId] = v3
	count += 1
	task.spawn(function()
		local image = nil

		for i = 1, 3 do
			local success, userThumbnailAsync, v5 = pcall(
				Players.GetUserThumbnailAsync,
				Players,
				avatarUserId,
				Enum.ThumbnailType.AvatarBust,
				Enum.ThumbnailSize.Size180x180
			)

			if success and v5 and type(userThumbnailAsync) == "string" and userThumbnailAsync ~= "" then
				image = userThumbnailAsync
				break
			elseif i < 3 then
				task.wait(i * 0.5)
			end
		end

		v3.pending = false
		v3.image = image
		v3.retryAt = os.clock() + 30

		for _, waiter in v3.waiters do
			waiter(image)
		end

		table.clear(v3.waiters)
	end)
end

function AvatarPortraits.new()
	return (setmetatable({
		alive = true,
		tokens = {}
	}, AvatarPortraits))
end

function AvatarPortraits.bind(p, data, data2)
	local v2 = {}
	p.tokens[data] = v2
	local portrait = data.Portrait
	local avatarFallback = data.AvatarFallback
	portrait.Image = ""
	portrait.Visible = false
	avatarFallback.Visible = data2 ~= nil

	if not data2 then
		return
	end

	local avatar = avatarFallback:FindFirstChild("Avatar")

	if avatar then
		for _, part in avatar:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			local v3 = data2.avatarColors and data2.avatarColors[part.Name]
			local defaultColor = part:GetAttribute("DefaultColor")
			part.Color = v3 and Color3.fromRGB(v3[1], v3[2], v3[3]) or defaultColor or part.Color
		end
	end

	local avatarUserId = data2.avatarUserId or not data2.isBot and data2.userId

	if type(avatarUserId) ~= "number" or avatarUserId <= 0 then
		return
	end

	request(avatarUserId, function(image)
		if not p.alive or p.tokens[data] ~= v2 or not (data.Parent and image) then
			return
		end

		portrait.Image = image
		portrait.Visible = true
		avatarFallback.Visible = false
	end)
end

function AvatarPortraits.clear(p)
	table.clear(p.tokens)
end

function AvatarPortraits:destroy()
	self.alive = false
	self:clear()
end

return AvatarPortraits