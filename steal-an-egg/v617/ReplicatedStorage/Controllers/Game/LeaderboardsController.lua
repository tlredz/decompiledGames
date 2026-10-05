local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Leaderboards = require(ReplicatedStorage.Shared.Types.Leaderboards)
local Log = require(ReplicatedStorage.Packages.Log)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = Log.new()
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local leaderboards = ReplicatedStorage.Assets.UI.Leaderboards
		local v2 = {}
		local v3 = {}
		local total = 0

		local function getLeaderboardPart(instance)
			local adornee = instance.Adornee

			if adornee and adornee:IsA("BasePart") then
				return adornee
			end

			local parent = instance.Parent

			if parent and parent:IsA("BasePart") then
				return parent
			end

			return nil
		end

		local function getRowTemplate(childName: string)
			local frame = leaderboards:FindFirstChild(childName)

			if frame == nil or not frame:IsA("Frame") then
				return nil
			end

			return frame
		end

		local function getHeadshotUrl(p: number)
			return (`rbxthumb://type=AvatarHeadShot&id={p}&w=48&h=48`)
		end

		local function createRow(data, p)
			local clone = data.Template:Clone()
			clone.Name = `Player_{p.UserId}`
			clone.Holder_Thumbnail.ImageLabel_PlayerThumb.Image = `rbxthumb://type=AvatarHeadShot&id={p.UserId}&w=48&h=48`
			clone.Parent = data.Container
			data.Rows[p.UserId] = clone
			return clone
		end

		local function renderLeaderboard(data, items)
			local v4 = {}

			for k, item in items do
				local clone = data.Rows[item.UserId]

				if not clone then
					clone = data.Template:Clone()
					clone.Name = `Player_{item.UserId}`
					clone.Holder_Thumbnail.ImageLabel_PlayerThumb.Image = `rbxthumb://type=AvatarHeadShot&id={item.UserId}&w=48&h=48`
					clone.Parent = data.Container
					data.Rows[item.UserId] = clone
				end

				clone.LayoutOrder = k
				clone.Holder_PlayerName.Display.TextLabel_PlayerName.Text = item.Name
				clone.Holder_Value.Holder.TextLabel_Value.Text = item.ValueText
				v4[item.UserId] = true
			end

			for k, row in data.Rows do
				if v4[k] then
					continue
				end

				data.Rows[k] = nil
				row:Destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateLeaderboard(p, rootPart)
			local v4 = v2[p]

			if not v4 then
				return
			end

			local enabled = true
			local maxDistance = v4.Gui.MaxDistance

			if rootPart then
				if maxDistance > 0 then
					enabled = (rootPart.Position - v4.Part.Position).Magnitude <= maxDistance
				end
			else
				enabled = false
			end

			if v4.Gui.Enabled ~= enabled then
				v4.Gui.Enabled = enabled
			end
		end

		local function cleanupLeaderboard(scrollingFrame)
			local v4 = v2[scrollingFrame]

			if not v4 then
				return
			end

			v4.Trove:Clean()

			for k, row in v4.Rows do
				v4.Rows[k] = nil
				row:Destroy()
			end

			if v4.Gui.Parent then
				v4.Gui.Enabled = true
			end

			v2[scrollingFrame] = nil
		end

		local function trackLeaderboard(scrollingFrame)
			if not scrollingFrame:IsA("ScrollingFrame") then
				return
			end

			cleanupLeaderboard(scrollingFrame)
			local key = scrollingFrame:GetAttribute("Key")

			if type(key) ~= "string" then
				v:AtWarning():Log((`leaderboard {scrollingFrame:GetFullName()} has no Key attribute`))
				return
			end

			local frame = leaderboards:FindFirstChild(key)

			if frame == nil or not frame:IsA("Frame") then
				frame = nil
			end

			if not frame then
				v:AtWarning():Log((`leaderboard key "{key}" has no row template`))
				return
			end

			local parent = scrollingFrame.Parent

			if not (parent and parent:IsA("Frame")) then
				return
			end

			local parent2 = parent.Parent

			if not (parent2 and parent2:IsA("SurfaceGui")) then
				return
			end

			local adornee = parent2.Adornee

			if not (adornee and adornee:IsA("BasePart")) then
				adornee = parent2.Parent

				if not (adornee and adornee:IsA("BasePart")) then
					adornee = nil
				end
			end

			if not adornee then
				return
			end

			parent2.Adornee = adornee
			parent2.Parent = playerGui
			local maid = Trove.new()
			local v4 = {
				Key = key,
				Part = adornee,
				Gui = parent2,
				Container = scrollingFrame,
				Template = frame,
				Rows = {},
				Trove = maid
			}
			v2[scrollingFrame] = v4
			maid:Add(scrollingFrame.Destroying:Connect(function()
				cleanupLeaderboard(scrollingFrame)
			end))
			maid:Add(parent2.Destroying:Connect(function()
				cleanupLeaderboard(scrollingFrame)
			end))
			local v5 = v3[key]

			if v5 then
				renderLeaderboard(v4, v5)
			end

			updateLeaderboard(scrollingFrame, Player.FindRootPart(localPlayer)) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateLeaderboards()
			local rootPart = Player.FindRootPart(localPlayer)

			for k in v2 do
				updateLeaderboard(k, rootPart) -- equivalent call inferred; original call site unknown
			end
		end

		local function stepLeaderboards(p: number)
			total += p

			if total < 0.2 then
				return
			end

			total = 0
			updateLeaderboards() -- equivalent call inferred; original call site unknown
		end

		local function setLeaderboardEntries(p: string, p2)
			v3[p] = p2

			for k in v2 do
				local v4 = v2[k]

				if v4.Key == p then
					renderLeaderboard(v4, p2)
				end
			end
		end

		local requestLeaderboards

		requestLeaderboards = function()
			local success, result = pcall(function()
				return Remotes.Leaderboards.Fetch:InvokeServer()
			end)
			local v4

			if success then
				v4 = Leaderboards.SchemaValidation.LeaderboardsByKey(result)
			else
				v4 = false
			end

			local v5 = tostring(result)

			if v4 then
				for k, v6 in result do
					if v3[k] == nil then
						setLeaderboardEntries(k, v6)
					end
				end
			else
				v:AtError():Log((`leaderboard request failed, retrying: {v5}`))
				task.delay(5, requestLeaderboards)
			end
		end

		local function onLeaderboardUpdate(value, p)
			if type(value) ~= "string" then
				v:AtError():Log((`leaderboard update had a non-string key: {tostring(value)}`))
				return
			end

			local leaderboard, v4 = Leaderboards.SchemaValidation.Leaderboard(p)

			if leaderboard then
				setLeaderboardEntries(value, p)
			else
				v:AtError():Log((`leaderboard update for "{value}" failed validation: {v4}`))
			end
		end

		for _, v4 in CollectionService:GetTagged("Leaderboard") do
			trackLeaderboard(v4)
		end

		CollectionService:GetInstanceAddedSignal("Leaderboard"):Connect(trackLeaderboard)
		CollectionService:GetInstanceRemovedSignal("Leaderboard"):Connect(cleanupLeaderboard)
		RunService.Heartbeat:Connect(stepLeaderboards)
		Remotes.Leaderboards.Updated.OnClientEvent:Connect(onLeaderboardUpdate)
		task.spawn(requestLeaderboards)
	end
}