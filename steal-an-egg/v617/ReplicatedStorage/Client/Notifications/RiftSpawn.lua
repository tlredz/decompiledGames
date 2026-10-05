local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Areas = require(ReplicatedStorage.Data.Areas)
local Audio = require(ReplicatedStorage.Shared.Audio)
local Lanes = require(script.Parent.Lanes)
local RiftEligibility = require(ReplicatedStorage.Shared.Util.RiftEligibility)
local Save = require(ReplicatedStorage.Shared.Save)
local t = require(ReplicatedStorage.Packages.t)
local riftNotif = ReplicatedStorage.Assets.UI.Notifs.RiftNotif
local color = Color3.fromRGB(57, 255, 90)
local playbackSpeed = { 0.95, 1.05 }
local interface = t.interface({
	AreaId = t.optional(t.string),
	Seconds = t.optional(t.number),
	Color = t.optional(t.Color3),
	Sound = t.optional(t.union(t.string, t.number)),
	UniqueKey = t.optional(t.string),
	DelayInRound = t.optional(t.boolean)
})

local function compose(p: string?, color2: Color3?)
	local v3

	if not (p == nil or p == "") then
		v3 = Areas.Directory[p]
	end

	if v3 == nil then
		return "A Rift has spawned!"
	end

	return (`A Rift has spawned in <font color="#{(color2 or v3.Color or color):ToHex()}">{v3.DisplayName}</font>`)
end

local function playSprites(instance)
	local main = instance:FindFirstChild("Main")

	if main == nil then
		return
	end

	local images = {}

	for _, image in main:GetChildren() do
		if image:IsA("ImageLabel") and image.Name == "Sprite" then
			table.insert(images, image)
		end
	end

	if #images == 0 then
		return
	end

	local cells = images[1]:GetAttribute("Cells")
	local FPS = images[1]:GetAttribute("FPS")

	if typeof(cells) ~= "Vector2" or typeof(FPS) ~= "number" or FPS <= 0 then
		return
	end

	task.spawn(function()
		local count = 0

		while instance.Parent ~= nil do
			local v3 = count % cells.X
			local v4 = math.floor(count / cells.X) % cells.Y

			for _, v5 in images do
				v5.ImageRectOffset = Vector2.new(v5.ImageRectSize.X * v3, v5.ImageRectSize.Y * v4)
			end

			count += 1
			task.wait(1 / FPS)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function seesTheRift()
	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return false
	end

	local v3 = Save.Await()
	local v4 = v3 == nil and 0 or v3.SpeedPower
	local v5 = v3 == nil and 0 or v3.LastLogout
	return RiftEligibility.IsRevealed(localPlayer, v4, v5)
end

return table.freeze({
	Show = function(options)
		local v3 = options or {}
		assert(interface(v3))

		-- equivalent call inferred; original call site unknown
		if not seesTheRift() then
			return
		end

		local clone = riftNotif:Clone()
		local content = clone:FindFirstChild("Main"):FindFirstChild("Content")
		local areaId = v3.AreaId
		local color2 = v3.Color
		local v4

		if not (areaId == nil or areaId == "") then
			v4 = Areas.Directory[areaId]
		end

		content.Text = v4 == nil and "A Rift has spawned!" or `A Rift has spawned in <font color="#{(color2 or v4.Color or color):ToHex()}">{v4.DisplayName}</font>`
		Lanes.Schedule({
			Lane = "Banner",
			Frame = clone,
			Seconds = v3.Seconds or 6,
			UniqueKey = v3.UniqueKey or "RiftSpawn",
			DelayInRound = v3.DelayInRound,
			OnShown = function(p)
				Audio.Play(v3.Sound or "rbxassetid://133842042346471", script, {
					Volume = 0.7,
					PlaybackSpeed = playbackSpeed
				})
				playSprites(p)
			end
		})
	end
})