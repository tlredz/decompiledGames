local Themes = {}
local Utility = require(script.Parent.Parent.Utility)
local Default = require(script.Default)

function Themes.getThemeValue(items, p, p2, _)
	if items then
		for _, list in pairs(items) do
			local v, v2, v3 = unpack(list)

			if p == v and p2 == v2 then
				return v3
			end
		end
	end
end

function Themes.getInstanceValue(instance, attributeName)
	local success, result = pcall(function()
		return instance[attributeName]
	end)

	if not success then
		result = instance:GetAttribute(attributeName)
	end

	return result
end

function Themes.getRealInstance(instance)
	if not instance:GetAttribute("IsAClippedClone") then
		return
	end

	local originalInstance = instance:FindFirstChild("OriginalInstance")

	if originalInstance then
		return originalInstance.Value
	end
end

function Themes.getClippedClone(instance)
	if not instance:GetAttribute("HasAClippedClone") then
		return
	end

	local clippedClone = instance:FindFirstChild("ClippedClone")

	if clippedClone then
		return clippedClone.Value
	end
end

function Themes.refresh(object, folder, p)
	if p then
		local stateGroup = object:getStateGroup()
		local v = Themes.getThemeValue(stateGroup, folder.Name, p) or Themes.getInstanceValue(folder, p)
		Themes.apply(object, folder, p, v, true)
	else
		local stateGroup = object:getStateGroup()

		if not stateGroup then
			return
		end

		local v = {
			[folder.Name] = folder
		}

		for _, descendant in pairs(folder:GetDescendants()) do
			local collective = descendant:GetAttribute("Collective")

			if collective then
				v[collective] = descendant
			end

			v[descendant.Name] = descendant
		end

		for _, list in pairs(stateGroup) do
			local v2, v3, v4 = unpack(list)
			local v5 = v[v2]

			if v5 then
				Themes.apply(object, v5.Name, v3, v4, true)
			end
		end
	end
end

function Themes.apply(object, instance, p, p2, p3)
	if object.isDestroyed then
		return
	end

	local name, clippedClones

	if typeof(instance) == "Instance" then
		name = instance.Name
		clippedClones = { instance }
	else
		clippedClones = object:getInstanceOrCollective(instance)
		name = instance
	end

	local v = name .. "-" .. p
	local customBehaviour = object.customBehaviours[v]

	for _, v2 in pairs(clippedClones) do
		local clippedClone = Themes.getClippedClone(v2)

		if clippedClone then
			table.insert(clippedClones, clippedClone)
		end
	end

	for _, v2 in pairs(clippedClones) do
		if not ((p ~= "Position" or not Themes.getClippedClone(v2)) and (p ~= "Size" or not Themes.getRealInstance(v2))) then
			continue
		end

		local instanceValue = Themes.getInstanceValue(v2, p)

		if not (p3 or p2 ~= instanceValue) then
			continue
		end

		if customBehaviour then
			local v3 = customBehaviour(p2, v2, p)

			if v3 ~= nil then
				p2 = v3
			end
		end

		local v3 = v2

		if pcall(function()
			v3[p] = p2
		end) then
			continue
		end

		v2:SetAttribute(p, p2)
	end
end

function Themes.getModifications(list)
	return typeof(list[1]) ~= "table" and { list } or list
end

function Themes:merge(list2, callback)
	local v, v2, v3, v4 = table.unpack(list2)
	local v5, v6, _, v7 = table.unpack(self)

	if v ~= v5 or v2 ~= v6 or not Themes.statesMatch(v4, v7) then
		return false
	end

	self[3] = v3

	if callback then
		callback(self)
	end

	return true
end

