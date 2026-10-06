local module = require("@game/ReplicatedStorage/Omni")
local profile = module.Interface:WaitForChild("Frames"):WaitForChild("Profile")
local main = profile:WaitForChild("Main")
local Controller = {
	CurrentFrame = nil,
	FrameModules = {},
	OverlayFrames = {
		Titles = true,
		Banners = true
	},
	FrameChanged = module.Libs.GoodSignal.new(),
	ProfileOpened = module.Libs.GoodSignal.new(),
	ProfileClosed = module.Libs.GoodSignal.new()
}

function Controller.OpenFrame(currentFrame: string?)
	if currentFrame == Controller.CurrentFrame then
		return
	end

	if currentFrame == nil then
		Controller.CurrentFrame = nil
		Controller.FrameChanged:Fire(nil)
	elseif Controller.OverlayFrames[currentFrame] then
		for k in Controller.OverlayFrames do
			if k ~= currentFrame then
				module.Frame:Close(k)
			end
		end

		local v = module.Libs.NeoHover.GetByIdentifier("Fighters")

		if v then
			v:Close()
		end

		module.Frame:Open(currentFrame)
	else
		Controller.CurrentFrame = currentFrame

		for _, frame in main:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == currentFrame
			end
		end

		Controller.FrameChanged:Fire(currentFrame)
	end
end

function Controller.SearchProfile(p: string)
	local v, v2 = module.Signal:Invoke("General", "Profile", "Get", p)

	if v == "Success" then
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = `Successfully found the profile of @{p}!`,
			Color = Color3.new(0, 1, 0)
		})
	elseif v == "InCooldown" then
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = "This is in cooldown!",
			Color = Color3.new(1, 1, 0)
		})
	else
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = "The profile of this player wasn't found!",
			Color = Color3.new(1, 1, 0)
		})
	end

	local profile2 = Controller.FrameModules.Profile

	if profile2 then
		profile2.SetCustomProfile(v2)
		Controller.OpenFrame("Profile")
	end

	if not module.Frame:IsFrameOpened(profile.Name) then
		module.Frame:Open(profile)
	end
end

module.Frame:OnFrameOpened(profile, function()
	Controller.OpenFrame("Profile")
	Controller.ProfileOpened:Fire()
end)
module.Frame:OnFrameClosed(profile, function()
	Controller.OpenFrame(nil)

	for k in Controller.OverlayFrames do
		module.Frame:Close(k)
	end

	Controller.ProfileClosed:Fire()
end)
return Controller