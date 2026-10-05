local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ButtonHintStrip = require(ReplicatedStorage.Client.ButtonHintStrip)
local EggPlacementRaycast = require(ReplicatedStorage.Shared.Eggs.EggPlacementRaycast)
local EggState = require(ReplicatedStorage.Client.EggState)
local EggToolDisplay = require(ReplicatedStorage.Shared.Eggs.EggToolDisplay)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PlacedEggRenderer = require(ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Trove = require(ReplicatedStorage.Packages.Trove)
local buttonR2 = Enum.KeyCode.ButtonR2
local localPlayer = Players.LocalPlayer
local maid = Trove.new()
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function showInvalidPlacement()
			Toast.Show({
				Text = "Cannot place egg here!",
				Seconds = 2,
				Color = Color3.fromRGB(255, 80, 80)
			})
		end

		local function tryPlace(p)
			local toolUid = EggToolDisplay.GetToolUid(p)

			if toolUid == nil then
				showInvalidPlacement() -- equivalent call inferred; original call site unknown
				return
			end

			local plot = PlotState.ResolvePlot()

			if plot == nil then
				showInvalidPlacement() -- equivalent call inferred; original call site unknown
				return
			end

			local petArea = plot.PetArea
			local raycast = EggPlacementRaycast.Raycast(petArea, localPlayer.UserId)

			if raycast == nil or raycast.Instance ~= petArea then
				showInvalidPlacement() -- equivalent call inferred; original call site unknown
				return
			end

			local objectSpace = plot.CenterPoint.CFrame:ToObjectSpace(CFrame.new(raycast.Position))
			local plantEgg, v = EggState.PlantEgg(toolUid, objectSpace)

			if plantEgg then
				PlacedEggRenderer.Refresh()
			else
				Toast.Show({
					Text = v or "Cannot place egg here!",
					Seconds = 2,
					Color = Color3.fromRGB(255, 80, 80)
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function canPlaceFromHere()
			if not PlatformController.IsConsole() then
				return false
			end

			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
				return false
			end

			return PlotState.ContainsLocalPoint(humanoidRootPart.Position)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshPlacePrompt()
			-- equivalent call inferred; original call site unknown
			if canPlaceFromHere() then
				ButtonHintStrip.Present("EggPlacement", buttonR2, "Place Egg")
			else
				ButtonHintStrip.Retract("EggPlacement")
			end
		end

		local function bindTool(child)
			maid:Clean()
			maid:Connect(child.Activated, function()
				tryPlace(child)
			end)
			local total = 0
			maid:Connect(RunService.Heartbeat, function(p: number)
				total += p

				if total < 0.2 then
					return
				end

				total = 0
				refreshPlacePrompt() -- equivalent call inferred; original call site unknown
			end)
			maid:Add(function()
				ButtonHintStrip.Retract("EggPlacement")
			end)
			refreshPlacePrompt() -- equivalent call inferred; original call site unknown
		end

		local function refreshCharacter(instance)
			maid:Clean()

			for _, child in ipairs(instance:GetChildren()) do
				if not (child.ClassName == "Tool" and EggToolDisplay.IsEggTool(child)) then
					continue
				end

				bindTool(child)
				break
			end
		end

		local function bindCharacter(character)
			refreshCharacter(character)
			character.ChildAdded:Connect(function(child)
				if child.ClassName == "Tool" and EggToolDisplay.IsEggTool(child) then
					bindTool(child)
				end
			end)
			character.ChildRemoved:Connect(function(child)
				if child.ClassName == "Tool" and EggToolDisplay.IsEggTool(child) then
					maid:Clean()
				end
			end)
		end

		localPlayer.CharacterAdded:Connect(bindCharacter)
		Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
			PlacedEggRenderer.SetPromptsSuppressed(p ~= nil)
		end)

		if localPlayer.Character ~= nil then
			bindCharacter(localPlayer.Character)
		end

		Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			local character = localPlayer.Character

			if character ~= nil then
				refreshCharacter(character)
			end
		end)
	end
}