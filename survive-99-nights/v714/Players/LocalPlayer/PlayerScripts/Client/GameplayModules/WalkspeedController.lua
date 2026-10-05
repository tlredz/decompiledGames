local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local WalkspeedController = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
require(ReplicatedStorage.Modules.GlobalSettings)
local walkSpeed = 16
local walkSpeed2 = 29
local berserkerRageDuration = Client.GlobalSettings.BerserkerRageDuration
local flag = false
local v3 = false
local v4 = false
local v5 = true
local v6 = false
local bar = nil
local runningConnection = nil
local mouse = localPlayer:GetMouse()
local cameraModule = nil
local v7 = {
	onAdd = {},
	onRemove = {}
}
local v8 = {
	"Vehicle",
	"Admin",
	"Traps",
	"Debuffs",
	"Effects",
	"Armour",
	"Class",
	"General"
}
local v9 = {
	"Vehicle",
	"Traps",
	"Debuffs",
	"Effects",
	"General"
}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}

function UpdateSortValue(state)
	if not state.Group then
		state.Group = "General"
	end

	local v14 = state.Mode == "Walk" and v9 or v8
	local total = 0

	for k, v16 in pairs(v14) do
		if v16 ~= state.Group then
			continue
		end

		total += (#v14 - (k - 1)) * 10000
		break
	end

	state.SortValue = total + (state.SortWeight or math.abs(state.Change))
end

function AddSpeedChange(id, group, change, options)
	if not change or change == 0 then
		WalkspeedController.RemoveSpeedChange(id)
		return
	end

	local v14 = options or {}
	v14.Id = id
	v14.Change = change
	v14.Group = group

	if v14.Mode == "Walk" then
		RemoveIdFromList(id, v11)
		table.insert(v11, v14)
	else
		RemoveIdFromList(id, v10)
		table.insert(v10, v14)
	end

	UpdateSortValue(v14)
	UpdatePlayerSpeed()

	if v7.onAdd[id] then
		v7.onAdd[id]()
	end
end

WalkspeedController.AddSpeedChange = AddSpeedChange

function RemoveIdFromList(p, list)
	local v14 = 1

	while v14 <= #list do
		if list[v14].Id == p then
			table.remove(list, v14)
		else
			v14 += 1
		end
	end
end

function RemoveSpeedChange(p)
	RemoveIdFromList(p, v10)
	RemoveIdFromList(p, v11)
	UpdatePlayerSpeed()

	if v7.onRemove[p] then
		v7.onRemove[p]()
	end
end

WalkspeedController.RemoveSpeedChange = RemoveSpeedChange

function UpdatePlayerSpeed()
	table.sort(v10, function(a, b)
		return a.SortValue > b.SortValue
	end)
	table.sort(v11, function(a, b)
		return a.SortValue > b.SortValue
	end)
	local v14 = {}
	local total = 16

	for _, v16 in pairs(v11) do
		if v14[v16.Group] then
			continue
		end

		total += v16.Change
		v14[v16.Group] = true

		if v16.Block then
			break
		end
	end

	local v16 = {}
	local total2 = 29

	for _, v18 in pairs(v10) do
		if v16[v18.Group] then
			continue
		end

		total2 += v18.Change
		v16[v18.Group] = true

		if v18.Block then
			break
		end
	end

	walkSpeed = total
	walkSpeed2 = math.max(total2, total)
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid then
		if flag then
			humanoid.WalkSpeed = walkSpeed2
		else
			humanoid.WalkSpeed = walkSpeed
		end
	end
end

function WalkspeedController.GetSprinting()
	return flag
end

function IsAssassinClass()
	return localPlayer:GetAttribute("Class") == "Assassin"
end

function CanAlienSprint()
	return localPlayer:GetAttribute("Class") == "Alien" and (localPlayer:GetAttribute("ClassLevel") or 1) == 3 and localPlayer:GetAttribute("EnergyAmmo") >= 100
end

function IsAlienSlowed()
	return localPlayer:GetAttribute("Class") == "Alien" and localPlayer:GetAttribute("EnergyOverheat")
end

function IsBigGameHunterBunnySpeed()
	if localPlayer:GetAttribute("Class") == "Big Game Hunter" and localPlayer:FindFirstChild("PeltList") and localPlayer.PeltList:FindFirstChild("Bunny Foot") then
		return localPlayer.PeltList["Bunny Foot"]:GetAttribute("Complete")
	end
end

function IsUndeadClass()
	if localPlayer:GetAttribute("Class") == "Undead" and localPlayer:FindFirstChild("UndeadClassPerks") and localPlayer.UndeadClassPerks:GetAttribute("MoreSpeed") then
		return true
	end
end

function UpdatePyroBurnSpeed()
	local numBurningEnemies = localPlayer:GetAttribute("NumBurningEnemies") or 0
	local v14 = (localPlayer:GetAttribute("Class") ~= "Pyromaniac" or (localPlayer:GetAttribute("ClassLevel") or 1) < 3) and 0 or numBurningEnemies
	local v15 = math.min(v14, 3) * 2 + math.max(v14 - 3, 0)
	AddSpeedChange("PyroSprintBoost", "Class", (math.clamp(v15, 0, 12)))
	AddSpeedChange("PyroWalkBoost", "Class", math.clamp(v14, 0, 3) * 2, {
		Mode = "Walk"
	})
end

function IsBerserkerRaging()
	if localPlayer:GetAttribute("Class") == "Berserker" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 or Client.Utility.HasTalent(
		localPlayer,
		"ReviveBoost"
	) then
		local respawnTime = localPlayer:GetAttribute("RespawnTime") or 0

		if workspace:GetServerTimeNow() - respawnTime < berserkerRageDuration - 0.1 then
			return true
		end
	end
end

function ToggleBoostPartParticles(p, instance, p2)
	if p == localPlayer then
		v6 = p2
	end

	if instance and instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance.HumanoidRootPart

		if p2 then
			if humanoidRootPart:FindFirstChild("Lightning") then
				return
			end

			local speedUp = ReplicatedStorage.Assets.Particles.SpeedUp

			for _, child in pairs(speedUp.TargetA1232:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = humanoidRootPart
			end

			humanoidRootPart.Small.Attachment0 = humanoidRootPart.Far
			humanoidRootPart.Small.Attachment1 = humanoidRootPart.Home
			humanoidRootPart.SpeedUpLight.Attachment0 = humanoidRootPart.FarClose
			humanoidRootPart.SpeedUpLight.Attachment1 = humanoidRootPart.HomeClose
		else
			for _, child in pairs(humanoidRootPart:GetChildren()) do
				if child:HasTag("CleanupLightning") then
					child:Destroy()
				end
			end
		end
	end
end

function v7.onAdd.Boostpad()
	if not v6 then
		Client.Events.BoostpadParticles:FireAllClients(localPlayer.Character, true)
		Client.Sound.Play("Boosted", {
			Volume = 0.4,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.35
			}
		})
		Client.Events.BoostpadUsedParticles:FireAllClients(localPlayer.Character)
		Client.CamShake.ShakeOnce(1.3, 20, 0.1, 0.4)
	end
end

function v7.onRemove.Boostpad()
	Client.Events.BoostpadParticles:FireAllClients(localPlayer.Character, false)
end

function v7.onAdd.Chilli()
	Client.Events.BoostpadParticles:FireAllClients(localPlayer.Character, true)
	Client.CamShake.ShakeOnce(0.65, 10, 0.05, 0.2)
end

function v7.onRemove.Chilli()
	Client.Events.BoostpadParticles:FireAllClients(localPlayer.Character, false)
end

function WalkspeedController.PlayerFrozen(p)
	if p then
		AddSpeedChange("Frozen", "Debuffs", -13, {
			Block = true
		})
	else
		RemoveSpeedChange("Frozen")
	end
end

function WalkspeedController.StartSprint(p)
	if not Client.PlayerHandler.Alive then
		return
	end

	v3 = true
	Client.GuiButtonHandler.HideButton("Sprint")
	flag = true

	if bar then
		if localPlayer:GetAttribute("Temperature") and localPlayer:GetAttribute("Temperature") <= 0 then
			bar.Parent.SprintWarning.Visible = false
			bar.Parent.FrozenWarning.Visible = true
		else
			bar.Parent.SprintWarning.Visible = true
			bar.Parent.FrozenWarning.Visible = false
		end
	end

	if walkSpeed2 > 0 then
		v4 = false
		Client.Events.PlayerSprinting:FireServer(true)
	else
		v4 = true
		Client.Events.PlayerSprinting:FireServer(false)
	end

	if runningConnection then
		runningConnection:Disconnect()
	end

	if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
		local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
		local flag2 = false
		humanoid.WalkSpeed = walkSpeed2
		runningConnection = humanoid.Running:Connect(function(p2)
			if not flag then
				return
			end

			if p2 > 0 then
				if not (flag2 or v4) then
					Client.Events.PlayerSprinting:FireServer(true)
					flag2 = true
				end
			elseif p and p.UserInputType == Enum.UserInputType.Gamepad1 then
				WalkspeedController.StopSprint()
			elseif flag2 then
				Client.Events.PlayerSprinting:FireServer(false)
				flag2 = false
			end
		end)
	end
end

function WalkspeedController.IsSprinting()
	return flag
end

function WalkspeedController.StopSprint()
	flag = false
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = walkSpeed
	end

	if bar then
		bar.Parent.SprintWarning.Visible = false
		bar.Parent.FrozenWarning.Visible = false
	end

	Client.Events.PlayerSprinting:FireServer(false)
end

local RunService = game:GetService("RunService")
RunService:IsStudio()

function ToggleSprinting(_, p, p2)
	if p2 and tostring(p2.UserInputType.Name):sub(1, 7) == "Gamepad" then
		if p == Enum.UserInputState.Begin then
			if not v5 then
				return
			end

			v5 = false
			task.spawn(function()
				wait(0.15)
				v5 = true
			end)

			if flag then
				WalkspeedController.StopSprint()
			else
				WalkspeedController.StartSprint(p2)
			end
		end
	elseif p == Enum.UserInputState.Begin then
		WalkspeedController.StartSprint(p2)
	elseif p2.UserInputType == Enum.UserInputType.Keyboard then
		WalkspeedController.StopSprint()
	end

	return Enum.ContextActionResult.Sink
end

local v14 = 0

function WalkspeedController.ExplorerSpeedBoost()
	local v15 = v14 + 1
	v14 = v15
	AddSpeedChange("ExplorerBoost", "Class", 8)
	task.delay(3, function()
		if v15 == v14 then
			RemoveSpeedChange("ExplorerBoost")
		end
	end)
end

function SetOverallSpeed(p, p2, value)
	local v15 = p2 - 29
	local v16 = p2 - 16
	AddSpeedChange(p, value or "Effects", v15, {
		Block = true
	})
	AddSpeedChange(p, value or "Effects", v16, {
		Block = true,
		Mode = "Walk"
	})
end

WalkspeedController.SetOverallSpeed = SetOverallSpeed

local function SetupRemoteEvents()
	Client.Events.BoostpadParticles:Connect(function(p, p2, p3, duration)
		ToggleBoostPartParticles(p, p2, p3)

		if duration then
			task.delay(duration, function()
				ToggleBoostPartParticles(p, p2, false)
			end)
		end
	end)
	Client.Events.SlowPlayer:Connect(function(value, value2, _, value3)
		if not (localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")) then
			return
		end

		local v15 = value or "slowed"
		local v16 = 16 + (value2 or -6)
		SetOverallSpeed(v15, v16, "Debuffs")
		v13[v15] = (v13[v15] or 0) + 1
		local v17 = v13[v15]
		task.delay(value3 or 5, function()
			if v13[v15] == v17 then
				RemoveSpeedChange(v15)
			end
		end)
	end)
	Client.Events.SpeedPlayer:Connect(function(value, value2, _, duration)
		print(value, value2)
		task.spawn(function()
			if not (localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("HumanoidRootPart")) then
				return
			end

			value = value or "speed"
			value2 = value2 or -6
			duration = duration or 5
			local _ = 16 + value2
			SetOverallSpeed(value, value2)
			v12[value] = (v12[value] or 0) + 1
			local v15 = v12[value]
			task.delay(duration, function()
				if v12[value] == v15 then
					RemoveSpeedChange(value)
				end
			end)
		end)
	end)
end

function CheckClasses()
	if localPlayer:GetAttribute("Class") == "Assassin" then
		AddSpeedChange("AssassinClass", "Class", 3)
	end

	if localPlayer:GetAttribute("Class") == "Nightcrawler" then
		task.spawn(function()
			while true do
				if Client.Utility.IsInDarkness(localPlayer) then
					AddSpeedChange("NightcrawlerClass", "Class", 7)
					AddSpeedChange("NightcrawlerClass", "Class", 7, {
						Mode = "Walk"
					})
				else
					RemoveSpeedChange("NightcrawlerClass")
				end

				task.wait(1)
			end
		end)
	end

	if localPlayer:GetAttribute("Class") == "Vampire" then
		workspace:GetAttributeChangedSignal("State"):Connect(function()
			local v15 = workspace:GetAttribute("State") == "Night" and 2 or 0
			AddSpeedChange("VampireClass", "Class", v15)
		end)

		if workspace:GetAttribute("State") == "Night" then
			AddSpeedChange("VampireClass", "Class", 2)
		end
	end

	if localPlayer:GetAttribute("Class") == "Feaster" then
		localPlayer:GetAttributeChangedSignal("Hunger"):Connect(function()
			if (localPlayer:GetAttribute("ClassLevel") or 1) >= 1 then
				if (localPlayer:GetAttribute("Hunger") or 0) > Client.GlobalSettings.MaxHunger then
					AddSpeedChange("FeasterClass", "Class", 6)
				else
					RemoveSpeedChange("FeasterClass")
				end
			end
		end)
	end

	if localPlayer:GetAttribute("Class") == "Bunny" then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local v15 = (localPlayer:GetAttribute("CarrotsEatenPct") or 0) * 5
			AddSpeedChange("BunnyClass", "Class", v15)
		end

		localPlayer:GetAttributeChangedSignal("CarrotsEatenPct"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	if localPlayer:GetAttribute("Class") == "Egg Hunter" then
		local eggBasket = localPlayer:WaitForChild("EggBasket")

		local function update()
			if (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 then
				local v15 = #eggBasket:GetChildren() * 0.5
				AddSpeedChange("EggHunterClass", "Class", v15)
			end
		end

		eggBasket.ChildAdded:Connect(update)
		eggBasket.ChildRemoved:Connect(update)
	end

	if localPlayer:GetAttribute("Class") == "Alien Scientist" then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			if (localPlayer:GetAttribute("ClassLevel") or 1) >= 3 then
				local v15 = 4 * ((localPlayer:GetAttribute("AlienEssencePct") or 0) / 100)
				AddSpeedChange("AlienScientistClass", "Class", v15)
			end
		end

		localPlayer:GetAttributeChangedSignal("AlienEssencePct"):Connect(update)
		localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	if localPlayer:GetAttribute("Class") == "Undead" then
		task.spawn(function()
			local undeadClassPerks = localPlayer:WaitForChild("UndeadClassPerks")
			undeadClassPerks:GetAttributeChangedSignal("MoreSpeed"):Connect(function()
				if undeadClassPerks:GetAttribute("MoreSpeed") then
					AddSpeedChange("UndeadClass", "Class", 2)
				end
			end)

			if undeadClassPerks:GetAttribute("MoreSpeed") then
				AddSpeedChange("UndeadClass", "Class", 2)
			end
		end)
	end

	if localPlayer:GetAttribute("Class") == "Big Game Hunter" then
		task.spawn(function()
			local bunnyFoot = localPlayer:WaitForChild("PeltList"):WaitForChild("Bunny Foot")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v15 = bunnyFoot:GetAttribute("Complete") and 4.35
				AddSpeedChange("BigGameHunterClass", "Class", v15)
			end

			bunnyFoot:GetAttributeChangedSignal("Complete"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
		end)
	end
end

function CharacterAdded(instance)
	instance:WaitForChild("Humanoid")
	UpdatePlayerSpeed()
end

local function SetupAttributeListeners()
	localPlayer:GetAttributeChangedSignal("Temperature"):Connect(function()
		if localPlayer:GetAttribute("Temperature") <= 0 then
			AddSpeedChange("ZeroTemperature", "Debuffs", -13, {
				Block = true
			})
		else
			RemoveSpeedChange("ZeroTemperature")
		end
	end)
	localPlayer:GetAttributeChangedSignal("SprintSpeed"):Connect(function()
		local v15 = localPlayer:GetAttribute("SprintSpeed") - 29
		AddSpeedChange("AdminSprint", "Admin", v15, {
			Block = true
		})
	end)

	if localPlayer:GetAttribute("SprintSpeed") then
		local v15 = localPlayer:GetAttribute("SprintSpeed") - 29
		AddSpeedChange("AdminSprint", "Admin", v15, {
			Block = true
		})
	end

	localPlayer:GetAttributeChangedSignal("FrogBoots"):Connect(function()
		local v15 = localPlayer:GetAttribute("FrogBoots") and 3
		AddSpeedChange("FrogBoots", "Armour", v15)
	end)
	localPlayer:GetAttributeChangedSignal("ObsidironBoots"):Connect(function()
		local v15 = localPlayer:GetAttribute("ObsidironBoots") and 3
		AddSpeedChange("ObsidironBoots", "Armour", v15)
	end)
	localPlayer:GetAttributeChangedSignal("HalloweenSpeed"):Connect(function()
		local v15 = localPlayer:GetAttribute("HalloweenSpeed") and 4
		AddSpeedChange("HalloweenSpeed", "Effects", v15)
	end)
	localPlayer:GetAttributeChangedSignal("HalloweenSlow"):Connect(function()
		local v15 = localPlayer:GetAttribute("HalloweenSlow") and -5
		AddSpeedChange("HalloweenSlow", "Debuffs", v15, {
			Block = true
		})
	end)
	localPlayer:GetAttributeChangedSignal("EnergyOverheat"):Connect(function()
		local v15 = IsAlienSlowed() and -13
		AddSpeedChange("AlienOverheat", "Debuffs", v15, {
			Block = true
		})
	end)
	localPlayer:GetAttributeChangedSignal("EnergyAmmo"):Connect(function()
		local v15 = CanAlienSprint() and 3
		AddSpeedChange("AlienSprint", "Class", v15)
	end)

	if CanAlienSprint() then
		AddSpeedChange("AlienSprint", "Class", 3)
	end

	localPlayer:GetAttributeChangedSignal("RespawnTime"):Connect(function()
		if localPlayer:GetAttribute("Class") == "Berserker" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 then
			AddSpeedChange("BerserkerSprint", "Class", 37)
			task.wait(berserkerRageDuration)
			RemoveSpeedChange("BerserkerSprint")
		end
	end)
	localPlayer:GetAttributeChangedSignal("NumBurningEnemies"):Connect(UpdatePyroBurnSpeed)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(UpdatePyroBurnSpeed)
	localPlayer:GetAttributeChangedSignal("Class"):Connect(UpdatePyroBurnSpeed)
	localPlayer:GetAttributeChangedSignal("Class"):Connect(function()
		CheckClasses()
	end)
	task.spawn(function()
		local flowerPots = game.ReplicatedStorage:WaitForChild("Shops"):WaitForChild("FlowerPots")
		local flag2 = false

		while true do
			local speedBoostFlower = workspace:GetAttribute("SpeedBoostFlower")

			if speedBoostFlower then
				local v15 = math.clamp(flowerPots:GetAttribute(speedBoostFlower) or 0, 0, 10) * 1
				local position = localPlayer.Character and localPlayer.Character:GetPivot().Position
				local magnitude = position and (position * createVector(1, 0, 1)).Magnitude

				if magnitude and magnitude <= 120 and v15 > 0 and position.Y > -10 and position.Y < 100 then
					if not flag2 then
						local pivot = localPlayer.Character:GetPivot()
						Client.Utility.SpawnParticles("PetalExplode", pivot, {
							Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
						})
						flag2 = true
					end

					AddSpeedChange("RoseSpeedBoost", "Effects", v15)
					AddSpeedChange("RoseSpeedBoost", "Effects", v15, {
						Mode = "Walk"
					})
				elseif flag2 then
					RemoveSpeedChange("RoseSpeedBoost")
					flag2 = false
				end
			end

			task.wait(1)
		end
	end)
end

function ToggleShiftLock()
	local icon = mouse.Icon
	task.spawn(function()
		local CameraModule = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"))
		cameraModule = CameraModule
		local activeMouseLockController = cameraModule.GetCameraController().activeMouseLockController
		activeMouseLockController:OnMouseLockToggled()
		local shiftlockWarning = Client.Interface.ShiftlockWarning
		local imageLabel = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileButtons"):WaitForChild("Frame").ShiftlockButton.ImageLabel

		if activeMouseLockController:GetIsMouseLocked() then
			mouse.Icon = icon
			imageLabel.Image = "rbxassetid://74442555294143"
			local currentPlatform = Client.GuiButtonHandler.GetCurrentPlatform()
			local lastInputType = UserInputService:GetLastInputType()

			if currentPlatform ~= "Touch" then
				print((tostring(lastInputType)))

				if lastInputType and string.find(tostring(lastInputType), "Gamepad") then
					shiftlockWarning.Text = "press L2 to disable shiftlock"
				else
					shiftlockWarning.Text = "press CTRL to remove mouselock"
				end

				shiftlockWarning.Visible = true
			end
		else
			imageLabel.Image = "rbxassetid://96552781557044"
			shiftlockWarning.Visible = false
		end
	end)
end

WalkspeedController.ToggleShiftLock = ToggleShiftLock

function ShiftLockButtonPressed(_, p, _)
	if p == Enum.UserInputState.Begin then
		ToggleShiftLock()
	end
end

local function SetupInputBindings()
	ContextActionService:BindActionAtPriority(
		"ToggleSprinting",
		ToggleSprinting,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.LeftShift,
		Enum.KeyCode.ButtonL3
	)
	ContextActionService:BindActionAtPriority(
		"ToggleShiftLock",
		ShiftLockButtonPressed,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.LeftControl
	)
end

function WalkspeedController.Init()
	task.spawn(function()
		bar = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")
		wait(70)

		if not v3 then
			Client.GuiButtonHandler.ShowButton("Sprint")
		end

		wait(100)

		if not v3 and Client.GuiButtonHandler.GetCurrentPlatform() == "PC" then
			Client.PopUpUI.AddPopUp("hold shift to sprint", "yellow")
		end
	end)
	task.spawn(function()
		cameraModule = Client.CameraModule
	end)
	SetupRemoteEvents()
	SetupAttributeListeners()
	CheckClasses()
	SetupInputBindings()
	task.spawn(function()
		localPlayer.CharacterAdded:Connect(CharacterAdded)

		if localPlayer.Character then
			CharacterAdded(localPlayer.Character)
		end
	end)
end

return WalkspeedController