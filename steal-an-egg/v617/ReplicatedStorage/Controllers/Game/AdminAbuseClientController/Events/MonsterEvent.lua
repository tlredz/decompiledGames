local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EggState = require(ReplicatedStorage.Client.EggState)
local Identity = require(ReplicatedStorage.Shared.Utils.Identity)
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local avatarBust = Enum.ThumbnailType.AvatarBust
local size150x150 = Enum.ThumbnailSize.Size150x150
local uDim = UDim2.fromScale(0, 0)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 255, 32)
local tweenInfo4 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local vector = Vector2.new(0.3, 0.35)
local vector2 = Vector2.new(0.7, 0.65)
local tweenInfo5 = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local maid = Trove.new()
local flag = false
local localPlayer = Players.LocalPlayer
local monsterEventUI = localPlayer.PlayerGui:WaitForChild("MonsterEventUI")
local rows = monsterEventUI.Board.Rows
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
local isCarrying = false
local v6 = {}
local v7 = {}
local v8 = false
local UpdateWinsUI

local function BuildRow(childName: string)
	local frame = rows:FindFirstChild(childName)
	assert(frame and frame:IsA("Frame"), (`MonsterEventUI is missing its {childName} row`))
	local avatar = frame:FindFirstChild("Avatar")
	assert(avatar and avatar:IsA("ImageLabel"), (`the {childName} row is missing its Avatar`))
	local amount = avatar:FindFirstChild("Amount")
	assert(amount and amount:IsA("TextLabel"), (`the {childName} row is missing its Amount label`))
	local v9 = {
		Frame = frame,
		Avatar = avatar,
		Amount = amount,
		BaseSize = frame.Size,
		BaseColor = frame.BackgroundColor3,
		Shown = false,
		Occupant = nil
	}
	frame.Size = uDim
	frame.Visible = false
	return v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetRowShown(state, shown: boolean)
	if state.Shown == shown then
		return
	end

	state.Shown = shown
	local frame = state.Frame

	if shown then
		frame.Size = uDim
		frame.Visible = true
		TweenService:Create(frame, tweenInfo, {
			Size = state.BaseSize
		}):Play()
	else
		local tween = TweenService:Create(frame, tweenInfo, {
			Size = uDim
		})
		tween.Completed:Once(function()
			frame.Visible = state.Shown
		end)
		tween:Play()
	end
end

local function FlashRow(state)
	state.Frame.BackgroundColor3 = state.BaseColor:Lerp(Color3.new(1, 1, 1), 0.6)
	TweenService:Create(state.Frame, tweenInfo2, {
		BackgroundColor3 = state.BaseColor
	}):Play()
end

local function ResolvePlayerImage(occupant: string)
	local v9 = v2[occupant]

	if v9 then
		return v9
	end

	if v3[occupant] then
		return nil
	end

	local player = Players:FindFirstChild(occupant)

	if player and player:IsA("Player") then
		v3[occupant] = true
		task.spawn(function()
			local success, result = pcall(Identity.Thumbnail, player.UserId, avatarBust, size150x150)
			v3[occupant] = nil

			if success and type(result) == "string" then
				v2[occupant] = result
				UpdateWinsUI()
			end
		end)
	end

	return nil
end

local function FillRow(state, name: string, p: number)
	local playerImage = ResolvePlayerImage(name)
	state.Avatar.Image = playerImage or ""
	state.Amount.Text = Simple.FormatCompact(p, ".#")

	if state.Occupant ~= nil and state.Occupant ~= name then
		FlashRow(state)
	end

	state.Occupant = name
	SetRowShown(state, true) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearRow(state)
	state.Occupant = nil
	SetRowShown(state, false) -- equivalent call inferred; original call site unknown
end

UpdateWinsUI = function()
	local v9 = {}

	for k, wins in v do
		if wins > 0 then
			table.insert(v9, {
				Name = k,
				Wins = wins
			})
		end
	end

	table.sort(v9, function(a, b)
		if a.Wins == b.Wins then
			return a.Name < b.Name
		end

		return a.Wins > b.Wins
	end)
	local name = localPlayer.Name
	local v10 = false

	for k, v11 in v4 do
		local v12 = v9[k]

		if v12 == nil then
			ClearRow(v11) -- equivalent call inferred; original call site unknown
		else
			FillRow(v11, v12.Name, v12.Wins)
			v10 = v10 or v12.Name == name
		end
	end

	local v11 = v5
	assert(v11, "MonsterEventUI has no You row")

	if not v10 then
		FillRow(v11, name, v[name] or 0)
		return
	end

	ClearRow(v11) -- equivalent call inferred; original call site unknown
end

