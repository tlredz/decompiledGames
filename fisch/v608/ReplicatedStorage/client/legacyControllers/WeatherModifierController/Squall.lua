local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trove = require(ReplicatedStorage.packages.Trove)
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
require(ReplicatedStorage.shared.modules.library.weathers)
local ZoneController = require(ReplicatedStorage.client.legacyControllers.ZoneController)
local v = {
	["Tropical Squall"] = "TropicalSquallVFX",
	["Raging Squall"] = "RagingSquallVFX"
}
local v2 = {
	["Tropical Squall"] = true,
	["Raging Squall"] = true
}
return {
	Start = function(_)
		local localPlayer = Players.LocalPlayer
		local groupValueObject = SharedWeather.GetGroupValueObject("squall")
		local vfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("vfx")
		local v3 = nil
		local v4 = nil
		local maid = Trove.new()

		local function resolveVfxTemplate(p: string)
			local v5 = v[p]

			if not v5 then
				warn((`[SovereignClient] {p} has no WeatherVfxName`))
				return nil
			end

			local child = vfx:FindFirstChild(v5)

			if not child then
				warn((`[SovereignClient] weather VFX template "{v5}" missing under ReplicatedStorage.resources.vfx`))
			end

			return child
		end

		local function getReferencePosition()
			local character = localPlayer.Character

			if character then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					return humanoidRootPart.Position
				end
			end

			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				return currentCamera.CFrame.Position
			end

			return nil
		end

		local function onActivate(value: string)
			maid:Clean()
			local v5 = v[value]
			local child

			if v5 then
				child = vfx:FindFirstChild(v5)

				if not child then
					warn((`[SovereignClient] weather VFX template "{v5}" missing under ReplicatedStorage.resources.vfx`))
				end
			else
				warn((`[SovereignClient] {value} has no WeatherVfxName`))
			end

			if not child then
				return
			end

			local v6 = maid:Add(child:Clone())
			v6:SetAttribute("ModifierName", value)
			local character = localPlayer.Character
			local position, currentCamera

			if character then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					position = humanoidRootPart.Position
				else
					currentCamera = workspace.CurrentCamera

					if currentCamera then
						position = currentCamera.CFrame.Position
					end
				end
			else
				currentCamera = workspace.CurrentCamera

				if currentCamera then
					position = currentCamera.CFrame.Position
				end
			end

			v6.PrimaryPart.CFrame = CFrame.new((position or createVector(0, 0, 0)) + createVector(0, 20, 0))
			v6.Parent = workspace.CurrentCamera or workspace
			v4 = v6
			maid:Add(RunService.RenderStepped:Connect(function()
				if not (v4 and v4.Parent) then
					return
				end

				local character2 = localPlayer.Character
				local position2, currentCamera2

				if character2 then
					local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
						position2 = humanoidRootPart.Position
					else
						currentCamera2 = workspace.CurrentCamera

						if currentCamera2 then
							position2 = currentCamera2.CFrame.Position
						end
					end
				else
					currentCamera2 = workspace.CurrentCamera

					if currentCamera2 then
						position2 = currentCamera2.CFrame.Position
					end
				end

				if position2 then
					v4.PrimaryPart.CFrame = CFrame.new(position2 + createVector(0, 20, 0))
				end
			end))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onDeactivate()
			maid:Clean()
			v4 = nil
		end

		local function pickActiveSovereign()
			if ZoneController.IsIndoors or ZoneController.IsFakeUnderwater then
				return nil
			end

			if v2[groupValueObject.Value] then
				return groupValueObject.Value
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onChanged()
			local value

			if not (ZoneController.IsIndoors or ZoneController.IsFakeUnderwater or not v2[groupValueObject.Value]) then
				value = groupValueObject.Value
			end

			if v3 == value then
				return
			end

			if v3 then
				onDeactivate() -- equivalent call inferred; original call site unknown
				v3 = nil
			end

			if value then
				v3 = value
				onActivate(value)
			end
		end

		groupValueObject.Changed:Connect(onChanged)
		ZoneController.ZoneChanged:Connect(onChanged)
		onChanged() -- equivalent call inferred; original call site unknown
	end
}