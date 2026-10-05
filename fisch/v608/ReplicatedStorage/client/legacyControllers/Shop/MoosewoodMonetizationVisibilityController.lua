game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local modules = ReplicatedStorage.client.modules
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
local Observers = require(packages.Observers)
local level = legacyLocalPlayerData.fetch():WaitForChild("Stats"):FindFirstChild("level")
local MoosewoodMonetizationVisibilityController = {}

function MoosewoodMonetizationVisibilityController:HideMonetizationNPCs()
	local v = Observers.observeTag("HideIfLevelUnder25", function(model)
		local v2 = {}

		if model:IsA("Model") then
			local v3 = {
				Parent = model.Parent
			}
			model.Parent = ReplicatedStorage
			v2[model] = v3
		end

		return function()
			for k, v3 in v2 do
				if not (k and k.Parent) then
					continue
				end

				for k2, v4 in v3 do
					k[k2] = v4
				end
			end
		end
	end)
	local changedConnection = nil
	changedConnection = level.Changed:Connect(function()
		if level.Value >= 25 then
			v()
			changedConnection:Disconnect()
		end
	end)
end

function MoosewoodMonetizationVisibilityController:Start()
	if level.Value < 25 then
		self:HideMonetizationNPCs()
	end
end

return MoosewoodMonetizationVisibilityController