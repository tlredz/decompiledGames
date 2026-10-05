return function()
	local Streamable = require(script.Parent.Streamable)
	local StreamableUtil = require(script.Parent.StreamableUtil)
	local folder = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CreateInstance(name)
		local folder2 = Instance.new("Folder")
		folder2.Name = name
		folder2.Archivable = false
		folder2.Parent = folder
		return folder2
	end

	beforeAll(function()
		folder = Instance.new("Folder")
		folder.Name = "KnitTest"
		folder.Archivable = false
		folder.Parent = workspace
	end)
	afterEach(function()
		folder:ClearAllChildren()
	end)
	afterAll(function()
		folder:Destroy()
	end)
	describe("Compound", function()
		it("should capture multiple streams", function()
			local S1 = Streamable.new(folder, "ABC")
			local S2 = Streamable.new(folder, "XYZ")
			local count = 0
			local count2 = 0
			StreamableUtil.Compound({
				S1 = S1,
				S2 = S2
			}, function(_, maid)
				count += 1
				maid:Add(function()
					count2 += 1
				end)
			end)
			local instance = CreateInstance("ABC") -- equivalent call inferred; original call site unknown
			local instance2 = CreateInstance("XYZ") -- equivalent call inferred; original call site unknown
			task.wait()
			instance.Parent = nil
			task.wait()
			instance.Parent = folder
			task.wait()
			instance.Parent = nil
			instance2.Parent = nil
			task.wait()
			instance2.Parent = folder
			task.wait()
			expect(count).to.equal(2)
			expect(count2).to.equal(2)
			S1:Destroy()
			S2:Destroy()
		end)
	end)
end