local function CollectWinPartFades(folder)
	local result = {
		{
			Object = folder,
			Property = "Transparency",
			Base = folder.Transparency
		}
	}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("TextLabel") then
			table.insert(result, {
				Object = descendant,
				Property = "TextTransparency",
				Base = descendant.TextTransparency
			})
			table.insert(result, {
				Object = descendant,
				Property = "BackgroundTransparency",
				Base = descendant.BackgroundTransparency
			})
		elseif descendant:IsA("ImageLabel") then
			table.insert(result, {
				Object = descendant,
				Property = "ImageTransparency",
				Base = descendant.ImageTransparency
			})
			table.insert(result, {
				Object = descendant,
				Property = "BackgroundTransparency",
				Base = descendant.BackgroundTransparency
			})
		elseif descendant:IsA("Frame") then
			table.insert(result, {
				Object = descendant,
				Property = "BackgroundTransparency",
				Base = descendant.BackgroundTransparency
			})
		elseif descendant:IsA("UIStroke") then
			table.insert(result, {
				Object = descendant,
				Property = "Transparency",
				Base = descendant.Transparency
			})
		end
	end

	return result
end

local function SetWinPartHidden(state, hidden: boolean)
	if state.Hidden == hidden then
		return
	end

	state.Hidden = hidden

	if not hidden then
		state.Gui.Enabled = true
	end

	for _, fade in state.Fades do
		local v9 = hidden and 1 or fade.Base
		TweenService:Create(fade.Object, tweenInfo3, {
			[fade.Property] = v9
		}):Play()
	end

	if hidden then
		task.delay(0.35, function()
			if state.Hidden then
				state.Gui.Enabled = false
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyWinPartVisibility()
	for k, v9 in v6 do
		SetWinPartHidden(v9, v8 or v7[k] == true)
	end
end

local function FlashWinClaim()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "MonsterEventWinFlash"
	colorCorrectionEffect.TintColor = color
	colorCorrectionEffect.Contrast = 0.2
	colorCorrectionEffect.Saturation = 0.1
	colorCorrectionEffect.Parent = Lighting
	colorCorrectionEffect.Enabled = true
	local tween = TweenService:Create(colorCorrectionEffect, tweenInfo4, {
		TintColor = Color3.new(1, 1, 1),
		Contrast = 0,
		Saturation = 0
	})
	tween.Completed:Once(function()
		colorCorrectionEffect:Destroy()
	end)
	tween:Play()
end

local function GetLocalRowAvatar()
	local name = localPlayer.Name

	for _, v9 in v4 do
		if v9.Shown and v9.Occupant == name then
			return v9.Avatar
		end
	end

	local v9 = v5

	if v9 == nil or not v9.Shown or v9.Occupant ~= name then
		return nil
	end

	return v9.Avatar
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScreenPositionOf(p)
	local absoluteSize = monsterEventUI.AbsoluteSize
	local v9 = p.AbsolutePosition + p.AbsoluteSize * 0.5 - monsterEventUI.AbsolutePosition
	return UDim2.fromScale(v9.X / absoluteSize.X, v9.Y / absoluteSize.Y)
end

local function SpawnTrophyBurst(value: number)
	for _ = 1, math.clamp(value, 1, 7) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "MonsterEventTrophy"
		imageLabel.Image = "rbxassetid://82857133407630"
		imageLabel.BackgroundTransparency = 1
		imageLabel.ImageTransparency = 1
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(imageLabel, TweenInfo.new(0.1), {
			Size = UDim2.fromScale(0.06, 0.06)
		}):Play()
		imageLabel.Rotation = math.random(0, 359)
		imageLabel.Position = UDim2.fromScale(
			vector.X + math.random() * (vector2.X - vector.X),
			vector.Y + math.random() * (vector2.Y - vector.Y)
		)
		imageLabel.ZIndex = 10
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
		uIAspectRatioConstraint.Parent = imageLabel
		imageLabel.Parent = monsterEventUI
		TweenService:Create(imageLabel, tweenInfo5, {
			ImageTransparency = 0
		}):Play()
		task.delay(0.2, function()
			if imageLabel.Parent == nil then
				return
			end

			local localRowAvatar = GetLocalRowAvatar()
			local v11 = {
				ImageTransparency = 1
			}

			if localRowAvatar ~= nil then
				v11.Position = ScreenPositionOf(localRowAvatar)
			end

			local tween = TweenService:Create(imageLabel, tweenInfo6, v11)
			tween.Completed:Once(function()
				imageLabel:Destroy()
			end)
			tween:Play()
		end)
	end
end

local function InitWinParts()
	local monsterEventMap = workspace:WaitForChild("MonsterEventMap", 10)

	if monsterEventMap == nil then
		return
	end

	local winParts = monsterEventMap:FindFirstChild("WinParts")
	assert(winParts ~= nil, "MonsterEventMap is missing its WinParts model")

	for _, part in winParts:GetChildren() do
		assert(part:IsA("BasePart"), (`Win part {part.Name} is not a BasePart`))
		local surfaceGui = part:FindFirstChildOfClass("SurfaceGui")
		assert(surfaceGui ~= nil, (`Win part {part.Name} is missing its SurfaceGui`))
		v6[part.Name] = {
			Part = part,
			Gui = surfaceGui,
			Fades = CollectWinPartFades(part),
			Hidden = false
		}
	end

	maid:Add(function()
		v6 = {}
	end)
end

for k, v9 in { "First", "Second", "Third" } do
	v4[k] = BuildRow(v9)
end

v5 = BuildRow("You")
local Cutscene = require(script.Cutscene)
local cutscene = Cutscene(maid)
Remotes.MonsterEvent.WinsUpdated.OnClientEvent:Connect(function(p)
	v = p
	UpdateWinsUI()
end)
Remotes.MonsterEvent.PlaySFX.OnClientEvent:Connect(function(p)
	script.SFX[p]:Play()
end)
EggState.CarryChanged:Connect(function(p)
	isCarrying = p.IsCarrying
end)
Remotes.MonsterEvent.WinPartsUpdated.OnClientEvent:Connect(function(p, p2)
	v7 = p
	ApplyWinPartVisibility() -- equivalent call inferred; original call site unknown

	if p2 ~= nil then
		FlashWinClaim()
		SpawnTrophyBurst(p2)
	end
end)
local flag2 = false

local function OnKillBrickAdded(p)
	p.Touched:Connect(function(otherPart)
		if otherPart.Parent ~= localPlayer.Character or flag2 then
			return
		end

		script.SFX.Died:Play()
		monsterEventUI.Cover.Position = UDim2.new(-2, 0, 0.5, 0)
		flag2 = true
		TweenService:Create(monsterEventUI.Cover, TweenInfo.new(0.2), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		task.wait(0.6)
		TweenService:Create(monsterEventUI.Cover, TweenInfo.new(0.2), {
			Position = UDim2.new(2.7, 0, 0.5, 0)
		}):Play()
		task.wait(0.2)
		flag2 = false
	end)
end

CollectionService:GetInstanceAddedSignal("MonsterEventKillBrick"):Connect(OnKillBrickAdded)

for _, v10 in CollectionService:GetTagged("MonsterEventKillBrick") do
	v10.Touched:Connect(function(otherPart)
		if otherPart.Parent ~= localPlayer.Character or flag2 then
			return
		end

		script.SFX.Died:Play()
		monsterEventUI.Cover.Position = UDim2.new(-2, 0, 0.5, 0)
		flag2 = true
		TweenService:Create(monsterEventUI.Cover, TweenInfo.new(0.2), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		task.wait(0.6)
		TweenService:Create(monsterEventUI.Cover, TweenInfo.new(0.2), {
			Position = UDim2.new(2.7, 0, 0.5, 0)
		}):Play()
		task.wait(0.2)
		flag2 = false
	end)
end

local MonsterEvent = {}

function MonsterEvent.StartEvent(_, _: number)
	maid:Clean()
	flag = true
	monsterEventUI.Enabled = true

	for _, part in game.Workspace.World.Build["1"].COLLISIONS["COLL GUARD"]["WALL RIGHT (COLL GUARD)"]:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		local v10 = part
		maid:Add(function()
			v10.CanCollide = true
		end)
	end

	task.spawn(function()
		local frozenWallRight = Workspace.World.Build["1"].COLLISIONS["GUARD NO COLLIDE"].PLAYER["WALL RIGHT"].FrozenWallRight

		while flag do
			frozenWallRight.CanCollide = isCarrying
			task.wait()
		end

		frozenWallRight.CanCollide = true
	end)
	workspace.World.Build.MainMap.Bases.SIDE_WALLS.CanCollide = false
	maid:Add(function()
		workspace.World.Build.MainMap.Bases.SIDE_WALLS.CanCollide = true
	end)
	v = Remotes.MonsterEvent.GetWins:InvokeServer()
	UpdateWinsUI()
	LightingController.SetLayer("MonsterEvent", "MonsterEvent", 25, 2)
	InitWinParts()
	v7 = Remotes.MonsterEvent.GetWinParts:InvokeServer()
	ApplyWinPartVisibility() -- equivalent call inferred; original call site unknown

	if workspace:GetAttribute("PlayMonsterCutscene") then
		v8 = true
		ApplyWinPartVisibility() -- equivalent call inferred; original call site unknown
		xpcall(cutscene.Run, warn)
		v8 = false
		ApplyWinPartVisibility() -- equivalent call inferred; original call site unknown
	end

	local monsterEventMap = workspace:FindFirstChild("MonsterEventMap")

	if monsterEventMap then
		local surfaceGui = monsterEventMap.WallStartVisual1.SurfaceGui
		local surfaceGui2 = monsterEventMap.WallStartVisual2.SurfaceGui
		surfaceGui.Enabled = true
		surfaceGui2.Enabled = true
	end

	local monsterEventMusic = workspace:FindFirstChild("MonsterEventMusic")

	if monsterEventMusic then
		TweenService:Create(monsterEventMusic, TweenInfo.new(5), {
			Volume = 0.5
		}):Play()
	end
end

function MonsterEvent.StopEvent(_)
	maid:Clean()
	flag = false
	monsterEventUI.Enabled = false
	v = {}
	UpdateWinsUI()
	v7 = {}
	v8 = false
	LightingController.ClearLayer("MonsterEvent", 2)
end

return MonsterEvent