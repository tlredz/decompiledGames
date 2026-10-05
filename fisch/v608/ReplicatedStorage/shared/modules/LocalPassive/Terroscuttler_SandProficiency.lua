local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local localPlayer = Players.LocalPlayer
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true
local TerroscuttlerSandProficiency = {
	MorphSpear = true,
	Morph = function(p, _, object)
		local scaledConfig = CompanionController.GetScaledConfig(p.config)
		local flashColor = scaledConfig.FlashColor or Color3.fromRGB(217, 166, 122)
		local v = {}

		for _, sandMaterial in ipairs(scaledConfig.SandMaterials) do
			local v2 = Enum.Material[sandMaterial]

			if v2 then
				v[v2] = true
			end
		end

		local random = object:GetRandom(13)
		local v2 = nil

		local function flashAttack()
			TweenService:Create(
				object.reel_playerbar,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = flashColor
				}
			):Play()

			if v2 then
				v2:Cancel()
			end

			local tween = TweenService:Create(
				object.reel_progress.bar,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					BackgroundColor3 = flashColor
				}
			)
			v2 = tween
			tween:Play()
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.terroscuttler, object.reel, true)
		end

		task.spawn(function()
			object:WaitUntilReady()
			local total = 0
			local number = random:NextNumber(scaledConfig.IntervalMin, scaledConfig.IntervalMax)
			p.reelTrove:Add(object.OnLogicStep:Connect(function(p2: number)
				if not object.active then
					return
				end

				total += p2

				if total < number then
					return
				end

				total = 0
				number = random:NextNumber(scaledConfig.IntervalMin, scaledConfig.IntervalMax)
				local activeCompanion = CompanionController.GetActiveCompanion(localPlayer)

				if not (activeCompanion and activeCompanion.RootPart and activeCompanion.RootPart.Parent) then
					return
				end

				local characters = { activeCompanion.Model }

				if localPlayer.Character then
					table.insert(characters, localPlayer.Character)
				end

				raycastParams.FilterDescendantsInstances = characters
				local v3 = activeCompanion.RootPart.Position + createVector(0, 4, 0)
				local raycastResult = workspace:Raycast(v3, createVector(0, -12, 0), raycastParams)

				if not (raycastResult and v[raycastResult.Material]) then
					return
				end

				object:AddProgress(scaledConfig.ProgressPerTick)
				flashAttack()
			end))
		end)
	end
}
setmetatable(TerroscuttlerSandProficiency, module)
return TerroscuttlerSandProficiency