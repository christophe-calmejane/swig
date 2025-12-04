-- Test for std::optional wrapper in Lua
require("import")        -- the import fn
import("cpp17_optional") -- import code

-- In Lua, classes are directly in the module (no 'test' namespace)
local mod = cpp17_optional

-- Test TestOptionals class
local testOptionals = mod.TestOptionals()

-- Checking SimpleOptional (uint32_t)
do
	local optU32 = testOptionals:getSimpleOptional()
	assert(optU32 == nil, "TestOptionals.getSimpleOptional() should return nil initially")

	testOptionals:setSimpleOptional(42)
	optU32 = testOptionals:getSimpleOptional()
	assert(optU32 == 42, "TestOptionals.getSimpleOptional() should return 42")

	testOptionals:setSimpleOptional(nil)
	optU32 = testOptionals:getSimpleOptional()
	assert(optU32 == nil, "TestOptionals.getSimpleOptional() should return nil after setting nil")
end

-- Checking StringOptional
do
	local optStr = testOptionals:getStringOptional()
	assert(optStr == nil, "TestOptionals.getStringOptional() should return nil initially")

	testOptionals:setStringOptional("Hello, World!")
	optStr = testOptionals:getStringOptional()
	assert(optStr == "Hello, World!", "TestOptionals.getStringOptional() should return 'Hello, World!'")

	testOptionals:setStringOptional(nil)
	optStr = testOptionals:getStringOptional()
	assert(optStr == nil, "TestOptionals.getStringOptional() should return nil after setting nil")
end

-- Test TestObjectString class
do
	-- getName()
	local obj = mod.TestObjectString("InitialName")
	assert(obj:getName() == "InitialName", "TestObjectString.getName() failed")

	-- setName()
	obj:setName("NewName")
	assert(obj:getName() == "NewName", "TestObjectString.setName() failed")

	-- getNameOpt()/setNameOpt()
	obj:setNameOpt("OptionalName")
	assert(obj:getNameOpt() == "OptionalName", "TestObjectString.getNameOpt() failed")

	-- Clear the optional string
	obj:setNameOpt(nil)
	assert(obj:getNameOpt() == nil, "TestObjectString.getNameOpt() should return nil after clearing")

	-- Test with empty string
	obj:setNameOpt("")
	assert(obj:getNameOpt() == "", "TestObjectString.getNameOpt() should handle empty string")

	obj:setNameOpt(nil)
	assert(obj:getNameOpt() == nil, "TestObjectString.getNameOpt() should return nil")
end

-- Test TestObjectPrimitives class
do
	local obj = mod.TestObjectPrimitives(true, 100, 5.55, 9.999)

	-- Test get methods
	assert(obj:getBool() == true, "TestObjectPrimitives.getBool() failed")
	assert(obj:getInt() == 100, "TestObjectPrimitives.getInt() failed")
	assert(math.abs(obj:getFloat() - 5.55) < 0.01, "TestObjectPrimitives.getFloat() failed")
	assert(math.abs(obj:getDouble() - 9.999) < 0.001, "TestObjectPrimitives.getDouble() failed")

	-- Test set methods
	obj:setBool(false)
	assert(obj:getBool() == false, "TestObjectPrimitives.setBool() failed")

	obj:setInt(200)
	assert(obj:getInt() == 200, "TestObjectPrimitives.setInt() failed")

	obj:setFloat(6.66)
	assert(math.abs(obj:getFloat() - 6.66) < 0.01, "TestObjectPrimitives.setFloat() failed")

	obj:setDouble(8.888)
	assert(math.abs(obj:getDouble() - 8.888) < 0.001, "TestObjectPrimitives.setDouble() failed")
end

do
	local obj = mod.TestObjectPrimitives(true, 100, 5.55, 9.999)

	-- Test optional bool
	obj:setBoolOpt(false)
	assert(obj:getBoolOpt() == false, "TestObjectPrimitives.getBoolOpt() failed")
	obj:setBoolOpt(nil)
	assert(obj:getBoolOpt() == nil, "TestObjectPrimitives.getBoolOpt() should return nil")

	-- Test optional int
	obj:setIntOpt(200)
	assert(obj:getIntOpt() == 200, "TestObjectPrimitives.getIntOpt() failed")
	obj:setIntOpt(nil)
	assert(obj:getIntOpt() == nil, "TestObjectPrimitives.getIntOpt() should return nil")

	-- Test optional float
	obj:setFloatOpt(6.66)
	assert(math.abs(obj:getFloatOpt() - 6.66) < 0.01, "TestObjectPrimitives.getFloatOpt() failed")
	obj:setFloatOpt(nil)
	assert(obj:getFloatOpt() == nil, "TestObjectPrimitives.getFloatOpt() should return nil")

	-- Test optional double
	obj:setDoubleOpt(8.888)
	assert(math.abs(obj:getDoubleOpt() - 8.888) < 0.001, "TestObjectPrimitives.getDoubleOpt() failed")
	obj:setDoubleOpt(nil)
	assert(obj:getDoubleOpt() == nil, "TestObjectPrimitives.getDoubleOpt() should return nil")

	-- Test getNullopt
	assert(obj:getNullopt() == nil, "TestObjectPrimitives.getNullopt() should return nil")
end

-- Test TestObjectCustom class
do
	local point = mod.Point(10, 20)
	local circle = mod.Circle(point, 5, "TestCircle")
	local obj = mod.TestObjectCustom(point, circle)

	-- Test Point
	local p = obj:getPoint()
	assert(p.x == 10 and p.y == 20, "TestObjectCustom.getPoint() failed")

	-- Test optional Point
	local pOpt = obj:getPointOpt()
	assert(pOpt ~= nil, "TestObjectCustom.getPointOpt() should not return nil")
	assert(pOpt.x == 10 and pOpt.y == 20, "TestObjectCustom.getPointOpt() values failed")

	-- Set new point
	local newPoint = mod.Point(30, 40)
	obj:setPointOpt(newPoint)
	pOpt = obj:getPointOpt()
	assert(pOpt.x == 30 and pOpt.y == 40, "TestObjectCustom.setPointOpt() failed")

	-- Clear optional point
	obj:setPointOpt(nil)
	pOpt = obj:getPointOpt()
	assert(pOpt == nil, "TestObjectCustom.getPointOpt() should return nil after clearing")

	-- Test optional Circle
	local cOpt = obj:getCircleOpt()
	assert(cOpt ~= nil, "TestObjectCustom.getCircleOpt() should not return nil")
end
