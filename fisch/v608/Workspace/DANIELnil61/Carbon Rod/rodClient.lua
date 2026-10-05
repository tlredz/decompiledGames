local createVector = vector.create

if not game:IsLoaded() then
	game.Loaded:Wait()
end

function dprint(...)
	local v = { ... }

	if #v > 1 then
		print(table.concat(v, " "), (`({script.Name}:{debug.info(2, "l")})`))
	else
		print(v[1], (`({script.Name}:{debug.info(2, "l")})`))
	end
end

function dwarn(...)
	local v = { ... }

	if #v > 1 then
		warn(table.concat(v, " "), (`({script.Name}:{debug.info(2, "l")})`))
	else
		warn(v[1], (`({script.Name}:{debug.info(2, "l")})`))
	end
end

local CollectionService = game:GetService("CollectionService")
game:GetService("GamepadService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local animator = humanoid and humanoid:WaitForChild("Animator")
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

if not (humanoid and humanoidRootPart and animator) then
	print("Cancelled rod/client loading due to no Humanoid or HumanoidRootPart")
	return
end

local parent = script.Parent
parent.RequiresHandle = false

if not (parent and parent.Parent) then
	print("Cancelled rod/client loading due to invalid fishing rod tool")
	return
end

if not (parent:IsDescendantOf(localPlayer) or parent:IsDescendantOf(character)) then
	print("Cancelled rod/client loading due to misplaced fishing rod tool")
	return
end

parent:WaitForChild("events")
local values = parent:WaitForChild("values")
local client = ReplicatedStorage:WaitForChild("client")
local shared = ReplicatedStorage:WaitForChild("shared")
local packages = ReplicatedStorage:WaitForChild("packages")
local legacyControllers = client:WaitForChild("legacyControllers")
local modules = client:WaitForChild("modules")
local modules2 = shared:WaitForChild("modules")
require(legacyControllers:WaitForChild("ABTests"):WaitForChild("ABTestController"))
require(legacyControllers:WaitForChild("PlayerController"))
local SettingsController = require(legacyControllers:WaitForChild("SettingsController"))
local ReelController = require(legacyControllers:WaitForChild("ReelController"))
require(legacyControllers:WaitForChild("Rods"):WaitForChild("PowerFeedbackController"))
local DataController = require(legacyControllers:WaitForChild("DataController"))
require(modules2:WaitForChild("character"))
local debris = require(modules2:WaitForChild("fx"):WaitForChild("debris"))
require(modules2:WaitForChild("fishing"))
local fx = require(modules2:WaitForChild("fx"))
local Input = require(packages:WaitForChild("Input"))
require(packages:WaitForChild("PID"))
local Net = require(packages:WaitForChild("Net"))
local Trove = require(packages:WaitForChild("Trove"))
local legacyLocalPlayerData = require(modules:WaitForChild("legacyLocalPlayerData"))
local EnchantReminder = require(modules:WaitForChild("EnchantReminder"))
local library = require(modules2:WaitForChild("library"))
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local BiteTypes = require(modules2.fishing.BiteTypes)
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local DeferredSignalHackaround = require(ReplicatedStorage.shared.modules.DeferredSignalHackaround)
local maid = Trove.new()
local maid2 = maid:Extend()
local random = Random.new()
DeferredSignalHackaround.OnceAsync(script.Destroying, maid:WrapClean())
local playerDataReplicator = DataController.PlayerDataReplicator
playerDataReplicator:WaitForLoaded()
local fetched = legacyLocalPlayerData.fetch()
local rods = playerDataReplicator.Data.Rods
local stats = fetched:WaitForChild("Stats")
local bait = stats:WaitForChild("bait")
local rod = stats:WaitForChild("rod")
local resources = ReplicatedStorage:WaitForChild("resources")
local animations = resources:WaitForChild("animations")
local replicated = resources:WaitForChild("replicated")
local sounds = resources:WaitForChild("sounds")
local fishing = animations:WaitForChild("fishing")
local fishing2 = replicated:WaitForChild("fishing")
local fx2 = replicated:WaitForChild("fx")
local sfx = sounds:WaitForChild("sfx")
local remoteFunction = Net:RemoteFunction("FishingRod/Cast", -1)
local remoteEvent = Net:RemoteEvent("FishingRod/HandleBobber", -1)
local remoteEvent2 = Net:RemoteEvent("FishingRod/BreakBobber", -1)
local remoteEvent3 = Net:RemoteEvent("FishingRod/Reset", -1)
local backpack = playerGui:WaitForChild("backpack")
local fishButtonMobile = playerGui:WaitForChild("FishButtonMobile")
local hud = playerGui:WaitForChild("hud")
local button = fishButtonMobile:WaitForChild("Frame"):WaitForChild("button")
local gamepadFishingTips = hud:WaitForChild("safezone"):WaitForChild("GamepadFishingTips")
local preferredInput = Input.PreferredInput
local v = {}
local v2 = {
	power = 10
}

-- equivalent calls inferred from this helper; original call sites unknown
local function ABEligible(_: boolean)
	if tostring(preferredInput.Current) == "Touch" then
		return SettingsController:GetSettingValue("mobileCastButton")
	end
end

local function hasBobber()
	return parent:FindFirstChild("bobber")
end

local function isAlive()
	return humanoid.Health > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSwimming()
	return humanoid:GetState() == Enum.HumanoidStateType.Swimming
end

local function stopAnims()
	local handle = parent:FindFirstChild("handle")
	local idle = handle:FindFirstChild("idle")
	local animationId = idle and idle:IsA("Animation") and idle.AnimationId

	for _, v3 in humanoid:GetPlayingAnimationTracks() do
		if not (v3.Name and fishing:FindFirstChild(v3.Name)) then
			continue
		end

		local v4 = v3.Animation and v3.Animation.AnimationId == animationId and true or handle:FindFirstChild(v3.Name) and handle:FindFirstChild(v3.Name).AnimationId == animationId

		if v3.Name == "idle" or v3.Name == "walk" or v4 then
			if not v2.equipped then
				v3:Stop()
			end
		else
			v3:Stop()
		end
	end
end

local function reset()
	v2.hasQuickSelectedFirst = false
	stopAnims()
	character:SetAttribute("FishingWalkSpeed", nil)
	character:SetAttribute("FishingJumpPower", nil)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, not localPlayer:GetAttribute("InAFKFishingZone"))

	if v.FovTween then
		v.FovTween:Cancel()
	end

	character:SetAttribute("Fishing", nil)
	v.FovTween = TweenService:Create(
		currentCamera,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			FieldOfView = 70
		}
	):Play()
	local v3 = fishButtonMobile
	local aBEligible = ABEligible() -- equivalent call inferred; original call site unknown
	v3.Enabled = aBEligible and v2.equipped
