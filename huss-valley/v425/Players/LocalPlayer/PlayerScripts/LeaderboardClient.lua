local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local LeaderboardConfig = require(chickenOrHero:WaitForChild("Presentation"):WaitForChild("LeaderboardConfig"))
local leaderboards = chickenOrHero:WaitForChild("Game"):WaitForChild("Leaderboards")
local ProgressionMath = require(chickenOrHero:WaitForChild("Progression"):WaitForChild("ProgressionMath"))
local VerifiedName = require(chickenOrHero.Presentation:WaitForChild("VerifiedName"))
local MapLocator = require(chickenOrHero.Game:WaitForChild("MapLocator"))
local v = {}
local flag = true
local userThumbnailAsyncsByUserId = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function numberText(value)
	if value >= 1000000000 then
		return ("%.1fB"):format(value / 1000000000)
	end

	if value >= 1000000 then
		return ("%.1fM"):format(value / 1000000)
	end

	if value >= 10000 then
		return ("%.1fK"):format(value / 1000)
	end

	return (tostring((math.floor(value))))
end

local function clear(k)
	local v2 = v[k]

	if not v2 then
		return
	end

	v[k] = nil
	v2.generation += 1
	v2.connection:Disconnect()
	v2.gui:Destroy()

	if v2.part.Parent then
		v2.part.CFrame = v2.base
	end

	if v2.source.Parent then
		v2.source.Enabled = v2.wasEnabled
	end
end

local function render(state)
	local success, result = pcall(HttpService.JSONDecode, HttpService, state.snapshot.Value)

	if not success or type(result) ~= "table" then
		return
	end

	local mainFrame = state.gui.MainFrame
	local entries = result.entries or {}
	local key = string.upper(state.key)
	mainFrame.Title.Text = state.def.Title
	local status = mainFrame.Status
	local text = result.status == "studio" and "STUDIO PREVIEW · SESSION " .. key

	if not text then
		if result.status == "retrying" then
			text = #entries > 0 and "GLOBAL · UPDATE DELAYED" or "GLOBAL · TEMPORARILY UNAVAILABLE"
		else
			text = result.status == "loading" and "GLOBAL · LOADING..." or #entries == 0 and "GLOBAL · NO " .. key .. " YET" or "GLOBAL · ALL TIME · TOP " .. state.def.PageSize
		end
	end

	status.Text = text
	local jSONEncode = HttpService:JSONEncode(entries)

	if jSONEncode == state.signature then
		return
	end

	state.signature = jSONEncode
	state.generation += 1
	local generation = state.generation

	for _, row in state.rows do
		row:Destroy()
	end

	table.clear(state.rows)

	for k, entry in entries do
		local clone = state.template:Clone()
		clone.Name = "Rank_" .. k
		clone.Visible = true
		clone.LayoutOrder = k
		local frame = clone.Frame
		frame.Username.RichText = true
		frame.Username.Text = ("#%d  %s"):format(k, VerifiedName.format(entry.name, entry.verified))
		local stat = frame.Stat
		local text2 = state.def.ValueFormat == "Level" and "LEVEL " .. ProgressionMath.state(entry.value).level

		if not text2 then
			local v4 = numberText(entry.value) -- equivalent call inferred; original call site unknown
			text2 = v4 .. " " .. state.def.Suffix
		end

		stat.Text = text2
		frame.PFP.Image = userThumbnailAsyncsByUserId[entry.userId] or ""
		clone.Parent = mainFrame.ScrollingFrame
		table.insert(state.rows, clone)

		if userThumbnailAsyncsByUserId[entry.userId] or not (entry.userId > 0) then
			continue
		end

		local v4 = entry
		local v5 = clone
		local frame2 = frame
		task.spawn(function()
			local success2, userThumbnailAsync, v7 = pcall(
				Players.GetUserThumbnailAsync,
				Players,
				v4.userId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)

			if success2 and v7 then
				userThumbnailAsyncsByUserId[v4.userId] = userThumbnailAsync

				if flag and v[state.key] == state and state.generation == generation and v5.Parent then
					frame2.PFP.Image = userThumbnailAsync
				end
			end
		end)
	end
end

local function attach(childName, board, board2)
	local leaderboardPart = board2:FindFirstChild("LeaderboardPart")
	local surfaceGui = leaderboardPart and leaderboardPart:FindFirstChildOfClass("SurfaceGui")
	local child = leaderboards:FindFirstChild(childName)

	if not (surfaceGui and child) then
		return
	end

	local clone = surfaceGui:Clone()
	clone.Name = "GlobalLeaderboard_" .. childName
	clone.Adornee = leaderboardPart
	clone.Enabled = true
	clone.Parent = playerGui
	local slotFrame = clone.MainFrame.ScrollingFrame.SlotFrame
	slotFrame.Visible = false
	local v2 = {
		key = childName,
		def = board,
		model = board2,
		part = leaderboardPart,
		base = leaderboardPart.CFrame,
		source = surfaceGui,
		wasEnabled = surfaceGui.Enabled,
		gui = clone,
		snapshot = child,
		template = slotFrame,
		rows = {},
		generation = 0
	}
	v[childName] = v2
	surfaceGui.Enabled = false
	v2.connection = child.Changed:Connect(function()
		render(v2)
	end)
	render(v2)
end

local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v2 in v do
		if not v2.part:IsDescendantOf(workspace) then
			continue
		end

		local position = currentCamera.CFrame.Position

		if (position - v2.base.Position).Magnitude > v2.def.AnimateDistance then
			continue
		end

		local v3 = v2.base.Position + Vector3.new(
			0,
			math.sin(serverTimeNow * 2 * 3.141592653589793 / v2.def.HoverPeriod) * v2.def.HoverStuds,
			0
		)
		local vector = Vector3.new(position.X, v3.Y, position.Z)

		if (vector - v3).Magnitude > 0.1 then
			v2.part.CFrame = v2.part.CFrame:Lerp(
				CFrame.lookAt(v3, vector),
				1 - math.exp(-v2.def.TurnResponsiveness * dt)
			)
		end
	end
end)
script.Destroying:Connect(function()
	flag = false
	renderSteppedConnection:Disconnect()

	for k in v do
		clear(k)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function findBoard(k, board, lobby)
	local function findIn(instance)
		if not instance then
			return nil
		end

		for _, model in instance:GetChildren() do
			if not model:IsA("Model") then
				continue
			end

			local leaderboardKey = model:FindFirstChild("LeaderboardKey")

			if (model:GetAttribute("LeaderboardKey") or leaderboardKey and leaderboardKey:IsA("StringValue") and leaderboardKey.Value) == k then
				return model
			end
		end

		local model = instance:FindFirstChild(board.ModelName)

		if not (model and model:IsA("Model") and model) then
			model = nil
		end

		return model
	end

	return findIn(lobby) or findIn(workspace)
end

while flag do
	local lobby = MapLocator.lobby()

	for k, board in LeaderboardConfig.Boards do
		local board2 = findBoard(k, board, lobby) -- equivalent call inferred; original call site unknown
		local v2 = v[k]

		if v2 and (board2 ~= v2.model or not v2.part:IsDescendantOf(workspace)) then
			clear(k)
			v2 = nil
		end

		if not board2 or v2 then
			continue
		end

		attach(k, board, board2)
	end

	task.wait(1)
end