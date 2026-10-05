local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.UseMapVoting)
local v6 = require3(ReplicatedStorage2.Shared.MapData)
local v7 = require3(ReplicatedStorage2.Controllers.DebugController)
local remoteEvent = v3:RemoteEvent("UpdateMapVotes")
local spawn = workspace:WaitForChild("Spawn")
local newPlayerCounter = nil
local colliders = nil
local top = nil
local voteTile = script.VoteTile
voteTile.Parent = nil
local v8 = {
	createVector(1, 0, 0),
	createVector(-1, 0, 0),
	createVector(0, 1, 0),
	createVector(0, -1, 0),
	createVector(0, 0, 1),
	createVector(0, 0, -1)
}
local parts = {}
local clones = {}
local connection = nil
local MapVoteController = {
	VoteChanged = v2.new(),
	CurrentVote = 0
}

function MapVoteController.Start(_)
	if not v5() then
		v7:Info("mapvote:start", "Map voting is disabled for this session")
		return
	end

	spawn = workspace:WaitForChild("Spawn")
	newPlayerCounter = spawn:WaitForChild("NewPlayerCounter")
	colliders = newPlayerCounter:WaitForChild("Colliders")
	top = newPlayerCounter:WaitForChild("GUI"):WaitForChild("SurfaceGui"):WaitForChild("Top")

	if top then
		for i = 1, 3 do
			local clone = voteTile:Clone()
			clone.Name = tostring(i)
			clone.Count.Text = "0 Votes"
			clone.Count.TextColor3 = Color3.fromRGB(0, 0, 0)
			clone.MapThumbnail.Gradient.MapName.Text = ""
			clone.MapThumbnail.Thumbnail.Image = ""
			clone.MapThumbnail.Options.NewMap.Visible = false
			clone.Parent = top.Options
			table.insert(clones, clone)
		end

		v7:Info("mapvote:start", "UI Tiles initialized successfully")
	else
		v7:Error("mapvote:start", "Failed to find MapVoteUI")
	end

	if colliders then
		for i = 1, 3 do
			local v9 = tostring(i)
			local part = colliders:FindFirstChild(v9)

			if part and part:IsA("BasePart") then
				table.insert(parts, part)
			else
				v7:Warn("mapvote:start", "Missing or invalid collider", part)
			end
		end
	else
		v7:Error("mapvote:start", "Colliders folder not found in Spawn")
	end

	local v9 = v.Client:WaitReplion("MapVoting")
	MapVoteController.VoteChanged:Connect(function()
		local maps = v9:Get("Maps")

		if not maps then
			v7:Warn("mapvote:votechange", "No maps available to vote")
			return
		end

		local currentVote = MapVoteController.CurrentVote

		if currentVote == 0 then
			v7:Warn("mapvote:votechange", "Current vote is 0")
			return
		end

		local map = maps[currentVote]

		if not map then
			v7:Warn("mapvote:votechange", "Invalid map index", currentVote)
			return
		end

		task.defer(function()
			ReplicatedStorage2.Misc.voteCast:Play()
		end)
		remoteEvent:FireServer(map)
		v7:Info("mapvote:votechange", "Vote sent to server", {
			map = map
		})
	end)
	v9:OnChange("Active", function(flag: boolean)
		MapVoteController.CurrentVote = 0
		MapVoteController:onActiveChanged(flag)
		v7:Log("mapvote:state", "Active changed", flag)
	end)
	v9:OnChange("Votes", function(p)
		MapVoteController:onVotesChanged(p)
		v7:Info("mapvote:state", "Votes changed", p)
	end)
	v9:OnChange("Maps", function(p)
		MapVoteController:onMapsChanged(p)
		v7:Info("mapvote:state", "Maps changed", p)
	end)
	MapVoteController:onActiveChanged(v9:GetExpect("Active"))
	MapVoteController:onVotesChanged(v9:GetExpect("Votes"))
	MapVoteController:onMapsChanged(v9:GetExpect("Maps"))
end

function MapVoteController:VoteForMap(currentVote: number)
	local replion = v.Client:GetReplion("MapVoting")

	if replion == nil then
		v7:Warn("mapvote:voteformap", "Could not find replion for MapVoting")
		return
	end

	if not replion:Get("Active") then
		v7:Warn("mapvote:voteformap", "Map voting is not active")
		return
	end

	local currentVote2 = MapVoteController.CurrentVote
	MapVoteController.CurrentVote = currentVote

	if currentVote2 ~= currentVote then
		MapVoteController.VoteChanged:Fire()
	end
end

