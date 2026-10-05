local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Item = require(ServerStorage.SAM.Services.Adders.Item)
local Item2 = require(ServerStorage.SAM.Services.Removers.Item)
local TitleService = require(ServerStorage.SAM.Services.TitleService)
local Movement = require(ServerStorage.SAM.AntiCheat.Movement)
local color = Color3.fromRGB(165, 0, 0)
local healthPotionServer = ReplicatedStorage.ToolScripts["Health Potion"]["Health PotionServer"]

local function playPotionSound(instance, childName: string)
	local v = script:FindFirstChild(childName) or healthPotionServer:FindFirstChild(childName)

	if v == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local clone = v:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 0)
end

local function convert(instance, data)
	if data.Inventory.Inventory:FindFirstChild("Biwa Bell") ~= nil then
		Item2(instance, "Biwa Bell")
	end

	data.Race.Value = "Demon"
	Item(instance, "Biwa Bell", 1, true, true, nil, "DemonConversion")
	TitleService.AddProgress(instance, "demon_conversions")
end

local function throwBottle(instance, instance2, parent)
	if parent == nil or parent.Parent == nil then
		return
	end

	local primaryPart = instance2.PrimaryPart

	if primaryPart == nil then
		return
	end

	local weld = parent:FindFirstChild("Weld")

	if weld == nil then
		return
	end

	local part1 = weld.Part1

	if part1 == nil then
		return
	end

	local cFrame = primaryPart.CFrame

	for _, part in ipairs(parent:GetChildren()) do
		if part:IsA("BasePart") then
			part:SetNetworkOwner(instance)
		end
	end

	weld:Destroy()
	local attachment = Instance.new("Attachment", part1)
	local linearVelocity = Instance.new("LinearVelocity", attachment)
	linearVelocity.Attachment0 = attachment
	linearVelocity.VectorVelocity = cFrame.LookVector * -20 + cFrame.UpVector * 5
	DebrisModule:AddItem(parent, 2)
	task.delay(0.3, function()
		attachment:Destroy()
		part1.CanCollide = true
	end)
end

return {
	MouseDown = function(instance, instance2, state, p: string)
		if not Checker.check(instance, nil, "MuzansBlood") then
			return
		end

		local data = Utility.GetData(instance)

		if not (data ~= nil and Utility.HeldItem(data, p) ~= nil and data.Race.Value == "Human" and instance:GetAttribute("SaveDisabledSlot") ~= true) then
			return
		end

		if state.TransformThread ~= nil or state.LastDrink ~= nil and os.clock() - state.LastDrink < 1 then
			return
		end

		state.LastDrink = os.clock()

		if InCombat.biasedCheck(instance) then
			SignalEvent.ToClient(instance, "Notify", {
				Text = `Can't transform while in combat ({Utility.formatTime(InCombat.biasedTimeLeft(instance))} left)`,
				Type = "Denied"
			})
			return
		end

		local getvaluesfolder = Utility.getvaluesfolder(instance2)

		if getvaluesfolder == nil then
			return
		end

		local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return
		end

		local v = MuzanSettings.TransformCutsceneAt + MuzanSettings.TransformLength
		state.TransformPause = Utility.AddValue(getvaluesfolder, "pause_gameplay", v + 0.5)
		Movement.Expect(instance, humanoidRootPart.Position)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function release()
			if state.TransformPause ~= nil then
				state.TransformPause:Destroy()
				state.TransformPause = nil
			end

			state.TransformThread = nil
		end

		state.TransformThread = task.spawn(function()
			local capWeld = instance2:FindFirstChild("CapWeld", true)
			local parent

			if capWeld ~= nil then
				parent = capWeld.Parent or nil
			end

			task.wait(0.3)

			if Checker.check_victim(script, instance2, instance2) == nil then
				return release()
			end

			if capWeld ~= nil and parent ~= nil and parent:FindFirstChild("Cap") ~= nil then
				capWeld.Part1 = nil
				parent.Cap.CanCollide = true
				playPotionSound(instance2, "PS2potionOPEN")
			end

			task.wait(0.9500000000000001)

			if Checker.check_victim(script, instance2, instance2) == nil then
				return release()
			end

			playPotionSound(instance2, "PS2potionDRINK")
			task.wait(MuzanSettings.TransformSipAt - 1.3)
			local humanoid = instance2:FindFirstChildOfClass("Humanoid")

			if instance2.Parent == nil or humanoid == nil or not (humanoid.Health > 0) or data.Race.Value ~= "Human" or not Item2(
				instance,
				p,
				nil,
				nil,
				"Consumed"
			) then
				return release()
			end

			playPotionSound(instance2, "PS2potionADMINISTER")
			EffectsEvent.ToAllInRange(instance2, "GeneralActivated", instance2, color)

			if parent ~= nil and parent.Parent ~= nil then
				parent.Parent = workspace.Debree
			end

			task.wait(MuzanSettings.TransformDrinkLead - MuzanSettings.TransformSipAt)
			throwBottle(instance, instance2, parent)
			playPotionSound(instance2, "PS2potionTHROW")
			task.wait(MuzanSettings.TransformCutsceneAt - MuzanSettings.TransformDrinkLead)
			EffectsEvent.ToAllInRange(humanoidRootPart, "MuzanTransformEffects", instance2)
			task.wait(MuzanSettings.TransformConvertAt)

			if instance2.Parent ~= nil and humanoid.Health > 0 and data.Race.Value == "Human" then
				convert(instance, data)
			end

			task.wait(MuzanSettings.TransformLength - MuzanSettings.TransformConvertAt)
			release() -- equivalent call inferred; original call site unknown
		end)
	end
}