end

local function UIUpdate()
	local hotbar = backpack:FindFirstChild("hotbar")
	local hotbarFolder = hotbar and hotbar:FindFirstChild("Folder")
	local hotbarFolderFrame = hotbarFolder and hotbarFolder:FindFirstChild("Frame")

	if not hotbarFolderFrame then
		print("Cancelled UIUpdate: Could not find hotbar frame")
		return
	end

	for _, childName in { "bait", "powerbar" } do
		local child = hotbarFolderFrame:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	EnchantReminder.Clear(hotbarFolderFrame, "rod")
	local value = bait.Value
	local value2

	if value then
		if value:lower() == "none" then
			value2 = false
		else
			value2 = bait:WaitForChild("bait_" .. value).Value
		end
	else
		value2 = value
	end

	local clone

	if bait and value and library.bait[value] then
		if not script:FindFirstChild("baittitle") then
			return
		end

		clone = script:WaitForChild("baittitle"):Clone()
		clone.Name = "bait"
		local rarity = library.rarities.Rarities[library.bait[value].Rarity]

		if rarity.ColorGradient then
			clone.Text = `Current Bait: <b>{FischUtils.GradientRichText(value, rarity.ColorGradient)}</b> [×{NumberUtils:Comma(value2)}]`
		else
			clone.Text = `Current Bait: <b><font color="#{rarity and rarity.Color:ToHex()}">{value}</font></b> [×{NumberUtils:Comma(value2)}]`
		end

		clone.Parent = hotbarFolderFrame
		clone.Visible = parent.Parent == character
	end

	local value3 = rod.Value
	local v3 = value3 and rods[value3]

	if not v3 then
		print("Cancelled UIUpdate: Rod not in inventory")
		return
	end

	local keeperboundEnchant

	if v3.keeperboundActive then
		keeperboundEnchant = v3.keeperboundEnchant
	else
		keeperboundEnchant = v3.enchant
	end

	local secondaryEnchant

	if not v3.keeperboundActive then
		secondaryEnchant = v3.secondaryEnchant
	end

	local v4 = not v3.keeperboundActive and {} or v3.keeperboundAffixes or {}
	local entries = {
		{
			Name = keeperboundEnchant
		},
		{
			Name = secondaryEnchant,
			Size = UDim2.fromScale(1, 0.27)
		}
	}

	for _, name in v4 do
		table.insert(entries, {
			Name = name,
			Size = UDim2.fromScale(1, 0.25)
		})
	end

	local render = EnchantReminder.Render
	local v6 = {
		Frame = hotbarFolderFrame,
		Prefix = "rod",
		Enchants = library.enchants,
		Entries = entries,
		Visible = parent.Parent == character,
		FirstPosition = 0
	}
	local firstPosition

	if not clone then
		firstPosition = script.baittitle.Position
	end

	v6.FirstPosition = firstPosition
	render(v6)

	if v3.keeperboundActive and v3.power then
		local clone2 = script.powerbar:Clone()
		clone2.bar.powerLabel.Text = `{math.floor(v3.power * 10) / 10}% Power`
		clone2.bar.fill.Size = UDim2.fromScale(v3.power / 100, 1)
		clone2.Visible = parent.Parent == character
		clone2.Parent = hotbarFolderFrame
	end
