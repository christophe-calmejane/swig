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

-- Test enum optionals
do
	print("Testing enum optionals...")

	local testEnums = mod.TestEnums()

	-- Test SmallEnum (uint8_t underlying type)
	local smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == nil, "TestEnums.getSmallEnumOpt() should be nil initially")

	-- Set to Value1 (= 1)
	testEnums:setSmallEnumOpt(mod.SmallEnum_Value1)
	smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == mod.SmallEnum_Value1, "TestEnums.getSmallEnumOpt() should return SmallEnum_Value1")

	-- Set to Value3 (= 255, max uint8_t)
	testEnums:setSmallEnumOpt(mod.SmallEnum_Value3)
	smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == mod.SmallEnum_Value3, "TestEnums.getSmallEnumOpt() should return SmallEnum_Value3")
	assert(smallEnumOpt == 255, "SmallEnum_Value3 should be 255")

	-- Clear the optional
	testEnums:setSmallEnumOpt(nil)
	smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == nil, "TestEnums.getSmallEnumOpt() should be nil after clearing")

	-- Test BigEnum (int64_t underlying type)
	local bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == nil, "TestEnums.getBigEnumOpt() should be nil initially")

	-- Set to Large (= 1000000000000)
	testEnums:setBigEnumOpt(mod.BigEnum_Large)
	bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == mod.BigEnum_Large, "TestEnums.getBigEnumOpt() should return BigEnum_Large")

	-- Set to Small (= -1000000000000)
	testEnums:setBigEnumOpt(mod.BigEnum_Small)
	bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == mod.BigEnum_Small, "TestEnums.getBigEnumOpt() should return BigEnum_Small")

	-- Clear the optional
	testEnums:setBigEnumOpt(nil)
	bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == nil, "TestEnums.getBigEnumOpt() should be nil after clearing")

	print("Enum optional tests passed!")
end

-- Test TestObjectDirected class with director support
do
	print("Testing director support for std::optional...")

	-- Test base class without overrides
	local baseObj = mod.TestObjectDirected()

	-- Test with nil optional (no value)
	local result = baseObj:doUint32OptionalChanged(nil)
	assert(result == nil, "Base doUint32OptionalChanged(nil) should return nil")

	result = baseObj:doIntOptionalChanged(nil)
	assert(result == nil, "Base doIntOptionalChanged(nil) should return nil")

	-- Test with value
	result = baseObj:doUint32OptionalChanged(42)
	assert(result == nil, "Base doUint32OptionalChanged(42) should return nil")

	result = baseObj:doIntOptionalChanged(123)
	assert(result == nil, "Base doIntOptionalChanged(123) should return nil")

	-- Test Rect optional
	result = baseObj:doRectOptionalChanged(nil)
	assert(result == nil, "Base doRectOptionalChanged(nil) should return nil")

	local rect = mod.Rect(3.0, 4.0)
	result = baseObj:doRectOptionalChanged(rect)
	assert(result == nil, "Base doRectOptionalChanged(rect) should return nil")

	-- Test string optional
	result = baseObj:doStringOptionalChanged(nil)
	assert(result == nil, "Base doStringOptionalChanged(nil) should return nil")

	result = baseObj:doStringOptionalChanged("hello")
	assert(result == nil, "Base doStringOptionalChanged('hello') should return nil")

	-- Test enum optionals through directors
	result = baseObj:doSmallEnumOptionalChanged(nil)
	assert(result == nil, "Base doSmallEnumOptionalChanged(nil) should return nil")

	result = baseObj:doSmallEnumOptionalChanged(mod.SmallEnum_Value1)
	assert(result == nil, "Base doSmallEnumOptionalChanged(SmallEnum_Value1) should return nil")

	result = baseObj:doBigEnumOptionalChanged(nil)
	assert(result == nil, "Base doBigEnumOptionalChanged(nil) should return nil")

	result = baseObj:doBigEnumOptionalChanged(mod.BigEnum_Large)
	assert(result == nil, "Base doBigEnumOptionalChanged(BigEnum_Large) should return nil")

	print("Director tests passed!")
end

print("All cpp17_optional tests passed!")