function Themes.modify(object, items, p)
	task.spawn(function()
		p = p or Utility.generateUID()
		items = Themes.getModifications(items)

		for _, list in pairs(items) do
			local v, v2, v3, v4 = table.unpack(list)

			if v4 == nil then
				Themes.modify(object, {
					v,
					v2,
					v3,
					"Selected"
				}, p)
				Themes.modify(object, {
					v,
					v2,
					v3,
					"Viewing"
				}, p)
			end

			local formatStateName = Utility.formatStateName(v4 or "Deselected")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function nowSetIt()
				if formatStateName == object.activeState then
					Themes.apply(object, v, v2, v3)
				end
			end

			local v9 = object:getStateGroup(formatStateName)
			local v10 = list
			local v11 = formatStateName
			local v12 = v
			local v13 = v2
			local v14 = v3

			local function updateRecord()
				for k, v15 in pairs(v9) do
					if Themes.merge(v15, v10, function(list2)
						list2[5] = p
						nowSetIt() -- equivalent call inferred; original call site unknown
					end) then
						return
					end
				end

				table.insert(v9, {
					v12,
					v13,
					v14,
					v11,
					p
				})
				nowSetIt() -- equivalent call inferred; original call site unknown
			end

			updateRecord()
		end
	end)
	return p
end

function Themes.remove(p, p2)
	for _, list in pairs(p.appearance) do
		for i = #list, 1, -1 do
			if list[i][5] == p2 then
				table.remove(list, i)
			end
		end
	end

	Themes.rebuild(p)
end

function Themes.removeWith(p, p2, p3, p4)
	for k, list in pairs(p.appearance) do
		if not (p4 == k or not p4) then
			continue
		end

		for i = #list, 1, -1 do
			local v = list[i]
			local v2 = v[1]
			local v3 = v[2]

			if v2 == p2 and v3 == p3 then
				table.remove(list, i)
			end
		end
	end

	Themes.rebuild(p)
end

function Themes.change(object)
	local stateGroup = object:getStateGroup()

	for _, list in pairs(stateGroup) do
		local v, v2, v3 = unpack(list)
		Themes.apply(object, v, v2, v3)
	end
end

function Themes:set(module)
	local themesJanitor = self.themesJanitor
	themesJanitor:clean()
	themesJanitor:add(self.stateChanged:Connect(function()
		Themes.change(self)
	end))

	if typeof(module) == "Instance" and module:IsA("ModuleScript") then
		module = require(module)
	end

	self.appliedTheme = module
	Themes.rebuild(self)
end

function Themes.statesMatch(value, value2)
	return (value and string.lower(value)) == (value2 and string.lower(value2)) or not (value and value2)
end

function Themes.rebuild(p)
	local appliedTheme = p.appliedTheme
	local v = { "Deselected", "Selected", "Viewing" }

	local function generateTheme()
		for _, v2 in pairs(v) do
			local v3 = {}
			local copyTables = v3

			local function updateDetails(items, p2)
				if not items then
					return
				end

				for k, item in pairs(items) do
					local v4 = item[5]
					local v5 = item[4]

					if not Themes.statesMatch(p2, v5) then
						continue
					end

					local v6 = item[1] .. "-" .. item[2]
					local copyTable = Utility.copyTable(item)
					copyTable[5] = v4
					copyTables[v6] = copyTable
				end
			end

			if v2 == "Selected" then
				updateDetails(Default, "Deselected")
			end

			updateDetails(Default, "Empty")
			updateDetails(Default, v2)

			if appliedTheme ~= Default then
				if v2 == "Selected" then
					updateDetails(appliedTheme, "Deselected")
				end

				updateDetails(Default, "Empty")
				updateDetails(appliedTheme, v2)
			end

			local v4 = {}
			local v5 = p.appearance[v2]

			if v5 then
				for _, v6 in pairs(v5) do
					local v7 = v6[5]

					if v7 ~= nil then
						table.insert(v4, {
							v6[1],
							v6[2],
							v6[3],
							v2,
							v7
						})
					end
				end
			end

			updateDetails(v4, v2)
			local v6 = {}

			for _, v7 in pairs(v3) do
				table.insert(v6, v7)
			end

			p.appearance[v2] = v6
		end

		Themes.change(p)
	end

	generateTheme()
end

return Themes