local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
require(ReplicatedStorage.Parts.RenderModules.TBLunge)
return {
	setupAll = function()
		local gui = GameContext.Gui
		local events = ReplicatedStorage.Events
		local itemMessage = gui:WaitForChild("ItemMessage")
		local messageText = gui:WaitForChild("MessageText")
		local itemInfo = gui:WaitForChild("ItemInfo")
		local cantUse = gui:WaitForChild("CantUse")
		local popUp = gui:WaitForChild("PopUp")
		local position = itemMessage.Position
		local lastTime = tick()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
		events.WarnUser.OnClientEvent:Connect(function(p, p2)
			if GameContext.ErrorMessage then
				GameContext.ErrorMessage(p, p2)
			end
		end)
		events.MessageEvent.OnClientEvent:Connect(function(p)
			if not (messageText and itemInfo and itemMessage and cantUse) then
				return
			end

			messageText.Text = tostring(p)
			itemInfo.Visible = false
			itemMessage.Visible = false
			messageText.Position = position + UDim2.new(0, 0, -0.075, 0)
			messageText.Visible = true
			cantUse:Stop()
			cantUse:Play()
			TweenService:Create(messageText, tweenInfo, {
				Position = position
			}):Play()
			lastTime = tick()
			task.delay(1.05, function()
				if tick() - lastTime >= 1 then
					messageText.Visible = false
				end
			end)
		end)
		events.TextEvent.OnClientEvent:Connect(function(p)
			if GameContext.QueueTextMessage then
				GameContext.QueueTextMessage(p)
			end
		end)
		events.RenderObject.OnClientEvent:Connect(function(moduleScript, p)
			local success, result = pcall(function()
				local module = moduleScript and require(moduleScript)

				if module then
					module.RenderObject(p)
				end
			end)

			if not success then
				warn(result)
			end
		end)
		events.PopUpEvent.OnClientEvent:Connect(function(image)
			if not popUp then
				return
			end

			local clone = popUp:Clone()
			CollectionService:AddTag(clone, "PopUp")
			clone.Parent = gui
			clone.Name = "TemporaryPopUp"
			clone.ImageLabel.Image = image
			clone.LocalScript.Disabled = false
		end)
		local flag = false
		ReplicatedStorage.DataLoaded.OnClientEvent:Connect(function()
			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false

				if GameContext.Update_Stats then
					GameContext.Update_Stats()
				end
			end)
		end)
	end
}