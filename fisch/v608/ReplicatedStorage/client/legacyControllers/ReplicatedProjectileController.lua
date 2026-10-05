local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
return {
	Start = function(_)
		local remoteEvent = Net:RemoteEvent("ProjectileFired", -1)
		local remoteEvent2 = Net:RemoteEvent("ProjectileStopped", -1)
		local modules = {}

		for _, moduleScript in script:GetChildren() do
			local module = require(moduleScript)
			module.Init()

			for _, v in module.Tags or { moduleScript.Name } do
				modules[v] = module
			end
		end

		remoteEvent.OnClientEvent:Connect(function(p)
			if modules[p.Projectile.Tag] then
				modules[p.Projectile.Tag].ProjectileCreated(p)
			else
				warn((`Projectile "{p.Projectile.Tag}" does not have an associated client module`))
			end
		end)
		remoteEvent2.OnClientEvent:Connect(function(p)
			if modules[p.Projectile.Tag] then
				modules[p.Projectile.Tag].ProjectileStopped(p)
			else
				warn((`Projectile "{p.Projectile.Tag}" does not have an associated client module`))
			end
		end)
	end
}