end

local function validateInput(p)
	if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch or p.KeyCode == Enum.KeyCode.ButtonR2 then
		return true
	end
end

local tagged = CollectionService:GetTagged("PartWater")
CollectionService:GetInstanceAddedSignal("PartWater"):Connect(function()
	tagged = CollectionService:GetTagged("PartWater")
end)
CollectionService:GetInstanceRemovedSignal("PartWater"):Connect(function()
	tagged = CollectionService:GetTagged("PartWater")
end)

local function isPointInVolume(position: Vector3, cFrame: CFrame, vector2: Vector3)
	local pointToObjectSpace = cFrame:PointToObjectSpace(position)
	return pointToObjectSpace.X >= -vector2.X / 2 and pointToObjectSpace.X <= vector2.X / 2 and pointToObjectSpace.Y >= -vector2.Y / 2 and pointToObjectSpace.Y <= vector2.Y / 2 and pointToObjectSpace.Z >= -vector2.Z / 2 and pointToObjectSpace.Z <= vector2.Z / 2
end

local PID = require(ReplicatedStorage.packages.PID)
local v3 = PID.new(-16, 16, 32, 1, 0.2)

local function handleBobber()
	local bobber = parent:WaitForChild("bobber", 5)

	if not bobber then
		return
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(0, 0, 0)
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.Parent = bobber
	task.wait(0.25)

	while bobber and bobber.Parent and bobber:IsDescendantOf(workspace) do
		local v4 = task.wait()

		if not bobber:IsDescendantOf(workspace) then
			break
		end

		local v5 = nil

		for _, v7 in tagged do
			if not isPointInVolume(bobber.CFrame.Position, v7.CFrame, v7.Size + createVector(0, 1.5, 0)) then
				continue
			end

			v5 = v7
			break
		end

		if v5 then
			bodyVelocity.MaxForce = Vector3.new(
				32 + bobber.AssemblyMass * 32,
				1000000000,
				32 + bobber.AssemblyMass * 32
			)
			local v7 = v5.CFrame.Y + v5.Size.Y / 2
			bodyVelocity.Velocity = Vector3.new(0, v3:Calculate(v7, bobber.CFrame.Y, v4), 0)
		else
			bodyVelocity.Velocity = createVector(0, 0, 0)
			bodyVelocity.MaxForce = createVector(0, 0, 0)
		end
	end
end

remoteEvent.OnClientEvent:Connect(handleBobber)
remoteEvent2.OnClientEvent:Connect(reset)
local v4 = 0
maid:Add(function()
	if v.powering then
		v.powering:Stop()
	end

	if v.FovTween then
		v.FovTween:Cancel()
	end
end)

