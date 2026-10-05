local _ = script.Parent
return {
	MusicStartTime = -1,
	PlayingStage = nil,
	Deltatime = 0,
	ConcertVolume = 1,
	AudioFader = Instance.new("AudioFader"),
	AudioWire = Instance.new("Wire"),
	AudioOutputWire = Instance.new("Wire")
}