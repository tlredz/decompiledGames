local _ = {
	normal = "rbxassetid://3150319038",
	christmas = "rbxassetid://4521639303",
	halloween = "http://www.roblox.com/asset/?id=15056209964",
	valentines = "http://www.roblox.com/asset/?id=12349622103",
	easter = "http://www.roblox.com/asset/?id=12966773156"
}
local coinIcon = script.Parent.CoinIcon

if workspace:GetAttribute("isChristmas") then
	coinIcon.Image = "rbxassetid://4521639303"
elseif workspace:GetAttribute("isValentines") then
	coinIcon.Image = "http://www.roblox.com/asset/?id=12349622103"
elseif workspace:GetAttribute("isEaster") then
	coinIcon.Image = "http://www.roblox.com/asset/?id=12966773156"
elseif workspace:GetAttribute("isHalloween") then
	coinIcon.Image = "http://www.roblox.com/asset/?id=15056209964"
else
	coinIcon.Image = "rbxassetid://3150319038"
end