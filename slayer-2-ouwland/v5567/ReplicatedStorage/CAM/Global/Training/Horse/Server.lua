local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local CharGrabPosCorrector = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Wen = require(ReplicatedStorage.CAM.Global.Shop.Cashiers.Wen)
local Item = require(ServerStorage.SAM.Services.Adders.Item)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
Shop.RegisterItem("Horse", {
	Type = Menum.ShopItemType.IngameItem
})

-- equivalent calls inferred from this helper; original call sites unknown
local function fireTamingVFX(p, instance, p2: string, flag: boolean?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	EffectsEvent.ToAllInRange(
		humanoidRootPart or instance,
		"HorseTamingVFX",
		p,
		instance,
		instance:GetAttribute("UniqueName"),
		p2,
		flag
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playRideAnim(humanoid, animation)
	if humanoid == nil then
		return nil
	end

	local v = humanoid:FindFirstChildOfClass("Animator")

	if v == nil then
		v = Instance.new("Animator")
		v.Parent = humanoid
	end

	local track = v:LoadAnimation(animation)
	track:Play()
	return track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restorePlayerNetwork(p, instance)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and p.Parent ~= nil and not humanoidRootPart.Anchored and humanoidRootPart:CanSetNetworkOwnership() then
		humanoidRootPart:SetNetworkOwner(p)
	end
end

local Horse = {
	Do = function(_, instance, p, _, prompt)
		local parent = prompt and prompt.Parent and prompt.Parent.Parent

		if not parent then
			return true, true
		end

		p.Horse = parent
		p.Prompt = prompt
		p.HorsePause = Utility.AddValue(parent, "pause_gameplay")
		local clientAnimatorServer = parent:FindFirstChild("ClientAnimatorServer")
		local currentAnim = clientAnimatorServer and clientAnimatorServer:FindFirstChild("CurrentAnim")

		if currentAnim then
			p.HorseAnim = currentAnim
			p.HorseAnimPrev = currentAnim.Value
			currentAnim.Value = "idle"
		end

		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			p.HorseRoot = humanoidRootPart
			p.HorseRootAnchored = humanoidRootPart.Anchored
			humanoidRootPart.Anchored = true
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				local weld = Instance.new("Weld")
				weld.Part0 = humanoidRootPart
				weld.Part1 = humanoidRootPart2
				weld.C0 = gameSettings.horseRidingPlayerOffset
				weld.Parent = humanoidRootPart
				humanoidRootPart2.CFrame = humanoidRootPart.CFrame * weld.C0
				p.HorseWeld = weld
			end
		end

		local horseRideTrack = playRideAnim(parent:FindFirstChild("Humanoid"), script.HorseResiting) -- equivalent call inferred; original call site unknown
		p.HorseRideTrack = horseRideTrack
		local playerRideTrack = playRideAnim(instance:FindFirstChild("Humanoid"), script.PlayerResiting) -- equivalent call inferred; original call site unknown
		p.PlayerRideTrack = playerRideTrack
		fireTamingVFX(instance, parent, "Taming", true) -- equivalent call inferred; original call site unknown
		local getvaluesfolder = Utility.getvaluesfolder(instance)
		local head = instance:FindFirstChild("Head")

		if getvaluesfolder and head then
			p.CamSubject = Utility.AddValue(getvaluesfolder, "camsubject", nil, "ObjectValue", head)
		end

		return true, true
	end,
	Destroying = function(p, instance, state, _)
		fireTamingVFX(instance, state.Horse, "Taming", false) -- equivalent call inferred; original call site unknown

		if state.HorseRideTrack ~= nil then
			state.HorseRideTrack:Stop()
			state.HorseRideTrack = nil
		end

		if state.PlayerRideTrack ~= nil then
			state.PlayerRideTrack:Stop()
			state.PlayerRideTrack = nil
		end

		if state.HorseThrowTrack ~= nil then
			state.HorseThrowTrack:Stop()
			state.HorseThrowTrack = nil
		end

		if state.PlayerThrowTrack ~= nil then
			state.PlayerThrowTrack:Stop()
			state.PlayerThrowTrack = nil
		end

		if state.HorseWeld ~= nil then
			state.HorseWeld:Destroy()
			state.HorseWeld = nil
		end

		restorePlayerNetwork(p, instance) -- equivalent call inferred; original call site unknown

		if state.CamSubject ~= nil then
			state.CamSubject:Destroy()
			state.CamSubject = nil
		end

		if not state.Tamed then
			if state.HorsePause ~= nil then
				state.HorsePause:Destroy()
				state.HorsePause = nil
			end

			if state.HorseAnim ~= nil then
				if state.HorseAnim.Parent ~= nil then
					state.HorseAnim.Value = state.HorseAnimPrev
				end

				state.HorseAnim = nil
				state.HorseAnimPrev = nil
			end

			if state.HorseRoot ~= nil then
				if state.HorseRoot.Parent ~= nil then
					state.HorseRoot.Anchored = state.HorseRootAnchored == true

					if state.HorseRoot:CanSetNetworkOwnership() then
						state.HorseRoot:SetNetworkOwner(nil)
					end
				end

				state.HorseRoot = nil
				state.HorseRootAnchored = nil
			end
		end
	end
}

local function throwOff(p, instance, state)
	local horse = state.Horse
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if state.HorseRideTrack then
		state.HorseRideTrack:Stop()
		state.HorseRideTrack = nil
	end

	if state.PlayerRideTrack then
		state.PlayerRideTrack:Stop()
		state.PlayerRideTrack = nil
	end

	if horse then
		local horseThrowTrack = playRideAnim(horse:FindFirstChild("Humanoid"), script.HorseThrowOff) -- equivalent call inferred; original call site unknown
		state.HorseThrowTrack = horseThrowTrack
	end

	local humanoid = instance and instance:FindFirstChild("Humanoid")
	local playerThrowTrack = playRideAnim(humanoid, script.PlayerThrowOff) -- equivalent call inferred; original call site unknown
	state.PlayerThrowTrack = playerThrowTrack
	task.wait(0.75)

	if state.PlayerThrowTrack then
		state.PlayerThrowTrack:Stop()
		state.PlayerThrowTrack = nil
	end

	if state.HorseWeld then
		state.HorseWeld:Destroy()
		state.HorseWeld = nil
	end

	restorePlayerNetwork(p, instance) -- equivalent call inferred; original call site unknown
	fireTamingVFX(instance, horse, "ThrowOff", nil) -- equivalent call inferred; original call site unknown

	if humanoidRootPart and humanoidRootPart.Parent ~= nil and horse then
		local getvaluesfolder = Utility.getvaluesfolder(instance)
		local horseRoot = state.HorseRoot or horse:FindFirstChild("HumanoidRootPart")
		local throwPart = horse:FindFirstChild("ThrowPart", true)
		local position = nil

		if throwPart then
			position = throwPart.Position
		elseif horseRoot then
			position = (horseRoot.CFrame * CFrame.new(0, 0, 12)).Position
		end

		if position then
			local v2 = position - humanoidRootPart.Position
			local v3 = (v2.Magnitude > 0 and v2.Unit or horseRoot and -horseRoot.CFrame.LookVector or createVector(
				0,
				0,
				1
			)) * 25 + createVector(0, -2, 0)

			if getvaluesfolder then
				Combat_Util.RagDoll(script, instance, getvaluesfolder, 1)
				Combat_Util.AddStun(script, instance, getvaluesfolder, 1)
			end

			Combat_Util.Knockback(script, instance, humanoidRootPart, v3, 0.25)
		end
	end

	task.wait(1)
end

local function tameHorse(player, state)
	local horse = state.Horse

	if horse == nil then
		return
	end

	state.Tamed = true

	if state.Prompt then
		state.Prompt:Destroy()
		state.Prompt = nil
	end

	local parent = horse.Parent
	local aiSignal = parent and parent:FindFirstChild("AiSignal")
	horse.Parent = workspace.Debree
	task.spawn(function()
		fireTamingVFX(player.Character, horse, "Tamed", nil) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(0.35)

		for _, descendant in horse:GetDescendants() do
			if not ((descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) and descendant.Transparency < 1) then
				continue
			end

			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end

		task.wait(0.35)

		if aiSignal then
			aiSignal:Fire("Died", player)
		end

		if horse.Parent ~= nil then
			horse:Destroy()
		end
	end)
end

local function getOff(p, instance, state, flag: boolean?)
	if state.HorseRideTrack then
		state.HorseRideTrack:Stop()
		state.HorseRideTrack = nil
	end

	if state.PlayerRideTrack then
		state.PlayerRideTrack:Stop()
		state.PlayerRideTrack = nil
	end

	local humanoid = instance and instance:FindFirstChild("Humanoid")
	local playerThrowTrack = playRideAnim(humanoid, script.PlayerGetOff) -- equivalent call inferred; original call site unknown
	state.PlayerThrowTrack = playerThrowTrack

	if playerThrowTrack and instance then
		CharGrabPosCorrector.Do(instance, playerThrowTrack, 1.333, instance)
	end

	task.wait(1.2329999999999999)

	if state.HorseWeld then
		state.HorseWeld:Destroy()
		state.HorseWeld = nil
	end

	task.wait(0.10000000000000009)

	if flag then
		tameHorse(p, state)
	end
end

local function offerHorsePurchase(p)
	local data = Utility.GetData(p)

	if data == nil then
		return false
	end

	if Shop.CanBuy(p, "Horse", data) then
		local formatted = `Would you like to purchase {Utility.NameTag("Horse", true)} for {Shop.GetPriceRichText("Horse")}?`
		local success, result = pcall(function()
			return SignalFunction.ToClient(p, "InferPopup", {
				Type = "Question",
				Content = formatted,
				Timout = 15
			})
		end)

		if not success or result ~= "Yes" or not Shop.CanBuy(p, "Horse", data) then
			return false
		end

		local v, v2 = Item(p, "Horse", nil, false, true, nil, "Shop")

		if v then
			local price = Shop.GetPrice("Horse")

			for k, v3 in price do
				Shop.cashiers[k].Buy(data, v3, p, "Horse")
			end

			return true
		else
			if v2 == "Already exists" then
				SignalEvent.ToClient(p, "Notify", {
					Text = `You already own a {Utility.NameTag("Horse")}`,
					Type = "Denied"
				})
			end

			return false
		end
	else
		local price = Shop.GetPrice("Horse")
		local v = math.max(0, (price and price.Wen or 0) - data.Wen.Value)
		SignalEvent.ToClient(p, "Notify", {
			Text = `Not enough wen to afford {Utility.NameTag("Horse")}, you need {Wen.FormulateTextPlusText(v)} more`,
			Type = "Warn"
		})
		return false
	end
end

function Horse:Stop(p2, state, flag: boolean?, ...)
	fireTamingVFX(p2, state.Horse, "Taming", false) -- equivalent call inferred; original call site unknown

	if state.CamSubject then
		state.CamSubject:Destroy()
		state.CamSubject = nil
	end

	if p2 == nil then
		return true
	end

	if flag == false then
		throwOff(self, p2, state)
	elseif flag == true then
		getOff(self, p2, state, offerHorsePurchase(self))
	end

	return true
end

return Horse