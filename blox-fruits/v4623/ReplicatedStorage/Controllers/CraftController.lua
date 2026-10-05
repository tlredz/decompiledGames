require(game.ReplicatedStorage.Modules.Util.Trove)
local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.Modules.Util.Signal)
local JuiceBar = require(game.ReplicatedStorage.ClientComponents.JuiceBar)
local v = nil
local v2 = nil
local CraftController = {
	GetRecipesAndMaterials = function(_)
		return v:InvokeServer({
			Context = "GetRecipesAndMaterials"
		})
	end,
	CraftSkin = function(_, storageName: string)
		return v:InvokeServer({
			Context = "Craft",
			StorageName = storageName
		})
	end
}

function startCutScene(storageName: string, value: string)
	assert(storageName, (`bad storageName: {storageName}`))
	assert(value and typeof(value) == "string", (`bad baristaId: "{value}" & "{typeof(value)}"`))
	local CollectionService = game:GetService("CollectionService")
	local v3 = nil

	for _, v5 in pairs(CollectionService:GetTagged("JuiceBar")) do
		if not v5:GetAttribute("BaristaId") then
			continue
		end

		v3 = v5
		break
	end

	local v5 = v3 and JuiceBar:FromInstance(v3)

	if v5 then
		task.spawn(function()
			local JuiceWindow = require(game.ReplicatedStorage.Controllers.UI.JuiceWindow)
			JuiceWindow:Close()
			local DialogueController = require(game.ReplicatedStorage.DialogueController)
			DialogueController.close()
		end)
		v5:Begin(storageName)
	else
		warn("Can't find juice bar?")
		task.spawn(function()
			Net:RemoteFunction("JuiceNetworkRF"):InvokeServer({
				Context = "FinishCraft",
				StorageName = storageName
			})
		end)
	end
end

function CraftController.OnStart(_)
	v = Net:RemoteFunction("JuiceNetworkRF")
	v2 = Net:RemoteEvent("JuiceNetworkRE")
	v2.OnClientEvent:Connect(function(data)
		if data.Context == "StartCutscene" then
			startCutScene(data.StorageName, data.BaristaId)
		end
	end)
end

return CraftController