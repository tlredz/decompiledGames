-- failed to load script (decompiled with syntax error):
-- ptSrqfoAWEkiHesEekgEzkkIM:583: Expected identifier when parsing expression, got ';'

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local _ = localPlayer.Character
local parent = script.Parent
local playerbar = parent:WaitForChild("playerbar")
local fish = parent:WaitForChild("fish")
local bar = parent:WaitForChild("progress"):WaitForChild("bar")
local parent2 = parent.Parent
local fx = require(ReplicatedStorage.shared.modules.fx)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local ReelController = require(ReplicatedStorage.client.legacyControllers.ReelController)
require(ReplicatedStorage.packages.Cache)
local Net = require(ReplicatedStorage.packages.Net)
local FTUEController = require(ReplicatedStorage.client.legacyControllers.FTUEController)
local ABResilienceController = require(ReplicatedStorage.client.legacyControllers.ABResilienceController)
local ABGuaranteedLegendaryController = require(ReplicatedStorage.client.legacyControllers.ABGuaranteedLegendaryController)
local fishBehaviors = ReplicatedStorage.shared.modules.FishBehaviors
local remoteEvent = Net:RemoteEvent("ProgressModifier")
local remoteEvent2 = Net:RemoteEvent("ResilienceModifier")
local library = require(ReplicatedStorage.shared.modules.library)
local rods = library.rods
local fish2 = library.fish
local bait = library.bait
local _ = library.enchants
local _ = library.weathers
local enchants = require(ReplicatedStorage.shared.modules.library.rods.enchants)
require(ReplicatedStorage.shared.modules.fishing.BiteTypes)
local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
local jSONDecode = HttpService:JSONDecode(script:WaitForChild("stats").Value)
local v = nil

for k, v2 in jSONDecode do
	if v2 == "inf" then
		jSONDecode[k] = 1e999
	elseif v2 == "-inf" then
		jSONDecode[k] = -1e999
	end
end

local v2 = ReelController.new(parent2, {
	accel = 1,
	bait = script.bait.Value,
	baitres = 0,
	dir = -1,
	fish = {
		Name = script.fish.Value
	},
	fishmove = tick(),
	impulse = 0.5,
	isPaused = false,
	lastimpulse = tick(),
	lastt = tick(),
	movementfactor = 1,
	perfect = true,
	progress = 20,
	progressefficiency = 1,
	ready = false,
	onbar = true,
	resilience = 0,
	rodName = script.rod.Value.Name,
	rodSkin = script.rod:GetAttribute("Skin"),
	start = tick(),
	vel = 0,
	base_seed = script.seed.Value,
	stats = jSONDecode
})
local random = Random.new()

if not v2.rodName then
	warn("No rod provided to fishing minigame...")
	return
end

if not v2.fish then
	warn("No fish provided to fishing minigame...")
	return
end

-- equivalent calls inferred from this helper; original call sites unknown
local function starterCatchABElegible(instance)
	if instance then
		return instance:GetAttribute("AB_StarterCatch") == true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local function round(p: number)
	return math.round(p * 10) / 10
end

remoteEvent.OnClientEvent:Connect(function(p, p2)
	if p == 1 then
		v2:AddModifier("progressefficiency", "add", p2)
	elseif p == 2 then
		v2:AddModifier("progress", "add", p2)
	end
end)
local rod = rods[v2.rodName]
local v3 = fish2[v2.fish.Name]

if rod.InstantCatch then
	v2:AddModifier("progress", "force", 100)
end

local v4 = v2.rodName == "Leviathan's Fang Rod"
local v5 = v2.rodName == "Astralhook Rod"
local v6 = v2.fish.Name == "Scylla"
local v7 = fishBehaviors:FindFirstChild(v2.fish.Name .. "Behavior") or fishBehaviors.BaseFishBehavior

if v7 then
	local module = require(v7)
	v = module.new(script, v2, playerbar, bar, fx, localPlayer)
end

local value, value2

if rodInv:FindFirstChild(script.rod.Value.Name) then
	value = rodInv:FindFirstChild(script.rod.Value.Name).Value
	value2 = rodInv:FindFirstChild(script.rod.Value.Name):FindFirstChild("secondaryEnchant").Value
else
	value = "none"
	value2 = "none"
end

local currentBoosts = enchants:GetCurrentBoosts(value, localPlayer)
local currentBoosts2 = enchants:GetCurrentBoosts(value2, localPlayer)
local v8 = bait[v2.bait]
local child = ReplicatedStorage.shared.modules.LocalPassive:FindFirstChild(script.rod.Value.Name)
local module

if child then
	module = require(child)
	local success, result = pcall(module.Morph, parent, v2)

	if not success and RunService:IsStudio() then
		warn("Error applying rod morph:", result)
	end
else
	module = nil
end

if fish2[v2.fish.Name].Attacks then
	warn("fish has minigame attacks")

	for _, childName in fish2[v2.fish.Name].Attacks do
		local child2 = ReplicatedStorage.shared.modules.LocalMinigameAttacks:FindFirstChild(childName)

		if not child2 then
			continue
		end

		local module2 = require(child2)
		local success, result = pcall(module2.Start, parent, v2)

		if success or not RunService:IsStudio() then
			continue
		end

		warn("Error applying fish attack:", result)
	end
