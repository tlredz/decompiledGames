local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
RunService:IsServer()
local isClient = RunService:IsClient()

-- equivalent calls inferred from this helper; original call sites unknown
local function getToolPlayer(instance)
	return instance:FindFirstAncestorOfClass("Player") or Players:GetPlayerFromCharacter(instance.Parent)
end

local function RegisterTool(p: string, callback, _)
	local v = {}

	local function wrapTool(tool)
		assert(tool:IsA("Tool"), (`tried to wrap {tool}`))
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function construct()
			if v2 then
				return
			end

			local v3 = callback(tool)
			assert(v3, (`no cleanup function given for tool {tool}`))
			v2 = v3
			v[tool] = v2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function deconstruct()
			if v2 then
				task.spawn(v2)
				v2 = nil
				v[tool] = nil
			end
		end

		if isClient then
			local function checkConstructClient()
				local v3 = tool

				if not v3:FindFirstAncestorOfClass("Player") then
					Players:GetPlayerFromCharacter(v3.Parent)
				end

				if tool.Parent and (tool.Parent == Players.LocalPlayer:FindFirstChild("Backpack") or tool.Parent == Players.LocalPlayer.Character) then
					construct() -- equivalent call inferred; original call site unknown
				else
					deconstruct() -- equivalent call inferred; original call site unknown
				end
			end

			if not tool:FindFirstAncestorOfClass("Player") then
				Players:GetPlayerFromCharacter(tool.Parent)
			end

			if tool.Parent and (tool.Parent == Players.LocalPlayer:FindFirstChild("Backpack") or tool.Parent == Players.LocalPlayer.Character) then
				construct() -- equivalent call inferred; original call site unknown
			else
				deconstruct() -- equivalent call inferred; original call site unknown
			end

			tool.AncestryChanged:Connect(checkConstructClient)
		else
			local function checkConstructServer()
				local toolPlayer = getToolPlayer(tool) -- equivalent call inferred; original call site unknown

				if toolPlayer and (tool.Parent == toolPlayer.Character or tool.Parent == toolPlayer:FindFirstChild("Backpack")) then
					construct() -- equivalent call inferred; original call site unknown
				else
					deconstruct() -- equivalent call inferred; original call site unknown
				end
			end

			local toolPlayer = getToolPlayer(tool) -- equivalent call inferred; original call site unknown

			if toolPlayer and (tool.Parent == toolPlayer.Character or tool.Parent == toolPlayer:FindFirstChild("Backpack")) then
				construct() -- equivalent call inferred; original call site unknown
			else
				deconstruct() -- equivalent call inferred; original call site unknown
			end

			tool.AncestryChanged:Connect(checkConstructServer)
		end
	end

	local formatted = `Tool_{p}`

	for _, v2 in CollectionService:GetTagged(formatted) do
		task.spawn(wrapTool, v2)
	end

	CollectionService:GetInstanceAddedSignal(formatted):Connect(wrapTool)
	CollectionService:GetInstanceRemovedSignal(formatted):Connect(function(p2)
		if v[p2] then
			v[p2]()
			v[p2] = nil
		end
	end)
end

return RegisterTool