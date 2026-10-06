local ClickSound = require(script.ClickSound)
local DeviceAdapt = require(script.DeviceAdapt)
local UIManager = require(script.UIManager)
local FeedbackButton = require(script.FeedbackButton)
return {
	client = {
		initClickSound = ClickSound.Init,
		initDeviceAdapt = DeviceAdapt.Init,
		initUIManager = UIManager.Init,
		initFeedbackButton = FeedbackButton.Init
	}
}