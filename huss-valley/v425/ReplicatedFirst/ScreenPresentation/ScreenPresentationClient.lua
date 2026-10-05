local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local clone = table.clone(require(parent.ScreenConfig))
local success, result = pcall(function()
	return TeleportService:GetLocalPlayerTeleportData()
end)
local v

if success then
	if type(result) == "table" then
		v = result.destination == "Public" or result.cohRefresh == true
	else
		v = false
	end
else
	v = success
end

if v then
	clone.MinimumLoadingTime = clone.ReturnMinimumLoadingTime
	clone.LightingSettleTime = clone.ReturnLightingSettleTime
end

local clone2 = parent.ScreenOverlay:Clone()
clone2.Enabled = true
clone2.Parent = localPlayer:WaitForChild("PlayerGui")
localPlayer:SetAttribute("ScreenPresentationActive", true)
ReplicatedFirst:RemoveDefaultLoadingScreen()
local IrisController = require(parent.IrisController)
local v2 = IrisController.new(clone2, clone)
local LoadingProgress = require(parent.LoadingProgress)
local v3 = LoadingProgress.new(clone2, clone)
local v4 = true
local v5 = nil
local v6 = false
local screenTransition = nil
local v7 = true
local ReadyHandshake = require(parent.ReadyHandshake)
local v8 = ReadyHandshake.new(localPlayer, function()
	return v7
end)

local function redirecting()
	return localPlayer:GetAttribute("TutorialDestination") == "Tutorial" and localPlayer:GetAttribute("TutorialSession") ~= true
end

local function updateRoutePresentation()
	local visible

	if localPlayer:GetAttribute("TutorialDestination") == "Tutorial" then
		visible = localPlayer:GetAttribute("TutorialSession") ~= true
	else
		visible = false
	end

	local v10

	if localPlayer:GetAttribute("TutorialSession") == true then
		v10 = true
	else
		v10 = success

		if v10 then
			if type(result) == "table" then
				v10 = result.destination == "Tutorial"
			else
				v10 = false
			end
		end
	end

	clone2.Transfer.Visible = visible
	clone2.Loading.Visible = v4 and not visible
	clone2.Loading.Eyebrow.Text = v10 and "YOUR PRACTICE MATCH" or not v and "WELCOME TO" or result.cohRefresh and "WELCOME BACK" or "READY FOR THE REAL MATCH"
	clone2.Loading.Status.Text = v10 and "Practice running and catching." or v and "Joining other players…" or "Ready for the chase?"
end

localPlayer:GetAttributeChangedSignal("TutorialDestination"):Connect(updateRoutePresentation)
localPlayer:GetAttributeChangedSignal("TutorialSession"):Connect(updateRoutePresentation)
updateRoutePresentation()
local lastTime = os.clock()
clone2:SetAttribute("LoadingStartedAt", workspace:GetServerTimeNow())

local function essentialsReady(p)
	local chickenOrHero = game.ReplicatedStorage:FindFirstChild("ChickenOrHero")
	local game2 = chickenOrHero and chickenOrHero:FindFirstChild("Game")
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v9

	if game:IsLoaded() or p == true then
		v9 = game2 and game2:FindFirstChild("PlayerPreferences") and humanoidRootPart and humanoidRootPart:IsDescendantOf(workspace)

		if v9 then
			if humanoid then
				if humanoid.Health > 0 then
					return workspace.CurrentCamera ~= nil
				else
					return false
				end
			else
				return humanoid
			end
		end
	else
		return false
	end

	return v9
end

local function release()
	localPlayer:SetAttribute("ScreenPresentationActive", nil)

	if localPlayer:GetAttribute("InitialLoadingComplete") == true then
		if localPlayer:GetAttribute("InitialLoadingComplete") ~= true then
			localPlayer:SetAttribute("InitialLoadingComplete", true)
			v8:complete()
		end
	elseif essentialsReady(true) then
		local v9

		if localPlayer:GetAttribute("TutorialDestination") == "Tutorial" then
			v9 = localPlayer:GetAttribute("TutorialSession") ~= true
		else
			v9 = false
		end

		if not v9 and localPlayer:GetAttribute("InitialLoadingComplete") ~= true then
			localPlayer:SetAttribute("InitialLoadingComplete", true)
			v8:complete()
		end
	end
end

local function open(p)
	if v4 or v5 ~= p then
		return
	end

	clone2.Loading.Visible = false
	local v9

	if v6 and localPlayer:GetAttribute("InitialLoadingComplete") ~= true then
		v2:forceOpen()
		v9 = true
	else
		v9 = v2:animate(true)
	end

	if v9 and v5 == p then
		v5 = nil
		release()

		if p and screenTransition then
			screenTransition:FireServer(p, "Shown")
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function failOpen()
	v5 = nil
	clone2.Transfer.Visible = false

	if not v4 then
		clone2.Loading.Visible = false
		v2:forceOpen()
		release()
	end
end

