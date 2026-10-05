local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local GamepassUtil = require(ReplicatedStorage.Modules.GamepassUtil)
local localPlayer = Players.LocalPlayer
local decalPicker = localPlayer:WaitForChild("PlayerGui"):WaitForChild("DecalPicker")
local Picker = require(decalPicker.Picker)
local image = script:FindFirstAncestorOfClass("Frame").AddComment.Image
local v = Picker.new({
	Name = "Image",
	Key = "CommentImage"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function updateImageDisplay()
	local imageId = image:GetAttribute("ImageId")

	if imageId then
		image.ImageLabel.Image = `https://www.roblox.com/asset-thumbnail/image?assetId={imageId}&width=420&height=420&format=png`
	else
		image.ImageLabel.Image = ""
	end

	image.ImageLabel.Visible = imageId and true or false
	image.Empty.Visible = not imageId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateLockedStatus()
	image.Locked.Visible = false
end

image.Button.Activated:Connect(function()
	if image.Locked.Visible then
		GamepassUtil:PromptGamepass("ImagePerms")
	else
		v:Show(image:GetAttribute("ImageId"))
	end
end)
v.ImageChanged:Connect(function(imageId: number?)
	if imageId == 0 then
		imageId = nil
	end

	image:SetAttribute("ImageId", imageId)
end)
UI:Bind(image.Button)
UI:AddShadowOnHover(image)
image:GetAttributeChangedSignal("ImageId"):Connect(updateImageDisplay)
localPlayer:GetAttributeChangedSignal("ImagePerms"):Connect(updateLockedStatus)
updateImageDisplay() -- equivalent call inferred; original call site unknown
updateLockedStatus() -- equivalent call inferred; original call site unknown
return nil