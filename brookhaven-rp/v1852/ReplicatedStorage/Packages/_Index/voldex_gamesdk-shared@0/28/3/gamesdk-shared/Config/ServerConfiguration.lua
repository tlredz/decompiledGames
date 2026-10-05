local BaseConfiguration = require(script.Parent:WaitForChild("BaseConfiguration"))
local parent = script.Parent.Parent.Parent
local t = require(parent.t)
local ServerConfiguration = {}
ServerConfiguration.__index = ServerConfiguration
ServerConfiguration._isServer = true
ServerConfiguration.superClass = BaseConfiguration
setmetatable(ServerConfiguration, BaseConfiguration)

local function warno(...)
	warn("[GameSdk - Configuration]", ...)
end

local interface = t.interface({
	_gameIdentifier = t.string,
	_experienceMapping = t.table
})
local v = {
	_debug = t.boolean,
	_sendTelemetry = t.boolean,
	_performanceTelemetry = t.boolean,
	_useSandboxDexter = t.boolean,
	_useLocalDexter = t.boolean,
	_useRemoteConfig = t.boolean,
	_sendGrafana = t.boolean,
	_telemetryPipelineImpl = t.number,
	_grafanaIdentifier = t.string,
	_remoteConfigIdentifier = t.string,
	_remoteConfigDevDefaultBranch = t.string,
	_useSandboxRemoteConfig = t.boolean,
	_discordWebhook = t.string,
	_remoteConfigInterval = t.number,
	_remoteConfigImpl = t.number,
	_dexterCacheExpiration = t.number,
	_grafanaModuloPercent = t.number,
	_useSandboxDeviceProfiler = t.boolean,
	_useSandboxDeploy = t.boolean,
	_useSandboxSerial = t.boolean,
	_registerTelemetry = t.table,
	_validClientTelemetry = t.table,
	_remoteConfigPackages = t.table,
	_abTestExperiments = t.table,
	_additionalSecretNames = t.table,
	_useLocalSecretManager = t.boolean,
	_useSandboxSecretManager = t.boolean,
	_abTestNoCachePlaceIds = t.array(t.string)
}
local v2 = {
	_secrets = true
}

function ServerConfiguration.new()
	return (setmetatable(BaseConfiguration.new(), ServerConfiguration))
end

function ServerConfiguration:Validate()
	local v3, v4 = interface(self)

	if not v3 then
		error("Missing required configuration options: " .. v4)
	end

	for k, v5 in v do
		if self[k] == nil then
			continue
		end

		local v6, v7 = v5(self[k])

		if not v6 then
			error("Supplied invalid type for " .. k .. " in configuration: " .. v7)
		end
	end

	for k, _ in v2 do
		if self[k] ~= nil and self[k].Validate ~= nil then
			self[k]:Validate()
		end
	end
end

function ServerConfiguration:Debug(debug: boolean)
	self._debug = debug
	return self
end

function ServerConfiguration:IsDebug()
	return self._debug
end

function ServerConfiguration:GameIdentifier(gameIdentifier: string)
	self._gameIdentifier = gameIdentifier
	return self
end

function ServerConfiguration:GetGameIdentifier()
	return self._gameIdentifier
end

function ServerConfiguration:Secrets(secrets)
	self._secrets = secrets
	return self
end

function ServerConfiguration:GetSecrets()
	return self._secrets
end

function ServerConfiguration:ExperienceMapping(experienceMapping)
	self._experienceMapping = experienceMapping
	return self
end

function ServerConfiguration:GetExperienceMapping()
	return self._experienceMapping
end

function ServerConfiguration:SendTelemetry(sendTelemetry: boolean)
	self._sendTelemetry = sendTelemetry
	return self
end

function ServerConfiguration:IsSendTelemetry()
	return self._sendTelemetry
end

function ServerConfiguration:RegisterTelemetry(registerTelemetry)
	self._registerTelemetry = registerTelemetry
	return self
end

