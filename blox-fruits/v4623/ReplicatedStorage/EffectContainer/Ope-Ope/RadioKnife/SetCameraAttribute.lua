local currentCamera = workspace.CurrentCamera
return function(list)
	local v, v2 = unpack(list)
	currentCamera[v] = v2
end