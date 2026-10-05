local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
return function(instance, imageTransparency: number)
	local root = ReactRoblox.createRoot(instance)
	local element = React.createElement(parentModule, {
		ImageTransparency = imageTransparency,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1)
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
	return cleanUp
end