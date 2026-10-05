local localPlayer = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local SocialService = game:GetService("SocialService")
local import = _G.import("romodel")
_G.import("global")
_G.import("event")
local import2 = _G.import("configuration")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local menu = import3:get("menu")
local avatar = import3:get("avatar").Avatar
local model = import.model("ScreenGui", basic.Ui)

function model.init(p)
	return {
		IgnoreGuiInset = false,
		DisplayOrder = 6,
		Name = "InviteFriendPopup",
		Location = "TopCenter",
		AspectRatio = 2.25,
		MinSize = 300,
		Scale = 0.3,
		Content = {
			Panel = import.make(import.wrap(basic.Corner), {
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, 0, 0.15, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(20, 20, 40),
				BackgroundTransparency = 0.05
			}, {
				Avatar = import.make(avatar, {
					Position = UDim2.new(0.05, 0, 0.35, 0),
					Size = UDim2.new(0.55, 0, 0.55, 0),
					UserId = p.UserId
				}, {
					OnlineStatus = import.make(import.wrap(basic.Element, basic.Corner), {
						Position = UDim2.new(0.8, 0, 0, 0),
						Size = UDim2.new(0.25, 0, 0.25, 0),
						CornerRadius = UDim.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(32, 255, 30)
					})
				}),
				Title = import.make(basic.TextLabel, {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0.04, 0),
					Size = UDim2.new(0.9, 0, 0.2, 0),
					Text = p.Username .. " is online!",
					StrokeWidth = 3,
					ZIndex = 2
				}),
				RewardLabel = import.make(basic.TextLabel, {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0.3, 0),
					Size = UDim2.new(0.75, 0, 0.2, 0),
					RichText = true,
					Text = "+<font color=\"rgb(0,255,0)\">" .. import2.INVITE.INVITE_FRIEND_REWARD .. "</font> Cash",
					StrokeWidth = 2,
					ZIndex = 2
				}),
				GoButton = import.make(menu.Button, {
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(0.97, 0, 0.94, 0),
					Size = UDim2.new(0.44, 0, 0.27, 0),
					Text = "INVITE",
					ZIndex = 2,
					MouseButton1Down = function(state)
						if state.Clicked then
							return
						end

						state.Clicked = true
						local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
						experienceInviteOptions.InviteUser = p.UserId
						experienceInviteOptions.LaunchData = HttpService:JSONEncode({
							InvitedBy = localPlayer.UserId
						})
						SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
						state.Ui:Destroy()
					end
				}),
				XButton = import.make(menu.XButton, {
					Position = UDim2.new(0.92, 0, -0.1, 0),
					Size = UDim2.new(0.3, 0, 0.3, 0),
					ZIndex = 10
				})
			})
		}
	}
end

return {
	InviteFriendPopup = model
}