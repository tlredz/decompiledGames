local success, _ = pcall(function()
	game:GetService("RunService")
end)
local success2, _ = pcall(function()
	require("@lune/datetime")
end)
return table.freeze({
	IS_RBX_ENV = success,
	IS_LUNE_ENV = success2
})