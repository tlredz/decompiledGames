local ContentProvider = game:GetService("ContentProvider")
local v = {}
local v2 = "http://www.roblox.com/Thumbs/Avatar.ashx?x=" .. 250 .. "&y=" .. 250 .. "&Format=Png&userId="
local v3 = "http://www.roblox.com/Thumbs/Avatar.ashx?x=" .. 250 .. "&y=" .. 250 .. "&Format=Png&username="
local bindableFunction = Instance.new("BindableFunction", game.ReplicatedStorage)
bindableFunction.Name = "GetPlayerImage"

local function FindImage(name)
	for k, v4 in pairs(v) do
		if v4.Name == name or v4.userId == tostring(name) then
			return v4.Image, k
		end
	end

	if tonumber(name) then
		return v2 .. name, nil
	end

	return v3 .. name, nil
end

bindableFunction.OnInvoke = FindImage

local function LoadPlayerImage(player)
	if player:IsA("Player") then
		local rawImage = player.Name:find("Guest ") and v2 .. "1" or player.userId < 1 and v2 .. "1" or v2 .. player.userId
		ContentProvider:Preload(rawImage)
		local image = rawImage .. "&bust=" .. math.floor((tick()))
		table.insert(v, {
			Name = player.Name,
			userId = tostring(player.userId),
			RawImage = rawImage,
			Image = image
		})
	end
end

game.Players.ChildAdded:connect(LoadPlayerImage)
game.Players.ChildRemoved:connect(function(p)
	local _, v4 = FindImage(p.Name)

	if v4 then
		table.remove(v, v4)
	end
end)

for _, v4 in pairs(game.Players:GetPlayers()) do
	LoadPlayerImage(v4)
end