local Storage = require(script.Storage)
local TypeHelp = require(script.TypeHelp)
return {
	GetForbiddenStorageFolder = Storage.GetForbiddenStorageFolder,
	GetForbiddenTemporaryWorkspaceFolder = Storage.GetForbiddenTemporaryWorkspaceFolder,
	GetForbiddenWSPartsFolder = Storage.GetForbiddenWSPartsFolder,
	GetBasePart = TypeHelp.GetBasePart,
	GetDistanceFromNPCToTarget = TypeHelp.GetDistanceFromNPCToTarget,
	TriggerCleanupTypeHelp = TypeHelp.TriggerCleanup
}