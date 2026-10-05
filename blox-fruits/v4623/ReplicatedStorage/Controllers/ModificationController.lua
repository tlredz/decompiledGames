local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local Display = require(game.ReplicatedStorage.Packages.Display)
local ItemReplication = require(game.ReplicatedStorage.Util.ItemReplication)
local Net = require(game.ReplicatedStorage.Modules.Net)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("Controller"):traceback():display(Display.JSON.new():setIndentWith(" "):build()):build()
local class = {}
class.__index = class

function class:SetEquipAsync(itemId: number, isEquipped: boolean)
	local extended = v.extend(":SetEquipAsync")
	extended.info((`calling fn: (modId={itemId}, isEquipped={isEquipped})`))
	local v2 = self._RemoteFunction:InvokeServer({
		Type = "SetEquip",
		ItemId = itemId,
		IsEquipped = isEquipped
	})
	extended.trace(function()
		local v3 = "server equip response"

		if v2.Type == "GetData" then
			return v3, {
				Type = v2.Type,
				Data = Modification.Data.Modification.debug(v2.Data)
			}
		end

		return v3, v2
	end)
	return v2
end

return ServiceLocker(function()
	local object = setmetatable({
		IsInitialized = true,
		_RemoteEvent = Net:RemoteEvent("ModificationEvent"),
		_RemoteFunction = Net:RemoteFunction("ModificationFunction"),
		_Connections = {},
		_Callbacks = {},
		OnEquip = Signal.new(),
		OnUnequip = Signal.new(),
		OnUnlock = Signal.new()
	}, class)
	task.spawn(function()
		task.wait()

		if not object.IsInitialized then
			return
		end

		table.insert(
			object._Callbacks,
			ItemReplication.IsOwned.onUpdateLoop(function(p: number, _: string?, flag: boolean?)
				if (Modification.getIfModification(p) or Modification.getIfAdornee(p)) and flag then
					object.OnUnlock:Fire(p)
				end
			end)
		)
		table.insert(
			object._Callbacks,
			ItemReplication.IsEquipped.onUpdateLoop(function(p: number, _: string?, flag: boolean?)
				if Modification.getIfModification(p) or Modification.getIfAdornee(p) then
					if flag then
						object.OnEquip:Fire(p)
					else
						object.OnUnequip:Fire(p)
					end
				end
			end)
		)
	end)
	return object
end, function(data)
	data.OnEquip:Destroy()
	data.OnUnequip:Destroy()
	data.OnUnlock:Destroy()
	data._RemoteEvent:Destroy()
	data._RemoteFunction:Destroy()

	for _, _Callback in data._Callbacks do
		local v2 = _Callback
		task.spawn(function()
			v2()
		end)
	end

	for _, _Connection in data._Connections do
		_Connection:Disconnect()
	end
end)