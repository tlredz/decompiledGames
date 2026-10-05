local ContentProvider = game:GetService("ContentProvider")
local v = {}
return {
	preload = function(instance)
		local proxyTexture = instance:GetAttribute("ProxyTexture")

		if typeof(proxyTexture) ~= "string" or proxyTexture == "" then
			proxyTexture = instance.Texture
		end

		instance.Texture = proxyTexture

		if proxyTexture == "" or v[proxyTexture] then
			return
		end

		v[proxyTexture] = true
		task.spawn(function()
			local v2 = false

			if not (pcall(function()
				ContentProvider:PreloadAsync({ proxyTexture }, function(_, p)
					v2 = p == Enum.AssetFetchStatus.Success
				end)
			end) and v2) then
				v[proxyTexture] = nil
			end
		end)
	end
}