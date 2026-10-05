local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local RevealRegistry = require(ReplicatedStorage._FRAMEWORK.Libraries.RevealRegistry)
local sources = {}
local v = {}
local flag = false

local function whenChild(remotes, childName: string, fn)
	local child = remotes:FindFirstChild(childName)

	if child then
		fn(child)
		return
	end

	local childAddedConnection = nil
	childAddedConnection = remotes.ChildAdded:Connect(function(child2)
		if child2.Name == childName then
			if childAddedConnection then
				childAddedConnection:Disconnect()
			end

			fn(child2)
		end
	end)
end

local function readRevealed(p: string)
	return RevealRegistry.isAllRevealed() or v[p] == true
end

local function sourceFor(p: string)
	local v2 = sources[p]

	if v2 then
		return v2
	end

	local source = Vide.source(RevealRegistry.isAllRevealed() or v[p] == true)
	sources[p] = source
	return source
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setRevealed(value: string, flag2: boolean)
	if v[value] == true == flag2 then
		return
	end

	v[value] = flag2
	local v2 = sources[value]

	if v2 then
		v2(RevealRegistry.isAllRevealed() or v[value] == true)
	end
end

local function applyInit(items)
	v = {}

	for k, item in pairs(items) do
		if item == true then
			v[k] = true
		end
	end

	for k, v2 in pairs(sources) do
		v2(RevealRegistry.isAllRevealed() or v[k] == true)
	end
end

local function start()
	if flag then
		return
	end

	flag = true
	local v2 = ReplicatedStorage

	local function fn(child)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn2(child2)
			child2.OnClientEvent:Connect(function(p, value)
				if p == "init" and type(value) == "table" then
					applyInit(value)
				elseif p == "reveal" and type(value) == "string" then
					setRevealed(value, true) -- equivalent call inferred; original call site unknown
				elseif p == "unreveal" and type(value) == "string" then
					setRevealed(value, false) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local revealUI = child:FindFirstChild("RevealUI")

		if revealUI then
			fn2(revealUI) -- equivalent call inferred; original call site unknown
			return
		end

		local childAddedConnection = nil
		local v3 = "RevealUI"
		childAddedConnection = child.ChildAdded:Connect(function(child2)
			if child2.Name == v3 then
				if childAddedConnection then
					childAddedConnection:Disconnect()
				end

				fn2(child2)
			end
		end)
	end

	local remotes = v2:FindFirstChild("Remotes")

	if remotes then
		whenChild(remotes, "RevealUI", function(p)
			p.OnClientEvent:Connect(function(p2, value)
				if p2 == "init" and type(value) == "table" then
					applyInit(value)
				elseif p2 == "reveal" and type(value) == "string" then
					setRevealed(value, true) -- equivalent call inferred; original call site unknown
				elseif p2 == "unreveal" and type(value) == "string" then
					setRevealed(value, false) -- equivalent call inferred; original call site unknown
				end
			end)
		end)
		return
	end

	local childAddedConnection = nil
	local v3 = "Remotes"
	childAddedConnection = v2.ChildAdded:Connect(function(child)
		if child.Name == v3 then
			if childAddedConnection then
				childAddedConnection:Disconnect()
			end

			fn(child)
		end
	end)
end

local RevealState = {}

function RevealState.observe(p: string)
	assert(RunService:IsClient(), "revealState.observe is client-only")

	if not flag then
		flag = true
		local v2 = ReplicatedStorage

		local function fn(child)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function fn2(child2)
				child2.OnClientEvent:Connect(function(p2, value)
					if p2 == "init" and type(value) == "table" then
						applyInit(value)
					elseif p2 == "reveal" and type(value) == "string" then
						setRevealed(value, true) -- equivalent call inferred; original call site unknown
					elseif p2 == "unreveal" and type(value) == "string" then
						setRevealed(value, false) -- equivalent call inferred; original call site unknown
					end
				end)
			end

			local revealUI = child:FindFirstChild("RevealUI")

			if revealUI then
				fn2(revealUI) -- equivalent call inferred; original call site unknown
				return
			end

			local childAddedConnection = nil
			local v3 = "RevealUI"
			childAddedConnection = child.ChildAdded:Connect(function(child2)
				if child2.Name == v3 then
					if childAddedConnection then
						childAddedConnection:Disconnect()
					end

					fn2(child2)
				end
			end)
		end

		local remotes = v2:FindFirstChild("Remotes")

		if remotes then
			whenChild(remotes, "RevealUI", function(p2)
				p2.OnClientEvent:Connect(function(p3, value)
					if p3 == "init" and type(value) == "table" then
						applyInit(value)
					elseif p3 == "reveal" and type(value) == "string" then
						setRevealed(value, true) -- equivalent call inferred; original call site unknown
					elseif p3 == "unreveal" and type(value) == "string" then
						setRevealed(value, false) -- equivalent call inferred; original call site unknown
					end
				end)
			end)
		else
			local childAddedConnection = nil
			local v3 = "Remotes"
			childAddedConnection = v2.ChildAdded:Connect(function(child)
				if child.Name == v3 then
					if childAddedConnection then
						childAddedConnection:Disconnect()
					end

					fn(child)
				end
			end)
		end
	end

	local v2 = sources[p]

	if v2 then
		return v2
	end

	local source = Vide.source(RevealRegistry.isAllRevealed() or v[p] == true)
	sources[p] = source
	return source
end

function RevealState.isRevealed(p: string)
	assert(RunService:IsClient(), "revealState.isRevealed is client-only")

	if flag then
		return RevealRegistry.isAllRevealed() or v[p] == true
	end

	flag = true
	local v2 = ReplicatedStorage

	local function fn(child)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn2(child2)
			child2.OnClientEvent:Connect(function(p2, value)
				if p2 == "init" and type(value) == "table" then
					applyInit(value)
				elseif p2 == "reveal" and type(value) == "string" then
					setRevealed(value, true) -- equivalent call inferred; original call site unknown
				elseif p2 == "unreveal" and type(value) == "string" then
					setRevealed(value, false) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local revealUI = child:FindFirstChild("RevealUI")

		if revealUI then
			fn2(revealUI) -- equivalent call inferred; original call site unknown
			return
		end

		local childAddedConnection = nil
		local v3 = "RevealUI"
		childAddedConnection = child.ChildAdded:Connect(function(child2)
			if child2.Name == v3 then
				if childAddedConnection then
					childAddedConnection:Disconnect()
				end

				fn2(child2)
			end
		end)
	end

	local remotes = v2:FindFirstChild("Remotes")

	if remotes then
		whenChild(remotes, "RevealUI", function(p2)
			p2.OnClientEvent:Connect(function(p3, value)
				if p3 == "init" and type(value) == "table" then
					applyInit(value)
				elseif p3 == "reveal" and type(value) == "string" then
					setRevealed(value, true) -- equivalent call inferred; original call site unknown
				elseif p3 == "unreveal" and type(value) == "string" then
					setRevealed(value, false) -- equivalent call inferred; original call site unknown
				end
			end)
		end)
	else
		local childAddedConnection = nil
		local v3 = "Remotes"
		childAddedConnection = v2.ChildAdded:Connect(function(child)
			if child.Name == v3 then
				if childAddedConnection then
					childAddedConnection:Disconnect()
				end

				fn(child)
			end
		end)
	end

	return RevealRegistry.isAllRevealed() or v[p] == true
end

return RevealState