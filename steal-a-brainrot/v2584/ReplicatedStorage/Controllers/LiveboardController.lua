local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Datas.Rarities)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Animals = require(ReplicatedStorage.Datas.Animals)
local CustomRichTextController = require(ReplicatedStorage.Controllers.CustomRichTextController)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local remoteEvent = Net:RemoteEvent("Liveboard/NewEntry")
local remoteEvent2 = Net:RemoteEvent("Liveboard/ClaimEntry")
local remoteFunction = Net:RemoteFunction("Liveboard/GetEntries")
local v = {}
local v2 = {}
local v3 = {}
local number = Random.new():NextNumber(0, 1)

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTimeAgo(p: number)
	local v4 = math.max(0, (math.floor(p)))

	if v4 < 60 then
		return (`Spawned {v4}s ago`)
	end

	local v5 = math.floor(v4 / 60)
	local v6 = v4 % 60

	if v6 > 0 then
		return (`Spawned {v5}m {v6}s ago`)
	end

	return (`Spawned {v5}m ago`)
end

local function applyOwner(p, p2: number?, text: string?)
	local filler = p.Filler

	if p2 and text then
		filler.PlayerBg.Visible = true
		filler.PlayerBg.Username.TextColor3 = Color3.fromRGB(255, 255, 255)
		filler.PlayerBg.Username.Text = text
		local GUID = HttpService:GenerateGUID(false)
		filler:SetAttribute("ImageJitter", GUID)
		local instant = FFlags:GetInstant("Liveboard/ThumbnailJitterMin", 0)
		local instant2 = FFlags:GetInstant("Liveboard/ThumbnailJitterMax", 7)
		task.delay(instant + (instant2 - instant) * number, function()
			if filler:GetAttribute("ImageJitter") ~= GUID then
				return
			end

			filler.PlayerBg.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={p2}&w=100&h=100`
		end)
	else
		filler.PlayerBg.Visible = false
		filler.PlayerBg.Username.TextColor3 = Color3.fromRGB(255, 61, 61)
		filler.PlayerBg.Username.Text = "UNCLAIMED"
		filler.PlayerBg.Headshot.Image = ""
		filler:SetAttribute("ImageJitter", nil)
	end
end

local function removeEntry(p: number)
	local v4 = v[p]

	if not v4 then
		return
	end

	v2[v4.UID] = nil
	v3[v4.UID] = v4.ExpiresAt
	v4.Trove:Destroy()
	v4.Frame:Destroy()
	table.remove(v, p)

	for k, v5 in v do
		v5.Frame.LayoutOrder = k
	end
end

local function createEntry(data, serverTemplate, globalTemplate, scrollingFrame)
	if v3[data.UID] then
		return
	end

	local v4 = v2[data.UID]

	if v4 then
		applyOwner(v4.Frame, data.OwnerUserId, data.OwnerDisplayName)
		return
	end

	local isLocalServer = data.IsLocalServer

	if isLocalServer then
		globalTemplate = serverTemplate
	end

	local clone = globalTemplate:Clone()
	clone.Visible = true
	clone.Name = "Entry"
	local filler = clone.Filler
	CustomRichTextController.apply(filler.Title, Animals2:ColorBrainrotName(data.BrainrotName))
	local spawned = filler.Spawned
	local text = formatTimeAgo(0) -- equivalent call inferred; original call site unknown
	spawned.Text = text
	local text2 = isLocalServer and "[SERVER]" or "[GLOBAL]"

	if data.IsFuse then
		filler.Location.RichText = true
		text2 ..= " <font color='#e1bb62'>[FUSE]</font>"
	elseif data.IsCraft then
		filler.Location.RichText = true
		text2 ..= " <font color='#bb7bcb'>[CRAFT]</font>"
	elseif data.IsCodes then
		filler.Location.RichText = true
		text2 ..= " <font color='#4da6ff'>[CODES]</font>"
	elseif data.IsTrader then
		filler.Location.RichText = true
		text2 ..= " <font color='#ad29ff'>[LOS TRADERS]</font>"
	elseif data.IsBeeMerchant then
		filler.Location.RichText = true
		text2 ..= " <font color='#FFD700'>[QUEEN BEE]</font>"
	elseif data.IsRNGMachine then
		filler.Location.RichText = true
		text2 ..= " <font color='#1774ff'>[RNG Machine]</font>"
	end

	filler.Location.Text = text2
	applyOwner(clone, data.OwnerUserId, data.OwnerDisplayName)
	filler.BrainrotBg.Img.Visible = false
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "BrainrotViewport"
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.Position = UDim2.fromScale(0.5, 0.5)
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	viewportFrame.Parent = filler.BrainrotBg
	task.spawn(pcall, function()
		Animals2:AttachOnViewport(data.BrainrotName, viewportFrame, nil, data.Mutation)
	end)
	local fill = filler.Bar.Fill
	fill.Size = UDim2.fromScale(1, 1)
	clone.Parent = scrollingFrame
	local trove = Trove.new()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v8 = math.max(0, serverTimeNow - data.Timestamp)
	local v9 = math.max(0, data.DisplayDuration - v8)

	if v9 <= 0 then
		clone:Destroy()
		trove:Destroy()
	else
		local v10 = v9 / data.DisplayDuration
		fill.Size = UDim2.fromScale(v10, 1)
		local tween = TweenService:Create(fill, TweenInfo.new(v9, Enum.EasingStyle.Linear), {
			Size = UDim2.fromScale(0, 1)
		})
		trove:Add(tween)
		tween:Play()
		local animal = Animals[data.BrainrotName]
		local rarity

		if animal then
			rarity = animal.Rarity
		end

		local v11 = {
			UID = data.UID,
			Rarity = rarity,
			Frame = clone,
			Trove = trove,
			ExpiresAt = serverTimeNow + v9,
			SpawnedAt = data.Timestamp,
			Duration = data.DisplayDuration
		}
		local v12

		if rarity == "OG" then
			v12 = 1
		else
			v12 = 1

			for k, v14 in v do
				if v14.Rarity == "OG" then
					v12 = k + 1
				else
					break
				end
			end
		end

		table.insert(v, v12, v11)
		v2[data.UID] = v11

		for i, v13 in ipairs(v) do
			v13.Frame.LayoutOrder = i
		end

		while #v > FFlags:GetInstant("Liveboard/MaxEntries", 50) do
			removeEntry(#v)
		end
	end
end

return {
	Start = function(_)
		if ServerData.IsDuelsServer() or ServerData.IsTsunamiServer() then
			return
		end

		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		Observers.observeTag("Liveboard", function(adornee)
			local maid = Trove.new()
			local clone = maid:Clone(script.SurfaceGui)
			clone.Adornee = adornee
			clone.Parent = playerGui
			local scrollingFrame = clone.ScrollingFrame
			local serverTemplate = scrollingFrame.ServerTemplate
			local globalTemplate = scrollingFrame.GlobalTemplate
			serverTemplate.Visible = false
			globalTemplate.Visible = false
			maid:Add(remoteEvent.OnClientEvent:Connect(function(p)
				if not (type(p) == "table" and type(p.BrainrotName) == "string") then
					return
				end

				createEntry(p, serverTemplate, globalTemplate, scrollingFrame)
			end))
			maid:Add(remoteEvent2.OnClientEvent:Connect(function(p: string, p2: number, text: string)
				local v4 = v2[p]

				if not v4 then
					return
				end

				applyOwner(v4.Frame, p2, text)
			end))
			maid:Add(RunService.Heartbeat:Connect(function()
				local serverTimeNow = workspace:GetServerTimeNow()
				local v4 = 1

				while v4 <= #v do
					local v5 = v[v4]

					if v5.ExpiresAt <= serverTimeNow then
						removeEntry(v4)
					else
						local v6 = serverTimeNow - v5.SpawnedAt
						local spawned = v5.Frame.Filler.Spawned
						local text = formatTimeAgo(v6) -- equivalent call inferred; original call site unknown
						spawned.Text = text
						v4 += 1
					end
				end

				for k, v5 in v3 do
					if v5 <= serverTimeNow then
						v3[k] = nil
					end
				end
			end))
			task.spawn(function()
				local success, result = pcall(remoteFunction.InvokeServer, remoteFunction)

				if success and typeof(result) == "table" then
					for _, v4 in result do
						createEntry(v4, serverTemplate, globalTemplate, scrollingFrame)
					end
				end
			end)
			return function()
				maid:Clean()
				table.clear(v)
				table.clear(v2)
				table.clear(v3)
			end
		end)
	end
}