end

v2:AddModifier("accel", "add", 1)

if v6 and v4 then
	v2:AddModifier("resilience", "add", 50)
end

local v9

if ABGuaranteedLegendaryController:IsEligible() then
	v9 = ABGuaranteedLegendaryController:Call()
else
	v9 = false
end

if v9 then
	v2:AddModifier("resilience", "multiply", 2)
end

local resilienceFromAB = ABResilienceController:GetResilienceFromAB()

if resilienceFromAB then
	v2:AddModifier("resilience", "add", resilienceFromAB)
end

remoteEvent2.OnClientEvent:Connect(function(p: number)
	v2:AddModifier("resilience", "multiply", p)
end)

if rod.FixedProgressEfficiency then
	v2:AddModifier("progressefficiency", "force", rod.FixedProgressEfficiency)
end

if v4 and v6 then
	v2:AddModifier("progressefficiency", "force_add", 0.95)
end

if v3 then
	local total = 0
	local total2 = 0

	if v3.CustomProgressEfficiency then
		for _, v10 in v3.CustomProgressEfficiency do
			if v10.Rod then
				if script.rod.Value.Name == v10.Rod then
					total2 += v10.Value
				end
			else
				total += v10.Value
			end
		end

		if total2 == 0 then
			if total ~= 0 then
				v2:AddModifier("progressefficiency", "add", total)
			end
		else
			v2:AddModifier("progressefficiency", "add", total2)
		end
	end
end

if localPlayer:GetAttribute("InAFKFishingZone") then
	if playerbar:FindFirstChild("Rod") then
		playerbar.Rod.Visible = false
	end

	parent.Visible = true
	parent2.Enabled = true
	parent.progressspeed.Visible = true
	parent.progressspeed.Text = "Fishing..."
	parent.fish.Position = UDim2.fromScale(0.5, 0.5)
	playerbar.Position = UDim2.fromScale(0.5, 0.5)
	playerbar.Size = UDim2.fromScale(1, 1)
	bar.Size = UDim2.fromScale(0, playerbar.Size.Y.Scale)
	local tween = TweenService:Create(bar, TweenInfo.new(1), {
		Size = UDim2.fromScale(1, playerbar.Size.Y.Scale)
	})
	tween:Play()
	tween.Completed:Wait()
	v2.OnMinigameEnd:Fire(true, true)
	ReplicatedStorage.events.bindable_reel_finished:Fire(true)
	ReplicatedStorage.events.reelfinished:FireServer(100, true)
