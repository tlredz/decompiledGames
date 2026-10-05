local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Observers = require(packages.Observers)
local Net = require(packages.Net)
local localPlayer = Players.LocalPlayer
local booth = localPlayer.PlayerGui:WaitForChild("Booth")
local SalesBoothClient = require(script.SalesBoothClient)
Net:RemoteEvent("SalesBoothService/UpdateInfo")
Net:RemoteFunction("SalesBoothService/RequestSalesBoothInfo")
local v = {}
local v2 = {}
local EditBooth = require(script.EditBooth)
v2.EditBooth = EditBooth.new(booth.EditBooth)
local SellItem = require(script.SellItem)
v2.SellItem = SellItem.new(booth.SellItem)
local BoothSkin = require(script.BoothSkin)
v2.BoothSkin = BoothSkin.new(booth.BoothSkin)

local function GetPlayerSalesBooth()
	for _, v3 in v do
		if v3:GetOwner() == localPlayer then
			return v3
		end
	end

	return nil
end

local function CloseCallback(p: string)
	if p == "EditBooth" then
		booth.Enabled = false
	end
end

local function OpenUI(p: string)
	for k, v3 in v2 do
		if p == k then
			v3:Toggle(true)
		else
			v3:Toggle(false)
		end
	end

	booth.Enabled = true
end

local function SetupEditBooth()
	booth.EditBooth.Close.Activated:Connect(function()
		booth.Enabled = false
	end)
end

return {
	Start = function(_)
		local function refreshSalesBooth(p: string, p2)
			if v[p] then
				v[p]:UpdateInfo(p2)
			end
		end

		Observers.observeTag("SalesBooth", function(p)
			local v3 = SalesBoothClient.new(p, OpenUI)
			v[v3:GetUID()] = v3
			return function()
				v[v3:GetUID()] = nil
				v3:Destroy()
			end
		end)

		for _, v3 in v2 do
			v3.CloseCallback = CloseCallback
			v3.OpenUI = OpenUI
		end

		booth.Enabled = false
	end
}