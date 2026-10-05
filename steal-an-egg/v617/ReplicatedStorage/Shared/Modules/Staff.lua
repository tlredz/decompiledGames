local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StaffTagFlags = require(ReplicatedStorage.Shared.Flags.StaffTagFlags)
local v = { "Assets", "Billboards", "StaffTag" }
local v2 = {
	Owner = "OwnerLabel",
	Admin = "AdminLabel",
	Developer = "DeveloperLabel"
}
local v3 = {
	Owner = "OwnerChatLabel",
	Admin = "AdminChatLabel",
	Developer = "DeveloperChatLabel"
}
local v4 = {
	Owner = "OwnerColor",
	Admin = "AdminColor",
	Developer = "DeveloperColor"
}
local v5 = {
	Owner = "OwnerLightColor",
	Admin = "AdminLightColor",
	Developer = "DeveloperLightColor"
}
local v6 = {
	Owner = "OWNER",
	Admin = "ADMIN",
	Developer = "DEVELOPER"
}
local v7 = {
	Owner = "OWNER",
	Admin = "ADMIN",
	Developer = "DEV"
}
local v8 = {
	Owner = Color3.fromRGB(255, 68, 68),
	Admin = Color3.fromRGB(255, 68, 68),
	Developer = Color3.fromRGB(64, 156, 255)
}
local v9 = {
	Owner = Color3.fromRGB(255, 176, 176),
	Admin = Color3.fromRGB(255, 176, 176),
	Developer = Color3.fromRGB(168, 220, 255)
}
local Staff = {
	Changed = StaffTagFlags.Changed
}

local function template()
	local billboardGui = ReplicatedStorage

	for _, childName in v do
		if billboardGui then
			billboardGui = billboardGui:FindFirstChild(childName)
		else
			billboardGui = nil
		end
	end

	if billboardGui and billboardGui:IsA("BillboardGui") then
		return billboardGui
	end

	return nil
end

local function chatBadge(p: string, color: Color3)
	return table.concat({
		"<font color=\"#",
		color:ToHex(),
		"\">[",
		p,
		"]</font>"
	})
end

function Staff.RoleOf(p)
	if StaffTagFlags.Enabled:Get() then
		return StaffTagFlags.Roles:Get()[tostring(p)]
	end

	return nil
end

function Staff.LabelOf(p)
	local v10 = template()
	local attribute

	if v10 then
		attribute = v10:GetAttribute(v2[p])
	end

	if typeof(attribute) == "string" and attribute ~= "" then
		return attribute
	end

	return v6[p]
end

function Staff.ChatLabelOf(p)
	local v10 = template()
	local attribute

	if v10 then
		attribute = v10:GetAttribute(v3[p])
	end

	if typeof(attribute) == "string" and attribute ~= "" then
		return attribute
	end

	return v7[p]
end

function Staff.OverheadLabel(p)
	return string.format("[%s]", Staff.LabelOf(p))
end

function Staff.ColorOf(p)
	local v10 = template()
	local attribute

	if v10 then
		attribute = v10:GetAttribute(v4[p])
	end

	if typeof(attribute) == "Color3" then
		return attribute
	end

	return v8[p]
end

function Staff.LightColorOf(p)
	local v10 = template()
	local attribute

	if v10 then
		attribute = v10:GetAttribute(v5[p])
	end

	if typeof(attribute) == "Color3" then
		return attribute
	end

	return v9[p]
end

function Staff.GradientOf(p)
	local color = Staff.ColorOf(p)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, Staff.LightColorOf(p)),
		ColorSequenceKeypoint.new(1, color)
	})
end

function Staff.ChatTag(p)
	local role = Staff.RoleOf(p)

	if role == nil then
		return nil
	end

	return chatBadge(Staff.ChatLabelOf(role), Staff.ColorOf(role))
end

return Staff