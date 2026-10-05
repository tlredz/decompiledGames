local frame = script:FindFirstAncestorOfClass("Frame")
local screenGui = frame:FindFirstAncestorOfClass("ScreenGui")
local Util = {}

function Util.GetTotalScale(_)
	return frame.UIScale.Scale * screenGui.UIScale.Scale
end

function Util.GetAvatarDecal(_, p: number)
	return (`rbxthumb://type=AvatarHeadShot&id={p}&w=48&h=48`)
end

return Util