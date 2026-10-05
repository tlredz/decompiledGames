local Translatewrapper = {}
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local LocalizationService = game:GetService("LocalizationService")
local v = nil
local translatorForLocaleAsyncs = {}
local v2 = 10

if not isServer and game.Players.LocalPlayer ~= nil then
	function recursion()
		if v ~= nil then
			return
		end

		task.spawn(function()
			local success, result = pcall(function()
				return LocalizationService:GetTranslatorForPlayerAsync(game.Players.LocalPlayer)
			end)

			if success then
				if translatorForLocaleAsyncs.Default == nil then
					translatorForLocaleAsyncs.Default = result
				end

				v = result
			elseif v2 > 0 then
				v2 -= 1
				task.delay(1, recursion)
			end
		end)
	end

	recursion()
end

function Translatewrapper.SetLanguage(p: string)
	if isServer then
		return
	end

	task.spawn(function()
		local success, result = pcall(function()
			if p == nil then
				if translatorForLocaleAsyncs.Default then
					return translatorForLocaleAsyncs.Default
				end

				local translatorForPlayerAsync = LocalizationService:GetTranslatorForPlayerAsync(game.Players.LocalPlayer)
				translatorForLocaleAsyncs.Default = translatorForPlayerAsync
				return translatorForPlayerAsync
			else
				if translatorForLocaleAsyncs[p] then
					return translatorForLocaleAsyncs[p]
				end

				local translatorForLocaleAsync = LocalizationService:GetTranslatorForLocaleAsync(p)

				if translatorForLocaleAsync == nil then
					return
				end

				translatorForLocaleAsyncs[p] = translatorForLocaleAsync
				return translatorForLocaleAsync
			end
		end)

		if success and v ~= result then
			v = result
		end
	end)
end

function Translatewrapper.TranslateByKey(p: string, p2)
	if isServer then
		return
	end

	local v3 = "Key formatted translation not found!"

	if v ~= nil then
		pcall(function()
			v3 = v:FormatByKey(p, p2)
		end)
	end

	return v3
end

function Translatewrapper:Translate(p)
	if isServer or self:match("^%s*$") or v == nil then
		return self
	end

	return v:Translate(p or game, self)
end

return Translatewrapper