local function getSound(p: string, p2)
	if not parent:FindFirstChild("handle") then
		return p2
	end

	local sounds2 = {}

	for _, sound in parent.handle:GetChildren() do
		if not sound:IsA("Sound") or not sound.Name:match((`^{p}%d*$`)) or sound:GetAttribute("temp") then
			continue
		end

		table.insert(sounds2, sound)
	end

	if #sounds2 > 0 then
		return sounds2[math.random(1, #sounds2)]
	end

	return p2
end

local function handleInput(input, flag: boolean?, flag2: boolean?)
	if workspace:GetAttribute("ClientCutsceneRunning") or (not (humanoid.Health > 0) or humanoid:GetState() == Enum.HumanoidStateType.Swimming) or localPlayer:GetAttribute("RodEquipInProgress") then
		return
	end

	if localPlayer:GetAttribute("BlockCast") or v4 > tick() or fishButtonMobile.Enabled and not flag2 then
		return
	end

	if parent.Parent and parent.Parent:IsA("Model") and (values.casted.Value or values.state.Value < BiteTypes.RodState.Casting) and (backpack.Enabled or not localPlayer:GetAttribute("UiEnabled")) then
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2) and (not flag or v2.isFishButtonMobile) then
			v2.startingcast = true
			v2.mb1down = true
			v4 = math.max(tick() + 0.5, v4)
			local handle = parent:FindFirstChild("handle")
			local disabledAnimations = handle:FindFirstChild("disabledAnimations")

			if not (disabledAnimations and disabledAnimations:GetAttribute("casthold")) then
				local casthold

				if handle:FindFirstChild("casthold") and handle.casthold:IsA("Animation") then
					casthold = handle.casthold
				else
					casthold = fishing.casthold
				end

				if not v.powering then
					v.powering = animator:LoadAnimation(casthold)
					v.powering.Priority = Enum.AnimationPriority.Action2
				end

				v.powering:Play(0.3)
			end

			maid2:Add(function()
				if not ReelController.ActiveReel then
					backpack.Enabled = true
				end

				if v.powering then
					v.powering:Stop()
				end
			end)
			task.wait(0.1)

			if v2.mb1down == true and parent.Parent:IsA("Model") and Players:FindFirstChild(parent.Parent.Name) then
				if v.FovTween then
					v.FovTween:Cancel()
				end

				v.FovTween = TweenService:Create(
					currentCamera,
					TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						FieldOfView = 55
					}
				)
				v.FovTween:Play()
				backpack.Enabled = false
				local clone = nil
				local v5 = math.random(15, 30) / 10
				character:SetAttribute("Fishing", true)
				character:SetAttribute("FishingWalkSpeed", 4)
				character:SetAttribute("FishingJumpPower", 0.5)
				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Jumping,
					not localPlayer:GetAttribute("InAFKFishingZone")
				)
				fx:PlaySound(getSound("CastStart") or sfx.fishing.powering, parent.handle, true)
				maid2:Add(function()
					if clone and clone.Parent then
						SaneDebris:AddItem(clone, 2)
					end
				end)

				if character:GetAttribute("ThundermaulCharged") or character:GetAttribute("ThundermaulElectrified") then
					local clone2 = fishing2.thunderpower:Clone()
					clone = clone2
					clone2.Enabled = true
					clone2.Parent = humanoidRootPart
					fx:PlaySound(sfx.fishing.thunderpower, parent.handle, false)
					v2.power = 100
					local electric = clone2.powerbar.electric
					local now = 0

					while true do
						task.wait(0.01)

						if tick() - now > 0.25 then
							now = tick()
							task.spawn(function()
								local clone3 = electric:Clone()
								clone3.Position = UDim2.fromScale(random:NextNumber(0, 1), random:NextNumber(0, 1))
								clone3.Rotation = random:NextNumber(0, 360)
								clone3.Visible = true
								clone3.Parent = clone.powerbar

								for i = 0, 768, 256 do
									for i2 = 0, 768, 256 do
										clone3.ImageRectOffset = Vector2.new(i2, i)
										task.wait(0.021875)
									end
								end

								clone3:Destroy()
							end)
						end

						if not (not v2.mb1down or parent.Parent ~= character or not (humanoid.Health > 0) or isSwimming()) then
							continue
						end

						v4 = tick() + 1
						clone2.Size = UDim2.fromScale(0.3, 6)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								Size = UDim2.new()
							}
						):Play()
						SaneDebris:AddItem(clone2, 2)
						break
					end
				else
					clone = fishing2.power:Clone()
					clone.powerbar.bar.Size = UDim2.new(1, 0, 0, 0)
					clone.Enabled = true
					clone.Parent = humanoidRootPart
					v2.power = math.random(6, 13)
					local v6 = "up"

					while true do
						task.wait(0.01)

						if v6 == "up" then
							v2.power += v5
							v6 = v2.power >= 100 and "down" or "up"
						else
							v2.power -= v5
							v6 = v2.power <= 0 and "up" or v6
						end

						clone.powerbar.bar.Size = UDim2.new(1, 0, math.clamp(v2.power / 100, 0, 1), 0)

						if not (not v2.mb1down or parent.Parent ~= character or not (humanoid.Health > 0) or isSwimming()) then
							continue
						end

						v4 = tick() + 1
						clone.powerbar.glow.ImageColor3 = Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 1), v2.power / 100)
						clone.powerbar.glow.ImageTransparency = 0
						clone.Size = UDim2.fromScale(0.3, 6)
						TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								Size = UDim2.new()
							}
						):Play()
						TweenService:Create(clone.powerbar.glow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
							ImageTransparency = 1
						}):Play()
						SaneDebris:AddItem(clone, 2)
						break
					end
				end

				v.FovTween = TweenService:Create(
					currentCamera,
					TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				)
				v.FovTween:Play()

				if v.powering then
					v.powering:Stop()
				end

				if humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
					local handle2 = parent:FindFirstChild("handle")
					local disabledAnimations2 = handle2:FindFirstChild("disabledAnimations")

					if not (disabledAnimations2 and disabledAnimations2:GetAttribute("throw")) then
						local v6

						if handle2:FindFirstChild("throw") and handle2.throw:IsA("Animation") then
							v6 = handle2.throw
						else
							v6 = fishing.throw
						end

						v.throw = animator:LoadAnimation(v6)
						v.throw.Priority = Enum.AnimationPriority.Action3
						v.throw.Looped = false
						v.throw:Play()
					end

					local v6 = 96 - v5 * 2

					if v2.power > 80 and v2.power <= v6 then
						local clone2 = fx2.perfectcast:Clone()
						clone2.Enabled = false
						clone2.Parent = character.Torso
						clone2:Emit(math.random(2, 3))
						debris:AddItem(clone2, 1)
					elseif v6 < v2.power then
						local clone2 = fx2.perfectcast:Clone()
						clone2.Enabled = false
						clone2.Parent = character.Torso
						clone2:Emit(math.random(9, 16))
						debris:AddItem(clone2, 1)

						if clone.Name ~= "thunderpower" then
							clone.powerbar.glow.ImageColor3 = Color3.fromRGB(100, 255, 92)
						end
					end

					character:SetAttribute("FishingJumpPower", 0)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
					local lastTime = tick()

					if not (disabledAnimations2 and disabledAnimations2:GetAttribute("waiting")) then
						local v7

						if handle2:FindFirstChild("waiting") and handle2.waiting:IsA("Animation") then
							v7 = handle2.waiting
						else
							v7 = fishing.waiting
						end

						v.waiting = animator:LoadAnimation(v7)
						v.waiting.Priority = Enum.AnimationPriority.Action2
						v.waiting:Play()
					end

					if remoteFunction:InvokeServer(math.clamp(v2.power, 0, 100), v6 <= v2.power) then
						task.wait(0.5 - (tick() - lastTime))

						if not ReelController.ActiveReel then
							maid2:Clean()

							if not (humanoid.Health > 0) or isSwimming() or not parent:FindFirstChild("bobber") then
								reset()
								return
							end
						end
					else
						warn("[rod/client] cast rejected by server")
						reset()
						maid2:Clean()
						return
					end
				else
					backpack.Enabled = true
					reset()
					remoteEvent3:FireServer()
				end
			else
				maid2:Clean()
			end

			v2.isFishButtonMobile = false
		end
	elseif (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2) and not flag and (values.state.Value == BiteTypes.RodState.Luring or values.state.Value == BiteTypes.RodState.Searching) and backpack.Enabled then
		if (localPlayer:GetAttribute("MisclickingExperiment") or SettingsController:GetSettingValue("shakeMisclick")) and not flag2 and (values.state.Value == BiteTypes.RodState.Luring or values.bobberzone.Value) then
			return
		end

		reset()
		remoteEvent3:FireServer()
		UIUpdate()
	end
