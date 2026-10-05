local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Themes = {}
local v = require3(script.Parent.Parent.Utility)
local v2 = require3(script.Default)

function Themes.getThemeValue(items, p, p2, _)
	if not items then
		return nil
	end

	for _, list in pairs(items) do
		local v3, v4, v5 = unpack(list)

		if p == v3 and p2 == v4 then
			return v5
		end
	end

	return nil
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
		local v3 = Themes.getThemeValue(stateGroup, folder.Name, p) or Themes.getInstanceValue(folder, p)
		Themes.apply(object, folder, p, v3, true)
	else
		local stateGroup = object:getStateGroup()

		if not stateGroup then
			return
		end

		local v3 = {
			[folder.Name] = folder
		}

		for _, descendant in pairs(folder:GetDescendants()) do
			local collective = descendant:GetAttribute("Collective")

			if collective then
				v3[collective] = descendant
			end

			v3[descendant.Name] = descendant
		end

		for _, list in pairs(stateGroup) do
			local v4, v5, v6 = unpack(list)
			local v7 = v3[v4]

			if v7 then
				Themes.apply(object, v7.Name, v5, v6, true)
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

	local v3 = name .. "-" .. p
	local customBehaviour = object.customBehaviours[v3]

	for _, v4 in pairs(clippedClones) do
		local clippedClone = Themes.getClippedClone(v4)

		if clippedClone then
			table.insert(clippedClones, clippedClone)
		end
	end

	for _, v4 in pairs(clippedClones) do
		if not ((p ~= "Position" or not Themes.getClippedClone(v4)) and (p ~= "Size" or not Themes.getRealInstance(v4))) then
			continue
		end

		local instanceValue = Themes.getInstanceValue(v4, p)

		if not (p3 or p2 ~= instanceValue) then
			continue
		end

		if customBehaviour then
			local v5 = customBehaviour(p2, v4, p)

			if v5 ~= nil then
				p2 = v5
			end
		end

		local v5 = v4

		if pcall(function()
			v5[p] = p2
		end) then
			continue
		end

		v4:SetAttribute(p, p2)
	end
end

function Themes.getModifications(list)
	return typeof(list[1]) ~= "table" and { list } or list
end

function Themes:merge(list2, callback)
	local v3, v4, v5, v6 = table.unpack(list2)
	local v7, v8, _, v9 = table.unpack(self)

	if v3 ~= v7 or v4 ~= v8 or not Themes.statesMatch(v6, v9) then
		return false
	end

	self[3] = v5

	if callback then
		callback(self)
	end

	return true
end

function Themes.modify(object, items, p)
	task.spawn(function()
		p = p or v.generateUID()
		items = Themes.getModifications(items)

		for _, list in pairs(items) do
			local v3, v4, v5, v6 = table.unpack(list)

			if v6 == nil then
				Themes.modify(object, {
					v3,
					v4,
					v5,
					"Selected"
				}, p)
				Themes.modify(object, {
					v3,
					v4,
					v5,
					"Viewing"
				}, p)
			end

			local formatStateName = v.formatStateName(v6 or "Deselected")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function nowSetIt()
				if formatStateName == object.activeState then
					Themes.apply(object, v3, v4, v5)
				end
			end

			local v11 = object:getStateGroup(formatStateName)
			local v12 = list
			local v13 = formatStateName
			local v14 = v3
			local v15 = v4
			local v16 = v5

			local function updateRecord()
				for k, v17 in pairs(v11) do
					if Themes.merge(v17, v12, function(list2)
						list2[5] = p
						nowSetIt() -- equivalent call inferred; original call site unknown
					end) then
						return
					end
				end

				table.insert(v11, {
					v14,
					v15,
					v16,
					v13,
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
			local v3 = list[i]
			local v4 = v3[1]
			local v5 = v3[2]

			if v4 == p2 and v5 == p3 then
				table.remove(list, i)
			end
		end
	end

	Themes.rebuild(p)
end

function Themes.change(object)
	local stateGroup = object:getStateGroup()

	for _, list in pairs(stateGroup) do
		local v3, v4, v5 = unpack(list)
		Themes.apply(object, v3, v4, v5)
	end
end

function Themes:set(moduleScript)
	local themesJanitor = self.themesJanitor
	themesJanitor:clean()
	themesJanitor:add(self.stateChanged:Connect(function()
		Themes.change(self)
	end))

	if typeof(moduleScript) == "Instance" and moduleScript:IsA("ModuleScript") then
		moduleScript = require3(moduleScript)
	end

	self.appliedTheme = moduleScript
	Themes.rebuild(self)
end

function Themes.statesMatch(value, value2)
	return (value and string.lower(value)) == (value2 and string.lower(value2)) or not (value and value2)
end

function Themes.rebuild(p)
	local appliedTheme = p.appliedTheme
	local v3 = { "Deselected", "Selected", "Viewing" }

	local function generateTheme()
		for _, v4 in pairs(v3) do
			local v5 = {}
			local copyTables = v5

			local function updateDetails(items, p2)
				if not items then
					return
				end

				for k, item in pairs(items) do
					local v6 = item[5]
					local v7 = item[4]

					if not Themes.statesMatch(p2, v7) then
						continue
					end

					local v8 = item[1] .. "-" .. item[2]
					local copyTable = v.copyTable(item)
					copyTable[5] = v6
					copyTables[v8] = copyTable
				end
			end

			if v4 == "Selected" then
				updateDetails(v2, "Deselected")
			end

			updateDetails(v2, "Empty")
			updateDetails(v2, v4)

			if appliedTheme ~= v2 then
				if v4 == "Selected" then
					updateDetails(appliedTheme, "Deselected")
				end

				updateDetails(v2, "Empty")
				updateDetails(appliedTheme, v4)
			end

			local v6 = {}
			local v7 = p.appearance[v4]

			if v7 then
				for _, v8 in pairs(v7) do
					local v9 = v8[5]

					if v9 ~= nil then
						table.insert(v6, {
							v8[1],
							v8[2],
							v8[3],
							v4,
							v9
						})
					end
				end
			end

			updateDetails(v6, v4)
			local v8 = {}

			for _, v9 in pairs(v5) do
				table.insert(v8, v9)
			end

			p.appearance[v4] = v8
		end

		Themes.change(p)
	end

	generateTheme()
end

return Themes