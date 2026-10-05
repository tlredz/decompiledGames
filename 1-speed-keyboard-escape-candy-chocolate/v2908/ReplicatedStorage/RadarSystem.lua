local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function getCoinPosition(model)
	if model:IsA("Model") then
		return model:GetPivot().Position
	end

	return model.Position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTagged(tag)
	return CollectionService:GetTagged(tag)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setRadarVisible(visible)
	for _, v in ipairs(getTagged("GoldenEggRadar")) do
		v.Visible = visible
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setArrowState(p)
	for _, v in ipairs(getTagged("GoldenEggRadarArrow")) do
		v.Image = p and "rbxassetid://123139547868771" or "rbxassetid://84022142264855"

		if not p then
			v.Rotation = 0
		end
	end

	for _, v in ipairs(getTagged("GoldenEggRadarDist")) do
		if not p then
			v.Text = "No egg..."
		end
	end
end

local function playSound(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.RollOffMaxDistance = 0
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

local function getActiveRadarConfig()
	local now = os.time()

	for _, event in ipairs(EventsConfig.Events) do
		if not (event.Start <= now and now < event.End) then
			continue
		end

		for _, v in ipairs(EventsConfig.CurrenciesRadar or {}) do
			if v.Event == event.Name then
				return v
			end
		end
	end

	return nil
end

local flag = false
local flag2 = false

local function stopRadar()
	flag2 = false
	flag = false
	setRadarVisible(false) -- equivalent call inferred; original call site unknown
	setArrowState(false) -- equivalent call inferred; original call site unknown
end

local function startRadar()
	if flag then
		return
	end

	flag = true
	flag2 = true
	local v = nil
	setRadarVisible(true) -- equivalent call inferred; original call site unknown
	ClientState:RegisterModalListener(function(p)
		if flag2 then
			setRadarVisible(not p) -- equivalent call inferred; original call site unknown
		end
	end)
	CollectionService:GetInstanceAddedSignal("GoldenEggRadar"):Connect(function(p)
		p.Visible = ClientState.ActiveModal == nil
	end)
	CollectionService:GetInstanceAddedSignal("Rarity1Coin"):Connect(function(p)
		v = p
		setArrowState(true) -- equivalent call inferred; original call site unknown
		playSound("rbxassetid://105044658147672")
	end)
	CollectionService:GetInstanceRemovedSignal("Rarity1Coin"):Connect(function(p)
		if v == p then
			v = nil
			setArrowState(false) -- equivalent call inferred; original call site unknown
			playSound("rbxassetid://130842421411875")
		end
	end)
	local tagged = getTagged("Rarity1Coin") -- equivalent call inferred; original call site unknown

	if #tagged > 0 then
		v = tagged[1]
		setArrowState(true) -- equivalent call inferred; original call site unknown
	else
		setArrowState(false) -- equivalent call inferred; original call site unknown
	end

	RunService.Heartbeat:Connect(function()
		if not flag2 then
			return
		end

		if v and not v.Parent then
			v = nil
			setArrowState(false) -- equivalent call inferred; original call site unknown
		end

		if not v then
			return
		end

		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local coinPosition = getCoinPosition(v) -- equivalent call inferred; original call site unknown
		local position = humanoidRootPart.Position
		local cFrame = workspace.CurrentCamera.CFrame
		local unit = Vector3.new(cFrame.LookVector.X, 0, cFrame.LookVector.Z).Unit
		local unit2 = Vector3.new(cFrame.RightVector.X, 0, cFrame.RightVector.Z).Unit
		local unit3 = Vector3.new(coinPosition.X - position.X, 0, coinPosition.Z - position.Z).Unit
		local rotation = math.deg((math.atan2(unit3:Dot(unit2), (unit3:Dot(unit)))))

		for _, v4 in ipairs(getTagged("GoldenEggRadarArrow")) do
			v4.Rotation = rotation
		end

		local magnitude = math.floor((coinPosition - position).Magnitude)

		for _, v4 in ipairs(getTagged("GoldenEggRadarDist")) do
			v4.Text = magnitude .. " studs"
		end
	end)
end

local function tryStartWithConfig(p)
	local gamepass = p.Gamepass or 0

	if gamepass == 0 then
		startRadar()
		return
	end

	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, gamepass)
	end)

	if success and result then
		startRadar()
	end
end

return {
	Init = function(_)
		local activeRadarConfig = getActiveRadarConfig()

		if activeRadarConfig then
			local gamepass = activeRadarConfig.Gamepass or 0

			if gamepass == 0 then
				startRadar()
			else
				local success, result = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, gamepass)
				end)

				if success and result then
					startRadar()
				end
			end
		end

		MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, p, p2)
			if not p2 then
				return
			end

			local activeRadarConfig2 = getActiveRadarConfig()

			if activeRadarConfig2 and (activeRadarConfig2.Gamepass == 0 or activeRadarConfig2.Gamepass == p) then
				startRadar()
			end
		end)
		local now = os.time()

		for _, event in ipairs(EventsConfig.Events) do
			for _, v2 in ipairs(EventsConfig.CurrenciesRadar or {}) do
				if v2.Event ~= event.Name then
					continue
				end

				if event.Start <= now and now < event.End then
					task.delay(event.End - now, stopRadar)
				elseif now < event.Start then
					local v3 = v2
					task.delay(event.Start - now, function()
						local gamepass = v3.Gamepass or 0

						if gamepass == 0 then
							startRadar()
							return
						end

						local success, result = pcall(function()
							return MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, gamepass)
						end)

						if success and result then
							startRadar()
						end
					end)
					task.delay(event.End - now, stopRadar)
				end

				break
			end
		end
	end
}