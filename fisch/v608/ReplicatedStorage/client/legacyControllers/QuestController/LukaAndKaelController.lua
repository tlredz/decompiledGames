local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local FollowingNpcController = require(legacyControllers.FollowingNpcController)
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Observers = require(packages.Observers)
local Trove = require(packages.Trove)
local v = nil
local maid = Trove.new()
local kael = nil
local clone = nil
local renderSteppedConnection = nil
local v2 = nil
local v3 = { "Devplace Island", "Azure Lagoon" }
local localPlayer = Players.LocalPlayer
local _ = CFrame.new(-555.992, 81.27, 1824.646) * CFrame.Angles(0, 0.7430739290365859, 0)
local customTarget = CFrame.new(-248.024, 75.627, -418.957) * CFrame.Angles(0, -2.1610841331118986, 0)
local cFrame = CFrame.new(1368.241, 94.2, 2300.052) * CFrame.Angles(1.5707963267948966, -0.06544984694978735, 0)
local events = ReplicatedStorage.events
local remoteEvent = Net:RemoteEvent("LukaAndKaelService/UpdateState")
local remoteEvent2 = Net:RemoteEvent("LukaAndKaelService/CollectPendant")
Net:RemoteEvent("LukaAndKaelService/FinalDialogue").OnClientEvent:Connect(function()
	ProximityPromptService.Enabled = false
	local v6 = {
		{ "Luka... I found it.", 1, "Kael" },
		{ "You were, Kael? I said we shouldn't go into the storm!", 3, "Luka" },
		{ "You kept going. You knew what happened last time with the pendant... Dad was never found!", 5, "Luka" },
		{ "Yeah... he did. That’s all I care about.", 2, "Luka" },
		{ "You said it was just fishing...", 2, "Luka" },
		{
			"I'm sorry, Luka. I never meant to hurt you. I just... I wanted to make Dad proud, even if he's gone.",
			2,
			"Kael"
		}
	}
	local _, _ = pcall(function()
		for i = 1, #v6 do
			local v7 = v6[i]
			local v8 = {
				dialog = {
					{
						text = v7[1],
						t = v7[2],
						choices = {}
					}
				}
			}
			local v9 = CollectionService:GetTagged((`{v7[3]}FinalNpc`))[1]

			if v9 then
				events.clientdialog:Fire(v8, v9:FindFirstChild("Head"), {
					dialog = v8.dialog
				})
				task.wait(v7[2] + 1)
			else
				print("model not found!")
				break
			end
		end
	end)
	ProximityPromptService.Enabled = true
end)
remoteEvent.OnClientEvent:Connect(function(p: string, flag: boolean)
	v2 = p

	if v then
		v()
		v = nil
	end

	v = Observers.observeTag("KaelNpc", function(instance)
		local parent = instance.Parent

		if instance:GetAttribute("Stage") == "Start" then
			if p == "LukaAndKael3" and flag == true or p == "LukaAndKael4" or p == "LukaAndKael5" or p == "End" then
				instance.Parent = ReplicatedStorage
			end
		elseif p ~= "End" then
			instance.Parent = ReplicatedStorage
		end

		return function()
			instance.Parent = parent
		end
	end)

	if p == "LukaAndKael3" and flag == true then
		clone = script["The Pendant"]:Clone()
		clone.Parent = workspace
		clone.PrimaryPart.CFrame = cFrame
		clone.Handle.ProximityPrompt.Triggered:Once(function()
			remoteEvent2:FireServer()
		end)
	elseif clone then
		clone:Destroy()
		clone = nil
	end

	if (p == "LukaAndKael3" or p == "LukaAndKael4") and flag == true then
		if not kael then
			kael = FollowingNpcController:New("Kael")
			maid:Add(kael, "Destroy")
			maid:Add(remoteEvent2.OnClientEvent:Connect(function()
				local thread = coroutine.running()
				maid:Add(thread)
				kael:LoadDialogue(nil, nil, "*Kael takes the pendant from your hands.*")
				task.wait(3)
				kael:LoadDialogue(
					nil,
					nil,
					"That's why I told him we were just fishing. He wouldn't have let me try to find it, but it's important. I didn't want to worry him."
				)
				maid:Remove(thread)
			end))
		end

		if renderSteppedConnection == nil then
			local v6 = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local zone = character and character:FindFirstChild("zone")

				if humanoidRootPart and v2 == "LukaAndKael4" and (customTarget.Position - humanoidRootPart.Position).Magnitude <= 30 then
					kael.focused = true
					kael.customTarget = customTarget
					kael.customMinDistance = 1
				end

				if zone and zone.Value and v2 == "LukaAndKael3" then
					local name = zone.Value.Name

					if table.find(v3, name) and name ~= v6 then
						v6 = name
						kael:LoadDialogue(nil, nil, "There’s a pendant somewhere here. I need your help finding it.")
					end
				end
			end)
		end
	else
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		maid:Clean()
		kael = nil
	end
end)
return {}