local function finishInitial(loadingExit)
	if not (v7 and v4) then
		return
	end

	v4 = false
	clone2:SetAttribute("LoadingExit", loadingExit)
	clone2:SetAttribute("LoadingSeconds", os.clock() - lastTime)
	clone2.Loading.Visible = false
	clone2.Transfer.Visible = false
	v3:destroy()

	if not (v5 or v4) then
		if v5 ~= nil then
			return
		end

		clone2.Loading.Visible = false
		local v9

		if v6 and localPlayer:GetAttribute("InitialLoadingComplete") ~= true then
			v2:forceOpen()
			v9 = true
		else
			v9 = v2:animate(true)
		end

		if v9 and v5 == nil then
			v5 = nil
			release()
		end
	end
end

task.spawn(function()
	while v7 and localPlayer:GetAttribute("InitialLoadingComplete") ~= true do
		if os.clock() - lastTime >= clone.InitialRecoveryTimeout then
			if not v6 then
				v6 = true
				v4 = false
				v5 = nil
				v3:destroy()
				clone2.Loading.Visible = false
				clone2.Transfer.Visible = false
				v2:forceOpen()
				localPlayer:SetAttribute("ScreenPresentationActive", nil)
				clone2:SetAttribute("LoadingExit", "TimedDismissal")
				clone2:SetAttribute("LoadingSeconds", os.clock() - lastTime)
			end

			if essentialsReady(true) then
				local v9

				if localPlayer:GetAttribute("TutorialDestination") == "Tutorial" then
					v9 = localPlayer:GetAttribute("TutorialSession") ~= true
				else
					v9 = false
				end

				if not v9 then
					release()
					break
				end
			end
		end

		task.wait(0.1)
	end
end)
script.Destroying:Connect(function()
	v7 = false
	v3:destroy()
	v2:destroy()
	localPlayer:SetAttribute("ScreenPresentationActive", nil)
end)
task.spawn(function()
	screenTransition = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("ScreenTransition")
	screenTransition.OnClientEvent:Connect(function(p, p2, p3, p4)
		if p == "Cancel" then
			failOpen() -- equivalent call inferred; original call site unknown
		elseif p == "Close" then
			if p3 == "Tutorial" or p3 == "Public" then
				local clone3 = parent.TeleportOverlay:Clone()
				clone3.Message.Title.Text = p3 == "Tutorial" and "YOUR PRACTICE MATCH" or "JOINING A PUBLIC MATCH"
				clone3.Message.Description.Text = p3 == "Tutorial" and "Learn to run and catch before joining other players." or "You're ready. Your next match is with other players."
				local UIProportions = require(game.ReplicatedFirst.UIProportions)
				UIProportions.prepareTeleport(clone3, workspace.CurrentCamera.ViewportSize)
				TeleportService:SetTeleportGui(clone3)
			end

			v5 = p2
			localPlayer:SetAttribute("ScreenPresentationActive", true)
			task.delay(clone.RecoveryTimeout, function()
				if v7 and v5 == p2 then
					failOpen() -- equivalent call inferred; original call site unknown
				end
			end)

			if v4 or v6 and localPlayer:GetAttribute("InitialLoadingComplete") ~= true or v2:animate(false) and v5 == p2 then
				screenTransition:FireServer(p2, "Closed")
			end
		elseif p == "Reveal" and v5 == p2 then
			local v9 = os.clock() + clone.PlacementTimeout

			while true do
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (typeof(p3) ~= "Vector3" or (humanoidRootPart.Position - p3).Magnitude < 12) and (p4 == nil or character:GetAttribute("MovementReset") == p4) then
					break
				end

				task.wait()

				if v9 <= os.clock() or v5 ~= p2 then
					break
				end
			end

			if typeof(p3) == "Vector3" and workspace.StreamingEnabled then
				pcall(function()
					localPlayer:RequestStreamAroundAsync(p3, clone.StreamTimeout)
				end)
			end

			while v4 and v5 == p2 do
				task.wait(0.05)
			end

			RunService.RenderStepped:Wait()
			RunService.RenderStepped:Wait()
			open(p2)
		end
	end)
	v8:transferReady()
end)