else
	parent.Visible = false

	if playerbar:FindFirstChild("Rod") then
		local rod_2 = playerbar:FindFirstChild("Rod")
		rod_2.Visible = script:WaitForChild("rod").Value.Name == "Flimsy Rod"
	end

	if FTUEController.GetReelAssistanceFlag() then
		v2:AddModifier("barSize", "multiply", 1.5)
	end

	local sparkles = fish:WaitForChild("sparkles")
	sparkles.Enabled = script.fish:GetAttribute("Special")

	function UpdateColors()
		if not script.Parent then
			return
		end

		local v10 = math.clamp(v2.progress / 100, 0, 1)
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Color3.new(0.388235, 0.164706, 0.164706):Lerp(Color3.new(0.34902, 0.494118, 0.34902), v10)
			),
			ColorSequenceKeypoint.new(
				0.1,
				Color3.new(0.388235, 0.164706, 0.164706):Lerp(Color3.new(0.34902, 0.494118, 0.34902), v10)
			),
			ColorSequenceKeypoint.new(0.2, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.8, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(
				0.9,
				Color3.new(0.388235, 0.164706, 0.1647062):Lerp(Color3.new(0.34902, 0.494118, 0.34902), v10)
			),
			ColorSequenceKeypoint.new(
				1,
				Color3.new(0.388235, 0.164706, 0.164706):Lerp(Color3.new(0.34902, 0.494118, 0.34902), v10)
			)
		})
		script.Parent.stroke.UIGradient.Color = colorSequence
		parent.licon.ImageColor3 = Color3.new(0.388235, 0.164706, 0.164706):Lerp(
			Color3.new(0.34902, 0.494118, 0.34902),
			v10
		)
		parent.ricon.ImageColor3 = Color3.new(0.388235, 0.164706, 0.164706):Lerp(
			Color3.new(0.34902, 0.494118, 0.34902),
			v10
		)
		bar.Size = UDim2.new(math.clamp(v2.progress / 100, 0, 1), 0, 1, 0)
	end

	local v10 = nil
	local v11 = false
	local v12 = nil

	if v9 then
		v2:AddModifier("progressLossMultiplier", "multiply", 0.5)
	end

	local function canChangeDirection()
		if v and v.ShouldAllowInput then
			return v:ShouldAllowInput()
		end

		return true
	end

	local modifier = v2:CreateModifier("dir", "add")
	modifier.Value = -1
	UserInputService.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA) and (not (v and v.ShouldAllowInput) or v:ShouldAllowInput()) then
			if modifier.Value ~= 1 then
				v2.OnBarDirectionChange:Fire(1)
			end

			modifier.Value = 1
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.fishing.dirchangeright, localPlayer.PlayerGui, true)
			v2.lastt = tick()
			local xboxcontrol = playerbar:WaitForChild("xboxcontrol")
			xboxcontrol.ImageColor3 = Color3.fromRGB(88, 109, 129)
			parent.pc.ImageColor3 = Color3.fromRGB(88, 109, 129)
			local mobile = parent:WaitForChild("mobile")
			mobile.ImageColor3 = Color3.fromRGB(88, 109, 129)

			if (v2.progress > 0.1 and v2.progress < 100 or tick() - v2.start <= 5) and v11 == true then
				if v10 then
					v10:Cancel()
					v10 = nil
				end

				v10 = fastTween(
					workspace.CurrentCamera,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 55
					}
				)

				if v12 then
					v12.Stop()
					v12 = nil
				end

				v12 = fx:ShakeScreen(localPlayer, 1, -1)
			end

			if playerbar.right.Visible == false and playerbar:FindFirstChild("Rod") then
				local tween = TweenService:Create(
					playerbar.Rod.Handle,
					TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0.529, 0, 0.243, 0),
						Rotation = 90
					}
				)
				tween.Completed:Once(function()
					tween:Destroy()
				end)
				tween:Play()
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA) and (not (v and v.ShouldAllowInput) or v:ShouldAllowInput()) then
			if modifier.Value ~= -1 then
				v2.OnBarDirectionChange:Fire(-1)
			end

			modifier.Value = -1
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.fishing.dirchangeleft, localPlayer.PlayerGui, true)
			v2.lastt = tick()
			local xboxcontrol = playerbar:WaitForChild("xboxcontrol")
			xboxcontrol.ImageColor3 = Color3.fromRGB(239, 239, 239)
			parent.pc.ImageColor3 = Color3.fromRGB(239, 239, 239)
			local mobile = parent:WaitForChild("mobile")
			mobile.ImageColor3 = Color3.fromRGB(239, 239, 239)

			if v12 then
				v12.Stop()
				v12 = nil
			end

			v12 = fx:ShakeScreen(localPlayer, 0, -1)

			if (v2.progress > 0.1 and v2.progress < 100 or tick() - v2.start <= 5) and v11 == true then
				if v10 then
					v10:Cancel()
					v10 = nil
				end

				v10 = fastTween(
					workspace.CurrentCamera,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 56
					}
				)
			end

			if playerbar.left.Visible == false and playerbar:FindFirstChild("Rod") then
				local tween = TweenService:Create(
					playerbar.Rod.Handle,
					TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0.48, 0, 0.261, 0),
						Rotation = -90
					}
				)
				tween.Completed:Once(function()
					tween:Destroy()
				end)
				tween:Play()
			end
		end
	end)

	if localPlayer.PlayerGui:FindFirstChild("hud") then
		local hud = localPlayer.PlayerGui:FindFirstChild("hud")
		hud.Enabled = false
	end

	v2:Update(0)
	UpdateColors()
	bar.Size = UDim2.new(0, 0, 1, 0)
	bar.Transparency = 1
	playerbar.Transparency = 1
	fish.Position = UDim2.new(0.5, 0, 0.5, 0)
	local tween = TweenService:Create(playerbar, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0
	})
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	local tween2 = TweenService:Create(bar, TweenInfo.new(1.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(math.clamp(v2.progress / 100, 0, 1), 0, 1, 0),
		Transparency = 0
	})
	tween2.Completed:Once(function()
		tween2:Destroy()
	end)
	tween2:Play()
	local v13 = {
		["Apex Leviathan"] = Color3.fromRGB(0, 157, 255),
		Mosslurker = Color3.fromRGB(68, 255, 0),
		["Bloop Fish"] = Color3.fromRGB(206, 219, 255)
	}
	local v14 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyApexGradients()
		local backgroundColor = v13[script.fish.Value]

		if not backgroundColor then
			return
		end

		v14 = true
		script.Parent.playerbar.BackgroundColor3 = backgroundColor
		local apexGradient = script.Parent.playerbar:FindFirstChild("ApexGradient")

		if apexGradient then
			apexGradient.Enabled = true
		end
	end

	applyApexGradients() -- equivalent call inferred; original call site unknown
	local fishing = ReplicatedStorage.resources.sounds.sfx.fishing
	local fishing2 = ReplicatedStorage.resources.replicated.fishing
	local v15 = {
		["Abyssal Spinecaster"] = {
			fishing:FindFirstChild("stabbystabspinecaster"),
			fishing:FindFirstChild("stabbystabspinecaster2")
		},
		["Mila's Wand Of Magic"] = { fishing:FindFirstChild("stabbystab") },
		["Paper Fan Rod"] = { fishing:FindFirstChild("stabbystabpaperfan") },
		["Dusekkar Rod"] = { fishing:FindFirstChild("stabbystabdusekkar") },
		["Pen Rod"] = { fishing:FindFirstChild("stabbystabpen") },
		["Tetra Rod"] = { fishing:FindFirstChild("stabbystabtetra") },
		["The Brick Rod"] = { fishing:FindFirstChild("stabbstabthebrickrod") },
		["Nates Blade"] = { fishing:FindFirstChild("scream") },
		["Ultratech Rod"] = {
			fishing:FindFirstChild("stabbystabspinecaster"),
			fishing:FindFirstChild("stabbystabspinecaster2")
		}
	}

	local function tridentStab(p, p2, p3)
		if not (localPlayer.Character and localPlayer.Character.HumanoidRootPart) then
			return
		end

		local v16 = p or fishing2.slashes:FindFirstChild(v2.rodName) or fishing2.slashes["Default Slash"]
		local v17 = p2 or v15[v2.rodName] or fishing.stabbystab
		local uIGradient = p3 or fishing2.gradients:FindFirstChild(v2.rodName) or rod.Color or Color3.fromRGB(
			255,
			255,
			255
		)
		local playbackSpeed = random:NextNumber(0.95, 1.1) * (rod.SlashSoundSpeed or 1)

		if typeof(v17) == "table" then
			for _, v19 in v17 do
				local clone = v19:Clone()
				clone.Parent = localPlayer.Character.HumanoidRootPart
				clone.PlaybackSpeed = playbackSpeed
				clone:Play()
				clone.Ended:Once(function()
					clone:Destroy()
				end)
			end
		else
			local clone = v17:Clone()
			clone.Parent = localPlayer.Character.HumanoidRootPart
			clone.PlaybackSpeed = playbackSpeed
			clone:Play()
			clone.Ended:Once(function()
				clone:Destroy()
			end)
		end

		local clone = v16:Clone()
		clone.Size = UDim2.fromScale(0, 0)
		clone.ImageTransparency = 0
		clone.Parent = fish

		if typeof(uIGradient) == "Instance" and uIGradient:IsA("UIGradient") then
			parent.progress.bar.UIGradient.Color = uIGradient.Color
		elseif typeof(uIGradient) == "ColorSequence" then
			parent.progress.bar.UIGradient.Color = uIGradient
		else
			parent.progress.bar.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, parent.progress.bar.BackgroundColor3),
				ColorSequenceKeypoint.new(0.3, uIGradient),
				ColorSequenceKeypoint.new(0.8, uIGradient),
				ColorSequenceKeypoint.new(1, parent.progress.bar.BackgroundColor3)
			})
		end

		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		fastTween(clone, tweenInfo, {
			Size = UDim2.fromScale(10.188, 4.5)
		}) -- equivalent call inferred; original call site unknown
		task.defer(function()
			local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
			local v20 = {
				Offset = Vector2.new(1, 0)
			}
			local tween3 = TweenService:Create(parent.progress.bar.UIGradient, tweenInfo2, v20)
			local vector = Vector2.new(-1, 0)
			parent.progress.bar.UIGradient.Offset = vector
			tween3:Play()
			tween3.Completed:Wait()
			parent.progress.bar.UIGradient.Offset = vector
		end)
		task.delay(tweenInfo.Time, function()
			;(fastTween(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.fromScale(7, 4.75),
				ImageTransparency = 1
			})).Completed:Once(function()
				clone:Destroy()
			end)
		end)
	end

	local function impact(parent3, position: UDim2, p: number, duration: number, flag: boolean?, value3: number?)
		local v16 = 0.8

		for _ = 0, p, duration do
			parent3.Position = position:Lerp(
				position + UDim2.new(random:NextNumber(-0.05, 0.05), 0, random:NextNumber(-0.08, 0.08), 0),
				v16
			)

			if flag then
				parent3.Rotation = math.lerp(0, random:NextNumber(-8, 8), v16)
			end

			v16 *= value3 or 0.9
			task.wait(duration)
		end

		parent3.Position = position
		parent3.Rotation = flag and 0 or parent3.Rotation
	end

	ReplicatedStorage:WaitForChild("events"):WaitForChild("debug_hammerhit").OnClientEvent:Connect(function(value3)
		v2:AddProgress(value3 or 30)
		impact(parent, parent.Position, 0.8, 0.025, true)
	end)
	ReplicatedStorage:WaitForChild("events"):WaitForChild("debug_swordhit").OnClientEvent:Connect(function(value3, p)
		if p then
			task.spawn(function()
				for _ = 1, 10 do
					task.wait(0.1)
					v2:AddProgress(10)
				end
			end)
		else
			v2:AddProgress(value3 or 99)
		end

		impact(parent, parent.Position, 0.8, 0.02, not p)
	end)
	ReplicatedStorage:WaitForChild("events"):WaitForChild("debug_daggerhit").OnClientEvent:Connect(function()
		v2:AddProgress(55)
	end)
	ReplicatedStorage:WaitForChild("events"):WaitForChild("debug_guitar").OnClientEvent:Connect(function(p)
		v2:AddProgress(p and 10 or 5)
	end)
	ReplicatedStorage:WaitForChild("events"):WaitForChild("debug_giveprogress").OnClientEvent:Connect(function(p)
		v2:AddProgress(p)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ftueProgressBoost()
		print("entering ftue tutorial mode")
		v2:AddProgress(50)
		v2:AddModifier("progressLossMultiplier", "multiply", 0.4)
	end

	local function voyagerLaser(p: number, p2: number?)
		task.spawn(impact, parent, parent.Position, 3, 0.025, true, 0.97)

		for _ = 1, 40 do
			v2:AddProgress(p, p2)
			task.wait(0.075)
		end
	end

	ReplicatedStorage:WaitForChild("events"):WaitForChild("voyagerlaser").OnClientEvent:Connect(function()
		coroutine.wrap(voyagerLaser)(0.5, 60)
	end)
	ReplicatedStorage:WaitForChild("events"):WaitForChild("mikulaser").OnClientEvent:Connect(function()
		coroutine.wrap(voyagerLaser)(0.5, 99)
	end)
	ReplicatedStorage:WaitForChild("events"):WaitForChild("seraphiclaser").OnClientEvent:Connect(function()
		task.spawn(function()
			parent.progress.Seraphic.Visible = true

			for _ = 1, 3 do
				local clone = parent.progress.Seraphic:Clone()
				clone.Name = "SeraphicClone"
				clone.Parent = parent.progress
				local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				fastTween(clone, tweenInfo, {
					ImageTransparency = 1
				}) -- equivalent call inferred; original call site unknown
				fastTween(clone.UIScale, tweenInfo, {
					Scale = 1.5
				}) -- equivalent call inferred; original call site unknown
				task.delay(tweenInfo.Time, function()
					if clone then
						clone:Destroy()
					end
				end)
				task.wait(1)
				fastTween(parent.progress.Seraphic, tweenInfo, {
					ImageTransparency = 1
				}) -- equivalent call inferred; original call site unknown
				task.delay(tweenInfo.Time, function()
					if parent.progress.Seraphic then
						parent.progress.Seraphic.Visible = false
						parent.progress.Seraphic.ImageTransparency = 0
					end
				end)
			end
		end)
		coroutine.wrap(voyagerLaser)(1, 60)
	end)

	if localPlayer.Character and localPlayer.Character.HumanoidRootPart:FindFirstChild("reeling") then
		local reeling = localPlayer.Character.HumanoidRootPart:FindFirstChild("reeling")
		reeling.Volume = 0.08
	end

	local tween3 = TweenService:Create(
		workspace.CurrentCamera,
		TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			FieldOfView = 56
		}
	)
	tween3.Completed:Once(function()
		tween3:Destroy()
	end)
	tween3:Play()

	if modifier.Value < 0 then
		if playerbar.left.Visible == false then
			local tween4 = TweenService:Create(
				playerbar.Rod.Handle,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.new(0.48, 0, 0.261, 0),
					Rotation = -90
				}
			)
			tween4.Completed:Once(function()
				tween4:Destroy()
			end)
			tween4:Play()
		end
	elseif playerbar.right.Visible == false then
		local tween4 = TweenService:Create(
			playerbar.Rod.Handle,
			TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0.529, 0, 0.243, 0),
				Rotation = 90
			}
		)
		tween4.Completed:Once(function()
			tween4:Destroy()
		end)
		tween4:Play()
	end

	local function UpdateInputUI()
		if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			local xboxcontrol = parent.playerbar:WaitForChild("xboxcontrol")
			xboxcontrol.Visible = true
			parent.pc.Visible = false
			parent.mobile.Visible = false
		elseif UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard or UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton1 then
			parent.pc.Visible = true
			local xboxcontrol_2 = parent.playerbar:WaitForChild("xboxcontrol")
			xboxcontrol_2.Visible = false
			parent.mobile.Visible = false
		else
			if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
				parent.mobile.Visible = true
				parent.pc.Visible = false
			else
				parent.mobile.Visible = false
				parent.pc.Visible = true
			end

			local xboxcontrol_3 = parent.playerbar:WaitForChild("xboxcontrol")
			xboxcontrol_3.Visible = false
		end
	end

	UserInputService.LastInputTypeChanged:Connect(UpdateInputUI)
	local Players2 = game:GetService("Players")
	local localPlayer2 = Players2.LocalPlayer
	local tracker_fishcaught = stats.tracker_fishcaught
	local v16 = starterCatchABElegible(localPlayer2) -- equivalent call inferred; original call site unknown

	if v16 and tracker_fishcaught.Value < 3 then
		v2:AddModifier("progressLossMultiplier", "multiply", 0.25)
	end

	if tracker_fishcaught.Value < 20 then
		v2:AddModifier("minBarSize", "force", 0.5)
	end

	v2:Update(0)
	v2.OnLoad:Fire()
	v2:Update(0)
	v2:UpdateUI(0)
	bar.Size = UDim2.fromScale(0, 1)
	UpdateInputUI()
	task.wait(0.8)
	UpdateInputUI()
	v2:Update(0)
	v2:UpdateUI(0)
	local shiny = script.fish:GetAttribute("Shiny")
	local sparkling = script.fish:GetAttribute("Sparkling")
	task.spawn(function()
		if not (shiny or sparkling) then
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, localPlayer.PlayerGui, false)
			return
		end

		local frame = Instance.new("Frame")
		frame.Name = "SpecialContainer"
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 0.175)
		frame.AnchorPoint = Vector2.new(0, 0.5)
		frame.Position = UDim2.fromScale(0, 0.5)
		frame.BackgroundTransparency = 1
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.Padding = UDim.new(0.05, 0)
		uIListLayout.Parent = frame
		frame.Parent = parent.Parent

		local function createStar(image, imageColor)
			local clone = script.Shiny:Clone()
			clone.Parent = frame
			clone.Image = image
			clone.ImageColor3 = imageColor
			clone.Size = UDim2.fromScale(1, 1)
			clone.ImageTransparency = 0
			local clone2 = clone:Clone()
			clone2.Position = UDim2.fromScale(0.5, 0.5)
			clone2.Size = UDim2.fromScale(1, 1)
			clone2.Parent = clone
			fastTween(clone2, TweenInfo.new(0.5), {
				Size = UDim2.fromScale(1.5, 1.5),
				ImageTransparency = 1
			}) -- equivalent call inferred; original call site unknown
			fastTween(clone, TweenInfo.new(1), {
				ImageTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end

		if shiny then
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.shiny, localPlayer.PlayerGui, false)
			local frame2 = Instance.new("Frame")
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Rotation = 90
			uIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0)
			})
			uIGradient.Parent = frame2
			frame2.BackgroundTransparency = 1
			frame2.BackgroundColor3 = Color3.fromRGB(255, 225, 134)
			frame2.Size = UDim2.fromScale(1, 1)
			frame2.BorderSizePixel = 0
			frame2.Parent = localPlayer.PlayerGui:WaitForChild("over")
			fastTween(frame2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				BackgroundTransparency = 0.6
			}) -- equivalent call inferred; original call site unknown
			task.wait(0.3)
			frame2:Destroy()
			createStar("rbxassetid://115495107196442", Color3.fromRGB(255, 225, 134))
		end

		if sparkling then
			createStar("rbxassetid://129869580684051", Color3.fromRGB(255, 184, 126))

			if not shiny then
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.shine, localPlayer.PlayerGui, false)
			end
		end

		task.delay(2, function()
			frame:Destroy()
		end)
	end)
	v11 = true
	parent.Visible = true
	parent2.Enabled = true
	task.wait(1.2)
	v2:Update(0)
	v2:UpdateUI(0)
	local random2 = v2:GetRandom(1)
	local random3 = v2:GetRandom(2)
	local random4 = v2:GetRandom(3)
	local random5 = v2:GetRandom(4)
	local postSimulationConnection = nil

	if not localPlayer.Character:GetAttribute("Reeling") then
		localPlayer.Character:GetAttributeChangedSignal("Reeling"):Wait()
	end

	v2.start = tick()
	local now = 0

	if FTUEController.GetReelTutorialFlag() then
		ftueProgressBoost() -- equivalent call inferred; original call site unknown
	end

	local v17, v18

	if FTUEController.shouldRightPull() then
		v17 = true
		v18 = 1
	else
		v17 = false
		v18 = 0
	end

	local v19

	if FTUEController.NoFailDuration > 0 then
		v19 = true
		task.delay(FTUEController.NoFailDuration, function()
			v19 = false
		end)
	else
		v19 = true
	end

	if workspace:GetAttribute("PoseidonWrathActive") and script.zone.Value == "Poseidon Pool" then
		v2:AddModifier("moveIntervalFactor", "multiply", 2)
	end

	local total = 0
	local v20 = nil
	local v21 = nil
	local v22 = false

	if value2 == "Cryogenic" then
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script.FrostImg })
		task.delay(1, function()
			if not v22 then
				v22 = true

				if random4:NextInteger(1, 5) == 1 then
					v2:FreezeFish(1e999)
					local GuiService = game:GetService("GuiService")
					local guiInset = GuiService:GetGuiInset()
					local clone = script.FrostImg:Clone()
					clone.Size = UDim2.new(1, guiInset.X, 1, guiInset.Y)
					clone.Parent = parent2
					TweenService:Create(clone.CryogenicFlash, TweenInfo.new(3, Enum.EasingStyle.Linear), {
						BackgroundTransparency = 1
					}):Play()
					TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Linear), {
						ImageTransparency = 0.5
					}):Play()
					ReplicatedStorage.resources.sounds.sfx.ui.cryogenic:Play()
				end
			end
		end)
	end

	local modifier2 = v2:CreateModifier("vel", "add")
	local modifier3 = v2:CreateModifier("impulse", "add")
	local modifier4 = v2:CreateModifier("progress", "add")
	modifier4.Value = 20
	v2:Update(0)
	v2:UpdateUI(0)
	local v23 = nil
	v2.ready = true
	v2.OnReady:FireDeferred()
	postSimulationConnection = RunService.PostSimulation:Connect(function(dt)
		if v2.isPaused then
			return
		end

		local _ = os.clock() - now
		now = os.clock()
		total += dt
		local v24 = math.clamp(v2.resilience / 100, 0.2, 9999)

		if (v19 or v2.progress > 0.1) and v2.progress < 100 or tick() - v2.start <= 1 then
			local v25 = math.max(1, (math.abs(v2.accel)))
			modifier2.Value = math.clamp(
				v2.vel + v2.dir * v2.accel * (tick() - v2.lastt) * (dt * 60),
				v25 * -14,
				v25 * 14
			)
			local v26 = v2.minBarPosition + v2.barSize / 2
			local v27 = v2.maxBarPosition - v2.barSize / 2

			if v27 < v26 then
				v27 = v26
			end

			v2.barPosition = math.clamp(v2.barPosition + v2.vel * 0.001 * (dt * 60), v26, v27)

			if tick() - v2.lastimpulse >= 0.5 then
				modifier3.Value = 0.5
			end

			if v2.barPosition <= v2.barSize / 2 and modifier2.Value < 0 or v2.barPosition >= 0.999999 - v2.barSize / 2 and modifier2.Value > 0 then
				local value3 = modifier2.Value
				modifier2.Value *= -v2.impulse
				modifier3.Value /= 2

				if tick() - v2.lastimpulse > 0.1 then
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.bounce, localPlayer.PlayerGui, true)
					v2.OnBarBounce:Fire(v2.barPosition > 0.5, value3)
				end

				v2.lastimpulse = tick()
			end

			local onbar = v2.onbar

			if v2:IsInBar(fish.Position.X.Scale, fish.Size.X.Scale) then
				if not onbar then
					v2.OnFishEnterBar:Fire()
				end

				v2.onbar = true
				playerbar.BackgroundTransparency = 0

				if not v14 then
					playerbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				end

				local v28 = 0.2 * (rod.OnWhiteBarInfluence or 1)
				modifier4.Value += v28 * v2.progressefficiency * (dt * 60)
			else
				if onbar then
					v2.OnFishExitBar:Fire()
				end

				v2.onbar = false
				playerbar.BackgroundTransparency = 0.2

				if not v14 then
					playerbar.BackgroundColor3 = Color3.new(0.388235, 0.164706, 0.164706):Lerp(
						Color3.new(0.34902, 0.494118, 0.34902),
						v2.progress / 100
					)
				end

				modifier4.Value -= (0.2 * (dt * 60) + (tick() - v2.start) * (v24 * 0.0017)) * v2.progressLossMultiplier
				v2.perfect = false
			end

			if localPlayer.Character and localPlayer.Character.HumanoidRootPart:FindFirstChild("reeling") then
				local reeling = localPlayer.Character.HumanoidRootPart:FindFirstChild("reeling")
				reeling.Volume = v2.onbar and 0.15 or 0.08
				local reeling_2 = localPlayer.Character.HumanoidRootPart:FindFirstChild("reeling")
				reeling_2.PlaybackSpeed = math.clamp(v2.progress / 100, 0.8, 1.2) + 0.1
			end

			UpdateColors()

			if v5 then
				local now2 = os.clock()

				if v20 == nil then
					v20 = now2
				end

				if v21 == nil then
					v21 = random5:NextNumber() * 2 + 2
				end

				local v28 = now2 - v20

				if v21 <= v28 then
					v20 = now2
					v21 = random5:NextNumber() * 2 + 2
					v2:AddProgress(15)
					local character = localPlayer2.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local clone = ReplicatedStorage.resources.replicated.fishing.AstralStars:Clone()
						clone.Parent = workspace
						clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 5, 0))
						local Debris = game:GetService("Debris")
						Debris:AddItem(clone, v21)
						ReplicatedStorage.resources.sounds.sfx.astralhook.starsfalling:Play()
					end
				end
			end

			if tick() - v2.fishmove > random2:NextInteger(v24 * 20, v24 * 51) / (10 * v2.moveIntervalFactor) then
				local v29 = starterCatchABElegible(localPlayer2) -- equivalent call inferred; original call site unknown

				if not (v29 and tracker_fishcaught.Value < 3) then
					if value == "Chronos" and total >= 2.5 then
						total = 0

						if random4:NextInteger(1, 2) == 1 then
							v2:FreezeFish(3)
							local clone = script.ChronosFlash:Clone()
							clone.Parent = parent2
							local tween4 = TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Linear), {
								BackgroundTransparency = 1
							})
							tween4:Play()
							tween4.Completed:Once(function()
								clone:Destroy()
							end)
							ReplicatedStorage.resources.sounds.sfx.ui.chronos:Play()
							task.spawn(impact, parent, parent.Position, 0.5, 0.01, false, 0.75)
						end
					end

					if v2.frozenUntil > tick() then
						v2:Update(dt)
						v2:UpdateUI(dt)

						if v23 and v23.PlaybackState == Enum.PlaybackState.Playing then
							v23:Pause()
						end

						return
					else
						if v23 and v23.PlaybackState == Enum.PlaybackState.Paused then
							v23:Play()
						end

						if v then
							v:Update(dt)
						end

						if currentBoosts and currentBoosts.SlashChance and random3:NextNumber(0, 100) <= currentBoosts.SlashChance then
							v2.fishmove = tick() + 0.35
							tridentStab()
							local slashDamage = currentBoosts.SlashDamage or 6
							v2:AddProgress(slashDamage)
							v2.OnSlash:Fire(slashDamage, "enchant", value)
						elseif currentBoosts2 and currentBoosts2.SlashChance and random3:NextNumber(0, 100) <= currentBoosts2.SlashChance then
							v2.fishmove = tick() + 0.35
							tridentStab()
							local slashDamage = currentBoosts2.SlashDamage or 6
							v2:AddProgress(slashDamage)
							v2.OnSlash:Fire(slashDamage, "secondaryEnchant", value2)
						elseif fishing2.slashes:FindFirstChild(v2.rodName) and random3:NextNumber(0, 100) <= (rod.SlashChance or 25) then
							v2.fishmove = tick() + 0.35
							tridentStab()
							local slashDamage = rod.SlashDamage or 6
							v2:AddProgress(slashDamage)
							v2.OnSlash:Fire(slashDamage, "rod", v2.rodName)
						elseif v8 and v8.SlashChance and random3:NextNumber(0, 100) <= v8.SlashChance * jSONDecode.BaitEffectiveness then
							v2.fishmove = tick() + 0.35
							tridentStab()
							local v30 = (v8.SlashDamage or 6) * jSONDecode.BaitEffectiveness
							v2:AddProgress(v30)
							v2.OnSlash:Fire(v30, "bait", v2.bait)
						else
							local v30

							if fish.Position.X.Scale >= 0.95 and (not v17 or math.random() < 0.2) then
								v30 = math.clamp(
									fish.Position.X.Scale - random2:NextInteger(9, 32) / 100 * math.clamp(v24, 0.8, 1.4),
									0.03,
									0.9
								)
							elseif fish.Position.X.Scale <= 0.05 then
								v30 = math.clamp(
									fish.Position.X.Scale + random2:NextInteger(9, 32) / 100 * math.clamp(v24, 0.8, 1.4),
									0.03,
									0.9
								)
							else
								local v31 = (random2:NextNumber(-40, 40) + v18 * 40) * v2.moveIntervalFactor
								v30 = math.clamp(
									fish.Position.X.Scale + v31 / 100 * math.clamp(v24, 0.8, 1.2),
									0.03,
									v17 and 1 or 0.9
								)
							end

							local v31 = random2:NextNumber(13, 35) * math.clamp(v24, 0.1, 1.5) / 10 * v2.movementfactor
							v2.OnFishMove:Fire(v30, v31)
							v23 = fastTween(fish, TweenInfo.new(v31, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Position = UDim2.new(v30, 0, 0.5, 0)
							})
							v2.fishmove = tick()
						end
					end
				end
			end

			v2:Update(dt)
			v2:UpdateUI(dt)
		else
			local progress = v2.progress
			v2:Update(dt)
			v2:UpdateUI(dt)

			if child and module and module.Cleanup then
				task.spawn(module.Cleanup)
			end

			if v then
				v:Destroy()
				v = nil
			end

			for _, sound in localPlayer2.PlayerGui:GetChildren() do
				if not (sound:IsA("Sound") and table.find({ "dirchangeleft", "dirchangeright", "bounce" }, sound.Name)) then
					continue
				end

				sound:Destroy()
			end

			postSimulationConnection:Disconnect()

			if v10 then
				v10:Cancel()
				v10 = nil
			end

			if localPlayer.PlayerGui:FindFirstChild("hud") then
				local hud = localPlayer.PlayerGui:FindFirstChild("hud")
				hud.Enabled = true
			end

			if progress >= 100 then
				local tween4 = TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				)
				tween4.Completed:Once(function()
					tween4:Destroy()
				end)
				tween4:Play()
			else
				local tween4 = TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 1),
					{
						FieldOfView = 70
					}
				)
				tween4.Completed:Once(function()
					tween4:Destroy()
				end)
				tween4:Play()
			end

			if progress >= 100 then
				ABResilienceController:OnSuccess()
			end

			v2.OnMinigameEnd:Fire(progress >= 100, v2.perfect)
			ReplicatedStorage.events.bindable_reel_finished:Fire(progress >= 100)
			ReplicatedStorage.events.reelfinished:FireServer(progress, v2.perfect)
			v2:Destroy()
		end
	end)
	local character = localPlayer2.Character or localPlayer2.CharacterAdded:Wait()

	local function HardClear()
		if postSimulationConnection.Connected then
			postSimulationConnection:Disconnect()
		end

		if v10 then
			v10:Cancel()
			v10 = nil
		end

		if localPlayer.PlayerGui:FindFirstChild("hud") then
			local hud = localPlayer.PlayerGui:FindFirstChild("hud")
			hud.Enabled = true
		end

		ReplicatedStorage.events.bindable_reel_finished:Fire(v2.progress >= 100)
		ReplicatedStorage.events.reelfinished:FireServer(v2.progress, v2.perfect)
		v2:Destroy()
	end

	if character:FindFirstChildOfClass("Tool") then
		local childRemovedConnection = nil
		childRemovedConnection = character.ChildRemoved:Connect(function(tool)
			if tool:IsA("Tool") then
				childRemovedConnection:Disconnect()
				childRemovedConnection = nil
				HardClear()
			end
		end)
	else
		HardClear()
	end
end