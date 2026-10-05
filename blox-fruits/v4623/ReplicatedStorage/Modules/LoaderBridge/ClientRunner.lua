local LoaderBridge = require(game.ReplicatedStorage.Modules.LoaderBridge)
local value = script.Module.Value
local module = require(value)
script:GetAttributeChangedSignal("CallMethod"):Connect(function()
	local v = module[script:GetAttribute("CallMethod")]

	if v and type(v) == "function" then
		debug.setmemorycategory(value.Name)
		v(module)
	end
end)
LoaderBridge.callback(value, module)