game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage.packages
local Observers = require(packages.Observers)
local Net = require(packages.Net)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local CutsceneController = require(legacyControllers.CutsceneController)
local SharedTerrapinExpansion = require(ReplicatedStorage.shared.modules.SharedTerrapinExpansion)
local _ = SharedTerrapinExpansion.Functions
local module = require("@self/LocalDataState")
local remoteEvent = Net:RemoteEvent("GuardCaught", 1e999)
local TerrapinExpansionController = {}

function TerrapinExpansionController.Start(_)
	remoteEvent.OnClientEvent:Connect(function()
		CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(1, 3)
	end)

	for _, child in script.Systems:GetChildren() do
		local success, result = pcall(require, child)

		if not success then
			warn(result)
		end
	end

	require("@self/Components")
	DataController.PlayerDataReplicator:Observe({ "TerrapinExpansion" }, TerrapinExpansionController._OnDataChanged)
	TerrapinExpansionController._StartEidolodonObtainment()
end

function TerrapinExpansionController._OnDataChanged(p)
	if not p then
		return
	end

	module:set(p)

	if p.UnlockedSanctum then
		Observers.observeTag("DeleteOnSanctumUnlocked", function(instance)
			instance:Destroy()
			return function() end
		end)
	end
end

function TerrapinExpansionController._StartEidolodonObtainment()
	task.defer(function()
		local count = 0
		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local v = {}
		Observers.observeTag("EidolodonObtainment", function(instance)
			local rig = instance:WaitForChild("rig"):WaitForChild("rig")

			for _, part in rig.Parent:GetDescendants() do
				if part ~= rig and part:IsA("BasePart") then
					part.Anchored = false
				end
			end

			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.ActionText = "Turn"
			proximityPrompt.ObjectText = "Obelisk"
			proximityPrompt.HoldDuration = 0
			proximityPrompt.Enabled = not v[instance.Name]
			proximityPrompt.Parent = rig
			proximityPrompt.Triggered:Connect(function()
				if v[instance.Name] then
					return
				end

				v[instance.Name] = true
				count += 1
				proximityPrompt.Enabled = false

				if count == 15 then
					TerrapinExpansionController._OnAllSwitchesActivated()
				end

				local tween = TweenService:Create(rig, tweenInfo, {
					CFrame = rig.CFrame * CFrame.fromOrientation(0, 0.6981317007977318, 0)
				})
				tween:Play()
				local turnSound = rig:WaitForChild("TurnSound")
				turnSound:Play()
				tween.Completed:Once(function()
					turnSound:Stop()
				end)
			end)
			return function()
				if proximityPrompt then
					proximityPrompt:Destroy()
				end
			end
		end)
		Observers.observeTag("EidolonRodInteractable", function(instance)
			local promptTemplate = instance:WaitForChild("PromptTemplate")
			promptTemplate.Enabled = count >= 15
			return function() end
		end)
		Observers.observeTag("MakeSureIStreamPleaseHatch", function(parent)
			task.wait(1)

			if not parent.Parent then
				return
			end

			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.ActionText = "Open"
			proximityPrompt.HoldDuration = 3
			proximityPrompt.Enabled = count < 15
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.Parent = parent
			proximityPrompt.Triggered:Connect(function()
				if count == 14 then
					ReplicatedStorage.events.anno_localthought:Fire("One obelisk remains...")
				else
					ReplicatedStorage.events.anno_localthought:Fire((`{15 - count} obelisks remain...`))
				end
			end)
			return function()
				if proximityPrompt then
					proximityPrompt:Destroy()
				end
			end
		end)
	end)
end

function TerrapinExpansionController._OnAllSwitchesActivated()
	Observers.observeTag("MakeSureIStreamPleaseHatch", function(instance)
		instance:Destroy()
		return function() end
	end)

	for _, v in CollectionService:GetTagged("EidolonRodInteractable") do
		local v2 = v
		task.spawn(function()
			local promptTemplate = v2:WaitForChild("PromptTemplate")
			promptTemplate.Enabled = true
		end)
	end

	ReplicatedStorage.events.anno_localthought:Fire("You hear the sound of something opening...")
end

return TerrapinExpansionController