local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = nil
local MusicPlayerController = {}

function MusicPlayerController.FrameworkStart()
	PanelController.OnPanelClosed:Connect(function(_, p)
		if p == "MainAudio" then
			MusicPlayerController.ResetMusicContext()
		end
	end)
end

function MusicPlayerController.SetMusicContext(name: string, instance)
	v = {
		name = name,
		instance = instance
	}
end

function MusicPlayerController.GetMusicContext()
	return v
end

function MusicPlayerController.ResetMusicContext()
	v = nil
end

return MusicPlayerController