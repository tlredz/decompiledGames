local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("dictUtil")
local import4 = _G.import("signalUtil")
local import5 = _G.import("modelUtil")
local import6 = _G.import("iterator")
local import7 = _G.import("itemModules")
_G.import("configuration")
local import8 = _G.import("viewImports")
local gameplayWindow = import8:get("gameplay").GameplayWindow
local boostBar = import8:get("boostBar").BoostBar
local rightBar = import8:get("rightBar").RightBar
local leftBar = import8:get("leftBar").LeftBar
local bottomLeftBar = import8:get("bottomLeftBar").BottomLeftBar
local bottomRightBar = import8:get("bottomRightBar").BottomRightBar
local hud = import8:get("AfkHud").Hud
local petsPopup = import8:get("petsPopup").PetsPopup
local _ = import8:get("inviteFriendPopup").InviteFriendPopup
local rankedMatchOver = import8:get("rankedMatchOver").RankedMatchOver
local rankUpOverlay = import8:get("rankUpOverlay").RankUpOverlay
local rankDownOverlay = import8:get("rankDownOverlay").RankDownOverlay
local playerWaitingScreen = import8:get("playerWaitingScreen").PlayerWaitingScreen
local topBar = import8:get("topBar").TopBar
local _ = import8:get("sprite").Sprite
local spriteSheet2 = import8:get("sprite").SpriteSheet
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local flag = false
local v = {
	NORMAL = function()
		import.mount(import.make("ScreenGui", {
			Name = "Hud",
			ResetOnSpawn = false
		}, {
			BoostBar = import.make(boostBar),
			RightBar = import.make(rightBar),
			LeftBar = import.make(leftBar),
			BottomLeftBar = import.make(bottomLeftBar),
			BottomRightBar = import.make(bottomRightBar)
		}), playerGui)
		import2.fire("openMenu", "Free")
	end,
	AFK = function()
		import.mount(import.make(hud), playerGui)
	end,
	RANKED = function()
		local expectedPlayerCount = import5.getAttribute(workspace, "MaxPlayers"):await()
		local jSONDecode = HttpService:JSONDecode((import5.getAttribute(workspace, "RankedPlayerIds"):await()))
		local dict = import6.fromArray(jSONDecode):map(function(p, userId)
			return p, {
				UserId = userId
			}
		end):dict()
		import.mount(import.make(playerWaitingScreen, {
			PlayerStates = dict,
			ExpectedPlayerCount = expectedPlayerCount
		}), playerGui)
	end
}
local v2 = nil
local v3 = nil
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function mountModel(p)
	local hud2 = import8:get(p).Hud
	local v5 = import.mount(import.make(hud2), playerGui)

	if v5.Name then
		v4[v5.Name] = v5
	end
end

local function rankedPlayersLoaded()
	playerGui:WaitForChild("PlayerWaitingScreen"):Destroy()
end

local function initUi()
	import.mount(import.make("ScreenGui", {
		Name = "TopBar",
		ResetOnSpawn = false
	}, {
		TopBar = import.make(topBar)
	}), playerGui)
	task.spawn(function()
		repeat
			task.wait(0)
		until workspace:GetAttribute("Mode")

		v[workspace:GetAttribute("Mode")]()
		playerGui:WaitForChild("ReplicatedFirstLoadingScreen"):Destroy()
	end)
	mountModel("signals") -- equivalent call inferred; original call site unknown
end

local v5 = nil