end

UserInputService.InputBegan:Connect(handleInput)
UserInputService.InputEnded:Connect(function(input, _)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch and input.KeyCode ~= Enum.KeyCode.ButtonR2 or fishButtonMobile.Enabled then
		return
	end

	v2.mb1down = false
	v2.startingcast = false
end)
button.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch and input.KeyCode ~= Enum.KeyCode.ButtonR2 then
		return
	end

	handleInput(input, false, true)
end)
button.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch and input.KeyCode ~= Enum.KeyCode.ButtonR2 then
		return
	end

	v2.mb1down = false
	v2.startingcast = false
end)
local tempinstantwalkthing = false
parent.Equipped:Connect(function()
	if values.state.Value >= BiteTypes.RodState.PreReel then
		character:SetAttribute("FishingJumpPower", 0)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		character:SetAttribute("FishingWalkSpeed", 0)
	else
		task.spawn(function()
			ContentProvider:PreloadAsync(parent.handle:QueryDescendants("Animation, Sound"))
		end)
		v2.equipped = true
		reset()
		UIUpdate()
		gamepadFishingTips.Visible = true
		local v5 = fishButtonMobile
		local enabled = ABEligible() -- equivalent call inferred; original call site unknown
		v5.Enabled = enabled
		local walk = not v.walk and parent:FindFirstChild("handle") and parent.handle:FindFirstChild("walk")

		if walk then
			tempinstantwalkthing = walk:GetAttribute("tempinstantwalkthing") or false
			v.walk = humanoid:WaitForChild("Animator"):LoadAnimation(walk)
			maid:Add(function()
				if v.walk then
					v.walk:Stop()
					v.walk:Destroy()
					v.walk = nil
				end
			end)
		end

		if parent:FindFirstChild("bobber") and not (humanoid.Health > 0) or isSwimming() then
			reset()
		end
	end
end)
local v5 = {
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.StrafingNoPhysics] = true,
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Freefall] = true
}
RunService.RenderStepped:Connect(function(_: number)
	if not (v.walk and humanoid and humanoid.Parent and humanoidRootPart and humanoidRootPart.Parent) then
		return
	end

	if v2.equipped and not ((humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude < 0.1) and v5[humanoid:GetState()] and not ((humanoid.MoveDirection * createVector(
		1,
		0,
		1
	)).Magnitude < 0.1) then
		if not v.walk.IsPlaying then
			v.walk:Play(tempinstantwalkthing and 0 or 0.25)
		end

		v.walk:AdjustSpeed(humanoid.WalkSpeed / 16)
	elseif v.walk.IsPlaying then
		v.walk:Stop(tempinstantwalkthing and 0 or 0.25)
	end
end)
humanoid.HealthChanged:Connect(function()
	if v2.equipped and humanoid.Health > 0 then
		return
	end

	reset()
	remoteEvent3:FireServer()
end)
humanoid.StateChanged:Connect(function(_, p)
	if not (p == Enum.HumanoidStateType.Swimming and v2.equipped) then
		return
	end

	if values.state.Value < BiteTypes.RodState.PreReel and not values.casted.Value then
		reset()
		remoteEvent3:FireServer("WaterEntered")
	end
end)
parent.Unequipped:Connect(function()
	if values.state.Value >= BiteTypes.RodState.PreReel then
		return
	end

	gamepadFishingTips.Visible = false
	v2.equipped = false

	if v2.mb1down then
		reset()
	else
		stopAnims()
	end

	UIUpdate()
	fishButtonMobile.Enabled = false
end)
local value = values:WaitForChild("state").Value
values:WaitForChild("state").Changed:Connect(function(p)
	local v6

	if BiteTypes.RodState.PreReel <= p then
		v6 = p < BiteTypes.RodState.CatchFinished
	else
		v6 = false
	end

	backpack.Enabled = not v6
	humanoid.AutoRotate = not v6
	local v7 = fishButtonMobile
	local aBEligible = ABEligible() -- equivalent call inferred; original call site unknown
	v7.Enabled = aBEligible and not v6 and v2.equipped

	if v6 then
		character:SetAttribute("FishingWalkSpeed", 0)
		character:SetAttribute("FishingJumpPower", 0)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	elseif p <= BiteTypes.RodState.Equipped and value > BiteTypes.RodState.Equipped then
		reset()
		UIUpdate()
	end

	value = p
end)
character:GetAttributeChangedSignal("FishingWalkSpeed"):Connect(function()
	if character:GetAttribute("FishingWalkSpeed") ~= 0 and values.state.Value >= BiteTypes.RodState.PreReel then
		character:SetAttribute("FishingWalkSpeed", 0)
		character:SetAttribute("FishingJumpPower", 0)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end
end)
bait.Changed:Connect(UIUpdate)
rod.Changed:Connect(UIUpdate)
UIUpdate()
task.spawn(function()
	ContentProvider:PreloadAsync(parent.handle:QueryDescendants("Animation, Sound"))
end)
task.wait(1)

for _, child in bait:GetChildren() do
	child.Changed:Connect(UIUpdate)
end

if rod.Value and rods[rod.Value] then
	local flag = false
	local v6 = playerDataReplicator:Observe({ "Rods", rod.Value }, function()
		if flag then
			UIUpdate()
		else
			flag = true
		end
	end)
	DeferredSignalHackaround.Once(script.Destroying, v6)
end