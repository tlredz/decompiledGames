local TestingGroupUtil = require(game.ReplicatedStorage.TestingGroupUtil)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
return function(p, p2)
	return (useAttribute(p, TestingGroupUtil.getReplicationAttributeKey(p2)))
end