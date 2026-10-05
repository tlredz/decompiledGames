local HalloweenHouseClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.NewHouseLit:Connect(function()
	Client.Sound.Play("HalloweenTreat", {
		Volume = 0.15
	})
	Client.Events.SetPopUpMessage:Fire("a new house is ready to Trick or Treat")
end)

function HalloweenHouseAdded(instance)
	if not instance:IsDescendantOf(workspace) or instance:GetAttribute("AlwaysActivated") then
		return
	end

	local flag = false
	instance:WaitForChild("Functional"):WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if flag or parent:GetAttribute("BeingUsed") or instance:GetAttribute("Activated") or parent:GetAttribute("Destroyed") then
			return
		end

		if instance:GetAttribute("LocalActivated") then
			return
		end

		if parent.Name == "Halloween Candle" then
			local function undo()
				instance:SetAttribute("LocalActivated", nil)
				parent:SetAttribute("BeingUsed", nil)
				parent.Parent = workspace.Items

				if not instance:GetAttribute("Activated") then
					Client.HalloweenUtil.SetHouseActivated(instance, false)
				end
			end

			flag = true
			parent:SetAttribute("BeingUsed", true)
			instance:SetAttribute("LocalActivated", true)
			Client.Sound.Play("HalloweenTreat")
			parent.Parent = game.ReplicatedStorage.TempStorage
			Client.HalloweenUtil.SetHouseActivated(instance, true)
			local pivot = parent:GetPivot()
			Client.Utility.SpawnParticles("PlaceCandle", pivot)
			local v = Client.Events.RequestActivateHalloweenHouse:InvokeServer(parent, instance)
			task.delay(1, function()
				flag = nil
				instance:SetAttribute("LocalActivated", nil)
			end)

			if not (v and v.Success) then
				task.spawn(function()
					wait(0.5)
					undo()
				end)
			end
		end
	end)
end

function HalloweenHouseClient.Init()
	Client.Utility.ForAllTagged("HalloweenHouse", HalloweenHouseAdded)
end

return HalloweenHouseClient