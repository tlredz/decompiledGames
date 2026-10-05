local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {}
local CountableDevProductController = {}

for _, v2 in CountableDevProducts.All do
	v[CountableDevProducts.GetId(v2)] = Signal.new()
end

local function getCountById(p: number)
	local clientReplica = ReplicatedDataController.clientReplica

	if clientReplica == nil or clientReplica.Data == nil then
		return 0
	end

	local countableDevProducts = clientReplica.Data.countableDevProducts

	if countableDevProducts == nil then
		return 0
	end

	return countableDevProducts[tostring(p)] or 0
end

function CountableDevProductController.PromptPurchase(p, value: string)
	local v2

	if typeof(value) == "string" then
		v2 = string.len(value) <= 100
	else
		v2 = false
	end

	assert(v2, "source must be a string up to 100 chars")
	local v3 = Remotes.invokeServer("PromptCountableProduct", value, CountableDevProducts.GetId(p))

	if v3 == "OK" or v3 == "AT_CAP" or v3 == "BACKEND_ERROR" then
		return v3
	end

	return "BACKEND_ERROR"
end

function CountableDevProductController.GetCount(p)
	local id = CountableDevProducts.GetId(p)
	local clientReplica = ReplicatedDataController.clientReplica

	if clientReplica == nil or clientReplica.Data == nil then
		return 0
	end

	local countableDevProducts = clientReplica.Data.countableDevProducts

	if countableDevProducts == nil then
		return 0
	end

	return countableDevProducts[tostring(id)] or 0
end

function CountableDevProductController.GetCountChangedSignal(p)
	return v[CountableDevProducts.GetId(p)]
end

function CountableDevProductController.FrameworkInit() end

function CountableDevProductController.FrameworkStart()
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object)
		object:OnSet({ "countableDevProducts" }, function(options, options2)
			local v2 = options or {}
			local v3 = options2 or {}

			for k, v4 in v do
				local v5 = tostring(k)
				local v6 = v2[v5] or 0

				if v6 ~= (v3[v5] or 0) then
					v4:Fire(v6)
				end
			end
		end)
	end)
end

return CountableDevProductController