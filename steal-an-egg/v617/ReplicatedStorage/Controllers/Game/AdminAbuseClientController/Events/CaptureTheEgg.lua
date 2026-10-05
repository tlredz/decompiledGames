local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local AreaEggResetWall = require(ReplicatedStorage.Client.AreaEggResetWall)
require(ReplicatedStorage.Shared.Types.AreaEggs)
local Audio = require(ReplicatedStorage.Shared.Audio)
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local CaptureTheEgg = require(ReplicatedStorage.Data.CaptureTheEgg)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggRenderer = require(ReplicatedStorage.Shared.Eggs.EggRenderer)
local EggState = require(ReplicatedStorage.Client.EggState)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local PlayVFX = require(ReplicatedStorage.UserGenerated.VFX.PlayVFX)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local SpawnLock = require(ReplicatedStorage.Client.SpawnLock)
local Trove = require(ReplicatedStorage.Packages.Trove)
local eggUidAttribute = CaptureTheEgg.EggUidAttribute
local v = { "Leader", "Second", "Third" }
local v2 = {
	"Leader",
	"Second",
	"Third",
	"You"
}
local v3 = { Color3.fromRGB(255, 214, 89), Color3.fromRGB(213, 213, 213), Color3.fromRGB(204, 141, 96) }
local uDim = UDim2.fromScale(0.5, 0.085)
local uDim2 = UDim2.fromScale(0.5, 0.2)
local uDim3 = UDim2.fromScale(0.5, -0.35)
local localPlayer = Players.LocalPlayer
local v4 = nil
local clones = {}
local v5 = {}
local sampledAt = 0
local revision = 0
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = false
local v10 = nil
local v11 = nil
local v12 = false
local v13 = false
local v14 = not AreaEggResetWall.IsSealed()
local count = 0
local v15 = nil
local count2 = 0
local count3 = 0
local v16 = false
local v17 = false
local v18 = false
local count4 = 0
local flag = false
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = {}
local v24 = {}
local v25 = {}

local function cancelTween(object)
	if object ~= nil then
		object:Cancel()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatSeconds(seconds: number)
	return string.format("%.1f", math.floor(math.max(seconds, 0) * 10) / 10)
end

local function easeOutQuint(p: number)
	return 1 - (1 - p) ^ 5
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeInOutCubic(p: number)
	if p < 0.5 then
		return p * 4 * p * p
	end

	return 1 - (p * -2 + 2) ^ 3 / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function warnMissingAssetOnce(childName: string, formatted: string)
	if v25[childName] then
		return
	end

	v25[childName] = true
	warn(formatted)
end

local function getScoreboardUi()
	local v26 = v4

	if v26 ~= nil and v26.Gui.Parent ~= nil then
		return v26
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local captureTheEggUI = playerGui and playerGui:FindFirstChild("CaptureTheEggUI")

	if captureTheEggUI == nil or not captureTheEggUI:IsA("ScreenGui") then
		if not v18 then
			v18 = true
			warn("[CaptureTheEgg] CaptureTheEggUI is missing from StarterGui.")
		end

		return nil
	else
		local board = captureTheEggUI:FindFirstChild("Board")
		local rows = board and board:FindFirstChild("Rows")

		if board == nil or not board:IsA("Frame") or rows == nil or not rows:IsA("Frame") then
			if not v18 then
				v18 = true
				warn("[CaptureTheEgg] CaptureTheEggUI is stale; it needs a Board frame with a Rows frame.")
			end

			return nil
		else
			local uIListLayout = rows:FindFirstChildOfClass("UIListLayout")

			if uIListLayout ~= nil then
				uIListLayout:Destroy()
			end

			local cards = {}

			for _, childName in v2 do
				local frame = rows:FindFirstChild(childName)
				local avatar = frame and frame:FindFirstChild("Avatar")
				local timer = avatar and avatar:FindFirstChild("Timer")

				if frame == nil or not frame:IsA("Frame") or avatar == nil or not avatar:IsA("ImageLabel") or timer == nil or not timer:IsA("TextLabel") then
					if not v18 then
						v18 = true
						warn((`[CaptureTheEgg] CaptureTheEggUI is missing its {childName} card.`))
					end

					return nil
				else
					local scale = frame:FindFirstChildOfClass("UIScale")

					if scale == nil then
						scale = Instance.new("UIScale")
						scale.Name = "UIScale"
						scale.Parent = frame
					end

					frame.AnchorPoint = Vector2.new(0.5, 0.5)
					frame.Position = UDim2.fromScale(0.5, 0.5)
					frame.Visible = false
					scale.Scale = 0.72
					cards[childName] = {
						Name = childName,
						Frame = frame,
						Avatar = avatar,
						Timer = timer,
						Scale = scale,
						Rank = nil,
						UserId = nil,
						MoveTween = nil,
						ScaleTween = nil,
						AvatarTween = nil,
						TimerTween = nil,
						Token = 0
					}
				end
			end

			local v28 = {
				Gui = captureTheEggUI,
				Board = board,
				Rows = rows,
				Cards = cards
			}
			v4 = v28
			v18 = false
			return v28
		end
	end
end

