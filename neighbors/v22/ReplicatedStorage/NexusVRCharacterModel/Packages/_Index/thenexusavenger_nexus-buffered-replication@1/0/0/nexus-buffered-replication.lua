return {
	Receiver = {
		BufferedRemoteEventReceiver = require(script:WaitForChild("Receiver"):WaitForChild("BufferedRemoteEventReceiver")),
		PlayerBufferedRemoteEventReceiver = require(script:WaitForChild("Receiver"):WaitForChild("PlayerBufferedRemoteEventReceiver"))
	},
	Sender = {
		BufferedRemoteEventSender = require(script:WaitForChild("Sender"):WaitForChild("BufferedRemoteEventSender")),
		EnrollableRemoteEvent = require(script:WaitForChild("Sender"):WaitForChild("EnrollableRemoteEvent"))
	}
}