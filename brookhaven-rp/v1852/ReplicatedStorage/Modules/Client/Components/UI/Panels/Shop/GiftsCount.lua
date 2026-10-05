local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "GiftsCount"
})

function v.Construct(_) end

function v.Start(p)
	local instance = p.Instance

	if not instance:IsA("TextLabel") then
		warn("GiftsCount not on TextLabel!")
		return
	end

	local giftsCount_Text = instance:GetAttribute("GiftsCount_Text")
	assert(typeof(giftsCount_Text) == "string")
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object)
		instance.Text = giftsCount_Text:format((tostring(object.Data.giftsGiven)))
		object:OnSet({ "giftsGiven" }, function(p2)
			instance.Text = giftsCount_Text:format((tostring(p2)))
		end)
	end)
end

function v.Stop(_) end

return v