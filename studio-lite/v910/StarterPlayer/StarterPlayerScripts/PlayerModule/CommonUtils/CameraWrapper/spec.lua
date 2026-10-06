local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals)
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local TestUtils = require(CorePackages.Workspace.Packages.TestUtils)
local waitForEvents = TestUtils.DeferredLuaHelpers.waitForEvents
local CameraWrapper = require(script.Parent.CameraWrapper)
describe("CameraWrapper", function()
	it("should instantiate", function()
		expect((CameraWrapper.new())).never.toBeNil()
	end)
	it("should return updated camera", function()
		local v = CameraWrapper.new()
		v:Enable()
		local camera = Instance.new("Camera")
		camera.Parent = game.Workspace
		expect(v:getCamera()).toBe(game.Workspace.CurrentCamera)
		expect(v:getCamera()).never.toBe(camera)
		game.Workspace.CurrentCamera = camera
		waitForEvents()
		expect(v:getCamera()).toBe(game.Workspace.CurrentCamera)
		expect(v:getCamera()).toBe(camera)
	end)
end)