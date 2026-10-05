local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local fishing = require(ReplicatedStorage.shared.modules.fishing)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local UI = script.Parent.Parent.UI
require("../Types")

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerModel()
	local v = nil
	local _, _ = pcall(function()
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		local appliedDescription = humanoid and humanoid:GetAppliedDescription() or Players:GetHumanoidDescriptionFromUserIdAsync(localPlayer.UserId)
		appliedDescription.NeckAccessory = ""
		local humanoidModelFromDescriptionAsync = Players:CreateHumanoidModelFromDescriptionAsync(
			appliedDescription,
			Enum.HumanoidRigType.R6
		)
		local humanoid2 = humanoidModelFromDescriptionAsync:FindFirstChildWhichIsA("Humanoid")

		if humanoid2 then
			humanoid2.BreakJointsOnDeath = false
			humanoid2.EvaluateStateMachine = false
			humanoid2.RequiresNeck = false
			humanoid2.AutoRotate = false
			humanoid2.AutoJumpEnabled = false
			humanoid2.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		for _, v2 in humanoidModelFromDescriptionAsync:QueryDescendants("BaseScript, Sound") do
			v2:Destroy()
		end

		local humanoidRootPart = humanoidModelFromDescriptionAsync:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			humanoidRootPart.Anchored = true
		end

		v = humanoidModelFromDescriptionAsync
		humanoidModelFromDescriptionAsync.Parent = workspace.active
		task.wait()
	end)
	return v
end

local function recolorObject(descendant, color: Color3)
	if descendant:IsA("BasePart") or descendant:IsA("Light") or descendant:IsA("SurfaceAppearance") then
		descendant.Color = color
	elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
		descendant.Color = ColorSequence.new(color)
	elseif descendant:IsA("Decal") then
		descendant.Color3 = color
	end
end

local RodSkin = {}