function ServerConfiguration:GetRegisterTelemetry()
	return self._registerTelemetry
end

function ServerConfiguration:AbTestExperiments(abTestExperiments)
	self._abTestExperiments = abTestExperiments
	return self
end

function ServerConfiguration:GetAbTestExperiments()
	return self._abTestExperiments
end

function ServerConfiguration:AdditionalSecretNames(options)
	self._additionalSecretNames = options or {}
	return self
end

function ServerConfiguration:GetAdditionalSecretNames()
	return self._additionalSecretNames or {}
end

function ServerConfiguration:UseLocalSecretManager(useLocalSecretManager: boolean)
	self._useLocalSecretManager = useLocalSecretManager
	return self
end

function ServerConfiguration:IsUseLocalSecretManager()
	return self._useLocalSecretManager
end

function ServerConfiguration:UseSandboxSecretManager(useSandboxSecretManager: boolean)
	self._useSandboxSecretManager = useSandboxSecretManager
	return self
end

function ServerConfiguration:IsUseSandboxSecretManager()
	return self._useSandboxSecretManager
end

function ServerConfiguration:ValidClientTelemetry(validClientTelemetry)
	self._validClientTelemetry = validClientTelemetry
	return self
end

function ServerConfiguration:GetValidClientTelemetry()
	return self._validClientTelemetry
end

function ServerConfiguration:PerformanceTelemetry(performanceTelemetry: boolean)
	self._performanceTelemetry = performanceTelemetry
	return self
end

function ServerConfiguration:GetPerformanceTelemetry()
	return self._performanceTelemetry
end

function ServerConfiguration:UseSandboxDexter(useSandboxDexter: boolean)
	self._useSandboxDexter = useSandboxDexter
	return self
end

function ServerConfiguration:IsUseSandboxDexter()
	return self._useSandboxDexter
end

function ServerConfiguration:UseLocalDexter(useLocalDexter: boolean)
	self._useLocalDexter = useLocalDexter
	return self
end

function ServerConfiguration:IsUseLocalDexter()
	return self._useLocalDexter
end

function ServerConfiguration:TelemetryPipelineImpl(telemetryPipelineImpl: number)
	self._telemetryPipelineImpl = telemetryPipelineImpl
	return self
end

function ServerConfiguration:GetTelemetryPipelineImpl()
	return self._telemetryPipelineImpl
end

function ServerConfiguration:UseRemoteConfig(useRemoteConfig: boolean)
	self._useRemoteConfig = useRemoteConfig
	return self
end

function ServerConfiguration:IsUseRemoteConfig()
	return self._useRemoteConfig
end

function ServerConfiguration:RemoteConfigIdentifier(remoteConfigIdentifier: string)
	self._remoteConfigIdentifier = remoteConfigIdentifier
	return self
end

function ServerConfiguration:GetRemoteConfigIdentifier()
	return self._remoteConfigIdentifier
end

function ServerConfiguration:RemoteConfigPackages(...)
	self._remoteConfigPackages = { ... }
	return self
end

function ServerConfiguration:GetRemoteConfigPackages()
	return self._remoteConfigPackages
end

function ServerConfiguration:RemoteConfigInterval(remoteConfigInterval: number)
	warno("Using deprecated option: RemoteConfigInterval - no longer supported from >=0.20.2")
	self._remoteConfigInterval = remoteConfigInterval
	return self
end

function ServerConfiguration:GetRemoteConfigInterval()
	return self._remoteConfigInterval
end

function ServerConfiguration:RemoteConfigImpl(remoteConfigImpl: number)
	warno("Using deprecated option: RemoteConfigImpl - no longer supported from >=0.14.0")
	self._remoteConfigImpl = remoteConfigImpl
	return self
end

function ServerConfiguration:GetRemoteConfigImpl()
	return self._remoteConfigImpl
end

function ServerConfiguration:RemoteConfigDevDefaultBranch(remoteConfigDevDefaultBranch: string)
	self._remoteConfigDevDefaultBranch = remoteConfigDevDefaultBranch
	return self
