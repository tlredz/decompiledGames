local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local events = ReplicatedStorage:WaitForChild("events")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Observers = require(packages.Observers)
local Trove = require(packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local currentCamera = workspace.CurrentCamera
local remoteFunction = Net:RemoteFunction("Apollo/Instrument", 1e999)
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function doolDoolDool(instance, flag2: boolean?)
	if flag2 then
		instance:PivotTo(instance:GetPivot() * CFrame.new(0, 50, 0))
		return
	end

	local primaryPart = instance.PrimaryPart
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = primaryPart.CFrame * CFrame.new(-75, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
	local fastTween = GeneralUtils.fastTween(currentCamera, TweenInfo.new(15, Enum.EasingStyle.Linear), {
		CFrame = currentCamera.CFrame * CFrame.new(0, 0, 25)
	})
	task.delay(2.5, function()
		GeneralUtils.pivotTween(
			instance,
			TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			instance:GetPivot() * CFrame.new(0, 50, 0)
		)
		task.wait(6)
		fastTween:Cancel()
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.CFrame = CFrame.new()
	end)
end

local function CompletePuzzle(flag2: boolean?)
	if flag then
		return
	end

	flag = true

	for _, v in CollectionService:GetTagged("ApolloInstrument") do
		local proximityPrompt = v:FindFirstChildOfClass("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt:Destroy()
		end
	end

	local v = CollectionService:GetTagged("ApolloDoor")[1]

	if v then
		doolDoolDool(v, flag2)
	end
end

return {
	Start = function(_)
		Observers.observeTag("ApolloInstrument", function(model)
			if not model:IsA("Model") then
				return
			end

			local instrumentId = model:GetAttribute("InstrumentId")

			if not instrumentId then
				return
			end

			local primaryPart = model.PrimaryPart

			if not primaryPart then
				return
			end

			local proximityPrompt = model:FindFirstChildOfClass("ProximityPrompt")

			if proximityPrompt then
				if flag then
					proximityPrompt:Destroy()
				end
			else
				if flag then
					return
				end

				local maid = Trove.new()
				maid:AttachToInstance(model)
				local v = maid:Add(Instance.new("ProximityPrompt"))
				v.Style = Enum.ProximityPromptStyle.Custom
				v.Name = "Prompt"
				v.ActionText = "Play"
				v.ObjectText = model.Name
				v.HoldDuration = 0
				v.RequiresLineOfSight = false
				v.Parent = model
				maid:Add(v.Triggered:Connect(function()
					local v2, _ = remoteFunction:InvokeServer(instrumentId)

					if v2 == "correct" then
						if script[model.Name] then
							fx:PlaySound(script[model.Name], primaryPart)
						end

						local highlight = Instance.new("Highlight")
						highlight.FillColor = Color3.fromRGB(255, 255, 255)
						highlight.FillTransparency = 0.75
						highlight.OutlineTransparency = 1
						highlight.DepthMode = Enum.HighlightDepthMode.Occluded
						highlight.Enabled = true
						highlight.Parent = model
						highlight.Adornee = model
						GeneralUtils.fastTween(highlight, TweenInfo.new(3, Enum.EasingStyle.Linear), {
							FillTransparency = 1
						}).Completed:Once(function()
							highlight:Destroy()
						end)
					elseif v2 == "incorrect" then
						events.anno_localthought:Fire((`<font color="#{Color3.fromRGB(255, 84, 87):ToHex()}">That wasn't quite the right order...</font>`))
					elseif v2 == "complete" then
						task.spawn(CompletePuzzle)
					end
				end))
				return function()
					maid:Destroy()
				end
			end
		end)
		DataController.PlayerDataReplicator:Observe(
			{ "WrathOfOlympus", "Apollo", "InstrumentPuzzleCompleted" },
			function(p)
				if not p then
					return
				end

				task.spawn(CompletePuzzle, true)
			end
		)
		CollectionService:GetInstanceAddedSignal("ApolloDoor"):Connect(function(instance)
			DataController.PlayerDataReplicator:WaitForLoaded()

			if DataController.PlayerDataReplicator:Index({ "WrathOfOlympus", "Apollo", "InstrumentPuzzleCompleted" }) then
				doolDoolDool(instance, true) -- equivalent call inferred; original call site unknown
			end
		end)
	end
}