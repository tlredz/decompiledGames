local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = Component.new({
	Tag = "DestroyIfMobile"
})

function v.Construct(_) end

function v.Start(p)
	if Platform.IsMobile() then
		p.Instance:Destroy()
	end
end

function v.Stop(_) end

return v