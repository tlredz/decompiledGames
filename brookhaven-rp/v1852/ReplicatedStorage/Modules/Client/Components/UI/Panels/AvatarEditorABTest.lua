local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AvatarEditorABTest"
})

function v.Construct(_) end

function v.Start(p)
	local v2, v3 = ABTest.GetExperimentVariables("new-avatar-editor"):timeout(7):await()
	local hasneweditor

	if v2 then
		hasneweditor = v3["has-new-editor"]
	else
		hasneweditor = false
	end

	local uiClone = ReplicatedStorage:WaitForChild("UiClone")
	local avatarEditorMenu = uiClone:WaitForChild("AvatarEditorMenu")
	local avatarEditorMenu_OLD = uiClone:WaitForChild("AvatarEditorMenu_OLD")

	if hasneweditor then
		Debris:AddItem(avatarEditorMenu_OLD, 0)
	else
		Debris:AddItem(avatarEditorMenu, 0)
		avatarEditorMenu = avatarEditorMenu_OLD
	end

	avatarEditorMenu.Name = "AvatarEditorMenu"
	avatarEditorMenu.Parent = p.Instance.Parent
	Debris:AddItem(p.Instance, 0)
end

function v.Stop(_) end

return v