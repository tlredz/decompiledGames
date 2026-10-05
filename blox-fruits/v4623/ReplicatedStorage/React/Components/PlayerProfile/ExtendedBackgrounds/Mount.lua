local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local dogeProfileFullArt = script.Parent:FindFirstChild("Doge Profile Full Art")
local vaporwaveFullArt = script.Parent:FindFirstChild("Vaporwave Full Art")
return function(p: string, instance)
	local root = ReactRoblox.createRoot(instance)
	local module = nil

	if dogeProfileFullArt and p == "Doge Profile Full Art" then
		module = require(dogeProfileFullArt)
	elseif vaporwaveFullArt and p == "Vaporwave Profile Full Art" then
		module = require(vaporwaveFullArt)
	end

	if not module then
		warn((`{p} is not setup`))
		return function() end, false
	end

	local element = React.createElement(module, {
		PreviewModel = true
	})
	root:render(ReactRoblox.createPortal(element, instance))
	local v = true
	local destroyingConnection = nil

	local function cleanUp()
		if not v then
			return
		end

		v = false
		root:unmount()

		if destroyingConnection then
			destroyingConnection:Disconnect()
		end
	end

	destroyingConnection = instance.Destroying:Connect(cleanUp)
	return cleanUp, true
end