local function applyBoardVisibility(flag2: boolean?)
	local scoreboardUi = getScoreboardUi()

	if scoreboardUi == nil then
		return
	end

	local gui = scoreboardUi.Gui
	local board = scoreboardUi.Board
	local v26 = v12 and v14

	if v26 == v13 and not flag2 then
		if v26 then
			gui.Enabled = true
		end
	else
		count2 += 1
		local v27 = count2
		local v28 = v15

		if v28 ~= nil then
			v28:Cancel()
		end

		v15 = nil

		if v26 then
			local position

			if v9 then
				position = uDim2
			else
				position = uDim
			end

			gui.Enabled = true

			if not v13 then
				board.Position = uDim3
			end

			v13 = true

			if flag2 then
				board.Position = position
				return
			end

			v15 = TweenService:Create(board, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = position
			})
			v15:Play()
		else
			v13 = false

			if flag2 then
				board.Position = uDim3
				gui.Enabled = false
			else
				if not gui.Enabled then
					board.Position = uDim3
					return
				end

				v15 = TweenService:Create(board, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Position = uDim3
				})
				v15:Play()
				v15.Completed:Once(function()
					if v27 == count2 and not v13 then
						gui.Enabled = false
					end
				end)
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBoardShown(flag2: boolean, flag3: boolean?)
	v12 = flag2
	applyBoardVisibility(flag3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setWallIsDown(flag2: boolean)
	if v14 == flag2 then
		return
	end

	v14 = flag2
	applyBoardVisibility()
end

local function setLocalPlayerCarryingEgg(flag2: boolean)
	if v9 == flag2 then
		return
	end

	v9 = flag2

	if not v13 then
		return
	end

	local scoreboardUi = getScoreboardUi()

	if scoreboardUi == nil or not scoreboardUi.Gui.Enabled then
		return
	end

	count2 += 1
	local v26 = v15

	if v26 ~= nil then
		v26:Cancel()
	end

	local board = scoreboardUi.Board
	local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local position

	if flag2 then
		position = uDim2
	else
		position = uDim
	end

	v15 = TweenService:Create(board, tweenInfo, {
		Position = position
	})
	v15:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshSpawnLock()
	local v26

	if v10 == nil then
		v26 = false
	else
		v26 = v10 == Workspace:GetAttribute(eggUidAttribute)
	end

	if v26 and v11 == nil then
		v11 = SpawnLock.ObtainLock()
	elseif not v26 and v11 ~= nil then
		local v27 = v11
		v11 = nil
		v27()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelCardTweens(state)
	local moveTween = state.MoveTween

	if moveTween ~= nil then
		moveTween:Cancel()
	end

	local scaleTween = state.ScaleTween

	if scaleTween ~= nil then
		scaleTween:Cancel()
	end

	local avatarTween = state.AvatarTween

	if avatarTween ~= nil then
		avatarTween:Cancel()
	end

	local timerTween = state.TimerTween

	if timerTween ~= nil then
		timerTween:Cancel()
	end

	state.MoveTween = nil
	state.ScaleTween = nil
	state.AvatarTween = nil
	state.TimerTween = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeTransferGhost(instance)
	local index = table.find(clones, instance)

	if index ~= nil then
		table.remove(clones, index)
	end

	instance:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearTransferGhosts()
	for _, v26 in clones do
		v26:Destroy()
	end

	table.clear(clones)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cardWidthScale(p, p2)
	local absoluteSize = p.Rows.AbsoluteSize

	if absoluteSize.X > 0 and absoluteSize.Y > 0 then
		return p2.Frame.Size.Y.Scale * absoluteSize.Y / absoluteSize.X
	end

	return p2.Frame.Size.X.Scale
end

local function calculateCardPositions(scoreboardUi, cardAssignments)
	local v26 = math.max(#cardAssignments - 1, 0) * 0.025
	local uDimsByName = {}

	for _, v27 in cardAssignments do
		local v28 = cardWidthScale(scoreboardUi, v27.State) -- equivalent call inferred; original call site unknown
		v26 += v28
	end

	local v27 = 0.5 - v26 * 0.5

	for _, v28 in cardAssignments do
		local v29 = cardWidthScale(scoreboardUi, v28.State) -- equivalent call inferred; original call site unknown
		uDimsByName[v28.State.Name] = UDim2.fromScale(v27 + v29 * 0.5, 0.5)
		v27 += v29 + 0.025
	end

	return uDimsByName
end

local function createTransferGhost(scoreboardUi, p, state, udim: UDim2)
	local absoluteSize = scoreboardUi.Rows.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 or p.Avatar.AbsoluteSize.X <= 0 then
		return false
	end

	local v26 = p.Avatar.AbsolutePosition + p.Avatar.AbsoluteSize * 0.5 - scoreboardUi.Rows.AbsolutePosition
	local clone = p.Avatar:Clone()
	clone.Name = `Transfer_{p.UserId or 0}`

	for _, label in clone:GetDescendants() do
		if label:IsA("TextLabel") then
			label:Destroy()
		end
	end

	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position = UDim2.fromScale(v26.X / absoluteSize.X, v26.Y / absoluteSize.Y)
	clone.Size = UDim2.fromScale(p.Avatar.AbsoluteSize.X / absoluteSize.X, p.Avatar.AbsoluteSize.Y / absoluteSize.Y)
	clone.ZIndex = 30
	clone.Parent = scoreboardUi.Rows
	table.insert(clones, clone)
	local v27 = cardWidthScale(scoreboardUi, state) -- equivalent call inferred; original call site unknown
	local uDim4 = UDim2.fromScale(v27, state.Frame.Size.Y.Scale)
	local tween = TweenService:Create(clone, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		ImageTransparency = 0.35,
		Position = udim,
		Size = uDim4
	})
	tween:Play()
	tween.Completed:Once(function()
		removeTransferGhost(clone) -- equivalent call inferred; original call site unknown
	end)
	return true
end

local function showCard(state, udim: UDim2)
	local v26 = state.Frame.Visible and state.UserId ~= nil
	state.Token += 1
	local moveTween = state.MoveTween

	if moveTween ~= nil then
		moveTween:Cancel()
	end

	local scaleTween = state.ScaleTween

	if scaleTween ~= nil then
		scaleTween:Cancel()
	end

	if not v26 then
		state.Frame.Position = udim + UDim2.fromScale(0, -0.32)
		state.Scale.Scale = 0.72
	end

	state.Frame.Visible = true
	state.MoveTween = TweenService:Create(
		state.Frame,
		TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Position = udim
		}
	)
	state.ScaleTween = TweenService:Create(
		state.Scale,
		TweenInfo.new(v26 and 0.24 or 0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	state.MoveTween:Play()
	state.ScaleTween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideCard(card, flag2: boolean?)
	if not card.Frame.Visible and card.UserId == nil then
		return
	end

	card.Token += 1
	local token = card.Token
	cancelCardTweens(card) -- equivalent call inferred; original call site unknown
	card.UserId = nil
	card.Rank = nil

	if flag2 then
		card.Frame.Visible = false
		card.Frame.Position = UDim2.fromScale(0.5, 0.5)
		card.Scale.Scale = 0.72
		card.Avatar.ImageTransparency = 0
		card.Timer.TextTransparency = 0
	else
		card.MoveTween = TweenService:Create(
			card.Frame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Position = card.Frame.Position + UDim2.fromScale(0, 0.18)
			}
		)
		card.ScaleTween = TweenService:Create(
			card.Scale,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{
				Scale = 0.72
			}
		)
		card.MoveTween:Play()
		card.ScaleTween:Play()
		card.ScaleTween.Completed:Once(function()
			if card.Token == token and card.UserId == nil then
				card.Frame.Visible = false
			end
		end)
	end
end

local function setCardEntry(state, entry, rank: number?, flag2: boolean)
	local v26 = state.UserId ~= entry.UserId
	local text = formatSeconds(entry.Seconds) -- equivalent call inferred; original call site unknown
	local v28 = state.Timer.Text ~= text
	state.Token += 1
	local token = state.Token
	local avatarTween = state.AvatarTween

	if avatarTween ~= nil then
		avatarTween:Cancel()
	end

	local timerTween = state.TimerTween

	if timerTween ~= nil then
		timerTween:Cancel()
	end

	state.UserId = entry.UserId
	state.Rank = rank
	state.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={entry.UserId}&w=150&h=150`
	state.Timer.Text = text
	local uIStroke = state.Avatar:FindFirstChildOfClass("UIStroke")

	if uIStroke ~= nil then
		local color

		if rank == nil then
			color = state.Frame.BackgroundColor3
		else
			color = v3[rank]
		end

		uIStroke.Color = color
	end

	if v26 then
		state.Avatar.ImageTransparency = flag2 and 1 or 0.52
		state.Timer.TextTransparency = 1
		task.delay(flag2 and 0.2356 or 0, function()
			if state.Token ~= token or state.UserId ~= entry.UserId then
				return
			end

			state.AvatarTween = TweenService:Create(
				state.Avatar,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageTransparency = 0
				}
			)
			state.TimerTween = TweenService:Create(
				state.Timer,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					TextTransparency = 0
				}
			)
			state.AvatarTween:Play()
			state.TimerTween:Play()
		end)
	else
		if state.Avatar.ImageTransparency > 0 then
			state.AvatarTween = TweenService:Create(
				state.Avatar,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageTransparency = 0
				}
			)
			state.AvatarTween:Play()
		end

		if v28 or state.Timer.TextTransparency > 0 then
			state.Timer.TextTransparency = math.max(state.Timer.TextTransparency, 0.28)
			state.TimerTween = TweenService:Create(
				state.Timer,
				TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					TextTransparency = 0
				}
			)
			state.TimerTween:Play()
		end
	end
end

local function pulseLeader(leader)
	local scaleTween = leader.ScaleTween

	if scaleTween ~= nil then
		scaleTween:Cancel()
	end

	leader.Scale.Scale = 1.16
	leader.ScaleTween = TweenService:Create(
		leader.Scale,
		TweenInfo.new(0.62, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	leader.ScaleTween:Play()
	local uIStroke = leader.Avatar:FindFirstChildOfClass("UIStroke")

	if uIStroke ~= nil then
		uIStroke.Color = Color3.new(1, 1, 1)
		uIStroke.Thickness = 4
		TweenService:Create(uIStroke, TweenInfo.new(0.62, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = v3[1],
			Thickness = 2
		}):Play()
	end
end

local function buildCardAssignments(scoreboardUi, list)
	local v26 = false
	local result = {}

	for i = 1, math.min(#list, #v) do
		v26 = v26 or list[i].UserId == localPlayer.UserId
		table.insert(result, {
			State = scoreboardUi.Cards[v[i]],
			Entry = list[i],
			Rank = i
		})
	end

	if v26 then
		return result
	end

	local v27 = nil

	for _, v29 in list do
		if v29.UserId ~= localPlayer.UserId then
			continue
		end

		v27 = v29
		break
	end

	local entry = v27 == nil and {
		UserId = localPlayer.UserId,
		Name = localPlayer.DisplayName,
		Seconds = 0
	} or v27
	table.insert(result, {
		State = scoreboardUi.Cards.You,
		Entry = entry,
		Rank = nil
	})
	return result
end

local function reconcileScoreboard(list)
	local scoreboardUi = getScoreboardUi()

	if scoreboardUi == nil then
		return
	end

	local cardAssignments = buildCardAssignments(scoreboardUi, list)
	local v26 = calculateCardPositions(scoreboardUi, cardAssignments)
	local cardsByUserId = {}

	for _, card in scoreboardUi.Cards do
		if card.Frame.Visible and card.UserId ~= nil then
			cardsByUserId[card.UserId] = card
		end
	end

	local v27 = {}

	if v13 and scoreboardUi.Gui.Enabled then
		for _, cardAssignment in cardAssignments do
			local v28 = cardsByUserId[cardAssignment.Entry.UserId]

			if v28 ~= nil and v28 ~= cardAssignment.State then
				v27[cardAssignment.State.Name] = createTransferGhost(
					scoreboardUi,
					v28,
					cardAssignment.State,
					v26[cardAssignment.State.Name]
				)
			end
		end
	end

	local v28 = {}

	for _, cardAssignment in cardAssignments do
		local state = cardAssignment.State
		v28[state.Name] = true
		showCard(state, v26[state.Name])
		setCardEntry(state, cardAssignment.Entry, cardAssignment.Rank, v27[state.Name] == true)
	end

	for k, card in scoreboardUi.Cards do
		if not v28[k] then
			hideCard(card)
		end
	end

	local userId

	if #list > 0 then
		userId = list[1].UserId
	end

	if v8 ~= nil and userId ~= nil and v8 ~= userId then
		pulseLeader(scoreboardUi.Cards.Leader)
	end

	v8 = userId
end

local function sanitizeEntries(items)
	local v26 = {}
	local result = {}

	for _, item in items do
		if not (type(item) == "table" and type(item.UserId) == "number" and type(item.Name) == "string") then
			continue
		end

		if type(item.Seconds) ~= "number" or item.Seconds ~= item.Seconds or not (item.Seconds < 1e999) or v26[item.UserId] then
			continue
		end

		v26[item.UserId] = true
		table.insert(result, {
			UserId = item.UserId,
			Name = item.Name,
			Seconds = math.max(item.Seconds, 0)
		})
	end

	return result
end

local function buildLiveEntries()
	local clone = table.clone(v5)
	local v26 = v6
	local v27 = 0

	if v26 ~= nil and v16 and v17 and Workspace:GetAttribute("Event_CaptureTheEggGameplay") == true then
		local attribute = Workspace:GetAttribute(eggUidAttribute)
		local v28

		if type(attribute) == "string" then
			v28 = EggState.ReadFieldEgg(attribute)
		end

		if v28 ~= nil and v28.CarrierUserId == v26 then
			v27 = math.clamp(Workspace:GetServerTimeNow() - sampledAt, 0, 2)
		end
	end

	if v27 > 0 then
		for k, v29 in clone do
			if v29.UserId ~= v26 then
				continue
			end

			local clone2 = table.clone(v29)
			clone2.Seconds += v27
			clone[k] = clone2
			break
		end
	end

	table.sort(clone, function(a, b)
		if a.Seconds == b.Seconds then
			return a.UserId < b.UserId
		end

		return a.Seconds > b.Seconds
	end)
	return clone
end

local function refreshScoreboardCards(p)
	local scoreboardUi = getScoreboardUi()

	if scoreboardUi == nil then
		return
	end

	local absoluteSize = scoreboardUi.Rows.AbsoluteSize

	if v7 == absoluteSize then
		local cardAssignments = buildCardAssignments(scoreboardUi, p)
		local v26 = {}

		for _, cardAssignment in cardAssignments do
			local state = cardAssignment.State
			v26[state.Name] = true

			if not (not state.Frame.Visible or state.UserId ~= cardAssignment.Entry.UserId or state.Rank ~= cardAssignment.Rank) then
				continue
			end

			reconcileScoreboard(p)
			return
		end

		for k, card in scoreboardUi.Cards do
			if card.UserId == nil or v26[k] then
				continue
			end

			reconcileScoreboard(p)
			return
		end

		for _, cardAssignment in cardAssignments do
			local timer = cardAssignment.State.Timer
			local text = formatSeconds(cardAssignment.Entry.Seconds) -- equivalent call inferred; original call site unknown

			if timer.Text ~= text then
				timer.Text = text
			end
		end
	else
		v7 = absoluteSize
		reconcileScoreboard(p)
	end
end

local function renderScoreboard(p, data)
	if type(data) ~= "table" or type(data.Revision) ~= "number" or data.Revision ~= data.Revision or data.Revision >= 1e999 or data.Revision <= revision or type(data.SampledAt) ~= "number" or data.SampledAt ~= data.SampledAt or math.abs(data.SampledAt) == 1e999 then
		return
	end

	revision = data.Revision
	v5 = sanitizeEntries(p)
	sampledAt = data.SampledAt
	local v26

	if type(data.CarrierUserId) == "number" then
		v26 = data.CarrierUserId
	end

	v6 = v26

	if not v16 and Workspace:GetAttribute("Event_CaptureTheEgg") == true then
		v16 = true
	end

	if not v16 then
		return
	end

	v17 = Workspace:GetAttribute("Event_CaptureTheEggGameplay") == true
	refreshScoreboardCards(buildLiveEntries())
	setBoardShown(v16 and v17 and not flag and true or false, nil) -- equivalent call inferred; original call site unknown
end

local function updateLiveTimers()
	if v4 == nil or not (v13 and v4.Gui.Enabled) then
		return
	end

	refreshScoreboardCards(buildLiveEntries())
end

local function resetScoreboardCards()
	clearTransferGhosts() -- equivalent call inferred; original call site unknown
	local scoreboardUi = getScoreboardUi()

	if scoreboardUi ~= nil then
		for _, card in scoreboardUi.Cards do
			hideCard(card, true) -- equivalent call inferred; original call site unknown
		end
	end

	v8 = nil
	v5 = {}
	sampledAt = 0
	v6 = nil
	v7 = nil
end

local function refreshScoreboardAvailability()
	if not v16 and Workspace:GetAttribute("Event_CaptureTheEgg") == true then
		v16 = true
	end

	v17 = v16 and Workspace:GetAttribute("Event_CaptureTheEggGameplay") == true

	if v17 and not flag then
		refreshScoreboardCards(buildLiveEntries())
		v12 = true
	else
		v12 = false
	end

	applyBoardVisibility(nil)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveAsset(childName: string, childName2: string)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local child = assets and assets:FindFirstChild(childName)
	return child and child:FindFirstChild(childName2)
end

local function playSound(childName: string, object, p)
	local asset = resolveAsset("Sounds", childName) -- equivalent call inferred; original call site unknown

	if asset == nil or not asset:IsA("Sound") then
		warnMissingAssetOnce(
			childName,
			`[CaptureTheEgg] Missing ReplicatedStorage.Assets.Sounds.{childName}; the cinematic will continue without it.`
		) -- equivalent call inferred; original call site unknown
		return nil
	else
		local success, result = pcall(Audio.Play, asset, p or script)

		if not success then
			warn((`[CaptureTheEgg] {childName} failed to play: {result}`))
			return nil
		end

		if result == nil or result.Parent == nil then
			return nil
		end

		if p == nil then
			object:Add(result)
		end

		return result
	end
end

local function emitImpactVfx(cFrame: CFrame)
	local asset = resolveAsset("Particles", "BigHitGroundAttach") -- equivalent call inferred; original call site unknown

	if asset == nil then
		warnMissingAssetOnce(
			"BigHitGroundAttach",
			"[CaptureTheEgg] Missing ReplicatedStorage.Assets.Particles.BigHitGroundAttach; impact VFX was skipped."
		) -- equivalent call inferred; original call site unknown
	elseif asset:IsA("ParticleEmitter") or asset:FindFirstChildWhichIsA("ParticleEmitter", true) ~= nil then
		local part = Instance.new("Part")
		part.Name = "CaptureTheEggImpactVFX"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = createVector(0.1, 0.1, 0.1)
		part.CFrame = cFrame
		part.Parent = Workspace:FindFirstChild("Transient") or Workspace
		Debris:AddItem(part, 10)
		local clone = asset:Clone()
		local success, result = pcall(PlayVFX, part, cFrame, clone)

		if not success then
			clone:Destroy()
			warn((`[CaptureTheEgg] BigHitGroundAttach failed to play: {result}`))
		end
	else
		warnMissingAssetOnce(
			"BigHitGroundAttachEmitter",
			"[CaptureTheEgg] BigHitGroundAttach has no ParticleEmitter descendants; impact VFX was skipped."
		) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preloadCutsceneAssets(preloadCategory: string)
	if v24[preloadCategory] then
		return
	end

	v24[preloadCategory] = true
	task.spawn(function()
		local v26 = {}
		local v27 = {}

		for _, v28 in {
			{ "Sounds", "CinematicRiser" },
			{ "Sounds", "CinematicBoom" },
			{ "Sounds", "ImpactBoom" },
			{ "Particles", "BigHitGroundAttach" }
		} do
			local asset = resolveAsset(v28[1], v28[2]) -- equivalent call inferred; original call site unknown

			if asset ~= nil then
				table.insert(v26, asset)
			end
		end

		local success, result = pcall(function()
			return EggRenderer.GetTemplate(EggRecords.NewEgg(preloadCategory))
		end)

		if success and typeof(result) == "Instance" then
			table.insert(v26, result)
		end

		for _, animationId in { CaptureTheEgg.DanceAnimationId, CaptureTheEgg.R6DanceAnimationId } do
			local animation = Instance.new("Animation")
			animation.AnimationId = animationId
			table.insert(v26, animation)
			table.insert(v27, animation)
		end

		if #v26 > 0 then
			pcall(ContentProvider.PreloadAsync, ContentProvider, v26)
		end

		for _, v28 in v27 do
			v28:Destroy()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvePreloadCategory(p)
	if type(p) == "table" and type(p.EggCategory) == "string" and p.EggCategory ~= "" then
		return p.EggCategory
	end

	return CaptureTheEgg.CarryCategory
end

local function ensureOverlay()
	local v26 = v22

	if v26 ~= nil and v26.Gui.Parent ~= nil then
		return v26
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CaptureTheEggCinematic"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 50
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Vignette"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://104574024062008"
	imageLabel.ImageColor3 = Color3.new(0, 0, 0)
	imageLabel.ImageTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ZIndex = 1
	imageLabel.Parent = screenGui

	local function createBar(name: string, position: UDim2)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Position = position
		frame.Size = UDim2.fromScale(1, 0.11)
		frame.ZIndex = 2
		frame.Parent = screenGui
		return frame
	end

	local bar = createBar("Top", UDim2.fromScale(0, -0.11))
	local bar2 = createBar("Bottom", UDim2.fromScale(0, 1))
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	local v27 = {
		Gui = screenGui,
		Top = bar,
		Bottom = bar2,
		Vignette = imageLabel
	}
	v22 = v27
	return v27
end

local function setOverlayShown(flag2: boolean)
	for _, v26 in v23 do
		v26:Cancel()
	end

	table.clear(v23)
	local overlay = ensureOverlay()
	local quint = Enum.EasingStyle.Quint
	local v27

	if flag2 then
		v27 = Enum.EasingDirection.Out
	else
		v27 = Enum.EasingDirection.In
	end

	local tweenInfo = TweenInfo.new(0.9, quint, v27)
	local top = overlay.Top
	local position

	if flag2 then
		position = UDim2.fromScale(0, 0)
	else
		position = UDim2.fromScale(0, -0.11)
	end

	local v32 = TweenService:Create(top, tweenInfo, {
		Position = position
	})
	local bottom = overlay.Bottom
	local position2

	if flag2 then
		position2 = UDim2.fromScale(0, 0.89)
	else
		position2 = UDim2.fromScale(0, 1)
	end

	v23 = { v32, TweenService:Create(bottom, tweenInfo, {
			Position = position2
		}), TweenService:Create(overlay.Vignette, tweenInfo, {
			ImageTransparency = flag2 and 0.3 or 1
		}) }

	for _, v36 in v23 do
		v36:Play()
	end
end

local function cloneStarterCharacter(p: number)
	local character = nil
	local model = ReplicatedStorage:FindFirstChild(CaptureTheEgg.StarterRigName)

	if model ~= nil and model:IsA("Model") then
		character = model
	end

	if character == nil then
		local playerByUserId = Players:GetPlayerByUserId(p)
		character = playerByUserId and playerByUserId.Character
	end

	if character == nil then
		return nil
	end

	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = false
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart", true)

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		humanoidRootPart = clone.PrimaryPart
	end

	if humanoidRootPart == nil then
		clone:Destroy()
		warnMissingAssetOnce("DanceRigRoot", "[CaptureTheEgg] The starter's cloned character has no root part.") -- equivalent call inferred; original call site unknown
		return nil
	else
		clone.PrimaryPart = humanoidRootPart

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = descendant == humanoidRootPart
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
				descendant.Massless = descendant ~= humanoidRootPart
			elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
				descendant:Destroy()
			end
		end

		local humanoid = clone:FindFirstChildOfClass("Humanoid")

		if humanoid ~= nil then
			humanoid.AutoRotate = false
			humanoid.BreakJointsOnDeath = false
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		return clone
	end
end

local function playDance(starterCharacter)
	local humanoid = starterCharacter:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		warnMissingAssetOnce("DanceHumanoid", "[CaptureTheEgg] The starter's dancer rig has no Humanoid.") -- equivalent call inferred; original call site unknown
	else
		local v26 = humanoid:FindFirstChildOfClass("Animator")

		if v26 == nil then
			v26 = Instance.new("Animator")
			v26.Parent = humanoid
		end

		for _, v27 in v26:GetPlayingAnimationTracks() do
			v27:Stop(0)
		end

		local animation = Instance.new("Animation")
		local animationId

		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			animationId = CaptureTheEgg.R6DanceAnimationId
		else
			animationId = CaptureTheEgg.DanceAnimationId
		end

		animation.AnimationId = animationId
		animation.Parent = starterCharacter
		local success, result = pcall(v26.LoadAnimation, v26, animation)

		if not success then
			warn((`[CaptureTheEgg] Could not load the starter dance: {result}`))
			return
		end

		result.Priority = Enum.AnimationPriority.Action
		result.Looped = true
		result:Play(0.1, 1, 1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModelTopOffset(model)
	local boundingBox, v26 = model:GetBoundingBox()
	return boundingBox.Position.Y + v26.Y * 0.5 - model:GetPivot().Position.Y
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModelBottomToPivot(starterCharacter)
	local boundingBox, v26 = starterCharacter:GetBoundingBox()
	return starterCharacter:GetPivot().Position.Y - (boundingBox.Position.Y - v26.Y * 0.5)
end

local function handheldNoise(p: number, p2: number)
	return (math.noise(p * 0.25, p2 * 7.31, 0.5) + math.noise(p * 1.25, p2 * 7.31 + 3.17, 9.5) * 0.2) / 1.2 * 2
end

local function handheldOffset(p: number, p2: number)
	local v26 = (math.noise(p * 0.25, 7.31, 0.5) + math.noise(p * 1.25, 10.48, 9.5) * 0.2) / 1.2 * 2 * 0.02007128639793479 * p2
	local v27 = (math.noise(p * 0.25, 14.62, 0.5) + math.noise(p * 1.25, 17.79, 9.5) * 0.2) / 1.2 * 2 * 0.014835298641951801 * p2
	local v28 = (math.noise(p * 0.25, 21.93, 0.5) + math.noise(p * 1.25, 25.1, 9.5) * 0.2) / 1.2 * 2 * 0.007853981633974483 * p2
	local v29 = Vector3.new(
		(math.noise(p * 0.25, 29.24, 0.5) + math.noise(p * 1.25, 32.41, 9.5) * 0.2) / 1.2 * 2 * 0.1599999964237213,
		(math.noise(p * 0.25, 36.55, 0.5) + math.noise(p * 1.25, 39.72, 9.5) * 0.2) / 1.2 * 2 * 0.12999999523162842,
		(math.noise(p * 0.25, 43.86, 0.5) + math.noise(p * 1.25, 47.03, 9.5) * 0.2) / 1.2 * 2 * 0.07999999821186066
	) * p2
	return CFrame.new(v29) * CFrame.Angles(0, v26, 0) * CFrame.Angles(v27, 0, v28)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveShotDirection(cFrame: CFrame, position: Vector3)
	local v26 = cFrame.Position - position
	local vector2 = Vector3.new(v26.X, 0, v26.Z)

	if vector2.Magnitude < 1 then
		return (createVector(1, 0, 1)).Unit
	end

	return vector2.Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveEggShot(vector2: Vector3, vector3: Vector3, p: number)
	local v26 = vector2 + Vector3.new(0, p * 0.5, 0)
	local v27 = vector2 + vector3 * (p * 0.55 + 45) + Vector3.new(0, p * 0.18 + 11, 0)
	return CFrame.lookAt(v27, v26)
end

local function restoreCutsceneCamera()
	local currentCamera = Workspace.CurrentCamera
	local v26 = v20
	v20 = nil

	if currentCamera == nil or v26 == nil then
		return
	end

	currentCamera.CFrame = v26.CFrame
	currentCamera.FieldOfView = v26.FieldOfView
	currentCamera.CameraType = v26.CameraType

	if v26.CameraSubject ~= nil and v26.CameraSubject.Parent ~= nil then
		currentCamera.CameraSubject = v26.CameraSubject
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function revealScoreboardAfterCutscene()
	if not v16 then
		return
	end

	refreshScoreboardAvailability()
end

local function stopCutscene(flag2: boolean)
	if not flag then
		return
	end

	count4 += 1
	flag = false
	pcall(RunService.UnbindFromRenderStep, RunService, "CaptureTheEggCutsceneCamera")
	local v26 = v19
	v19 = nil

	if v26 ~= nil then
		v26:Clean()
	end

	setOverlayShown(false)
	local currentCamera = Workspace.CurrentCamera
	local v27 = v20
	v20 = nil

	if currentCamera ~= nil and v27 ~= nil then
		currentCamera.CFrame = v27.CFrame
		currentCamera.FieldOfView = v27.FieldOfView
		currentCamera.CameraType = v27.CameraType

		if v27.CameraSubject ~= nil and v27.CameraSubject.Parent ~= nil then
			currentCamera.CameraSubject = v27.CameraSubject
		end
	end

	if v21 ~= nil then
		local v28 = v21
		v21 = nil
		v28()
	end

	if flag2 then
		revealScoreboardAfterCutscene() -- equivalent call inferred; original call site unknown
	end
end

local function buildCutsceneRecord(p: string, list)
	local egg = EggRecords.NewEgg(p)

	if list ~= nil and #list > 0 then
		egg.Mutations = table.clone(list)
		egg.BaseMutation = list[1]
	end

	return egg
end

local function playCutscene(p: number, cframe: CFrame, cframe2: CFrame, p2: number, p3: string, p4)
	if flag then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		revealScoreboardAfterCutscene() -- equivalent call inferred; original call site unknown
	else
		local success, result = pcall(function()
			local renderVisual = EggRenderer.RenderVisual
			local v28 = p4
			local egg = EggRecords.NewEgg(p3)

			if v28 ~= nil and #v28 > 0 then
				egg.Mutations = table.clone(v28)
				egg.BaseMutation = v28[1]
			end

			return renderVisual({
				OwnerUserId = 0,
				UID = "CaptureTheEggCutscene",
				ModelName = "CaptureTheEggCutsceneEgg",
				Record = egg,
				ScaleMultiplier = CaptureTheEgg.EggScale
			}, Workspace)
		end)

		if success then
			local v26, v27 = xpcall(function()
				count4 += 1
				local v28 = count4
				flag = true
				local v29 = Trove.new()
				v19 = v29
				local v30 = CameraShaker.new()
				local model = result.Model
				v29:Add(model)
				local modelTopOffset = getModelTopOffset(model) -- equivalent call inferred; original call site unknown
				local v31 = cframe.Position + createVector(0, 260, 0)
				local v32 = CFrame.new(v31) * cframe.Rotation
				model:PivotTo(v32)
				local shotDirection = resolveShotDirection(currentCamera.CFrame, cframe2.Position) -- equivalent call inferred; original call site unknown
				local starterCharacter = cloneStarterCharacter(p)
				local v33

				if starterCharacter == nil then
					v33 = 0
				else
					v33 = getModelBottomToPivot(starterCharacter)
				end

				local rotation = CFrame.lookAt(createVector(0, 0, 0), shotDirection).Rotation

				if starterCharacter ~= nil then
					local v34 = v32.Position + v32.UpVector * modelTopOffset + Vector3.new(0, v33 + 0.25, 0)
					starterCharacter:PivotTo(CFrame.new(v34) * rotation)
					starterCharacter.Parent = Workspace
					v29:Add(starterCharacter)
					playDance(starterCharacter)
				end

				local lastTime = os.clock()
				local flag2 = false
				local v34 = false
				local flag3 = true
				local v35 = false
				local v36 = playSound("CinematicRiser", v29, nil)
				v20 = {
					CFrame = currentCamera.CFrame,
					FieldOfView = currentCamera.FieldOfView,
					CameraType = currentCamera.CameraType,
					CameraSubject = currentCamera.CameraSubject
				}
				local v37 = v20
				v12 = false
				local scoreboardUi = getScoreboardUi()

				if scoreboardUi ~= nil then
					local gui = scoreboardUi.Gui
					local board = scoreboardUi.Board
					local v38 = v12 and v14
					local _ = v38 == v13
					count2 += 1
					local v39 = v15

					if v39 ~= nil then
						v39:Cancel()
					end

					v15 = nil

					if v38 then
						local position

						if v9 then
							position = uDim2
						else
							position = uDim
						end

						gui.Enabled = true

						if not v13 then
							board.Position = uDim3
						end

						v13 = true
						board.Position = position
					else
						v13 = false
						board.Position = uDim3
						gui.Enabled = false
					end
				end

				v21 = HiddenUIHandler.Acquire()
				setOverlayShown(true)
				currentCamera.CameraType = Enum.CameraType.Scriptable

				local function stepCutscene(p5: number)
					if v28 ~= count4 or not flag then
						return
					end

					currentCamera.CameraType = Enum.CameraType.Scriptable
					local serverTimeNow = Workspace:GetServerTimeNow()
					local v38 = math.clamp(
						(serverTimeNow - (p2 - CaptureTheEgg.CutsceneFallSeconds)) / CaptureTheEgg.CutsceneFallSeconds,
						0,
						1
					)
					local v39 = v38 * 0.08 + v38 ^ 2.65 * 0.92
					local lerped = v31:Lerp(cframe.Position, v39)
					local v40 = math.sin(3.141592653589793 * v38)
					local v41 = math.sin(15.707963267948966 * v38) * 0.19198621771937624 * v40
					local v42 = math.sin(21.991148575128552 * v38) * 0.13962634015954636 * v40
					local cframe3 = CFrame.Angles(v41, 25.132741228718345 * v38, v42)
					local v43 = CFrame.new(lerped) * cframe.Rotation * cframe3

					if flag3 then
						model:PivotTo(v43)
					end

					if starterCharacter ~= nil then
						local v44 = v43.Position + v43.UpVector * modelTopOffset + Vector3.new(0, v33 + 0.25, 0)
						starterCharacter:PivotTo(CFrame.new(v44) * rotation)
					end

					if v38 >= 1 and not flag2 then
						flag2 = true

						if flag3 then
							flag3 = false
							model:PivotTo(cframe)
							model:Destroy()
						end

						if starterCharacter ~= nil then
							local v44 = cframe.Position + cframe.UpVector * modelTopOffset + Vector3.new(
								0,
								v33 + 0.25,
								0
							)
							starterCharacter:PivotTo(CFrame.new(v44) * rotation)
						end

						if v36 ~= nil and v36.Parent ~= nil then
							local tween = TweenService:Create(
								v36,
								TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Volume = 0
								}
							)
							v29:Add(tween)
							tween:Play()
						end

						playSound("CinematicBoom", v29, nil)
						playSound("ImpactBoom", v29, cframe2)
						emitImpactVfx(cframe2)
						v30:ShakeOnce(8.5, 12, 0, 1.35)
					end

					local v44 = os.clock() - lastTime
					local v45 = 1 - (1 - math.clamp(v44 / 0.95, 0, 1)) ^ 5
					local eggShot = resolveEggShot(lerped, shotDirection, modelTopOffset) -- equivalent call inferred; original call site unknown
					local eggShot2 = resolveEggShot(cframe.Position, shotDirection, modelTopOffset) -- equivalent call inferred; original call site unknown
					local lerped2 = v37.CFrame:Lerp(eggShot, v45)
					local fieldOfView = v37.FieldOfView + (50 - v37.FieldOfView) * v45
					local v51 = math.max(serverTimeNow - p2, 0)
					local v52 = 0

					if flag2 then
						lerped2 = v37.CFrame:Lerp(eggShot2, v45)
						fieldOfView += math.exp(-v51 * 6) * 9

						if v51 >= 1.5 then
							v52 = math.clamp((v51 - 1.5) / 1.15, 0, 1)
							local v53 = easeInOutCubic(v52)
							lerped2 = eggShot2:Lerp(v37.CFrame, v53)
							fieldOfView = (v37.FieldOfView - 50) * v53 + 50

							if not v34 then
								v34 = true
								setOverlayShown(false)
							end
						end
					end

					local v53 = math.clamp(v44 / 1.1, 0, 1)

					if flag2 then
						v53 *= 0.55
					end

					local v54 = v53 * (1 - v52)
					currentCamera.FieldOfView = fieldOfView
					currentCamera.CFrame = lerped2 * handheldOffset(v44, v54) * v30:Update(p5)

					if v52 >= 1 and not v35 then
						v35 = true
						task.defer(function()
							if v28 == count4 then
								stopCutscene(true)
							end
						end)
					end
				end

				RunService:BindToRenderStep(
					"CaptureTheEggCutsceneCamera",
					Enum.RenderPriority.Camera.Value + 1,
					function(p5: number)
						local v38, v39 = xpcall(stepCutscene, debug.traceback, p5)

						if not (v38 or v35) then
							v35 = true
							warn((`[CaptureTheEgg] Cutscene frame failed: {v39}`))
							task.defer(function()
								if v28 == count4 then
									stopCutscene(true)
								end
							end)
						end
					end
				)
			end, debug.traceback)

			if not v26 then
				warn((`[CaptureTheEgg] Cutscene setup failed: {v27}`))

				if flag then
					stopCutscene(true)
					return
				end

				revealScoreboardAfterCutscene() -- equivalent call inferred; original call site unknown
			end
		else
			warn((`[CaptureTheEgg] Could not render the falling egg: {result}`))
			revealScoreboardAfterCutscene() -- equivalent call inferred; original call site unknown
		end
	end
end

local CaptureTheEgg2 = {
	StartEvent = function(_, _: number, p)
		count3 += 1
		v16 = true
		v17 = Workspace:GetAttribute("Event_CaptureTheEggGameplay") == true
		resetScoreboardCards()
		v12 = false
		local scoreboardUi = getScoreboardUi()

		if scoreboardUi ~= nil then
			local gui = scoreboardUi.Gui
			local board = scoreboardUi.Board
			local v26 = v12 and v14
			local _ = v26 == v13
			count2 += 1
			local v27 = v15

			if v27 ~= nil then
				v27:Cancel()
			end

			v15 = nil

			if v26 then
				local position

				if v9 then
					position = uDim2
				else
					position = uDim
				end

				gui.Enabled = true

				if not v13 then
					board.Position = uDim3
				end

				v13 = true
				board.Position = position
			else
				v13 = false
				board.Position = uDim3
				gui.Enabled = false
			end
		end

		local preloadCategory = resolvePreloadCategory(p) -- equivalent call inferred; original call site unknown
		preloadCutsceneAssets(preloadCategory) -- equivalent call inferred; original call site unknown
		refreshScoreboardAvailability()
	end,
	StopEvent = function(_)
		count3 += 1
		local v26 = count3
		v16 = false
		v17 = false
		stopCutscene(false)
		setBoardShown(false, nil) -- equivalent call inferred; original call site unknown
		local scoreboardUi = getScoreboardUi()

		if scoreboardUi ~= nil then
			for _, card in scoreboardUi.Cards do
				hideCard(card)
			end
		end

		task.delay(0.26, function()
			if v26 == count3 then
				resetScoreboardCards()
				v12 = false
				local scoreboardUi2 = getScoreboardUi()

				if scoreboardUi2 == nil then
					return
				end

				local gui = scoreboardUi2.Gui
				local board = scoreboardUi2.Board
				local v27 = v12 and v14
				local _ = v27 == v13
				count2 += 1
				local v28 = v15

				if v28 ~= nil then
					v28:Cancel()
				end

				v15 = nil

				if v27 then
					local position

					if v9 then
						position = uDim2
					else
						position = uDim
					end

					gui.Enabled = true

					if not v13 then
						board.Position = uDim3
					end

					v13 = true
					board.Position = position
				else
					v13 = false
					board.Position = uDim3
					gui.Enabled = false
				end
			end
		end)
	end
}
Remotes.EggCapture.StandingsRefreshed.OnClientEvent:Connect(function(p, p2)
	if type(p) ~= "table" then
		return
	end

	renderScoreboard(p, p2)
end)
Remotes.EggCapture.CutsceneBegan.OnClientEvent:Connect(function(value: number, cframe: CFrame, cframe2: CFrame, value2: number, value3: string, p)
	if type(value) ~= "number" or typeof(cframe) ~= "CFrame" or typeof(cframe2) ~= "CFrame" or type(value2) ~= "number" or value2 ~= value2 or type(value3) ~= "string" then
		return
	end

	if type(p) ~= "table" then
		p = nil
	end

	playCutscene(value, cframe, cframe2, value2, value3, p)
end)
AreaEggResetWall.Changed:Connect(function(flag2: boolean)
	count += 1

	if flag2 then
		setWallIsDown(false) -- equivalent call inferred; original call site unknown
	else
		local v26 = count
		task.delay(AreaEggResetWall.CollapseSeconds, function()
			if v26 == count and not AreaEggResetWall.IsSealed() then
				setWallIsDown(true) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end)
EggState.CarryChanged:Connect(function(p)
	setLocalPlayerCarryingEgg(p.IsCarrying)
	local v26

	if p.IsCarrying then
		v26 = p.Uid
	end

	v10 = v26
	refreshSpawnLock() -- equivalent call inferred; original call site unknown
end)
localPlayer.CharacterRemoving:Connect(function()
	setLocalPlayerCarryingEgg(false)
	v10 = nil
	refreshSpawnLock() -- equivalent call inferred; original call site unknown
end)
Workspace:GetAttributeChangedSignal(eggUidAttribute):Connect(refreshSpawnLock)
Workspace:GetAttributeChangedSignal("Event_CaptureTheEggGameplay"):Connect(refreshScoreboardAvailability)
RunService.RenderStepped:Connect(function()
	local v26 = v4

	if v26 ~= nil and v13 then
		if not v26.Gui.Enabled then
			return
		end

		refreshScoreboardCards(buildLiveEntries())
	end
end)
task.defer(function()
	if Workspace:GetAttribute("Event_CaptureTheEgg") == true then
		v16 = true
		refreshScoreboardAvailability()
	else
		resetScoreboardCards()
		v12 = false
		local scoreboardUi = getScoreboardUi()

		if scoreboardUi == nil then
			return
		end

		local gui = scoreboardUi.Gui
		local board = scoreboardUi.Board
		local v26 = v12 and v14
		local _ = v26 == v13
		count2 += 1
		local v27 = v15

		if v27 ~= nil then
			v27:Cancel()
		end

		v15 = nil

		if v26 then
			local position

			if v9 then
				position = uDim2
			else
				position = uDim
			end

			gui.Enabled = true

			if not v13 then
				board.Position = uDim3
			end

			v13 = true
			board.Position = position
		else
			v13 = false
			board.Position = uDim3
			gui.Enabled = false
		end
	end
end)
return CaptureTheEgg2