function MapVoteController:PollPosition()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = {}
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.MaxParts = 1

	local function onCharacterAdded(instance)
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 5)

		if not humanoidRootPart then
			v7:Error("mapvote:poll", "HumanoidRootPart not found within 5 seconds")
			return
		end

		overlapParams.FilterDescendantsInstances = { humanoidRootPart }
		v7:Info("mapvote:poll", "Tracking HumanoidRootPart for player", humanoidRootPart)
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)

	if localPlayer.Character then
		task.spawn(onCharacterAdded, localPlayer.Character)
	end

	local v9 = nil
	local lastTime = os.clock()
	return v4.Thread.Every(0.1, function()
		if #parts == 0 then
			return
		end

		local character = localPlayer.Character

		if character and character.PrimaryPart then
			local _ = character.PrimaryPart
			local v10 = nil

			for k, v12 in parts do
				if not (#workspace:GetPartsInPart(v12, overlapParams) > 0) then
					continue
				end

				v10 = k
				break
			end

			if v10 and v10 ~= v9 then
				v7:Log("mapvote:poll", (`Collider {v10} triggered vote`))
				MapVoteController:VoteForMap(v10)
				v9 = v10
				lastTime = os.clock()
			elseif not v10 and v9 ~= nil then
				v7:Log("mapvote:poll", (`Player left collider {v9}`))
				v9 = nil
			end
		elseif os.clock() - lastTime > 2 then
			v7:Warn("mapvote:poll", "Character or PrimaryPart missing", {
				hasCharacter = character ~= nil,
				hasPrimaryPart = character and character.PrimaryPart ~= nil
			})
			lastTime = os.clock()
		end
	end)
end

function MapVoteController:onActiveChanged(visible: boolean)
	if typeof(connection) == "RBXScriptConnection" and connection.Connected then
		connection:Disconnect()
	end

	if v5() and #Players:GetPlayers() >= (RunService:IsStudio() and 1 or 2) then
		top.Top.Label.Text = "VOTE FOR A MAP"
		top.Top.Label.TextColor3 = Color3.fromRGB(16, 255, 116)
		top.NoOptions.TextLabel.Text = "<stroke color=\"#000000\" joins=\"miter\" thickness=\"6\" transparency=\"0\">Round in progress!</stroke>"
	else
		top.Top.Label.Text = "MAP VOTING"
		top.Top.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		top.NoOptions.TextLabel.Text = "<stroke color=\"#000000\" joins=\"miter\" thickness=\"6\" transparency=\"0\">Map voting not available!</stroke>"
	end

	top.Options.Visible = visible
	top.NoOptions.Visible = not visible

	if not visible then
		v7:Warn("mapvote:active", "PollPosition not started")
		return
	end

	connection = MapVoteController:PollPosition()
	v7:Info("mapvote:active", "PollPosition started successfully")
end

function MapVoteController:onMapsChanged(maps)
	local serverTimeNow = workspace:GetServerTimeNow()
	v7:Info("mapvote:maps", "Map data updated", {
		maps = maps
	})

	for _, v9 in ipairs(maps) do
		local index = table.find(maps, v9)

		if not index then
			continue
		end

		local v10 = v6[v9]

		if not v10 then
			continue
		end

		local v11 = clones[index]

		if not v11 then
			continue
		end

		v11.MapThumbnail.Gradient.MapName.Text = v10.DisplayName
		v11.MapThumbnail.Thumbnail.Image = v10.Thumbnail or v10.RankedImage or ""
		local visible = v10.ReleaseDate and serverTimeNow <= v10.ReleaseDate + 1209600 and true or false
		v11.MapThumbnail.Options.NewMap.Visible = visible

		for _, child in v11.MapThumbnail.Options.EventMap:GetChildren() do
			child.Visible = false
		end

		local eventMap = v10.EventMap
		local child = eventMap and v11.MapThumbnail.Options.EventMap:FindFirstChild(eventMap)

		if child then
			child.Visible = true
		end
	end
end

function MapVoteController:onVotesChanged(items)
	local replion = v.Client:GetReplion("MapVoting")

	if not replion then
		return
	end

	local v9 = {}

	for k, _ in v9 do
		v9[k] = 0
	end

	local v10 = nil

	for k, item in items do
		if k == localPlayer then
			v10 = item
		end

		v9[item] = (v9[item] or 0) + 1
	end

	local v11 = 0
	local v12 = nil

	for k, v13 in v9 do
		if v11 < v13 then
			v12 = k
			v11 = v13
		elseif v11 == v13 then
			v12 = nil
		end
	end

	local maps = replion:Get("Maps")

	for _, map in maps do
		local index = table.find(maps, map)

		if not (index and v6[map]) then
			continue
		end

		local v13 = v9[map] or 0
		local v14 = clones[index]

		if not v14 then
			continue
		end

		local v15 = {}
		local v16 = v13 == 1 and "Vote" or "Votes"
		v14.Count.Text = `{v13} {v16}`
		local visible = v12 == map

		if visible and v14.SelectedMapLabel.Visible == false and v14.SelectedMapOutline.Visible == false then
			v14.SelectedMapLabel.BackgroundTransparency = 1
			v14.SelectedMapLabel.TextTransparency = 1
			v14.SelectedMapOutline.UIStroke.Transparency = 1
			v14.SelectedMapOutline.Glow.ImageTransparency = 1
			table.insert(v15, (TweenService:Create(v14.SelectedMapLabel, TweenInfo.new(0.3), {
				BackgroundTransparency = 0,
				TextTransparency = 0
			})))
			table.insert(v15, (TweenService:Create(v14.SelectedMapOutline.UIStroke, TweenInfo.new(0.3), {
				Transparency = 0
			})))
			table.insert(v15, (TweenService:Create(v14.SelectedMapOutline.Glow, TweenInfo.new(0.3), {
				ImageTransparency = 0.5
			})))
		end

		v14.SelectedMapLabel.Visible = visible
		v14.SelectedMapOutline.Visible = visible

		if #v15 > 0 then
			for _, v18 in ipairs(v15) do
				v18:Play()
			end
		end

		if v10 and v10 == map then
			v14.Count.BackgroundColor3 = Color3.fromRGB(16, 255, 116)
		else
			v14.Count.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	v7:Log("mapvote:votes", "Vote counts recalculated", v9)
end

function IsPartWithinPart(p, p2)
	for _, v9 in ipairs(v8) do
		local v10 = p.Position + p.Size * v9 / 2
		local v11 = p2.Position + p2.Size * v9 / 2
		local unit = (p.Position - v10).Unit
		local v12 = (v10 - v11).Unit * unit

		if v12.X > 0 or v12.Z > 0 or v12.Y > 0 then
			return false
		end
	end

	return true
end

return MapVoteController