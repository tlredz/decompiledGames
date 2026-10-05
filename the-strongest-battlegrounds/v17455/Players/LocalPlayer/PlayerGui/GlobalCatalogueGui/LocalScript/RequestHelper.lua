-- equivalent calls inferred from this helper; original call sites unknown
local function warnMissingOnce(p, p2, p3)
	if p.warned[p2] == true then
		return
	end

	p.warned[p2] = true
	p.warnFn(p3)
end

local function getDirectChild(instance, childName, className)
	if typeof(instance) ~= "Instance" then
		return nil
	end

	local child = instance:FindFirstChild(childName)

	if not child or className and not child:IsA(className) then
		return nil
	end

	return child
end

local function getFirstDirectChild(instance, value, className)
	local v = type(value) == "string" and { value } or value

	for _, childName in ipairs(v or {}) do
		local child

		if typeof(instance) == "Instance" then
			child = instance:FindFirstChild(childName)

			if child then
				if className and not child:IsA(className) then
					child = nil
				end
			else
				child = nil
			end
		end

		if child then
			return child
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lowerTrim(type2)
	local v = tostring(type2 or ""):gsub("^%s+", ""):gsub("%s+$", "")
	return string.lower(v)
end

local RequestHelper = {
	newRequestApi = function(options)
		local v = options or {}
		local remoteFunction = v.remoteFunction
		local httpService = v.httpService or game:GetService("HttpService")
		local warnFn = v.warnFn or warn
		local v2 = typeof(v.blockedReadActions) ~= "table" and {} or v.blockedReadActions
		local v3 = {}
		local v4 = {}

		function v3.isCharAddPending(value)
			return v4[tostring(value or "")] ~= nil
		end

		function v3.beginCharAddPending(value)
			local v5 = tostring(value or "")

			if v5 == "" then
				return 0
			end

			local token = (not v4[v5] and 0 or v4[v5].token or 0) + 1
			v4[v5] = {
				token = token
			}
			return token
		end

		function v3.endCharAddPending(value, p)
			local v5 = tostring(value or "")

			if v5 == "" then
				return
			end

			if p == nil or v4[v5] and v4[v5].token == p then
				v4[v5] = nil
			end
		end

		local v5 = 0

		function v3.setForceFresh(p)
			v5 = os.clock() + (tonumber(p) or 4)
		end

		function v3.req(action, options2, value)
			if not remoteFunction then
				return {
					ok = false,
					error = "remote-missing"
				}
			end

			if _G.__TSB_GLOBAL_CATALOGUE_UI_OPEN ~= true and v2[action] then
				return {
					ok = false,
					error = "ui-closed"
				}
			end

			local count = 0
			local v6 = {
				ok = false,
				error = "invoke-failed"
			}

			for i = 1, value or 3 do
				local success, result = pcall(function()
					local payload = options2 or {}

					if os.clock() < v5 then
						local v8 = {}

						if typeof(payload) == "table" then
							for k, v9 in pairs(payload) do
								v8[k] = v9
							end
						end

						v8.fresh = true
						payload = v8
					end

					return remoteFunction:InvokeServer({
						Action = action,
						Payload = payload
					})
				end)

				if success and typeof(result) == "table" then
					if result.ok or result.error ~= "throttled" and result.error ~= "busy-try-again" then
						return result
					end

					if result.error == "busy-try-again" then
						count += 1

						if count >= 2 then
							return result
						end
					end

					local retryAfter = tonumber(result.retryAfter)

					if retryAfter and retryAfter > 0 then
						if result.error == "busy-try-again" then
							task.wait((math.clamp(retryAfter, 0.03, 0.15)))
						else
							task.wait((math.clamp(retryAfter, 0.05, 1.5)))
						end
					elseif result.error == "busy-try-again" then
						task.wait(i * 0.03)
					else
						task.wait(i * 0.07)
					end

					v6 = result
				else
					task.wait(i * 0.07)
				end
			end

			return v6
		end

		function v3.reqAllPagedEntries(p, p2, p3)
			local v6 = typeof(p2) == "table" and p2 or {}
			local page = 1
			local v8 = 1
			local entries = {}
			local flag = false
			local v10 = {}

			while page <= v8 and page <= 40 and #entries < 4000 do
				local clone = table.clone(v6)
				clone.page = page
				clone.limit = 120
				local req = v3.req(p, clone, p3)

				if not req.ok then
					return req
				end

				flag = true

				for _, v11 in ipairs(req.entries or {}) do
					local v12 = tostring(not v11 and "" or v11.id or "")

					if v12 ~= "" then
						if v10[v12] then
							continue
						else
							v10[v12] = true
						end
					end

					table.insert(entries, v11)

					if #entries >= 4000 then
						break
					end
				end

				v8 = math.max(page, (math.floor(tonumber(req.totalPages) or page)))

				if req.hasMore == false and v8 <= page or #(req.entries or {}) == 0 and v8 <= page then
					break
				else
					page += 1
				end
			end

			if flag then
				return {
					ok = true,
					entries = entries,
					total = #entries,
					totalPages = 1,
					hasMore = false,
					page = 1,
					limit = 120
				}
			end

			return {
				ok = true,
				entries = {},
				total = 0,
				totalPages = 1,
				hasMore = false,
				page = 1,
				limit = 120
			}
		end

		function v3.notifyCharCreatorCatalogueRefresh(p)
			local v6 = rawget(_G, "CharCreatorRefreshCatalogueItems")

			if type(v6) ~= "function" then
				return
			end

			local success, result = pcall(v6, p == true)

			if not success then
				warnFn("[GlobalCatalogue] CharCreatorRefreshCatalogueItems failed: " .. tostring(result))
			end
		end

		function v3.describeCatalogueError(value)
			local v6 = tostring(value or "")
			return ({
				["name-too-short"] = "name is too short (minimum 3 characters)",
				["at-least-one-tag-required"] = "at least one tag is required",
				["source-required"] = "no source selected",
				["source-not-found"] = "source no longer exists; refresh and try again",
				["duplicate-upload"] = "this source is already uploaded; use Update in My Uploads",
				["upload-invalid-payload"] = "upload request data is invalid",
				["upload-invalid-asset-type"] = "upload asset type is invalid",
				["upload-invalid-source"] = "upload source data is invalid; refresh and try again",
				["upload-session-source-disallowed"] = "temporary imported saves cannot be published",
				["upload-non-authored-source"] = "imported or added content cannot be republished as your own",
				["upload-invalid-config"] = "upload source snapshot/config is invalid; re-save and try again",
				["upload-invalid-content-meta"] = "upload metadata is invalid; re-save and try again",
				["upload-invalid-move-snapshot"] = "move snapshot is invalid; re-save the move and try again",
				["upload-invalid-animation-snapshot"] = "animation snapshot is invalid; re-save the animation and try again",
				["upload-invalid-map-config"] = "map upload data is invalid; re-save the map and try again",
				["upload-verification-internal"] = "upload verification failed on the server",
				["invalid-type"] = "backend rejected this asset type",
				["unsupported-type"] = "this asset type is not supported by backend",
				["entry-not-found"] = "entry not found",
				["entry-not-active"] = "entry is not active right now",
				["entry-required"] = "entry id missing",
				["user-required"] = "target user id missing",
				["import-code-required"] = "enter an import code first",
				["import-code-invalid"] = "import code is invalid or unavailable",
				["import-code-unavailable"] = "import code was claimed already; wait for refresh and try again",
				["list-keys-unsupported"] = "random key listing is not available on this server build",
				["list-keys-failed"] = "random key listing failed",
				["catalogue-access-revoked"] = "your catalogue publishing access has been revoked",
				["upload-limit-reached"] = "you've reached the upload limit; delete a listing to upload more",
				["duplicate-name"] = "you already have an upload with this name; please choose a different name",
				["character-import-cap-reached"] = "you can only upload 3 characters with other creators' moves",
				["move-uid-belongs-to-other-creator"] = "this move originated from another creator and cannot be uploaded",
				["move-uid-already-listed"] = "this move is already listed in the catalogue",
				["imported-anim-blocked"] = "animations loaded from Roblox cannot be uploaded",
				["anim-too-few-keyframes"] = "animation needs at least 30 keyframes to upload",
				["anim-quality-blocked"] = "animation doesn't meet quality requirements",
				["move-too-empty"] = "this move has too few events to upload",
				throttled = "rate limited; wait a moment and try again",
				["busy-try-again"] = "entry is busy, try again in a moment",
				["backend-unavailable"] = "catalogue backend unavailable right now",
				["backend-required"] = "this action requires the catalogue backend",
				["backend-misconfigured"] = "catalogue backend api key missing on this server",
				unauthorized = "catalogue backend auth failed on this server",
				["invalid-response"] = "catalogue backend returned an invalid response",
				internal = "internal server error"
			})[v6] or v6
		end

		function v3.decodeConfigTable(value)
			local result

			if typeof(value) == "string" then
				local v6 = value:gsub("^%s+", ""):gsub("%s+$", "")

				if v6 == "" then
					result = value
				else
					local success
					success, result = pcall(function()
						return httpService:JSONDecode(v6)
					end)

					if success then
						if typeof(result) ~= "table" then
							result = value
						end
					else
						result = value
					end
				end
			else
				result = value
			end

			if typeof(result) == "table" then
				return result
			end

			return nil
		end

		local function normalizeEntryContentMeta(data)
			if typeof(data) ~= "table" then
				return nil
			end

			local v6 = {}
			local blockCount = math.max(0, (math.floor(tonumber(data.blockCount or data.blocks) or 0)))
			local keyframeCount = math.max(
				0,
				(math.floor(tonumber(data.keyframeCount or data.keyframes or data.keyFrameCount) or 0))
			)
			local partCount = math.max(0, (math.floor(tonumber(data.partCount or data.parts) or 0)))
			local chunkCount = math.max(0, (math.floor(tonumber(data.chunkCount or data.chunks) or 0)))
			local payloadSize = math.max(0, (math.floor(tonumber(data.payloadSize or data.bytes) or 0)))
			local duration = tonumber(data.duration or data.durationSec or data.durationSeconds)

			if blockCount > 0 then
				v6.blockCount = blockCount
			end

			if keyframeCount > 0 then
				v6.keyframeCount = keyframeCount
			end

			if partCount > 0 then
				v6.partCount = partCount
			end

			if chunkCount > 0 then
				v6.chunkCount = chunkCount
			end

			if payloadSize > 0 then
				v6.payloadSize = payloadSize
			end

			if duration and duration > 0 then
				v6.duration = math.max(0.05, duration)
			end

			if next(v6) == nil or not v6 then
				return nil
			end

			return v6
		end

		local function resolveMoveConfigRoot(c)
			if typeof(c) ~= "table" then
				return nil
			end

			if typeof(c.c) == "table" then
				c = c.c
			end

			if typeof(c[1]) == "table" and typeof(c[1].Data) == "table" then
				c = c[1]
			end

			return typeof(c) == "table" and c or nil
		end

		local function countPoseKeyframes(result)
			if typeof(result) == "string" and result ~= "" then
				local success
				success, result = pcall(httpService.JSONDecode, httpService, result)

				if not success then
					result = nil
				end
			end

			if typeof(result) ~= "table" then
				return 0, nil
			end

			local v6 = {}
			local v7 = nil
			local count = 0

			for _, item in ipairs(result) do
				if typeof(item) ~= "table" then
					continue
				end

				local time = tonumber(item.Time or item.time)

				if time == nil then
					continue
				end

				local v8 = math.max(0, math.floor(time * 1000 + 0.5) / 1000)
				local v9 = string.format("%.3f", v8)

				if not v6[v9] then
					v6[v9] = true
					count += 1
				end

				if v7 == nil or v7 < v8 then
					v7 = v8
				end
			end

			return count, v7
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function trimString(eventType)
			return tostring(eventType or ""):gsub("^%s+", ""):gsub("%s+$", "")
		end

		function v3.readCatalogueCharacterImportMetadata(data)
			if typeof(data) == "table" then
				return
					tostring(data.catalogueEntryId or data.CatalogueEntryId or data.ce or data.entryId or data.EntryId or ""):gsub(
						"^%s+",
						""
					):gsub(
						"%s+$",
						""
					),
					data.catalogueAllowEditing ~= false and data.CatalogueAllowEditing ~= false and data.AllowEditing ~= false and data.cea ~= false and tostring(data.catalogueAllowEditing) ~= "false" and tostring(data.CatalogueAllowEditing) ~= "false" and tostring(data.AllowEditing) ~= "false" and tostring(data.cea) ~= "false"
			end

			return "", true
		end

		function v3.encodeCatalogueCharacterCode(data, options2)
			local v6 = options2 or {}
			local buildImportCompactConfig = v6.buildImportCompactConfig
			local trimString2 = v6.trimString or trimString

			if typeof(data) ~= "table" then
				return nil, "invalid-item"
			end

			warn(string.format(
				"[CHARFIX][encode] item keys+values: name=%s id=%s creatorUserId=%s CreatorUserId=%s type=%s sourceType=%s category=%s",
				tostring(data.name),
				tostring(data.id),
				tostring(data.creatorUserId),
				tostring(data.CreatorUserId),
				tostring(data.type),
				tostring(data.sourceType),
				(tostring(data.category))
			))

			if type(buildImportCompactConfig) ~= "function" then
				return nil, "missing-config-builder"
			end

			local importCompactConfig = buildImportCompactConfig(data.config)

			if not importCompactConfig then
				return nil, "missing-config"
			end

			if not (importCompactConfig.b1 or importCompactConfig.b2 or importCompactConfig.b3 or importCompactConfig.b4) then
				return nil, "no-base-moves"
			end

			local v7 = {
				v = 1,
				e = {
					n = tostring(data.name or "Imported Character"),
					c = importCompactConfig,
					t = { "Imported" }
				}
			}
			local ce = trimString2(data.id or data.catalogueEntryId)

			if ce ~= "" then
				v7.e.ce = ce
				v7.e.cea = data.catalogueAllowEditing ~= false
			end

			local creatorUserId = math.floor(tonumber(data.creatorUserId or data.CreatorUserId) or 0)

			if creatorUserId > 0 then
				v7.e.cu = creatorUserId
			end

			local success, result = pcall(function()
				return httpService:JSONEncode(v7)
			end)

			if not success or type(result) ~= "string" or result == "" then
				return nil, "encode-json-failed"
			end

			local success2, result2 = pcall(function()
				return httpService:Base64Encode(result)
			end)

			if success2 and type(result2) == "string" and result2 ~= "" then
				return "CC1:" .. result2, nil
			end

			return result, "base64-fallback-json"
		end

		function v3.importCharacterIntoCreator(data, data2, options2)
			local v6 = options2 or {}
			local getCommRemote = v6.getCommRemote
			local trimString2 = v6.trimString or trimString

			if type(getCommRemote) ~= "function" then
				return false, "communicate-remote-missing"
			end

			local commRemote = getCommRemote(4)

			if not commRemote then
				return false, "communicate-remote-missing"
			end

			local v7 = data2 and (data2.autoAddToSelection == true or data2.addToSelection == true)
			local v8 = data2 and (data2.suppressNotification == true or data2.silent == true)
			local catalogueEntryId = trimString2(data and data.id)

			if catalogueEntryId ~= "" then
				commRemote:FireServer({
					Goal = "Custom Character",
					Action = "ImportCatalogueEntry",
					CatalogueEntryId = catalogueEntryId,
					CatalogueSourceUpdatedAt = tonumber(data and data.updatedAt) or nil,
					AutoAddToSelection = v7 == true,
					SuppressNotification = v8 == true
				})
				return true, nil
			end

			local encodeCatalogueCharacterCode, v10 = v3.encodeCatalogueCharacterCode(data, v6)

			if not encodeCatalogueCharacterCode then
				return false, v10 or "encode-failed"
			end

			local v11 = {
				Goal = "Custom Character",
				Action = "ImportCode",
				Code = encodeCatalogueCharacterCode,
				AutoAddToSelection = v7 == true,
				SuppressNotification = v8 == true,
				CatalogueEntryId = trimString2(data and data.id),
				CatalogueAllowEditing = not data or data.catalogueAllowEditing ~= false,
				MoveBuffersB64 = 0
			}
			local moveBuffersB

			if typeof(data) == "table" and typeof(data.moveBuffersB64) == "table" then
				moveBuffersB = data.moveBuffersB64 or nil
			end

			v11.MoveBuffersB64 = moveBuffersB
			commRemote:FireServer(v11)
			return true, nil
		end

		function v3.localCharacterMatchesCatalogueItem(data, data2, options2)
			local v6 = options2 or {}
			local trimString2 = v6.trimString or trimString
			local buildImportFingerprint = v6.buildImportFingerprint

			if typeof(data) ~= "table" or typeof(data2) ~= "table" then
				return false
			end

			local v7 = trimString2(data.id or data.catalogueEntryId)

			if v7 ~= "" then
				return trimString2(data2.catalogueEntryId) == v7
			end

			local importFingerprint = tostring(data.importFingerprint or "")

			if importFingerprint == "" and type(buildImportFingerprint) == "function" then
				importFingerprint = tostring(buildImportFingerprint(data.config) or "")
			end

			if importFingerprint ~= "" and tostring(data2.importFingerprint or "") == importFingerprint then
				return true
			end

			local name = string.lower((tostring(data.name or "")))
			return name ~= "" and string.lower((tostring(data2.name or ""))) == name
		end

		local v6 = {
			"b1",
			"b2",
			"b3",
			"b4",
			"a1",
			"a2",
			"a3",
			"a4",
			"s",
			"u",
			"m",
			"w",
			"f"
		}

		function v3.isCharacterImportCandidate(data, options2)
			local v7 = options2 or {}
			local lowerTrim2 = v7.lowerTrim or lowerTrim
			local buildImportCompactConfig = v7.buildImportCompactConfig

			if typeof(data) ~= "table" then
				return false
			end

			local v8 = lowerTrim2(data.type)
			local v9 = lowerTrim2(data.sourceType)

			if v8 == "characters" or v8 == "character" or v9 == "custom_character" then
				return true
			end

			if v8 ~= "" then
				return false
			end

			return type(buildImportCompactConfig) == "function" and buildImportCompactConfig(data.config) ~= nil
		end

		function v3.buildImportFingerprint(p, options2)
			local buildImportCompactConfig = (options2 or {}).buildImportCompactConfig

			if type(buildImportCompactConfig) ~= "function" then
				return ""
			end

			local importCompactConfig = buildImportCompactConfig(p)

			if typeof(importCompactConfig) ~= "table" then
				return ""
			end

			local v7 = {}

			for _, v8 in ipairs(v6) do
				v7[#v7 + 1] = string.lower((tostring(importCompactConfig[v8] or "")))
			end

			return table.concat(v7, "|")
		end

		function v3.decodeLocalCustomCharacters(options2, options3)
			local v7 = options2 or {}
			local v8 = options3 or {}
			local player = v7.player
			local listCacheState = v7.listCacheState

			if typeof(player) ~= "Instance" then
				return {}
			end

			local customCharacters = player:GetAttribute("CustomCharacters")
			local localCharactersRaw = typeof(customCharacters) == "string" and customCharacters or false

			if typeof(listCacheState) == "table" and listCacheState.localCharactersRaw == localCharactersRaw and typeof(listCacheState.localCharactersDecoded) == "table" then
				return listCacheState.localCharactersDecoded
			end

			if typeof(customCharacters) == "string" and customCharacters ~= "" then
				local success, result = pcall(function()
					return httpService:JSONDecode(customCharacters)
				end)

				if success and typeof(result) == "table" then
					if typeof(result.characters) == "table" then
						result = result.characters
					elseif typeof(result.c) == "table" then
						result = result.c
					end

					local result2 = {}

					for _, v10 in ipairs(result) do
						if typeof(v10) ~= "table" then
							continue
						end

						local config = v10.config or v10.Config or v10.c
						local c = v3.decodeConfigTable(config)

						if typeof(c) == "table" and typeof(c.c) == "table" then
							c = c.c
						end

						local importFingerprint = v3.buildImportFingerprint(c, v8)
						local catalogueCharacterImportMetadata, catalogueAllowEditing = v3.readCatalogueCharacterImportMetadata(v10)
						table.insert(result2, {
							id = tostring(v10.id or v10.i or ""),
							name = tostring(v10.name or v10.n or ""),
							added = v10.added == true or v10.Added == true or v10.a == true,
							imported = v10.imported == true or v10.Imported == true or tostring(v10.imported) == "true" or tostring(v10.Imported) == "true",
							gift = v10.gift == true or v10.Gift == true or v10.g == true,
							source = tostring(v10.source or v10.Source or ""),
							giftSourceId = tostring(v10.giftSourceId or v10.GiftSourceId or v10.r or ""),
							giftOwnerUserId = tonumber(v10.giftOwnerUserId or v10.GiftOwnerUserId or v10.o),
							catalogueEntryId = catalogueCharacterImportMetadata,
							catalogueAllowEditing = catalogueAllowEditing,
							config = c,
							importFingerprint = importFingerprint
						})
					end

					if typeof(listCacheState) ~= "table" then
						return result2
					end

					listCacheState.localCharactersRaw = localCharactersRaw
					listCacheState.localCharactersDecoded = result2
					return listCacheState.localCharactersDecoded
				end
			end

			if typeof(listCacheState) ~= "table" then
				return {}
			end

			listCacheState.localCharactersRaw = localCharactersRaw
			listCacheState.localCharactersDecoded = {}
			return listCacheState.localCharactersDecoded
		end

		function v3.isLocalImportedCharacter(data)
			if typeof(data) ~= "table" then
				return false
			end

			if data.imported == true or data.gift == true or tonumber(data.giftOwnerUserId) and tonumber(data.giftOwnerUserId) > 0 then
				return true
			end

			local source = string.lower((tostring(data.source or "")))
			return source == "imported" or source == "gift"
		end

		function v3.findLocalCharacterMatchesForItem(p, p2, p3, options2)
			local v7 = options2 or {}

			if typeof(p) ~= "table" then
				return {}
			end

			local v8 = {
				buildImportFingerprint = function(p4)
					return v3.buildImportFingerprint(p4, v7)
				end,
				trimString = v7.trimString
			}
			local result = {}

			for _, v9 in ipairs(v3.decodeLocalCustomCharacters(p3, v7)) do
				local localImportedCharacter = v3.isLocalImportedCharacter(v9)

				if (p2 == true or localImportedCharacter) and v3.localCharacterMatchesCatalogueItem(p, v9, v8) then
					table.insert(result, v9)
				end
			end

			return result
		end

		function v3.buildLocalCharacterSelectionMap(p, p2)
			local result = {}

			for _, v7 in ipairs(v3.decodeLocalCustomCharacters(p, p2)) do
				local v8 = tostring(not v7 and "" or v7.importFingerprint or "")

				if v8 == "" then
					continue
				end

				local v9 = result[v8]

				if not v9 then
					v9 = {
						found = false,
						added = false,
						importedIds = {}
					}
					result[v8] = v9
				end

				v9.found = true

				if v7.added == true then
					v9.added = true
				end

				if v3.isLocalImportedCharacter(v7) and v7.id and v7.id ~= "" then
					table.insert(v9.importedIds, (tostring(v7.id)))
				end
			end

			return result
		end

		function v3.ensureCharacterInSelection(p, p2, options2)
			local v7 = options2 or {}
			local fireCustomCharacterAction = v7.fireCustomCharacterAction

			if typeof(p) ~= "table" then
				return false, "invalid-item"
			end

			local v8 = v3.findLocalCharacterMatchesForItem(p, true, p2, v7)[1]

			if v8 and v8.id ~= "" then
				if not v8.added then
					if type(fireCustomCharacterAction) ~= "function" then
						return false, "action-helper-missing"
					end

					fireCustomCharacterAction("AddToSelection", v8.id, {
						suppressNotification = true
					})
				end

				return true, nil, v8
			else
				local importCharacterIntoCreator, v9 = v3.importCharacterIntoCreator(p, {
					autoAddToSelection = true,
					suppressNotification = true
				}, v7)

				if importCharacterIntoCreator then
					return true, nil, nil
				end

				return false, v9 or "import-failed"
			end
		end

		function v3.removeCharacterFromSelection(p, p2, options2)
			local v7 = options2 or {}
			local fireCustomCharacterAction = v7.fireCustomCharacterAction

			if typeof(p) ~= "table" or type(fireCustomCharacterAction) ~= "function" then
				return false
			end

			local v8 = false

			for _, v9 in ipairs(v3.findLocalCharacterMatchesForItem(p, true, p2, v7)) do
				if not (v9.id ~= "" and v9.added == true) then
					continue
				end

				fireCustomCharacterAction("RemoveFromSelection", v9.id, {
					suppressNotification = true
				})
				v8 = true
			end

			return v8
		end

		function v3.removeImportedCharacterFromSelection(p, p2, options2)
			local v7 = options2 or {}
			local fireCustomCharacterAction = v7.fireCustomCharacterAction

			if typeof(p) ~= "table" or type(fireCustomCharacterAction) ~= "function" then
				return false
			end

			local v8 = false

			for _, v9 in ipairs(v3.findLocalCharacterMatchesForItem(p, false, p2, v7)) do
				if v9.id == "" then
					continue
				end

				fireCustomCharacterAction("Delete", v9.id)
				v8 = true
			end

			return v8
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isTimelineStructuralEntry(p)
			if typeof(p) ~= "table" then
				return false
			end

			local v7 = trimString(p.EventType) -- equivalent call inferred; original call site unknown

			if v7 == "" or v7 == "Pose" then
				return false
			end

			return tostring(p.EventCategory or ""):gsub("^%s+", ""):gsub("%s+$", "") ~= "Flow" or v7 ~= "Label"
		end

		local function forEachTimelineEntry(list, fn)
			if typeof(list) ~= "table" or type(fn) ~= "function" then
				return
			end

			if #list > 0 then
				for _, v7 in ipairs(list) do
					if typeof(v7) == "table" then
						fn(v7)
					end
				end
			else
				for _, v7 in pairs(list) do
					if typeof(v7) == "table" then
						fn(v7)
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function countTimelineStructuralEntries(data)
			local count = 0
			forEachTimelineEntry(data, function(p)
				-- equivalent call inferred; original call site unknown
				if isTimelineStructuralEntry(p) then
					count += 1
				end
			end)
			return count
		end

		local function resolveTimelineEntryDuration(data)
			if typeof(data) ~= "table" then
				return 0
			end

			local properties = nil

			if typeof(data.Data) == "table" and typeof(data.Data.Properties) == "table" then
				properties = data.Data.Properties
			elseif typeof(data.Properties) == "table" then
				properties = data.Properties
			end

			return (math.max(
				0,
				tonumber(data.Duration) or tonumber(properties and (properties._duration or properties.Duration)) or 0
			))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function deriveTimelineTotalDuration(data)
			local v7 = 0
			forEachTimelineEntry(data, function(p)
				-- equivalent call inferred; original call site unknown
				if not isTimelineStructuralEntry(p) then
					return
				end

				local v8 = math.max(0, tonumber(p.Time) or 0) + resolveTimelineEntryDuration(p)

				if v7 < v8 then
					v7 = v8
				end
			end)

			if v7 > 0 then
				return v7
			end

			return nil
		end

		function v3.deriveEntryContentMeta(p)
			local entryContentMeta = normalizeEntryContentMeta(p and p.contentMeta)
			local decodeConfigTable = v3.decodeConfigTable(p and p.config)

			if typeof(decodeConfigTable) ~= "table" then
				return entryContentMeta
			end

			local clone = entryContentMeta and table.clone(entryContentMeta) or {}
			local v7

			if typeof(decodeConfigTable) == "table" then
				local c

				if typeof(decodeConfigTable.c) == "table" then
					c = decodeConfigTable.c
				else
					c = decodeConfigTable
				end

				if typeof(c[1]) == "table" and typeof(c[1].Data) == "table" then
					c = c[1]
				end

				v7 = typeof(c) == "table" and c or nil
			end

			if typeof(v7) == "table" then
				local data

				if typeof(v7.Data) == "table" then
					data = v7.Data or nil
				end

				local blockCount = countTimelineStructuralEntries(data) -- equivalent call inferred; original call site unknown

				if blockCount <= 0 then
					blockCount = math.max(0, (math.floor(tonumber(v7.blockCount) or 0)))
				end

				if blockCount > 0 then
					clone.blockCount = blockCount
				end

				local v9

				if typeof(data) == "table" then
					v9 = data[1] or nil
				end

				local properties

				if typeof(v7.Properties) == "table" then
					properties = v7.Properties or nil
				end

				local properties2

				if typeof(v9) == "table" and typeof(v9.Properties) == "table" then
					properties2 = v9.Properties or nil
				end

				local keyframeCount = math.max(
					0,
					(math.floor(tonumber(v7.keyframeCount or v7.keyframes or v7.keyFrameCount) or 0))
				)
				local v11

				if keyframeCount <= 0 then
					keyframeCount, v11 = countPoseKeyframes(v7.PoseData or properties and properties.PoseData or properties2 and properties2.PoseData)
				end

				if keyframeCount > 0 then
					clone.keyframeCount = keyframeCount
				end

				local timelineTotalDuration = deriveTimelineTotalDuration(data) -- equivalent call inferred; original call site unknown
				local v13 = timelineTotalDuration or tonumber(v7.duration or v7.Duration) or tonumber(properties and (properties._duration or properties.Duration)) or tonumber(properties2 and (properties2._duration or properties2.Duration))

				if not v13 then
					local v14

					if typeof(v9) == "table" then
						v14 = v9.Duration
					else
						v14 = false
					end

					v13 = tonumber(v14) or v11
				end

				if v13 and v13 > 0 then
					clone.duration = math.max(0.05, v13)
				end
			end

			local mapRef = nil

			if typeof(decodeConfigTable.mapRef) == "table" then
				mapRef = decodeConfigTable.mapRef
			elseif typeof(decodeConfigTable.map) == "table" then
				mapRef = decodeConfigTable.map
			end

			if typeof(mapRef) ~= "table" then
				return (normalizeEntryContentMeta(clone))
			end

			local partCount = math.max(0, (math.floor(tonumber(mapRef.partCount) or 0)))
			local chunkCount = math.max(0, (math.floor(tonumber(mapRef.chunks or mapRef.chunkCount) or 0)))
			local payloadSize = math.max(0, (math.floor(tonumber(mapRef.payloadSize or mapRef.bytes) or 0)))

			if partCount > 0 then
				clone.partCount = partCount
			end

			if chunkCount > 0 then
				clone.chunkCount = chunkCount
			end

			if payloadSize > 0 then
				clone.payloadSize = payloadSize
			end

			return (normalizeEntryContentMeta(clone))
		end

		local v7 = {}
		local fn

		local function runQueuedDetailPsToggle(value, data, data2)
			local v8 = tostring(value or "")

			if v8 == "" then
				return
			end

			local v9 = v7[v8]
			v7[v8] = nil

			if v9 == nil then
				return
			end

			local addedToPS

			if typeof(data2 and data2.addedToPS) == "table" then
				addedToPS = data2.addedToPS or nil
			end

			if v9 == (addedToPS and addedToPS[v8] == true and true or false) then
				return
			end

			local getLiveDetail

			if type(data2 and data2.getLiveDetail) == "function" then
				getLiveDetail = data2.getLiveDetail or nil
			end

			if getLiveDetail then
				data = getLiveDetail(v8, data)
			else
				local entryById

				if typeof(data2 and data2.entryById) == "table" then
					entryById = data2.entryById or nil
				end

				if typeof(entryById and entryById[v8]) == "table" then
					data = entryById[v8]
				end
			end

			if typeof(data) ~= "table" then
				return
			end

			task.defer(function()
				fn(data, v9, data2)
			end)
		end

		fn = function(data, p, options2)
			local v8 = options2 or {}
			local v9 = tostring(not data and "" or data.id or "")

			if v9 == "" then
				return
			end

			local addedToPS

			if typeof(v8.addedToPS) == "table" then
				addedToPS = v8.addedToPS or nil
			end

			local addInFlight

			if typeof(v8.addInFlight) == "table" then
				addInFlight = v8.addInFlight or nil
			end

			if not (addedToPS and addInFlight) then
				return
			end

			if addInFlight[v9] then
				v7[v9] = p == true
				return
			end

			local fn2 = type(v8.showToast) ~= "function" and function() end or v8.showToast or function() end
			local entryById

			if typeof(v8.entryById) == "table" then
				entryById = v8.entryById or nil
			end

			local fn3 = type(v8.updateLocalEntryAddedCount) ~= "function" and function() end or v8.updateLocalEntryAddedCount or function() end
			local fn4 = type(v8.setPendingPsMutation) ~= "function" and function() end or v8.setPendingPsMutation or function() end
			local fn5 = type(v8.clearPendingPsMutation) ~= "function" and function() end or v8.clearPendingPsMutation or function() end
			local fn6 = type(v8.updateDetailPS) ~= "function" and function() end or v8.updateDetailPS or function() end
			local fn7 = type(v8.updateTabCounts) ~= "function" and function() end or v8.updateTabCounts or function() end
			local fn8 = type(v8.requestCatalogueMapLoad) ~= "function" and function() end or v8.requestCatalogueMapLoad or function() end
			local fn9 = type(v8.requestCatalogueMapCleanup) ~= "function" and function() end or v8.requestCatalogueMapCleanup or function() end
			local fn10 = type(v8.refreshAddedTabImmediatelyIfVisible) ~= "function" and function() end or v8.refreshAddedTabImmediatelyIfVisible or function() end
			local fn11 = type(v8.schedulePsMutationRefresh) ~= "function" and function() end or v8.schedulePsMutationRefresh or function() end
			local fireCustomCharacterAction

			if type(v8.fireCustomCharacterAction) == "function" then
				fireCustomCharacterAction = v8.fireCustomCharacterAction or nil
			end

			local getCommRemote

			if type(v8.getCommRemote) == "function" then
				getCommRemote = v8.getCommRemote or nil
			end

			local buildImportCompactConfig

			if type(v8.buildImportCompactConfig) == "function" then
				buildImportCompactConfig = v8.buildImportCompactConfig or nil
			end

			local trimString2

			if type(v8.trimString) == "function" then
				trimString2 = v8.trimString or nil
			end

			local listCacheState = v8.listCacheState
			local player = v8.player
			local req = type(v8.req) == "function" and v8.req or v3.req
			addInFlight[v9] = true
			v7[v9] = nil

			if p == true then
				local v10 = not data and "Item" or data.name or "Item"
				local v11 = data and data.category == "Map"
				local flag = true
				local v12 = addedToPS[v9] == true

				if data and data.category == "Character" then
					if not v12 then
						local v13 = v3.beginCharAddPending(v9)
						fn6()
						fn7()
						local v14 = req("AddToPS", {
							entryId = v9
						}, 3)
						v3.endCharAddPending(v9, v13)

						if v14 and v14.ok then
							fn4(v9, true)
							fn3(v9, v14.addedCount)
							local v15

							if entryById then
								v15 = entryById[v9] or nil
							end

							if v15 then
								v15.addedCount = tonumber(v14.addedCount) or v15.addedCount
								v15.downloads = math.max(v15.downloads or 0, v15.addedCount or 0)
							end

							fn6()
							fn7()
							fn2("ADDED TO PS! CHECK THE ADDED MENU")
							v3.notifyCharCreatorCatalogueRefresh(true)
							fn11()
							local item = v14.item
							local v16 = not item and v15 and {
								type = "characters",
								name = v15.name,
								config = v15.config,
								sourceType = "custom_character",
								creatorUserId = tonumber(v15.creatorUserId) or 0
							} or item

							if v16 and (v16.id == nil or tostring(v16.id) == "") then
								v16.id = v9
							end

							if v16 then
								v3.ensureCharacterInSelection(v16, {
									player = player,
									listCacheState = listCacheState
								}, {
									fireCustomCharacterAction = fireCustomCharacterAction,
									getCommRemote = getCommRemote,
									buildImportCompactConfig = buildImportCompactConfig,
									trimString = trimString2
								})
							end
						else
							fn6()
							fn7()
							fn2("Add failed: " .. v3.describeCatalogueError(v14 and v14.error or "unknown"))
						end
					end

					addInFlight[v9] = nil
					runQueuedDetailPsToggle(v9, data, v8)
					return
				else
					if not v12 then
						fn4(v9, true)
						fn6()
						fn7()
						local v13 = req("AddToPS", {
							entryId = v9
						}, 3)

						if v13 and v13.ok then
							fn3(v9, v13.addedCount)
							local v14

							if entryById then
								v14 = entryById[v9] or nil
							end

							if v14 then
								v14.addedCount = tonumber(v13.addedCount) or v14.addedCount
								v14.downloads = math.max(v14.downloads or 0, v14.addedCount or 0)
							end

							if v11 then
								fn2("\"" .. tostring(v10) .. "\" added to PS")
							else
								local v15 = nil
								local item = v13.item

								if not item and v14 and v14.category == "Character" then
									item = {
										type = "characters",
										name = v14.name,
										config = v14.config,
										sourceType = "custom_character",
										creatorUserId = tonumber(v14.creatorUserId) or 0,
										moveBuffersB64 = 0
									}
									local moveBuffersB

									if typeof(v14.moveBuffersB64) == "table" then
										moveBuffersB = v14.moveBuffersB64 or nil
									end

									item.moveBuffersB64 = moveBuffersB
								end

								if item and v3.isCharacterImportCandidate(item, {
									lowerTrim = lowerTrim,
									buildImportCompactConfig = buildImportCompactConfig
								}) then
									local v16
									v16, v15 = v3.ensureCharacterInSelection(item, {
										player = player,
										listCacheState = listCacheState
									}, {
										fireCustomCharacterAction = fireCustomCharacterAction,
										getCommRemote = getCommRemote,
										buildImportCompactConfig = buildImportCompactConfig,
										trimString = trimString2
									})

									if not v16 then
										v15 = tostring(v15 or "unknown")
									end
								end

								if v15 and v15 ~= "import-pending" then
									fn2("\"" .. tostring(v10) .. "\" added to PS (selection warning: " .. tostring(v15) .. ")")
								else
									fn2("\"" .. tostring(v10) .. "\" added to PS!")
								end
							end
						else
							fn5(v9)
							addedToPS[v9] = nil
							fn6()
							fn7()
							fn2("Add failed: " .. v3.describeCatalogueError(v13 and v13.error or "unknown"))
							flag = false
						end
					end

					if flag and v11 then
						fn8(data, "GlobalCatalogueDetail")
					end

					if flag then
						fn6()
						fn7()
						v3.notifyCharCreatorCatalogueRefresh(true)
						fn11()
					end
				end
			else
				local category = data and data.category
				local v10 = addedToPS[v9] == true
				fn4(v9, false)
				fn6()
				fn7()
				local v11 = req("RemoveFromPS", {
					entryId = v9
				}, 3)

				if v11 and v11.ok then
					fn3(v9, v11.addedCount)

					if category == "Character" then
						v3.removeImportedCharacterFromSelection({
							name = data and data.name,
							config = data and data.config
						}, {
							player = player,
							listCacheState = listCacheState
						}, {
							fireCustomCharacterAction = fireCustomCharacterAction,
							buildImportCompactConfig = buildImportCompactConfig,
							trimString = trimString2
						})
					elseif category == "Map" then
						fn9("GlobalCatalogueDetailRemove")
					end

					if category ~= "Character" then
						fn2("Removed from PS")
					end

					fn6()
					fn7()
					fn10()
					v3.notifyCharCreatorCatalogueRefresh(true)
					fn11()
				else
					fn5(v9)

					if v10 then
						addedToPS[v9] = true
					else
						addedToPS[v9] = nil
					end

					fn6()
					fn7()
					fn2("Remove failed: " .. v3.describeCatalogueError(v11 and v11.error or "unknown"))
				end
			end

			addInFlight[v9] = nil
			runQueuedDetailPsToggle(v9, data, v8)
		end

		function v3.performDetailPsToggle(p, p2, p3)
			fn(p, p2, p3)
		end

		local function hashString(value)
			local v8 = 2166136261
			local v9 = 2246822507

			for i = 1, #value do
				local v10 = string.byte(value, i)
				v8 = bit32.band(bit32.bxor(v8, v10) * 16777619, 4294967295)
				v9 = bit32.band(bit32.bxor(v9, (bit32.bnot(v10))) * 3266489909, 4294967295)
			end

			return string.format("%08x%08x", v8, v9)
		end

		local function computeAnimHash(result)
			if typeof(result) == "string" and result ~= "" then
				local success
				success, result = pcall(httpService.JSONDecode, httpService, result)

				if not success or typeof(result) ~= "table" then
					return nil
				end
			end

			if typeof(result) ~= "table" then
				return nil
			end

			local v8 = {}

			for _, item in ipairs(result) do
				if typeof(item) ~= "table" then
					continue
				end

				local v9 = math.floor((tonumber(item.Time or item.time) or 0) * 100 + 0.5) / 100
				local poses = item.Poses or item.poses

				if typeof(poses) ~= "table" then
					continue
				end

				local pos = {}

				for _, pos2 in ipairs(poses) do
					if typeof(pos2) == "table" then
						table.insert(pos, pos2)
					end
				end

				table.sort(pos, function(a, b)
					return (tonumber(a.limb or a.Limb) or 0) < (tonumber(b.limb or b.Limb) or 0)
				end)
				local v10 = {}

				for _, v11 in ipairs(pos) do
					local limb = tonumber(v11.limb or v11.Limb) or 0
					local cFrame = v11.CFrame or v11.cframe or v11.cf

					if typeof(cFrame) ~= "table" then
						continue
					end

					local v12 = {}

					for _, v13 in ipairs(cFrame) do
						table.insert(v12, string.format("%.2f", math.floor((tonumber(v13) or 0) * 100 + 0.5) / 100))
					end

					table.insert(v10, limb .. ":" .. table.concat(v12, ","))
				end

				table.insert(v8, string.format("%.2f|%s", v9, table.concat(v10, ";")))
			end

			if #v8 == 0 then
				return nil
			end

			table.sort(v8)
			return hashString(table.concat(v8, "\n"))
		end

		local v8 = {
			"Damage",
			"damage",
			"Radius",
			"radius",
			"Duration",
			"duration",
			"SoundId",
			"soundId",
			"ParticleId",
			"particleId",
			"Force",
			"force",
			"Speed",
			"speed",
			"Knockback",
			"knockback",
			"HitboxSize",
			"hitboxSize"
		}

		local function computeBlockSignature(data)
			if typeof(data) ~= "table" then
				return nil
			end

			local properties = data.Properties

			if properties == nil and typeof(data.Data) == "table" then
				properties = data.Data.Properties
			end

			local eventType = tostring(data.EventType or data.eventType or data.Type or data.type or "unknown")
			local layer = tonumber(data.Layer or data.layer) or 0
			local v9 = math.floor((tonumber(data.Time or data.time) or 0) * 10 + 0.5) / 10
			local v10 = {}

			if typeof(properties) == "table" then
				for _, v11 in ipairs(v8) do
					local property = properties[v11]

					if property ~= nil then
						table.insert(v10, string.lower(v11) .. "=" .. tostring(property))
					end
				end
			end

			table.sort(v10)
			return hashString(string.format(
				"type=%s|layer=%d|time=%.1f|%s",
				eventType,
				layer,
				v9,
				table.concat(v10, "|")
			))
		end

		function v3.computeMoveHashes(p)
			local c = v3.decodeConfigTable(p)

			if typeof(c) ~= "table" then
				return nil
			end

			if typeof(c.c) == "table" then
				c = c.c
			end

			if typeof(c[1]) == "table" and typeof(c[1].Data) == "table" then
				c = c[1]
			end

			if typeof(c) ~= "table" then
				return nil
			end

			local animHashes = {}
			local blockHashes = {}
			local v11 = {}
			local v12 = {}
			local properties

			if typeof(c.Properties) == "table" then
				properties = c.Properties or nil
			end

			local poseData = c.PoseData or properties and properties.PoseData

			if poseData then
				local v13 = computeAnimHash(poseData)

				if v13 and not v11[v13] then
					v11[v13] = true
					table.insert(animHashes, v13)
				end
			end

			local v13 = typeof(c.Data) ~= "table" and {} or c.Data or {}

			for _, v14 in ipairs(v13) do
				if typeof(v14) ~= "table" then
					continue
				end

				local properties2 = v14.Properties

				if properties2 == nil and typeof(v14.Data) == "table" then
					properties2 = v14.Data.Properties
				end

				if typeof(properties2) == "table" and properties2.PoseData then
					local v15 = computeAnimHash(properties2.PoseData)

					if v15 and not v11[v15] then
						v11[v15] = true
						table.insert(animHashes, v15)
					end
				end

				local v15 = computeBlockSignature(v14)

				if not v15 or v12[v15] then
					continue
				end

				v12[v15] = true
				table.insert(blockHashes, v15)
			end

			if #animHashes == 0 and #blockHashes == 0 then
				return nil
			end

			return {
				animHashes = animHashes,
				blockHashes = blockHashes
			}
		end

		return v3
	end
}
RequestHelper.new = RequestHelper.newRequestApi

function RequestHelper.newAddedImportApi(options)
	local v = options or {}
	local fn = type(v.trimString) ~= "function" and function(value)
		return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
	end or v.trimString
	local v2 = {
		addedScroll = v.addedScroll,
		addedSearchBox = v.addedSearchBox,
		addedRowTemplate = v.addedRowTemplate,
		req = v.req,
		showToast = v.showToast,
		describeCatalogueError = v.describeCatalogueError,
		notifyCharCreatorCatalogueRefresh = v.notifyCharCreatorCatalogueRefresh,
		schedulePsMutationRefresh = v.schedulePsMutationRefresh,
		updateTabCounts = v.updateTabCounts,
		syncAdded = v.syncAdded,
		refreshAddedToPS = v.refreshAddedToPS,
		getActiveTab = v.getActiveTab,
		claimActionDebounce = v.claimActionDebounce,
		warnFn = v.warnFn or warn,
		container = nil,
		textBox = nil,
		addBtn = nil,
		inFlight = false,
		warned = {}
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function warnAddedImportOnce(p, p2)
		warnMissingOnce(v2, tostring(p), tostring(p2)) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function normalizeAddedImportCode(text)
		local v4 = string.upper(fn(text))
		return (string.gsub(v4, "%s+", ""))
	end

	local function refreshUi()
		local textBox = v2.textBox
		local addBtn = v2.addBtn

		if not (textBox and addBtn) then
			return
		end

		local text = textBox.Text or ""
		local v4 = normalizeAddedImportCode(text) ~= ""
		local inFlight = v2.inFlight == true
		addBtn.AutoButtonColor = not inFlight and v4
		addBtn.Active = not inFlight and v4
		addBtn.Text = inFlight and "ADDING" or "ADD"
		addBtn.TextColor3 = (not inFlight and v4 and true or false) and Color3.fromRGB(130, 220, 130) or Color3.fromRGB(
			170,
			170,
			170
		)
		addBtn.BackgroundColor3 = (not inFlight and v4 and true or false) and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(
			72,
			72,
			72
		)
		addBtn.BackgroundTransparency = (inFlight or not v4) and 0.5 or 0.75
		textBox.PlaceholderText = inFlight and "adding..." or "Paste import code"
	end

	local function submit()
		if v2.inFlight == true then
			return
		end

		local textBox = v2.textBox

		if textBox and textBox:IsA("TextBox") then
			local text = textBox.Text or ""
			local addedImportCode = normalizeAddedImportCode(text) -- equivalent call inferred; original call site unknown
			textBox.Text = addedImportCode
			refreshUi()

			if addedImportCode == "" then
				if type(v2.showToast) == "function" then
					v2.showToast("Enter an import code first")
				end
			else
				if type(v2.claimActionDebounce) == "function" and not v2.claimActionDebounce(
					"added_import_code",
					addedImportCode,
					0.35
				) then
					return
				end

				v2.inFlight = true
				refreshUi()
				local success, result = pcall(function()
					return v2.req("AddToPSByImportCode", {
						importCode = addedImportCode
					}, 4)
				end)
				v2.inFlight = false
				refreshUi()

				if success then
					if typeof(result) == "table" and result.ok then
						textBox.Text = ""
						refreshUi()
						local v4

						if type(v2.getActiveTab) == "function" then
							v4 = v2.getActiveTab() or nil
						end

						if v4 == "ADDED_TO_PS" and type(v2.refreshAddedToPS) == "function" then
							v2.refreshAddedToPS(true)
						elseif type(v2.syncAdded) == "function" then
							v2.syncAdded(true)
						end

						if type(v2.updateTabCounts) == "function" then
							v2.updateTabCounts()
						end

						if type(v2.notifyCharCreatorCatalogueRefresh) == "function" then
							v2.notifyCharCreatorCatalogueRefresh(true)
						end

						if type(v2.schedulePsMutationRefresh) == "function" then
							v2.schedulePsMutationRefresh()
						end

						if type(v2.showToast) == "function" then
							local v5 = tostring(not result.item and "Item" or result.item.name or "Item")

							if result.alreadyAdded == true then
								v2.showToast("\"" .. v5 .. "\" is already in Added")
							else
								v2.showToast("\"" .. v5 .. "\" added to PS")
							end
						end
					else
						local v4 = typeof(result) ~= "table" and "unknown" or result.error or "unknown"
						v2.warnFn(string.format(
							"[GlobalCatalogue][AddedImport][Warn] add rejected code=%s err=%s",
							tostring(addedImportCode),
							(tostring(v4))
						))

						if type(v2.showToast) == "function" then
							local fn2 = type(v2.describeCatalogueError) ~= "function" and function(value)
								return (tostring(value or "unknown"))
							end or v2.describeCatalogueError or function(value)
								return (tostring(value or "unknown"))
							end
							v2.showToast("Import add failed: " .. tostring(fn2(v4)))
						end
					end
				else
					v2.warnFn(string.format(
						"[GlobalCatalogue][AddedImport][Warn] request failed code=%s err=%s",
						tostring(addedImportCode),
						(tostring(result))
					))

					if type(v2.showToast) == "function" then
						v2.showToast("Import add failed: internal")
					end
				end
			end
		else
			warnAddedImportOnce(
				"submit_missing_textbox",
				"[GlobalCatalogue][AddedImport][UIWarn] importer textbox missing during submit"
			) -- equivalent call inferred; original call site unknown
		end
	end

	return {
		ensureUi = function()
			if v2.container and v2.container.Parent then
				refreshUi()
				return true
			end

			if v2.addedScroll and v2.addedScroll:IsA("ScrollingFrame") then
				local addedImportRow = v2.addedScroll:FindFirstChild("AddedImportRow")

				if addedImportRow then
					local importCodeBox = addedImportRow:FindFirstChild("ImportCodeBox", true)
					local importAddBtn = addedImportRow:FindFirstChild("ImportAddBtn", true)

					if importCodeBox and importCodeBox:IsA("TextBox") and importAddBtn and importAddBtn:IsA("TextButton") then
						v2.container = addedImportRow
						v2.textBox = importCodeBox
						v2.addBtn = importAddBtn
						importCodeBox.ClearTextOnFocus = false
						importCodeBox.Text = ""
						importCodeBox.PlaceholderText = "Paste import code"
						importCodeBox:GetPropertyChangedSignal("Text"):Connect(function()
							refreshUi()
						end)
						importCodeBox.FocusLost:Connect(function(p)
							local text = importCodeBox.Text or ""
							local addedImportCode = normalizeAddedImportCode(text) -- equivalent call inferred; original call site unknown

							if importCodeBox.Text ~= addedImportCode then
								importCodeBox.Text = addedImportCode
							end

							refreshUi()

							if p == true then
								submit()
							end
						end)
						importAddBtn.MouseButton1Click:Connect(function()
							submit()
						end)
						refreshUi()
						return true
					end
				end

				if not v2.addedScroll:FindFirstChildOfClass("UIListLayout") then
					warnAddedImportOnce(
						"missing_layout",
						"[GlobalCatalogue][AddedImport][UIWarn] Added scroll missing UIListLayout; importer placement may be off"
					) -- equivalent call inferred; original call site unknown
				end

				local v4 = math.max(32, tonumber(v2.addedSearchBox and v2.addedSearchBox.AbsoluteSize.Y) or 32)
				local frame = Instance.new("Frame")
				frame.Name = "AddedImportRow"
				frame.BackgroundTransparency = 1
				frame.LayoutOrder = -1000
				frame.Size = UDim2.new(1, -8, 0, v4)
				local uIListLayout = Instance.new("UIListLayout")
				uIListLayout.FillDirection = Enum.FillDirection.Horizontal
				uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				uIListLayout.Padding = UDim.new(0, 8)
				uIListLayout.Parent = frame
				local textBox

				if v2.addedSearchBox and v2.addedSearchBox:IsA("TextBox") then
					textBox = v2.addedSearchBox:Clone()
				else
					warnAddedImportOnce(
						"missing_search_template",
						"[GlobalCatalogue][AddedImport][UIWarn] Added search box missing or invalid; using fallback importer box"
					) -- equivalent call inferred; original call site unknown
					textBox = Instance.new("TextBox")
					textBox.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
					textBox.BackgroundTransparency = 0.1
					textBox.BorderSizePixel = 0
					textBox.Font = Enum.Font.Gotham
					textBox.TextSize = 14
					textBox.TextColor3 = Color3.fromRGB(245, 245, 245)
					textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
				end

				textBox.Name = "ImportCodeBox"
				textBox.Visible = true
				textBox.ClearTextOnFocus = false
				textBox.Text = ""
				textBox.PlaceholderText = "Paste import code"
				textBox.Size = UDim2.new(1, -96, 1, 0)
				textBox.LayoutOrder = 1
				textBox.Parent = frame
				local removeBtn = v2.addedRowTemplate and v2.addedRowTemplate:FindFirstChild("RemoveBtn", true)
				local addBtn

				if removeBtn and removeBtn:IsA("TextButton") then
					addBtn = removeBtn:Clone()
				else
					warnAddedImportOnce(
						"missing_add_template",
						"[GlobalCatalogue][AddedImport][UIWarn] Added row button template missing; using fallback Add button"
					) -- equivalent call inferred; original call site unknown
					addBtn = Instance.new("TextButton")
					addBtn.Font = Enum.Font.GothamBold
					addBtn.TextSize = 13
					addBtn.BorderSizePixel = 0
				end

				addBtn.Name = "ImportAddBtn"
				addBtn.Visible = true
				addBtn.Size = UDim2.new(0, 88, 1, 0)
				addBtn.LayoutOrder = 2
				addBtn.Text = "ADD"
				addBtn.Parent = frame
				textBox:GetPropertyChangedSignal("Text"):Connect(function()
					refreshUi()
				end)
				textBox.FocusLost:Connect(function(p)
					local text = textBox.Text or ""
					local addedImportCode = normalizeAddedImportCode(text) -- equivalent call inferred; original call site unknown

					if textBox.Text ~= addedImportCode then
						textBox.Text = addedImportCode
					end

					refreshUi()

					if p == true then
						submit()
					end
				end)
				addBtn.MouseButton1Click:Connect(function()
					submit()
				end)
				frame.Parent = v2.addedScroll
				v2.container = frame
				v2.textBox = textBox
				v2.addBtn = addBtn
				refreshUi()
				return true
			else
				warnAddedImportOnce(
					"missing_scroll",
					"[GlobalCatalogue][AddedImport][UIWarn] Added scroll missing; importer UI not created"
				) -- equivalent call inferred; original call site unknown
				return false
			end
		end,
		refreshUi = function()
			refreshUi()
		end
	}
end

function RequestHelper.newDetailCardApi(options)
	local v = options or {}
	local v2 = {
		overlay = v.overlay,
		warnFn = v.warnFn or warn,
		warned = {}
	}

	local function getRequiredDirectChild(instance, p, p2, p3, p4)
		local firstDirectChild = getFirstDirectChild(instance, p, p4)

		if firstDirectChild then
			return firstDirectChild
		end

		warnMissingOnce(
			v2,
			p2,
			string.format(
				"[GlobalCatalogue][UIWarn] %s missing on %s",
				tostring(p3),
				(tostring(typeof(instance) ~= "Instance" and "nil" or instance:GetFullName() or "nil"))
			)
		) -- equivalent call inferred; original call site unknown
		return nil
	end

	local function buildRefs(childName)
		local overlay = v2.overlay
		local guiObject

		if typeof(overlay) == "Instance" then
			guiObject = overlay:FindFirstChild(childName)

			if guiObject then
				if not guiObject:IsA("GuiObject") then
					guiObject = nil
				end
			else
				guiObject = nil
			end
		end

		if guiObject then
			local frame

			if typeof(guiObject) == "Instance" then
				frame = guiObject:FindFirstChild("Frame")

				if frame then
					if not frame:IsA("GuiObject") then
						frame = nil
					end
				else
					frame = nil
				end
			end

			local requiredDirectChild = getRequiredDirectChild(
				guiObject,
				{ "ActionSection" },
				"missing_action_" .. childName,
				"ActionSection",
				"GuiObject"
			)
			local frame2

			if typeof(requiredDirectChild) == "Instance" then
				frame2 = requiredDirectChild:FindFirstChild("Frame")

				if frame2 then
					if not frame2:IsA("GuiObject") then
						frame2 = nil
					end
				else
					frame2 = nil
				end
			end

			local requiredDirectChild2 = getRequiredDirectChild(
				guiObject,
				{ "CreatorRow" },
				"missing_creatorrow_" .. childName,
				"CreatorRow",
				"GuiObject"
			)
			local requiredDirectChild3 = getRequiredDirectChild(
				guiObject,
				{ "StatsBar" },
				"missing_stats_" .. childName,
				"StatsBar",
				"GuiObject"
			)
			local requiredDirectChild4 = getRequiredDirectChild(
				guiObject,
				{ "VoteRow" },
				"missing_voterow_" .. childName,
				"VoteRow",
				"GuiObject"
			)
			local movesSec

			if childName == "CharacterDetailCard" then
				movesSec = getFirstDirectChild(guiObject, { "DataHolder", "MovesSection" }, "GuiObject")
			else
				movesSec = getFirstDirectChild(guiObject, { "MovesSection" }, "GuiObject")
			end

			local v4 = {
				key = childName,
				card = guiObject,
				headerFrame = frame,
				close = getRequiredDirectChild(
					frame,
					{ "CloseBtn" },
					"missing_close_" .. childName,
					"CloseBtn",
					"GuiButton"
				),
				fav = getFirstDirectChild(frame, { "FavBtn" }, "GuiObject"),
				addedBadge = getFirstDirectChild(guiObject, { "AddedBadge" }, "GuiObject"),
				scroll = getFirstDirectChild(guiObject, { "DetailScroll" }, "GuiObject") or guiObject,
				titleSec = getFirstDirectChild(guiObject, { "TitleSection" }, "GuiObject") or guiObject,
				typeBadge = getFirstDirectChild(guiObject, { "DetailTypeBadge" }, "GuiObject"),
				charName = getRequiredDirectChild(guiObject, { "CharName" }, "missing_name_" .. childName, "CharName"),
				subtitle = getFirstDirectChild(guiObject, { "SubtitleLabel" }, "GuiObject"),
				creatorRow = requiredDirectChild2,
				creatorBtn = getFirstDirectChild(requiredDirectChild2, { "CreatorBtn" }, "GuiObject") or getFirstDirectChild(
					requiredDirectChild2,
					{ "ByLabel" },
					"GuiObject"
				),
				timeLabel = getFirstDirectChild(requiredDirectChild2, { "TimeLabel" }, "GuiObject"),
				tagRow = getFirstDirectChild(guiObject, { "DetailTags" }, "GuiObject"),
				desc = getRequiredDirectChild(guiObject, { "DescLabel" }, "missing_desc_" .. childName, "DescLabel"),
				stats = requiredDirectChild3,
				voteRow = requiredDirectChild4,
				likeBtn = getFirstDirectChild(requiredDirectChild4, { "LikeBtn" }, "GuiObject"),
				dislikeBtn = getFirstDirectChild(requiredDirectChild4, { "DislikeBtn" }, "GuiObject"),
				actSec = requiredDirectChild,
				addPSBtn = getFirstDirectChild(requiredDirectChild, { "AddToPSBtn", "AddToPSPBtn" }, "GuiObject"),
				removePSBtn = getFirstDirectChild(frame2, { "RemoveFromPSBtn" }, "GuiObject") or getFirstDirectChild(
					requiredDirectChild,
					{ "RemoveFromPSBtn" },
					"GuiObject"
				),
				reportBtn = getFirstDirectChild(frame2, { "ReportBtn" }, "GuiObject") or getFirstDirectChild(
					requiredDirectChild,
					{ "ReportBtn" },
					"GuiObject"
				),
				confirmReport = getFirstDirectChild(frame2, { "ConfirmReportBtn" }, "GuiObject") or getFirstDirectChild(
					requiredDirectChild,
					{ "ConfirmReportBtn" },
					"GuiObject"
				),
				movesSec = movesSec
			}

			if childName ~= "CharacterDetailCard" or v4.movesSec then
				return v4
			end

			warnMissingOnce(
				v2,
				"missing_character_moves_section",
				string.format(
					"[GlobalCatalogue][UIWarn] DataHolder missing on %s (%s)",
					tostring(childName),
					guiObject:GetFullName()
				)
			) -- equivalent call inferred; original call site unknown
			return v4
		else
			warnMissingOnce(
				v2,
				"missing_card_" .. tostring(childName),
				string.format("[GlobalCatalogue][UIWarn] detail card missing: %s", (tostring(childName)))
			) -- equivalent call inferred; original call site unknown
			return nil
		end
	end

	local v3 = {
		defaultRefs = buildRefs("DetailCard"),
		characterRefs = buildRefs("CharacterDetailCard")
	}
	local defaultCard

	if v3.defaultRefs then
		defaultCard = v3.defaultRefs.card or nil
	end

	v3.defaultCard = defaultCard
	local characterCard

	if v3.characterRefs then
		characterCard = v3.characterRefs.card or nil
	end

	v3.characterCard = characterCard

	function v3.warnMissingOnce(p, p2)
		warnMissingOnce(v2, tostring(p), tostring(p2)) -- equivalent call inferred; original call site unknown
	end

	function v3.isCharacterEntry(p)
		if type(p) ~= "table" then
			return false
		end

		if tostring(p.category or "") == "Character" then
			return true
		end

		local v6 = lowerTrim(p.type) -- equivalent call inferred; original call site unknown
		return v6 == "character" or v6 == "char" or v6 == "characters"
	end

	function v3.selectRefsForEntry(p)
		if v3.isCharacterEntry(p) and v3.characterRefs then
			return v3.characterRefs, true
		end

		return v3.defaultRefs, false
	end

	function v3.showOnly(p)
		if v3.defaultCard then
			v3.defaultCard.Visible = p and p.card == v3.defaultCard and true or false
		end

		if v3.characterCard then
			v3.characterCard.Visible = p and p.card == v3.characterCard and true or false
		end
	end

	function v3.hideAll()
		if v3.defaultCard then
			v3.defaultCard.Visible = false
		end

		if v3.characterCard then
			v3.characterCard.Visible = false
		end
	end

	return v3
end

function RequestHelper.newCreatorProfileApi(options)
	local v = options or {}
	local v2 = {
		warnFn = v.warnFn or warn,
		warned = {},
		tabs = typeof(v.tabs) ~= "table" and {} or v.tabs or {},
		creatorOverlay = v.creatorOverlay,
		detailOverlay = v.detailOverlay,
		cachedProfile = nil
	}
	local v3 = typeof(v.refs) ~= "table" and {} or v.refs or {}
	local req = v.req
	local showToast = v.showToast or function() end
	local setLoading = v.setLoading or function() end
	local getActiveTab = v.getActiveTab or function()
		return nil
	end
	local isPopupCooldown = v.isPopupCooldown or function()
		return false
	end
	local closeDetail = v.closeDetail
	local startPopupCooldown = v.startPopupCooldown or function() end
	local syncOverlayLayout = v.syncOverlayLayout
	local setCloseButtonsBackMode = v.setCloseButtonsBackMode
	local toRuntimeLegacyEntry = v.toRuntimeLegacyEntry or function(p)
		return p
	end
	local getVerifiedAvatarHeadshot = v.getVerifiedAvatarHeadshot or function()
		return "", false
	end
	local applyNameStroke = v.applyNameStroke or function() end
	local v4 = typeof(v.typeToCategory) ~= "table" and {} or v.typeToCategory or {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function warnCreatorProfileOnce(p, p2)
		warnMissingOnce(v2, tostring(p), tostring(p2)) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolveCreatorStatInt(p)
		local v5 = tonumber(p)

		if type(v5) == "number" and v5 == v5 then
			return (math.max(0, (math.floor(v5 + 0.5))))
		end

		return nil
	end

	local function formatStatShort(p)
		local v5 = math.max(0, (math.floor(tonumber(p) or 0)))

		if v5 >= 1000000 then
			local v6 = v5 / 1000000
			return v6 % 1 == 0 and string.format("%dM", v6) or string.format("%.1fM", v6)
		end

		if v5 >= 1000 then
			local v6 = v5 / 1000
			return v6 % 1 == 0 and string.format("%dK", v6) or string.format("%.1fK", v6)
		else
			return (tostring(v5))
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setCreatorStatNumber(guiObject, p)
		if guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
			guiObject.Text = formatStatShort(p)
		end
	end

	local function resolveCreatorProfileTotalDownloads(data)
		local creatorStatInt = resolveCreatorStatInt(data and data.totalDownloads) -- equivalent call inferred; original call site unknown

		if creatorStatInt ~= nil then
			return creatorStatInt
		end

		local creatorStatInt2 = resolveCreatorStatInt(data and data.totalUses) -- equivalent call inferred; original call site unknown
		local creatorStatInt3 = resolveCreatorStatInt(data and data.totalAdded) -- equivalent call inferred; original call site unknown
		return (math.max(creatorStatInt2 or 0, creatorStatInt3 or 0))
	end

	local function resolveCreatorProfileTotalFavorites(creator, p, p2)
		local v5 = {
			creator and creator.totalFavorites,
			creator and creator.totalFavourites,
			p and p.totalFavorites,
			p and p.totalFavourites
		}

		for _, v6 in ipairs(v5) do
			local creatorStatInt = resolveCreatorStatInt(v6) -- equivalent call inferred; original call site unknown

			if creatorStatInt ~= nil then
				return creatorStatInt
			end
		end

		warnCreatorProfileOnce(
			"missing_total_favourites_" .. tostring(p2),
			string.format(
				"[GlobalCatalogue][CreatorProfile][Warn] total favourites missing creatorUserId=%s; defaulting to 0 until backend provides it",
				(tostring(p2))
			)
		) -- equivalent call inferred; original call site unknown
		return 0
	end

	local function collectCreatorProfileItems(data)
		local result = {}
		local result2 = {}
		local entriesByType

		if type(data) == "table" then
			entriesByType = data.entriesByType or nil
		end

		local entriesByTypeCounts

		if type(data) == "table" then
			entriesByTypeCounts = data.entriesByTypeCounts or nil
		end

		if type(entriesByType) == "table" then
			for k, v5 in pairs(entriesByType) do
				local v6 = v4[tostring(k or "")]
				local v7

				if type(entriesByTypeCounts) == "table" then
					v7 = entriesByTypeCounts[k] or nil
				end

				local creatorStatInt = resolveCreatorStatInt(v7) -- equivalent call inferred; original call site unknown

				if v6 and creatorStatInt ~= nil then
					result2[v6] = (result2[v6] or 0) + creatorStatInt
				end

				if type(v5) ~= "table" then
					continue
				end

				for _, v8 in ipairs(v5) do
					table.insert(result, toRuntimeLegacyEntry(v8))
				end
			end
		end

		if #result <= 0 then
			for _, v5 in ipairs(type(data) ~= "table" and {} or data.topEntries or {}) do
				table.insert(result, toRuntimeLegacyEntry(v5))
			end
		end

		return result, result2
	end

	local function applyCreatorTakeoverVisibility(p)
		local visible = p == true

		if type(syncOverlayLayout) == "function" then
			syncOverlayLayout()
		end

		local activeTab = getActiveTab()

		for k, tab in pairs(v2.tabs) do
			if typeof(tab) == "table" and tab.frame then
				tab.frame.Visible = not visible and k == activeTab
			end
		end

		if v2.creatorOverlay then
			v2.creatorOverlay.Visible = visible
		end

		if v3.card and v3.card:IsA("GuiObject") then
			v3.card.Visible = visible
		end

		if type(setCloseButtonsBackMode) == "function" then
			setCloseButtonsBackMode(visible)
		end
	end

	local function renderCreatorProfilePayload(p, p2, response)
		local creator = response.creator or {}
		local name = creator.name or p2 or "User" .. tostring(p)
		v2.cachedProfile = {
			creatorUserId = math.max(0, (math.floor(tonumber(p) or 0))),
			creatorName = tostring(name or ""),
			response = response
		}
		applyCreatorTakeoverVisibility(true)
		local nameLabel = v3.nameLabel

		if nameLabel and (nameLabel:IsA("TextLabel") or nameLabel:IsA("TextButton")) then
			nameLabel.Text = name
			applyNameStroke(nameLabel)
		else
			warnCreatorProfileOnce(
				"missing_creator_name",
				"[GlobalCatalogue][CreatorProfile][UIWarn] CreatorHeader.Frame.CreatorName missing"
			) -- equivalent call inferred; original call site unknown
		end

		local snapshotImage = v3.snapshotImage

		if snapshotImage and (snapshotImage:IsA("ImageLabel") or snapshotImage:IsA("ImageButton")) then
			local verifiedAvatarHeadshot, v6 = getVerifiedAvatarHeadshot(p)
			snapshotImage.Image = v6 and verifiedAvatarHeadshot or ""
			snapshotImage.Visible = true
		else
			warnCreatorProfileOnce(
				"missing_creator_snapshot",
				"[GlobalCatalogue][CreatorProfile][UIWarn] CreatorHeader.Frame.ImageLabel missing"
			) -- equivalent call inferred; original call site unknown
		end

		local likesLabel = v3.likesLabel
		local creatorStatInt = resolveCreatorStatInt(creator.totalLikes) -- equivalent call inferred; original call site unknown
		setCreatorStatNumber(likesLabel, creatorStatInt or 0) -- equivalent call inferred; original call site unknown
		local downloadsLabel = v3.downloadsLabel
		local creatorStatInt2 = resolveCreatorStatInt(creator and creator.totalDownloads) -- equivalent call inferred; original call site unknown

		if creatorStatInt2 == nil then
			local creatorStatInt3 = resolveCreatorStatInt(creator and creator.totalUses) -- equivalent call inferred; original call site unknown
			local creatorStatInt4 = resolveCreatorStatInt(creator and creator.totalAdded) -- equivalent call inferred; original call site unknown
			creatorStatInt2 = math.max(creatorStatInt3 or 0, creatorStatInt4 or 0)
		end

		setCreatorStatNumber(downloadsLabel, creatorStatInt2) -- equivalent call inferred; original call site unknown
		setCreatorStatNumber(v3.favouritesLabel, resolveCreatorProfileTotalFavorites(creator, response, p)) -- equivalent call inferred; original call site unknown
		local v7 = collectCreatorProfileItems(response)
		local creationsLabel = v3.creationsLabel
		local creatorStatInt3 = resolveCreatorStatInt(creator.totalUploads) -- equivalent call inferred; original call site unknown
		setCreatorStatNumber(creationsLabel, creatorStatInt3 or #v7) -- equivalent call inferred; original call site unknown

		if type(v.renderItems) == "function" then
			v.renderItems(p, name, v7)
		end
	end

	return {
		close = function(p)
			applyCreatorTakeoverVisibility(false)

			if p ~= true then
				startPopupCooldown()
			end
		end,
		open = function(p, p2, options2)
			local v6 = options2 or {}

			if isPopupCooldown() and v6.bypassCooldown ~= true then
				return
			end

			local creatorUserId = math.max(0, (math.floor(tonumber(p) or 0)))

			if creatorUserId <= 0 then
				return
			end

			if v2.detailOverlay and v2.detailOverlay.Visible and type(closeDetail) == "function" then
				closeDetail(true)
			end

			local cachedProfile = v2.cachedProfile

			if v6.useCached == true and typeof(cachedProfile) == "table" and tonumber(cachedProfile.creatorUserId) == creatorUserId and typeof(cachedProfile.response) == "table" then
				applyCreatorTakeoverVisibility(true)
			elseif type(req) == "function" then
				setLoading(true)
				local response = req("CreatorProfile", {
					creatorUserId = creatorUserId,
					assetType = "all",
					index = "most_liked"
				}, 4)

				if type(response) == "table" and response.ok then
					renderCreatorProfilePayload(creatorUserId, p2, response)
					setLoading(false)
				else
					setLoading(false)
					showToast("Creator load failed")
				end
			else
				warnCreatorProfileOnce(
					"missing_req",
					"[GlobalCatalogue][CreatorProfile][Warn] request function missing"
				) -- equivalent call inferred; original call site unknown
				showToast("Creator load failed")
			end
		end
	}
end

function RequestHelper.newDetailReturnApi()
	local v = {
		pendingCreatorProfile = nil
	}
	local v2 = {
		rememberCreatorProfile = function(p, value)
			local userId = math.max(0, (math.floor(tonumber(p) or 0)))

			if userId <= 0 then
				v.pendingCreatorProfile = nil
			else
				v.pendingCreatorProfile = {
					userId = userId,
					name = tostring(value or "")
				}
			end
		end,
		consumeCreatorProfile = function()
			local pendingCreatorProfile = v.pendingCreatorProfile
			v.pendingCreatorProfile = nil
			return pendingCreatorProfile
		end
	}

	function v2.restoreCreatorProfile(callback)
		local v3 = v2.consumeCreatorProfile()

		if not v3 or type(callback) ~= "function" then
			return false
		end

		local v4 = math.max(0, (math.floor(tonumber(v3.userId) or 0)))

		if v4 <= 0 then
			return false
		end

		callback(v4, v3.name, {
			bypassCooldown = true,
			useCached = true
		})
		return true
	end

	function v2.clear()
		v.pendingCreatorProfile = nil
	end

	return v2
end

function RequestHelper.refreshUploadPreviewCard(options, options2)
	local v = options2 or {}
	local uploadPreviewCard = v.uploadPreviewCard

	if not uploadPreviewCard then
		return
	end

	local inferTypeFromSource = v.inferTypeFromSource or function(p)
		return (tostring(p and p.assetType or "moves"))
	end
	local v2 = typeof(v.typeToCategory) ~= "table" and {} or v.typeToCategory or {}
	local v3 = typeof(v.categoryDefaultImages) ~= "table" and {} or v.categoryDefaultImages or {}
	local v4 = typeof(v.categoryColors) ~= "table" and {} or v.categoryColors or {}
	local v5 = typeof(v.categoryLabels) ~= "table" and {} or v.categoryLabels or {}
	local resolveUploadThumbnail = v.resolveUploadThumbnail or function()
		return nil
	end
	local normalizeCatalogueImage = v.normalizeCatalogueImage or function(p)
		return p
	end
	local rgb = v.rgb or Color3.fromRGB
	local playerName = tostring(v.playerName or "Player")
	local escapeRichText = v.escapeRichText or function(value)
		return (tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
	end
	local findStatsOverlayNode = v.findStatsOverlayNode or function()
		return nil
	end
	local setStatTextPreservePrefix = v.setStatTextPreservePrefix or function() end
	local emojiThumbsUp = v.emojiThumbsUp or function()
		return "+"
	end
	local emojiThumbsDown = v.emojiThumbsDown or function()
		return "-"
	end
	local emojiStar = v.emojiStar or function()
		return "*"
	end
	local applyFavouriteVisual = v.applyFavouriteVisual or function() end
	local printFn = v.printFn or print
	local v6, v7

	if options then
		v6 = inferTypeFromSource(options) or tostring(not options and "moves" or options.assetType or "moves")
		v7 = v2[v6] or "Move"
	else
		v7 = "Character"
		v6 = "characters"
	end

	local text = not options and "Character Name" or tostring(options.name or "Character Name") or "Character Name"
	local uploadThumbnail = resolveUploadThumbnail(options or {}, true)
	local catalogueImage = normalizeCatalogueImage(uploadThumbnail)
	local v9 = v3[v7] or v3.Character
	uploadPreviewCard.Visible = true
	local cardHeader = uploadPreviewCard:FindFirstChild("CardHeader")

	if cardHeader and cardHeader:IsA("GuiObject") then
		local realImage = cardHeader:FindFirstChild("RealImage", true)
		local templateImage = cardHeader:FindFirstChild("TemplateImage", true)
		local iconLabel = cardHeader:FindFirstChild("IconLabel", true)

		if realImage and (realImage:IsA("ImageLabel") or realImage:IsA("ImageButton")) then
			realImage.BackgroundTransparency = 1
			realImage.Image = catalogueImage or ""
			realImage.Visible = catalogueImage ~= nil
		end

		if templateImage and (templateImage:IsA("ImageLabel") or templateImage:IsA("ImageButton")) then
			templateImage.Image = catalogueImage ~= nil and "" or tostring(v9 or "") or ""
			templateImage.Visible = catalogueImage == nil and v9 ~= nil
		end

		if iconLabel and (iconLabel:IsA("TextLabel") or iconLabel:IsA("TextButton")) then
			iconLabel.Visible = false
		end

		printFn(string.format(
			"[GlobalCatalogue][UploadPreview][Debug] refresh card=%s category=%s raw=%s real=%s realVisible=%s template=%s templateVisible=%s",
			tostring(uploadPreviewCard:GetFullName()),
			tostring(v7),
			tostring(uploadThumbnail or "nil"),
			tostring(not realImage and "nil" or realImage.Image or "nil"),
			tostring(realImage and realImage.Visible or false),
			tostring(not templateImage and "nil" or templateImage.Image or "nil"),
			(tostring(templateImage and templateImage.Visible or false))
		))
	else
		printFn(string.format(
			"[GlobalCatalogue][UploadPreview][Debug] refresh missing CardHeader card=%s",
			(tostring(not uploadPreviewCard and "nil" or uploadPreviewCard:GetFullName() or "nil"))
		))
	end

	local typeBadge = uploadPreviewCard:FindFirstChild("TypeBadge")

	if typeBadge and (typeBadge:IsA("TextLabel") or typeBadge:IsA("TextButton")) then
		if v7 == "Character" then
			typeBadge.Visible = false
		else
			typeBadge.Text = v5[v7] or ""
			typeBadge.TextColor3 = rgb(255, 255, 255)
			typeBadge.BackgroundColor3 = v4[v7] or rgb(200, 60, 60)
			typeBadge.Visible = true
		end
	end

	local cardInfo = uploadPreviewCard:FindFirstChild("CardInfo")

	if cardInfo and cardInfo:IsA("GuiObject") then
		local charName = cardInfo:FindFirstChild("CharName")

		if charName and (charName:IsA("TextLabel") or charName:IsA("TextButton")) then
			charName.Text = text
		end

		local creatorLine = cardInfo:FindFirstChild("CreatorLine")

		if creatorLine and (creatorLine:IsA("TextLabel") or creatorLine:IsA("TextButton")) then
			creatorLine.RichText = true
			creatorLine.Text = "by <b>" .. escapeRichText(playerName) .. "</b>"
		end

		local days = cardInfo:FindFirstChild("Days")

		if days and (days:IsA("TextLabel") or days:IsA("TextButton")) then
			days.Text = "Today"
			days.Visible = true
		end

		local subtitleLabel = cardInfo:FindFirstChild("SubtitleLabel")

		if subtitleLabel and (subtitleLabel:IsA("TextLabel") or subtitleLabel:IsA("TextButton")) then
			subtitleLabel.Visible = false
		end

		local robuxText = cardInfo:FindFirstChild("RobuxText")

		if robuxText and robuxText:IsA("GuiObject") then
			robuxText.Visible = false
		end
	end

	local statsOverlayNode = findStatsOverlayNode(uploadPreviewCard)

	if statsOverlayNode and statsOverlayNode:IsA("GuiObject") then
		local likesStat = statsOverlayNode:FindFirstChild("LikesStat")
		local dislikeStat = statsOverlayNode:FindFirstChild("DislikeStat")
		local favouriteStat = statsOverlayNode:FindFirstChild("FavouriteStat") or statsOverlayNode:FindFirstChild("FavStat")
		local dlState = statsOverlayNode:FindFirstChild("DlState") or statsOverlayNode:FindFirstChild("DlStat")
		setStatTextPreservePrefix(likesStat, 0, emojiThumbsUp())
		setStatTextPreservePrefix(dislikeStat, 0, emojiThumbsDown())
		setStatTextPreservePrefix(favouriteStat, 0, emojiStar())
		setStatTextPreservePrefix(dlState, 0, utf8.char(11015))
	end

	local favBtn = uploadPreviewCard:FindFirstChild("FavBtn")

	if favBtn and favBtn:IsA("TextButton") then
		applyFavouriteVisual(favBtn, false)
	end

	local addedBadge = uploadPreviewCard:FindFirstChild("AddedBadge")

	if addedBadge and addedBadge:IsA("GuiObject") then
		addedBadge.Visible = false
	end

	uploadPreviewCard:SetAttribute("PreviewAssetType", v6)
end

function RequestHelper.bindUploadImageInputPreview(options)
	local v = options or {}
	local uploadListState = v.uploadListState

	if not (typeof(uploadListState) == "table" and uploadListState.uploadImagePreviewBound ~= true) then
		return
	end

	local textBox = (v.findUploadImageInput or function()
		return nil
	end)()

	if not (textBox and textBox:IsA("TextBox")) then
		return
	end

	local warnFn = v.warnFn or warn
	local printFn = v.printFn or print
	local normalizeCatalogueImage = v.normalizeCatalogueImage or function(p)
		return p
	end
	local isUploadConfirmVisible = v.isUploadConfirmVisible or function()
		return false
	end
	local getSelectedUploadSource = v.getSelectedUploadSource or function()
		return nil
	end
	local refreshUploadPreviewCard = v.refreshUploadPreviewCard or function() end
	uploadListState.uploadImagePreviewBound = true
	warnFn("[GlobalCatalogue][UploadPreview][Debug] bound image input", textBox, (tostring(textBox:GetFullName())))
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local catalogueImage = normalizeCatalogueImage(textBox.Text)
		printFn(string.format(
			"[GlobalCatalogue][UploadPreview][Debug] text_changed textbox=%s raw=%s normalized=%s visible=%s",
			tostring(textBox:GetFullName()),
			tostring(textBox.Text or ""),
			tostring(catalogueImage or "nil"),
			(tostring(isUploadConfirmVisible() == true))
		))

		if not isUploadConfirmVisible() then
			return
		end

		refreshUploadPreviewCard(getSelectedUploadSource())
	end)
	textBox.FocusLost:Connect(function(p)
		local catalogueImage = normalizeCatalogueImage(textBox.Text)
		printFn(string.format(
			"[GlobalCatalogue][UploadPreview][Debug] focus_lost textbox=%s enter=%s raw=%s normalized=%s visible=%s",
			tostring(textBox:GetFullName()),
			tostring(p == true),
			tostring(textBox.Text or ""),
			tostring(catalogueImage or "nil"),
			(tostring(isUploadConfirmVisible() == true))
		))

		if not isUploadConfirmVisible() then
			return
		end

		refreshUploadPreviewCard(getSelectedUploadSource())
	end)
end

RequestHelper.CAT_LABELS = {
	Character = "CHARACTER",
	Map = "MAP",
	Move = "MOVE",
	AwakenMove = "AWAKEN MOVE",
	SpawnAnim = "SPAWN ANIM",
	AwakenAnim = "AWAKEN ANIM",
	M1Style = "M1 STYLE",
	WallCombo = "WALL COMBO",
	ForwardDash = "FORWARD DASH",
	Effect = "EFFECT",
	CreatedAnim = "ANIMATION"
}
RequestHelper.CAT_ICONS = {
	Character = utf8.char(128100),
	Map = utf8.char(128506),
	Move = utf8.char(9876),
	SpawnAnim = utf8.char(129486),
	AwakenAnim = utf8.char(128293),
	M1Style = utf8.char(128074),
	WallCombo = utf8.char(129521),
	ForwardDash = utf8.char(128168),
	AwakenMove = utf8.char(128293),
	Effect = utf8.char(10024),
	CreatedAnim = utf8.char(127916)
}
RequestHelper.CATEGORY_DEFAULT_IMAGES = {
	Character = "rbxassetid://12285568530",
	Map = "rbxassetid://73255217081166",
	Move = "rbxassetid://71409159204082",
	AwakenMove = "rbxassetid://70373346654887",
	SpawnAnim = "rbxassetid://86172747048612",
	AwakenAnim = "rbxassetid://70373346654887",
	M1Style = "rbxassetid://91334818474792",
	WallCombo = "rbxassetid://71409159204082",
	ForwardDash = "rbxassetid://12252434969",
	Effect = "rbxassetid://71409159204082",
	CreatedAnim = "rbxassetid://74229804273283"
}
RequestHelper.CAT_ADD_TEXT = {
	Character = "ADD CHARACTER TO PS",
	Map = "LOAD MAP",
	Move = "ADD MOVE TO PS",
	SpawnAnim = "ADD ANIM TO PS",
	AwakenAnim = "ADD ANIM TO PS",
	M1Style = "ADD M1 STYLE TO PS",
	WallCombo = "ADD WALL COMBO TO PS",
	ForwardDash = "ADD DASH TO PS",
	AwakenMove = "ADD MOVE TO PS",
	Effect = "ADD EFFECT TO PS",
	CreatedAnim = "ADD ANIM TO PS"
}
RequestHelper.TYPE_TO_UPLOAD_LABEL = {
	characters = "Characters",
	maps = "Maps",
	moves = "Moves",
	awaken_moves = "Awaken Moves",
	m1_styles = "M1 Styles",
	forward_dashes = "Forward Dashes",
	wall_combos = "Wall Combos",
	spawn_animations = "Spawn Animations",
	awakening_animations = "Awakening Animations",
	effects = "Effects",
	created_anims = "Animations"
}
RequestHelper.UPLOAD_TYPE_ORDER = {
	"characters",
	"maps",
	"moves",
	"awaken_moves",
	"m1_styles",
	"forward_dashes",
	"wall_combos",
	"spawn_animations",
	"awakening_animations",
	"effects",
	"created_anims"
}
RequestHelper.SORT_TO_INDEX = {
	liked = "most_liked",
	new = "newest",
	used = "most_used",
	trending = "trending",
	added = "added",
	favourites = "favourites"
}
RequestHelper.SEARCH_MIN_TOKEN_LENGTH = 3
RequestHelper.ITEMS_PER_PAGE = 50
RequestHelper.PENDING_PS_MUTATION_TTL_SEC = 8
RequestHelper.ENTRY_BY_ID_MAX = 5000
RequestHelper.BROWSE_BACKGROUND_FULL_REFRESH_SEC = 60
RequestHelper.LEADERBOARD_CACHE_TTL_SEC = 25
RequestHelper.VERIFIED_AVATAR_CACHE_SUCCESS_TTL = 300
RequestHelper.VERIFIED_AVATAR_CACHE_FAILURE_TTL = 20
RequestHelper.VERIFIED_AVATAR_CACHE_SWEEP_INTERVAL = 10
RequestHelper.VERIFIED_AVATAR_CACHE_MAX_SIZE = 5000
return RequestHelper