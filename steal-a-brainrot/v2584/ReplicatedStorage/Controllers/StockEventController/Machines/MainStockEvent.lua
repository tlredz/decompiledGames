local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local stockEventController = ReplicatedStorage.Controllers.StockEventController
local ClientAPI = require(stockEventController.ClientAPI)
local module = require(stockEventController)
local Truck = require(stockEventController.Interfaces.Truck)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local v = ClientAPI.create("Taco14")
return {
	Start = function(_)
		Observers.observeAttribute(ReplicatedStorage, "StockEvent", function(p)
			if not p then
				return nil
			end

			local listItems, v2 = v:ListItems()

			if not listItems or typeof(v2) ~= "table" then
				return nil
			end

			local v3 = Truck:Setup(v, v2)
			local v4 = Observers.observeTag("StockMachinePrompt", function(p2)
				local maid = Trove.new()

				local function updatePrompt()
					if not Synchronizer:Wait(localPlayer) then
						return
					end

					p2.Enabled = module:IsEnabled()
				end

				maid:Add(task.spawn(function()
					if not Synchronizer:Wait(localPlayer) then
						return
					end

					maid:Add(Timer.Simple(1, updatePrompt))
					task.spawn(updatePrompt)
				end))
				maid:Add(p2.Triggered:Connect(function()
					if not Synchronizer:Get(localPlayer) then
						return
					end

					v3:Toggle()
				end))
				return function()
					maid:Destroy()
				end
			end)
			local v5 = Observers.observeTag("StockMachine", function(p2)
				local touchedConnection = p2.DeliveryHitbox.Touched:Connect(function(otherPart)
					if otherPart.Name ~= "HumanoidRootPart" then
						return
					end

					local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

					if not playerFromCharacter or playerFromCharacter ~= localPlayer or not playerFromCharacter:GetAttribute("StealingIndex") or not module:IsEnabled() then
						return
					end

					local v6, _, _ = Net:RemoteFunction("StockEventService/Delivery"):InvokeServer(
						v.MachineName,
						p2.DeliveryHitbox
					)

					if not v6 then
						return
					end

					task.spawn(function()
						SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx["Fuse Machine"].Deposit)
					end)
				end)
				return function()
					touchedConnection:Disconnect()
				end
			end)
			return function()
				v3:Close()
				v3:Destroy()
				v4()
				v5()
			end
		end)
	end
}