local function openMenu(childName, p)
	v5 = v5 or import.mount(import.make("ScreenGui", {
		Name = "Menus",
		ResetOnSpawn = false
	}), localPlayer.PlayerGui)

	if v5:FindFirstChild(childName) then
		return
	end

	for _, v6 in pairs(v5._Children) do
		v6:Destroy()
	end

	import.apply(v5, nil, {
		[childName] = import.make(import8:get(string.lower(childName))[childName], import3.merge({
			ResetOnSpawn = false
		}, p))
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setHudVisibility(enabled)
	if flag then
		return
	end

	local hud2 = playerGui:FindFirstChild("Hud")

	if not hud2 then
		return
	end

	for _, child in pairs(hud2:GetChildren()) do
		child.Enabled = enabled
	end
end

local function updateRound(p, _, _, p2, _, p3, options)
	setHudVisibility(false) -- equivalent call inferred; original call site unknown

	if not v2 then
		v2 = import.make(gameplayWindow)
		import.mount(v2, playerGui)
	end

	v2:question(p, p2, p3)

	if v3 then
		v2:setHealth(v3)
		v3 = nil
	end

	if not p.Choices then
		for _, v6 in ipairs(options or {}) do
			v2:note(v6)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endGame()
	v3 = nil

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	setHudVisibility(true) -- equivalent call inferred; original call site unknown
end

local function setGameplayInvisible(p)
	if not v2 then
		return
	end

	v2:setInvisible(p)
end

local function setGameplayAbilityPopup(p)
	if not v2 then
		return
	end

	v2:setAbilityPopup(p)
end

local function setHealth(p, p2)
	if p ~= localPlayer.UserId then
		return
	end

	if v2 then
		v2:setHealth(p2)
	else
		v3 = p2
	end
end

local function inGame()
	if localPlayer:GetAttribute("InGame") then
		return
	end

	endGame() -- equivalent call inferred; original call site unknown
end

local function showPetsPopup()
	import.mount(import.make(petsPopup), playerGui)
end

local function renderSprite(instance)
	import4.connect(instance:GetAttributeChangedSignal("Skin"), function()
		local spriteInstance = instance:FindFirstChild("SpriteInstance")

		if spriteInstance then
			spriteInstance:Destroy()
		end

		local skin = instance:GetAttribute("Skin")

		if not skin then
			return
		end

		local item = import7:getItem("Skin", skin)
		import.mount(import.make(item.Sheet and spriteSheet or spriteSheet2, {
			Name = "SpriteInstance",
			AspectRatio = 1.33,
			Size = UDim2.new(6, 0, 6, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Images = item.Sprite,
			ZIndex = -1,
			Looping = true
		}), instance)
	end)
end

local function rotateGradient(uIGradient)
	if not uIGradient:IsA("UIGradient") then
		return
	end

	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not uIGradient:IsDescendantOf(game) then
			renderSteppedConnection:Disconnect()
			return
		end

		local rotSpeed = uIGradient:GetAttribute("RotSpeed")

		if not rotSpeed then
			return
		end

		uIGradient.Rotation = (uIGradient.Rotation + rotSpeed * dt) % 360
	end)
end

local function signal(p)
	v4.Signals:signal(p)
end

local function showRankedMatchResult(data)
	local win = data.Win

	if win then
		if data.OldRank == data.NewRank then
			win = false
		else
			win = data.NewRank ~= "Unranked"
		end
	end

	local v6 = not data.Win and data.OldRank ~= data.NewRank

	if win then
		import.mount(import.make(rankUpOverlay, data), playerGui)
	elseif v6 then
		import.mount(import.make(rankDownOverlay, data), playerGui)
	end

	import.mount(import.make(rankedMatchOver, {
		Win = data.Win,
		Elo = data.Elo,
		EloChange = data.EloChange,
		OldRank = data.OldRank,
		NewRank = data.NewRank,
		PlacementsLeft = data.PlacementsLeft,
		OldProgress = data.OldProgress,
		Progress = data.Progress,
		AvgSpeed = data.AvgSpeed,
		AvgLength = data.AvgLength,
		CashEarned = data.CashEarned
	}), playerGui)
end

return {
	Priority = 1,
	Run = function()
		import2.connect("setHudVisibility", setHudVisibility, {
			Blocking = true
		})
		import2.connect("hudLock", function()
			flag = true
		end, {
			Blocking = true
		})
		import2.connect("hudUnlock", function()
			flag = false
		end, {
			Blocking = true
		})
		import2.connect("dataLoaded", initUi)
		import2.connect("openMenu", openMenu, {
			Blocking = true
		})
		import2.connect("signal", signal)
		import2.remoteConnect("signal", signal)
		import2.remoteConnect("openMenu", openMenu, {
			Blocking = true
		})
		import2.remoteConnect("rankedPlayersLoaded", rankedPlayersLoaded)
		import2.remoteConnect("updateRound", updateRound)
		import2.remoteConnect("endGame", endGame)
		import2.remoteConnect("setHealth", setHealth)
		import2.remoteConnect("showPetsPopup", showPetsPopup)
		import2.remoteConnect("rankedMatchResult", showRankedMatchResult)
		import2.connect("setGameplayInvisible", setGameplayInvisible)
		import2.connect("setGameplayAbilityPopup", setGameplayAbilityPopup, {
			Blocking = true
		})
		localPlayer:GetAttributeChangedSignal("InGame"):Connect(inGame)
		import4.onTag("Sprite", renderSprite)
		import4.onTag("RotatingGradient", rotateGradient)
	end
}