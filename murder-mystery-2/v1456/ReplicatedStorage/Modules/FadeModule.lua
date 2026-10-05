local FadeModule = {}
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false)
TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayTweens(items)
	for _, item in pairs(items) do
		item:Play()
	end
end

local v = {
	In = 0,
	Out = 1
}
local v2 = {
	In = false,
	Out = true
}

function FadeModule.PlayCameraFade(p)
	local fade = game.Players.LocalPlayer.PlayerGui:WaitForChild("CameraFade").Fade
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, v2[p])
	PlayTweens({ TweenService:Create(fade, tweenInfo, {
			BackgroundTransparency = v[p]
		}) }) -- equivalent call inferred; original call site unknown
end

local function PlayDeathFade(p)
	local fade = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SpawnFade").Fade
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, v2[p])
	PlayTweens({ TweenService:Create(fade, tweenInfo, {
			BackgroundTransparency = v[p]
		}) }) -- equivalent call inferred; original call site unknown
end

function FadeModule.DeathFlash()
	local fade = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SpawnFade").Fade
	fade.BackgroundTransparency = 0
	fade.BackgroundColor3 = Color3.new(1, 1, 1)
	wait(0.1)
	fade.BackgroundColor3 = Color3.new(0, 0, 0)
end

function FadeModule.FadeToWinner(player, p)
	if p then
		FadeModule.PlayCameraFade("In")
		wait(0.3)
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if humanoid then
		game.Workspace.CurrentCamera.CameraSubject = humanoid
	end

	FadeModule.PlayCameraFade("Out")
	PlayDeathFade("Out")
	wait(0.4)
end

function FadeModule.SpawnFade()
	wait(0.5)
	local fade = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SpawnFade").Fade
	fade.BackgroundTransparency = 0
	fade.BackgroundColor3 = Color3.new(0, 0, 0)
	PlayDeathFade("Out")
	FadeModule.PlayCameraFade("Out")
	game.Workspace.CurrentCamera.CameraType = "Custom"
	game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid

	if _G.CancelSpectate ~= nil then
		_G.CancelSpectate()
	end
end

function FadeModule.CameraFadeToLocalPlayer()
	if game.Players.LocalPlayer.Character ~= nil then
		game.Workspace.CurrentCamera.CameraType = "Custom"
		game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
	end

	if _G.CancelSpectate ~= nil then
		_G.CancelSpectate()
	end

	FadeModule.PlayCameraFade("Out")
end

return FadeModule