function RodSkin.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local skin = RodSkins.Skins[data.Name]
	local rod = rods[skin.TargetRod]
	clone.Name = data.Name
	clone.detail.itemName.Text = skin.DisplayText or data.Name
	clone.detail.itemType.Text = `<font color="#{rod.Color:ToHex()}">{skin.TargetRod}</font> Skin`
	clone.icon.Image = data.Icon or skin.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function RodSkin.LoadScene(object, p, p2)
	local skin = RodSkins.Skins[p.Name]
	local playerModel = getPlayerModel() -- equivalent call inferred; original call site unknown
	local v2 = {}

	if playerModel then
		for _, v3 in playerModel:QueryDescendants("JointInstance"), nil, nil do
			v2[v3] = {
				Part1 = v3.Part1,
				C0 = v3.C0,
				C1 = v3.C1
			}
		end
	end

	if playerModel and skin.RodPatches and skin.RodPatches.FishingPassives and skin.RodPatches.FishingPassives.Generic_WeldAccessory and skin.RodPatches.FishingPassives.Generic_WeldAccessory.Models then
		local rod = rods[skin.TargetRod]

		for _, model in skin.RodPatches.FishingPassives.Generic_WeldAccessory.Models do
			if model.OnlyMode then
				local v3 = playerDataReplicator:TryIndex({ "Rods", skin.TargetRod, "mode" }) or rod.DefaultMode

				if model.OnlyMode ~= v3 then
					continue
				end
			end

			local part = playerModel:FindFirstChild(model.WeldToLimb)

			if not (part and part:IsA("BasePart")) then
				continue
			end

			local cloneAsync = assets.getCloneAsync("weldAccessory", model.ModelName)
			cloneAsync.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
			cloneAsync:PivotTo(part.CFrame)
			local weld = cloneAsync.PrimaryPart and cloneAsync.PrimaryPart:FindFirstChild("weld")
			local assert_2 = assert(weld)
			assert_2.Part0 = part

			if model.HaloColorSelector then
				local descendants = cloneAsync:QueryDescendants(model.HaloColorSelector)
				local settingValue = SettingsController:GetSettingValue("haloColor")
				local color = Color3.fromRGB(settingValue.r, settingValue.g, settingValue.b)

				for _, descendant in ipairs(descendants) do
					recolorObject(descendant, color)
				end
			end

			cloneAsync.Parent = playerModel
		end
	end

	if playerModel then
		playerModel.PrimaryPart = playerModel:FindFirstChild("HumanoidRootPart")
	end

	local cloneAsync = assets.getCloneAsync("skin", p.Name)
	local skin2 = cloneAsync:FindFirstChild("Skin")
	local vfx = cloneAsync:FindFirstChild("Vfx")
	local bobber = vfx and vfx:FindFirstChild("Bobber")
	local handle = skin2:FindFirstChild("handle")

	if playerModel then
		local tool = Instance.new("Tool")

		for _, child in skin2:GetChildren() do
			child.Parent = tool
		end

		tool.CanBeDropped = false
		tool.PrimaryPart = tool:FindFirstChild("handle")
		tool.Parent = playerModel
		fishing:WeldToArm(playerModel, handle)
		local waiting = handle and (handle:FindFirstChild("waiting") or handle:FindFirstChild("fighting") or handle:FindFirstChild("idle")) or ReplicatedStorage.resources.animations.fishing.waiting
		local humanoid = playerModel:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		ContentProvider:PreloadAsync({ waiting })
		local track = animator:LoadAnimation(waiting)
		track.Looped = true
		track:Play()
		object:IgnorePerformance(playerModel)
		playerModel.Parent = workspace.active
		task.wait()
		skin2 = tool

		for k, v3 in v2 do
			k.Part1 = v3.Part1
			k.C0 = CFrame.new(v3.C0.Position * playerModel:GetScale()) * v3.C0.Rotation
			k.C1 = CFrame.new(v3.C1.Position * playerModel:GetScale()) * v3.C1.Rotation
		end
	end

	local v3 = handle and handle:QueryDescendants("> Sound#Idle, > Sound#Loop, > Sound#Back")[1]

	if v3 then
		v3:Play()
	end

	object:IgnorePerformance(cloneAsync)
	local podium = object:CreatePodium(playerModel or skin2, p2, playerModel and createVector(4, 5.1, 1.1) or nil)

	if playerModel then
		playerModel:PivotTo(playerModel:GetPivot() * CFrame.fromOrientation(0, 3.141592653589793, 0))
	else
		skin2:PivotTo(skin2:GetPivot() * CFrame.fromOrientation(0, 1.5707963267948966, 0))
	end

	task.delay(0.1, function()
		if not playerModel then
			return
		end

		for k, v4 in v2 do
			k.Part1 = v4.Part1
			k.C0 = CFrame.new(v4.C0.Position * playerModel:GetScale()) * v4.C0.Rotation
			k.C1 = CFrame.new(v4.C1.Position * playerModel:GetScale()) * v4.C1.Rotation
		end
	end)

	if not p2 then
		local v4 = 2

		if bobber then
			for _, v5 in bobber:QueryDescendants("ParticleEmitter") do
				v4 = math.max(v4, (v5:GetAttribute("EmitDelay") or 0) + v5.Lifetime.Max / v5.TimeScale)
			end
		end

		object:SetInfo({
			Description = skin.Description,
			VfxButtonName = bobber and "Play Cast Effect" or nil,
			TriggerVfx = function()
				object:FadeModelAsync(playerModel or skin2, 1)
				task.wait(0.5)
				local pivot = podium:GetPivot()
				local clone = bobber:Clone()
				clone:PivotTo(CFrame.new(pivot.Position))
				clone.Parent = podium
				ContentProvider:PreloadAsync({ clone })
				local Controller = require(clone:FindFirstChild("Controller"))
				Controller:Start()
				task.wait(v4)
				object:FadeModelAsync(playerModel or skin2, 0)
			end
		})
	end
end

return RodSkin