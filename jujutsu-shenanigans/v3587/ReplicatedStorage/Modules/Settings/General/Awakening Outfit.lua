local AwakeningOutfit = {
	Btn = 4,
	SortOrder = 7,
	Val = "Outfit",
	Desc = "Changes your outfit when awakened",
	BtnText = "Outfits",
	Gamepass = "857428668"
}
local menus = game.Players.LocalPlayer.PlayerGui:WaitForChild("Menus")
local settings = menus.Group.Settings
local sounds = game.ReplicatedStorage.Sounds
local AvatarEditorService = game:GetService("AvatarEditorService")
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local service = Knit.GetService("JoinService")
local controller = Knit.GetController("FXController")

local function loadOutfits()
	local outfits = AvatarEditorService:GetOutfits(Enum.OutfitSource.Created)

	for _, button in settings.Outfits.Outfits:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	while true do
		for _, v in outfits:GetCurrentPage() do
			local clone = menus.Preset.Outfit:Clone()
			clone.Image = "rbxthumb://type=Outfit&id=" .. v.Id .. "&w=150&h=150"
			clone.BackgroundColor3 = v.Id == tonumber(_G.Settings[AwakeningOutfit.Val]) and Color3.fromRGB(85, 170, 255) or Color3.new(
				1,
				1,
				1
			)
			clone.Parent = settings.Outfits.Outfits
			local v3 = v
			clone.MouseButton1Down:Connect(function()
				local v4 = clone.BackgroundColor3 == Color3.new(1, 1, 1)

				for i, button in settings.Outfits.Outfits:GetChildren() do
					if button:IsA("ImageButton") then
						button.BackgroundColor3 = Color3.new(1, 1, 1)
					end
				end

				controller:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

				if v4 ~= true then
					service.Setting:Fire(AwakeningOutfit.Val, nil)
					return
				end

				clone.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
				service.Setting:Fire(AwakeningOutfit.Val, v3.Id)
			end)
		end

		if outfits.IsFinished then
			break
		else
			outfits:AdvanceToNextPageAsync()
		end
	end
end

function AwakeningOutfit.Callback(_)
	settings.Outfits.Visible = true
	settings.Settings.Visible = false
	AvatarEditorService:PromptAllowInventoryReadAccess()
end

settings.Outfits.Return.MouseButton1Down:Connect(function()
	settings.Outfits.Visible = false
	settings.Settings.Visible = true
end)
settings:GetPropertyChangedSignal("Visible"):Connect(function()
	if settings.Visible == true then
		return
	end

	settings.Outfits.Visible = false
	settings.Settings.Visible = true
end)
AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Connect(function()
	if settings.Outfits.Visible == false then
		return
	end

	pcall(loadOutfits)
end)
return AwakeningOutfit