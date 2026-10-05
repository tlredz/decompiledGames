local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local SequenceTeleport = require(ReplicatedStorage.CAM.Client.Modules.SequenceTeleport)
local localPlayer = Players.LocalPlayer
local muzansBloodServer = script.Parent:WaitForChild("Muzan's BloodServer")

local function getDrinkClip()
	local drink = muzansBloodServer:FindFirstChild("Drink")

	if drink ~= nil then
		return drink
	end

	local healthPotion = ReplicatedStorage.ToolScripts:FindFirstChild("Health Potion")
	local healthPotion2 = healthPotion ~= nil and healthPotion:FindFirstChild("Health Potion") or nil
	return healthPotion2 ~= nil and healthPotion2:FindFirstChild("HealthPotionThrowAway") or nil
end

local now = 0
local v = nil
local track = nil
local v2 = nil

local function setHeadCam()
	local character = localPlayer.Character
	local head = character ~= nil and character:FindFirstChild("Head") or nil
	local getvaluesfolder = Utility.getvaluesfolder(localPlayer)

	if head == nil or getvaluesfolder == nil then
		return
	end

	if v2 == nil or v2.Parent == nil then
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "camsubject"
		objectValue.Parent = getvaluesfolder
		v2 = objectValue
	end

	v2.Value = head
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHeadCam()
	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end
end

return {
	MouseDown = function(instance, p: string)
		if instance == nil then
			return
		end

		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoid == nil or humanoid.Health <= 0 or humanoidRootPart == nil or not Checker.check(
			localPlayer,
			nil,
			"MuzansBlood"
		) then
			return
		end

		local data = Utility.GetData(localPlayer)

		if not (data ~= nil and Utility.HeldItem(data, p) ~= nil and data.Race.Value == "Human" and localPlayer:GetAttribute("SaveDisabledSlot") ~= true) then
			return
		end

		if v ~= nil or os.clock() - now < 1 then
			return
		end

		now = os.clock()

		if InCombat.biasedCheck(localPlayer) then
			return
		end

		local groundSnap = SequenceTeleport.GroundSnap(humanoidRootPart.CFrame)
		instance:PivotTo(groundSnap)
		v = Utility.lock(humanoidRootPart, groundSnap, nil, (`{localPlayer.Name}_MuzanBloodLock`))
		local drinkClip = getDrinkClip()

		if drinkClip ~= nil then
			track = humanoid.Animator:LoadAnimation(drinkClip)
			track:Play()
		end

		task.delay(MuzanSettings.TransformCutsceneAt, function()
			if v == nil then
				return
			end

			if track ~= nil then
				track:Stop()
			end

			setHeadCam()
			local transformation = muzansBloodServer:FindFirstChild("Transformation")

			if transformation ~= nil and humanoid.Parent ~= nil then
				track = humanoid.Animator:LoadAnimation(transformation)
				track:Play()
			end
		end)
		task.delay(MuzanSettings.TransformCutsceneAt + MuzanSettings.TransformLength, function()
			if track ~= nil then
				track:Stop()
				track = nil
			end

			if v ~= nil then
				v:Destroy()
				v = nil
			end

			clearHeadCam() -- equivalent call inferred; original call site unknown
		end)
	end
}