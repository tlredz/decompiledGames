local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Icons = require(script.Icons)
local ImagePreloader = require(ReplicatedStorage.Client.ImagePreloader)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
return {
	Start = function()
		ImagePreloader.RequestAll(TableUtil.Values(Icons.Preload))

		local function onImageLabelAdded(image)
			if typeof(image) ~= "Instance" or not image:IsA("ImageLabel") then
				return
			end

			local iconId = image:GetAttribute("IconId")
			local image2 = iconId and Icons.All[iconId]

			if image2 then
				image.Image = image2
			else
				warn("Invalid icon id", iconId, " | ", image:GetFullName())
			end
		end

		CollectionService:GetInstanceAddedSignal("ICON"):Connect(onImageLabelAdded)

		for _, v in CollectionService:GetTagged("ICON") do
			task.spawn(onImageLabelAdded, v)
		end
	end
}