end

function ServerConfiguration:GetRemoteConfigDevDefaultBranch()
	return self._remoteConfigDevDefaultBranch
end

function ServerConfiguration:UseSandboxRemoteConfig(useSandboxRemoteConfig: boolean)
	self._useSandboxRemoteConfig = useSandboxRemoteConfig
	return self
end

function ServerConfiguration:IsUseSandboxRemoteConfig()
	return self._useSandboxRemoteConfig
end

function ServerConfiguration:DexterCacheExpiration(dexterCacheExpiration: number)
	self._dexterCacheExpiration = dexterCacheExpiration
	return self
end

function ServerConfiguration:GetDexterCacheExpiration()
	return self._dexterCacheExpiration
end

function ServerConfiguration:UseDiscordWebhook(usesDiscordWebhook: boolean)
	self._usesDiscordWebhook = usesDiscordWebhook
	return self
end

function ServerConfiguration:IsUsingDiscordWebhook()
	return self._usesDiscordWebhook
end

function ServerConfiguration:DiscordWebhook(discordWebhook: string)
	self._discordWebhook = discordWebhook
	return self
end

function ServerConfiguration:GetDiscordWebhook()
	return self._discordWebhook
end

function ServerConfiguration:UseCMDR(cmdrInstance)
	self._cmdrInstance = cmdrInstance
	return self
end

function ServerConfiguration:GetCMDRInstance()
	return self._cmdrInstance
end

function ServerConfiguration:GameGroup(gameGroup: number)
	self._gameGroup = gameGroup
	return self
end

function ServerConfiguration:GetGameGroup()
	return self._gameGroup
end

function ServerConfiguration:GrafanaIdentifier(grafanaIdentifier: string)
	self._grafanaIdentifier = grafanaIdentifier
	return self
end

function ServerConfiguration:GetGrafanaIdentifier()
	return self._grafanaIdentifier
end

function ServerConfiguration:SendGrafana(sendGrafana: boolean)
	self._sendGrafana = sendGrafana
	return self
end

function ServerConfiguration:IsSendGrafana()
	return self._sendGrafana
end

function ServerConfiguration.SetIsRampUpMode(p, _: boolean)
	warno("Using deprecated option: SetIsRampUpMode - no longer supported from >=0.17.0")
	return p
end

function ServerConfiguration.IsRampUpMode(_)
	warno("Using deprecated option: IsRampUpMode - no longer supported from >=0.17.0")
	return false
end

function ServerConfiguration:GrafanaPercent(grafanaModuloPercent: number)
	self._grafanaModuloPercent = grafanaModuloPercent
	return self
end

function ServerConfiguration:GetGrafanaPercent()
	return self._grafanaModuloPercent
end

function ServerConfiguration:UseSandboxDeviceProfiler(useSandboxDeviceProfiler: boolean)
	self._useSandboxDeviceProfiler = useSandboxDeviceProfiler
	return self
end

function ServerConfiguration:IsUseSandboxDeviceProfiler()
	return self._useSandboxDeviceProfiler
end

function ServerConfiguration:UseSandboxDeploy(useSandboxDeploy: boolean)
	self._useSandboxDeploy = useSandboxDeploy
	return self
end

function ServerConfiguration:IsUseSandboxDeploy()
	return self._useSandboxDeploy
end

function ServerConfiguration:UseSandboxSerial(useSandboxSerial: boolean)
	self._useSandboxSerial = useSandboxSerial
	return self
end

function ServerConfiguration:IsUseSandboxSerial()
	return self._useSandboxSerial
end

function ServerConfiguration:ABTestNoCachePlaceIds(abTestNoCachePlaceIds)
	self._abTestNoCachePlaceIds = abTestNoCachePlaceIds
	return self
end

function ServerConfiguration:GetABTestNoCachePlaceIds()
	return self._abTestNoCachePlaceIds
end

return ServerConfiguration