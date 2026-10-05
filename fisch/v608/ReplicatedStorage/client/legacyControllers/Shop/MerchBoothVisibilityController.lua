local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local client = ReplicatedStorage:WaitForChild("client")
client:WaitForChild("modules")
ReplicatedStorage:WaitForChild("events")
client:WaitForChild("legacyControllers")
local Trove = require(packages.Trove)
require(packages.Signal)
local Observers = require(packages.Observers)
local module = require("./OfficialCommerceController")
local localPlayer = Players.LocalPlayer
local policyCommerceProduct = localPlayer:GetAttribute("PolicyCommerceProduct")
local v = {}
local MerchBoothVisibilityController = {}

function MerchBoothVisibilityController:HideMerchBooth()
	local v2 = Observers.observeTag("hideIfNoPolicyProduct", function(model)
		local v3 = {}

		if model:IsA("Model") then
			local children = model:GetChildren()

			for _, instance in children do
				if instance:IsA("Model") then
					local v4 = {
						Parent = instance.Parent
					}
					instance.Parent = ReplicatedStorage
					v3[instance] = v4
				elseif instance:IsA("Part") then
					local v4 = {
						Enabled = instance.BillboardGui.Enabled
					}
					instance.BillboardGui.Enabled = true
					v3[instance.BillboardGui] = v4
				end
			end
		end

		return function()
			for k, v4 in v3 do
				if not (k and k.Parent) then
					continue
				end

				for k2, v5 in v4 do
					k[k2] = v5
				end
			end
		end
	end)
	local policyCommerceProductChangedConnection = nil
	policyCommerceProductChangedConnection = localPlayer:GetAttributeChangedSignal("PolicyCommerceProduct"):Connect(function()
		policyCommerceProduct = localPlayer:GetAttribute("PolicyCommerceProduct")

		if policyCommerceProduct then
			v2()
			policyCommerceProductChangedConnection:Disconnect()
		end
	end)
end

function MerchBoothVisibilityController:Start()
	if not policyCommerceProduct then
		self:HideMerchBooth()
	end

	Observers.observeTag("MerchHitBox", function(p)
		local maid = Trove.new()
		maid:Add(p.Touched:Connect(function(otherPart)
			local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

			if playerFromCharacter and playerFromCharacter == game.Players.LocalPlayer then
				if v[playerFromCharacter] then
					return
				end

				v[playerFromCharacter] = true
				module:ToggleVisibility(true)
			end
		end))
		maid:Add(p.TouchEnded:Connect(function(otherPart)
			local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

			if playerFromCharacter and playerFromCharacter == game.Players.LocalPlayer then
				module:ToggleVisibility(false)
				v[playerFromCharacter] = nil
			end
		end))
		return function()
			maid:Destroy()
		end
	end)
end

return MerchBoothVisibilityController