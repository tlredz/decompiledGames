local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DecalPicker = require(ReplicatedStorage.Modules.DecalPicker)
local Network = require(ReplicatedStorage.Modules.Network)
local GamepassUtil = require(ReplicatedStorage.Modules.GamepassUtil)
local UI = require(ReplicatedStorage.Modules.UI)
local localPlayer = Players.LocalPlayer
local edit = script:FindFirstAncestorOfClass("Frame").Corner.Edit
local v = DecalPicker.new({
	Name = "Background",
	Key = "CommentBackground",
	DefaultSearchText = "background",
	Size = UDim2.new(0, 126, 0, 140)
})
edit.Button.Activated:Connect(function()
	local commentId = localPlayer:GetAttribute("CommentId")

	if commentId == 0 then
		commentId = nil
	end

	if not localPlayer:GetAttribute("ProfileColors") then
		return GamepassUtil:DisplayGamepassInfo("ProfileColors")
	end

	v:Show(commentId)
end)
v.ImageChanged:Connect(function(p: number?)
	Network:fire("Comment/SetCommentsBackground", p)
end)
UI:Bind(edit.Button)
UI:AddShadowOnHover(edit)
return nil