local function preload()
	local v9 = lastTime + clone.LoadingTimeout

	while v7 and v4 and not essentialsReady() and os.clock() < v9 do
		task.wait(0.05)
	end

	if not (v7 and v4 and essentialsReady()) then
		return
	end

	local chickenOrHero = game.ReplicatedStorage:FindFirstChild("ChickenOrHero")
	local v10 = {}
	local v11 = {}
	local v12 = {}
	local gameAudio = game.SoundService:FindFirstChild("GameAudio")
	local _01_Soundtracks = gameAudio and gameAudio:FindFirstChild("01_Soundtracks")
	local lobby = _01_Soundtracks and _01_Soundtracks:FindFirstChild("Lobby")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(p, value)
		if type(value) == "string" and value ~= "" and value ~= "rbxassetid://0" and not v11[value] and #v10 < 256 then
			v11[value] = true
			table.insert(v10, p)
		end
	end

	local function collect(folder)
		if not folder then
			return
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				add(descendant, "Image:" .. descendant.Image) -- equivalent call inferred; original call site unknown
			elseif descendant:IsA("Sound") and descendant.SoundId ~= "" and not (lobby and descendant:IsDescendantOf(lobby)) then
				add(descendant, "Sound:" .. descendant.SoundId) -- equivalent call inferred; original call site unknown
			elseif descendant:IsA("Animation") then
				add(descendant, "Animation:" .. descendant.AnimationId) -- equivalent call inferred; original call site unknown
			elseif descendant:IsA("MeshPart") then
				add(descendant, "Mesh:" .. descendant.MeshId .. ":" .. descendant.TextureID) -- equivalent call inferred; original call site unknown
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				add(descendant, "Texture:" .. descendant.Texture) -- equivalent call inferred; original call site unknown
			elseif descendant:IsA("Sky") then
				add(descendant, "Sky:" .. descendant:GetFullName()) -- equivalent call inferred; original call site unknown
			end
		end
	end

	collect(game.Lighting)
	collect(localPlayer.PlayerGui)
	collect(game.ReplicatedFirst:FindFirstChild("Soundtracks"))
	local animation = chickenOrHero and chickenOrHero:FindFirstChild("Animation")
	local animationConfig = animation and animation:FindFirstChild("AnimationConfig")

	if animationConfig then
		local success2, result2 = pcall(require, animationConfig)

		if success2 then
			for _, animationId in result2.PublishedIds or {} do
				local animation2 = Instance.new("Animation")
				animation2.AnimationId = animationId
				table.insert(v12, animation2)
				add(animation2, "Animation:" .. animationId) -- equivalent call inferred; original call site unknown
			end
		end
	end

	collect(game.SoundService:FindFirstChild("GameAudio"))
	local MapLocator = require(game.ReplicatedStorage.ChickenOrHero.Game:WaitForChild("MapLocator"))
	collect(MapLocator.lobby())
	collect(localPlayer.Character)
	local count = 0
	local v13 = #v10 == 0
	local v14 = math.min(6, #v10)
	clone2:SetAttribute("PreloadTotal", #v10)
	local count2 = 0
	local count3 = 0

	for _ = 1, v14 do
		task.spawn(function()
			while v7 and v4 and os.clock() < v9 do
				count2 += 1
				local v15 = v10[count2]

				if not v15 then
					break
				end

				if not pcall(function()
					ContentProvider:PreloadAsync({ v15 }, function(p, p2)
						if p2 ~= Enum.AssetFetchStatus.Success then
							count3 += 1
						end
					end)
				end) then
					count3 += 1
				end

				count += 1
			end

			v14 -= 1

			if v14 == 0 then
				v13 = true
				clone2:SetAttribute("PreloadFailed", count3)
				clone2:SetAttribute("PreloadSucceeded", count3 == 0)

				for _, v15 in v12 do
					v15:Destroy()
				end
			end
		end)
	end

	while v7 and not v13 and os.clock() < v9 do
		task.wait(0.05)
	end

	if not v7 then
		return
	end

	clone2:SetAttribute("PreloadCompleted", count)
	clone2:SetAttribute("PreloadTimedOut", not v13)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and workspace.StreamingEnabled and os.clock() < v9 - 1 then
		pcall(function()
			localPlayer:RequestStreamAroundAsync(humanoidRootPart.Position, (math.min(1, v9 - os.clock())))
		end)
	end

	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
end

local v9 = false
local v10 = false
task.spawn(function()
	local v11, v12 = xpcall(preload, debug.traceback)

	if not v11 then
		v10 = true
		warn("Screen presentation loading:", v12)
	end

	v9 = true
end)
local v11 = nil

while v7 and v4 do
	local now = os.clock()

	if (v9 or now - lastTime >= clone.LoadingTimeout) and essentialsReady() then
		v11 = v11 or now
	else
		v11 = nil
	end

	local v12

	if localPlayer:GetAttribute("TutorialDestination") == "Tutorial" then
		v12 = localPlayer:GetAttribute("TutorialSession") ~= true
	else
		v12 = false
	end

	if v12 or not (v11 and now - lastTime >= clone.MinimumLoadingTime and now - v11 >= clone.LightingSettleTime) then
		task.wait(0.05)
	else
		break
	end
end

if v7 and v4 then
	clone2:SetAttribute(
		"LoadingExit",
		v10 and "Recovered" or v9 and not clone2:GetAttribute("PreloadTimedOut") and "Ready" or "AssetTimeout"
	)
	clone2:SetAttribute("LoadingReadyAt", workspace:GetServerTimeNow())
	local success2, result2 = pcall(function()
		v3:complete()
	end)

	if not success2 then
		warn("Loading finish recovered:", result2)
	end

	finishInitial(clone2:GetAttribute("LoadingExit"))
end