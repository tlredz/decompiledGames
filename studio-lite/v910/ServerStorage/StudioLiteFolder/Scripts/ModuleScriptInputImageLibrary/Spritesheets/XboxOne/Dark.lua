local Spritesheet = require(script.Parent.Parent.Parent.Spritesheet)
local Dark = {}
Dark.__index = Dark
setmetatable(Dark, Spritesheet)

function Dark.new()
	local rbxassetid408444495 = Spritesheet.new("rbxassetid://408444495")
	setmetatable(rbxassetid408444495, Dark)
	rbxassetid408444495:AddSprite("ButtonX", Vector2.new(510, 416), Vector2.new(95, 95))
	rbxassetid408444495:AddSprite("ButtonY", Vector2.new(616, 318), Vector2.new(95, 95))
	rbxassetid408444495:AddSprite("ButtonA", Vector2.new(318, 416), Vector2.new(95, 95))
	rbxassetid408444495:AddSprite("ButtonB", Vector2.new(520, 522), Vector2.new(95, 95))
	rbxassetid408444495:AddSprite("ButtonR1", Vector2.new(0, 628), Vector2.new(115, 64))
	rbxassetid408444495:AddSprite("ButtonL1", Vector2.new(116, 628), Vector2.new(115, 64))
	rbxassetid408444495:AddSprite("ButtonR2", Vector2.new(616, 414), Vector2.new(105, 115))
	rbxassetid408444495:AddSprite("ButtonL2", Vector2.new(616, 0), Vector2.new(105, 115))
	rbxassetid408444495:AddSprite("ButtonR3", Vector2.new(0, 416), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("ButtonL3", Vector2.new(0, 522), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("ButtonSelect", Vector2.new(424, 522), Vector2.new(95, 95))
	rbxassetid408444495:AddSprite("DPadLeft", Vector2.new(318, 522), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("DPadRight", Vector2.new(212, 416), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("DPadUp", Vector2.new(616, 530), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("DPadDown", Vector2.new(212, 522), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("Thumbstick1", Vector2.new(616, 116), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("Thumbstick2", Vector2.new(106, 522), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("DPad", Vector2.new(106, 416), Vector2.new(105, 105))
	rbxassetid408444495:AddSprite("Controller", Vector2.new(0, 0), Vector2.new(615, 415))
	rbxassetid408444495:AddSprite("RotateThumbstick1", Vector2.new(414, 416), Vector2.new(95, 95))
	rbxassetid408444495:AddSprite("RotateThumbstick2", Vector2.new(616, 222), Vector2.new(95, 95))
	return rbxassetid408444495
end

return Dark