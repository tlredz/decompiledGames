require(script.Parent.Types)
local Signal = require(script.Parent.Signal)
local signals = {
	EntityAdded = Signal.new()
}
local Events = {
	EntityAdded = signals.EntityAdded.Event
}
signals.EntityRemoved = Signal.new()
Events.EntityRemoved = signals.EntityRemoved.Event
signals.PlayerCharacterRegistered = Signal.new()
Events.PlayerCharacterRegistered = signals.PlayerCharacterRegistered.Event
signals.PlayerCharacterUnregistered = Signal.new()
Events.PlayerCharacterUnregistered = signals.PlayerCharacterUnregistered.Event
signals.PlayerOwnedAdded = Signal.new()
Events.PlayerOwnedAdded = signals.PlayerOwnedAdded.Event
signals.PlayerOwnedRemoved = Signal.new()
Events.PlayerOwnedRemoved = signals.PlayerOwnedRemoved.Event
signals.EntityMountChanged = Signal.new()
Events.EntityMountChanged = signals.EntityMountChanged.Event
signals["请不要使用_内部_设置值_拜托谢谢_嗨_这个名字有点长_好吧_再见_算了_这个确实被用了_因为递归错误_而我懒得去解决_所以这是一个能用的_创可贴式修复_好吧"] = Signal.new()
signals.PlayerLoaded = Signal.new()
Events._Signals = signals
return Events