local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductController = {}
local GlobalReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.GlobalReplicatedDataController)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)

function DevProductController.PromptPurchaseWithId(value: number, value2: string, p)
	local v

	if typeof(value2) == "string" then
		v = string.len(value2) <= 100
	else
		v = false
	end

	assert(v, "Source must be a string when firing DevProductController::PromptDevProductByName()")
	local v2

	if typeof(value) == "number" then
		v2 = value == value
	else
		v2 = false
	end

	assert(v2, "Developer product ID must be a number!")
	assert(DevProducts.Exists(value), "Dev product with id " .. value .. " does not exist")
	Remotes.fireServer("PromptProduct", value2, value, p)
end

DevProductController.OnPurchase = Signal.new()
local v = nil

local function runPendingPurchaseIfMatching(p: number)
	if v == nil or v.devProductId ~= p then
		return
	end

	if v.promptClosedAt ~= nil and os.clock() - v.promptClosedAt > 10 then
		v = nil
		return
	end

	local callback = v.callback
	v = nil
	task.spawn(callback)
end

function DevProductController.NotifyPurchasePromptStarted(devProductId: number, callback)
	if callback == nil then
		v = nil
	else
		v = {
			devProductId = devProductId,
			callback = callback
		}
	end
end

function DevProductController.FrameworkInit() end

function DevProductController.FrameworkStart()
	Remotes.connect("DevProductPromptPurchaseFinished", function(p: number, flag: boolean)
		if flag then
			Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()

			if v ~= nil and v.devProductId == p then
				v.promptClosedAt = os.clock()
			end
		elseif v ~= nil and v.devProductId == p then
			v = nil
		end
	end)
	GlobalReplicatedDataController.WaitForReplica():OnChange(function(p, list, items, _)
		local v2 = list[1] == tostring(Players.LocalPlayer.UserId)
		local v3 = list[2] == "profile"
		local v4 = list[3] == "devProducts"

		if p == "SetValues" and v2 and v3 and v4 then
			for k, item in items do
				if not item then
					continue
				end

				local v5 = tonumber(k)
				DevProductController.OnPurchase:Fire(v5)

				if not (v ~= nil and v.devProductId == v5) then
					continue
				end

				if v.promptClosedAt == nil or not (os.clock() - v.promptClosedAt > 10) then
					local callback = v.callback
					v = nil
					task.spawn(callback)
				else
					v = nil
				end
			end
		end
	end)
end

function DevProductController.IsOwned(p)
	local replicatedData = GlobalReplicatedDataController.GetReplicatedData(Players.LocalPlayer.UserId)

	if replicatedData == nil or replicatedData.profile == nil or replicatedData.profile.devProducts == nil then
		return false
	end

	local v2 = tostring(DevProducts.GetId(p))
	return replicatedData.profile.devProducts[v2] and true or false
end

return DevProductController