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

-- Checking CustomOptional/StructOptional
do
	-- Empty StructOptional
	local optStruct = testOptionals:getStructOptional()
	assert(optStruct == nil, "TestOptionals.getStructOptional() should return nil initially")

	-- setStructOptional()
	local subStruct = mod.SubStruct()
	subStruct.z = 99
	local structObj = mod.Struct()
	structObj.a = 56
	structObj.b = 78
	structObj.sub = subStruct
	structObj.bigEnumOpt = mod.BigEnum_Large
	structObj.aliasEnumOpt = 1234567890123456789

	testOptionals:setStructOptional(structObj)
	optStruct = testOptionals:getStructOptional()
	assert(optStruct ~= nil, "TestOptionals.setStructOptional() should not return nil")
	assert(optStruct.a == 56, "optStruct.a should be 56, got " .. tostring(optStruct.a))
	assert(optStruct.b == 78, "optStruct.b should be 78, got " .. tostring(optStruct.b))
	assert(optStruct.sub.z == 99, "optStruct.sub.z should be 99, got " .. tostring(optStruct.sub.z))
	assert(optStruct.bigEnumOpt == mod.BigEnum_Large, "optStruct.bigEnumOpt should be BigEnum_Large")
	assert(optStruct.aliasEnumOpt == 1234567890123456789, "optStruct.aliasEnumOpt should be 1234567890123456789")

	local optStructCopy = testOptionals:getStructOptionalCopy()
	assert(optStructCopy ~= nil, "TestOptionals.getStructOptionalCopy() should not return nil")
	assert(optStructCopy.a == 56, "optStructCopy.a should be 56")
	assert(optStructCopy.b == 78, "optStructCopy.b should be 78")
	assert(optStructCopy.sub.z == 99, "optStructCopy.sub.z should be 99")
	assert(optStructCopy.bigEnumOpt == mod.BigEnum_Large, "optStructCopy.bigEnumOpt should be BigEnum_Large")
	assert(optStructCopy.aliasEnumOpt == 1234567890123456789, "optStructCopy.aliasEnumOpt should be 1234567890123456789")

	-- Test struct modifier
	structObj.a = 4
	structObj.b = 2
	-- In Lua, we need to create a new SubStruct and assign it to sub
	local modifiedSubStruct = mod.SubStruct()
	modifiedSubStruct.z = 1
	structObj.sub = modifiedSubStruct
	structObj.bigEnumOpt = mod.BigEnum_Small
	structObj.aliasEnumOpt = 987654321098765432
	testOptionals:setStructOptional(structObj)
	-- In Lua, we need to re-read the value since it's not a reference like in C#
	optStruct = testOptionals:getStructOptional()
	-- Verify modified values
	assert(optStruct.a == 4, "optStruct.a should be 4 after modification")
	assert(optStruct.b == 2, "optStruct.b should be 2 after modification")
	assert(optStruct.sub.z == 1, "optStruct.sub.z should be 1 after modification")
	assert(optStruct.bigEnumOpt == mod.BigEnum_Small, "optStruct.bigEnumOpt should be BigEnum_Small after modification")
	assert(optStruct.aliasEnumOpt == 987654321098765432,
		"optStruct.aliasEnumOpt should be 987654321098765432 after modification")

	-- Verify the copy wasn't affected
	assert(optStructCopy.a == 56, "optStructCopy.a should still be 56")
	assert(optStructCopy.b == 78, "optStructCopy.b should still be 78")
	assert(optStructCopy.sub.z == 99, "optStructCopy.sub.z should still be 99")
	assert(optStructCopy.bigEnumOpt == mod.BigEnum_Large, "optStructCopy.bigEnumOpt should still be BigEnum_Large")
	assert(optStructCopy.aliasEnumOpt == 1234567890123456789,
		"optStructCopy.aliasEnumOpt should still be 1234567890123456789")

	-- Clear the optional
	testOptionals:setStructOptional(nil)
	optStruct = testOptionals:getStructOptional()
	assert(optStruct == nil, "TestOptionals.getStructOptional() should return nil after clearing")
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

	-- Test optional primitives
	obj:setBoolOpt(false)
	assert(obj:getBoolOpt() == false, "TestObjectPrimitives.getBoolOpt() failed")
	obj:setBoolOpt(nil)
	assert(obj:getBoolOpt() == nil, "TestObjectPrimitives.getBoolOpt() should return nil")

	obj:setIntOpt(200)
	assert(obj:getIntOpt() == 200, "TestObjectPrimitives.getIntOpt() failed")
	obj:setIntOpt(nil)
	assert(obj:getIntOpt() == nil, "TestObjectPrimitives.getIntOpt() should return nil")

	obj:setFloatOpt(6.66)
	assert(math.abs(obj:getFloatOpt() - 6.66) < 0.01, "TestObjectPrimitives.getFloatOpt() failed")
	obj:setFloatOpt(nil)
	assert(obj:getFloatOpt() == nil, "TestObjectPrimitives.getFloatOpt() should return nil")

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

-- Test object instantiation
do
	-- NoNamespaceStruct
	local stru = mod.NoNamespaceStruct()
	stru.a = 42
	assert(stru.a == 42, "NoNamespaceStruct instantiation failed")

	-- Struct
	local stru2 = mod.Struct()
	stru2.a = 42
	stru2.b = 84
	assert(stru2.a == 42, "Struct.a instantiation failed")
	assert(stru2.b == 84, "Struct.b instantiation failed")
end

-- Test enum optionals (TestEnums class)
do
	local testEnums = mod.TestEnums()

	-- Test SmallEnum (uint8_t underlying type)
	local smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == nil, "TestEnums.getSmallEnumOpt() should be nil initially")

	-- Set to Value1
	testEnums:setSmallEnumOpt(mod.SmallEnum_Value1)
	smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == mod.SmallEnum_Value1, "TestEnums.getSmallEnumOpt() should return SmallEnum_Value1")

	-- Set to Value3 (= 255, max uint8_t)
	testEnums:setSmallEnumOpt(mod.SmallEnum_Value3)
	smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == mod.SmallEnum_Value3, "TestEnums.getSmallEnumOpt() should return SmallEnum_Value3")

	-- Set back to nil
	testEnums:setSmallEnumOpt(nil)
	smallEnumOpt = testEnums:getSmallEnumOpt()
	assert(smallEnumOpt == nil, "TestEnums.getSmallEnumOpt() should be nil after clearing")

	-- Test BigEnum (int64_t underlying type)
	local bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == nil, "TestEnums.getBigEnumOpt() should be nil initially")

	-- Set to Small (negative large value)
	testEnums:setBigEnumOpt(mod.BigEnum_Small)
	bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == mod.BigEnum_Small, "TestEnums.getBigEnumOpt() should return BigEnum_Small")

	-- Set to Large (positive large value)
	testEnums:setBigEnumOpt(mod.BigEnum_Large)
	bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == mod.BigEnum_Large, "TestEnums.getBigEnumOpt() should return BigEnum_Large")

	-- Set to Zero
	testEnums:setBigEnumOpt(mod.BigEnum_Zero)
	bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == mod.BigEnum_Zero, "TestEnums.getBigEnumOpt() should return BigEnum_Zero")

	-- Set back to nil
	testEnums:setBigEnumOpt(nil)
	bigEnumOpt = testEnums:getBigEnumOpt()
	assert(bigEnumOpt == nil, "TestEnums.getBigEnumOpt() should be nil after clearing")
end

-- Test DirectedDefault (base class returns nullopt by default)
do
	local testDefaultDirected = mod.TestObjectDirected()

	-- Test with a valid uint32_t
	local result = testDefaultDirected:doUint32OptionalChanged(42)
	assert(result == nil, "TestObjectDirected.doUint32OptionalChanged(42) should return nil")

	-- Test with nil to simulate std::optional being empty
	result = testDefaultDirected:doUint32OptionalChanged(nil)
	assert(result == nil, "TestObjectDirected.doUint32OptionalChanged(nil) should return nil")

	-- Test with int
	result = testDefaultDirected:doIntOptionalChanged(123)
	assert(result == nil, "TestObjectDirected.doIntOptionalChanged(123) should return nil")

	result = testDefaultDirected:doIntOptionalChanged(nil)
	assert(result == nil, "TestObjectDirected.doIntOptionalChanged(nil) should return nil")

	-- Test with Rect
	local rect = mod.Rect(10.0, 20.0)
	result = testDefaultDirected:doRectOptionalChanged(rect)
	assert(result == nil, "TestObjectDirected.doRectOptionalChanged(rect) should return nil")

	result = testDefaultDirected:doRectOptionalChanged(nil)
	assert(result == nil, "TestObjectDirected.doRectOptionalChanged(nil) should return nil")

	-- Test with string
	result = testDefaultDirected:doStringOptionalChanged("test")
	assert(result == nil, "TestObjectDirected.doStringOptionalChanged('test') should return nil")

	result = testDefaultDirected:doStringOptionalChanged(nil)
	assert(result == nil, "TestObjectDirected.doStringOptionalChanged(nil) should return nil")

	-- Test SmallEnum optional
	result = testDefaultDirected:doSmallEnumOptionalChanged(mod.SmallEnum_Value1)
	assert(result == nil, "TestObjectDirected.doSmallEnumOptionalChanged(Value1) should return nil")

	result = testDefaultDirected:doSmallEnumOptionalChanged(nil)
	assert(result == nil, "TestObjectDirected.doSmallEnumOptionalChanged(nil) should return nil")

	-- Test BigEnum optional
	result = testDefaultDirected:doBigEnumOptionalChanged(mod.BigEnum_Large)
	assert(result == nil, "TestObjectDirected.doBigEnumOptionalChanged(Large) should return nil")

	result = testDefaultDirected:doBigEnumOptionalChanged(nil)
	assert(result == nil, "TestObjectDirected.doBigEnumOptionalChanged(nil) should return nil")
end

-- Test Director with derived class (MyDirectedObject equivalent in Lua)
do
	-- Create a derived object with overridden methods
	local myDirected = mod.TestObjectDirected()

	-- Override onUint32OptionalChanged (returns input + 1)
	swig_override(myDirected, "onUint32OptionalChanged", function(self, value)
		if value == nil then
			return nil
		else
			return value + 1
		end
	end)

	-- Test uint32_t optional director
	local result = myDirected:doUint32OptionalChanged(42)
	assert(result == 43, "MyDirectedObject.doUint32OptionalChanged(42) should return 43, got " .. tostring(result))

	result = myDirected:doUint32OptionalChanged(0)
	assert(result == 1, "MyDirectedObject.doUint32OptionalChanged(0) should return 1, got " .. tostring(result))

	result = myDirected:doUint32OptionalChanged(nil)
	assert(result == nil, "MyDirectedObject.doUint32OptionalChanged(nil) should return nil")

	-- Override onIntOptionalChanged (returns input * 2)
	local myDirected2 = mod.TestObjectDirected()
	swig_override(myDirected2, "onIntOptionalChanged", function(self, value)
		if value == nil then
			return nil
		else
			return value * 2
		end
	end)

	-- Test int optional director
	result = myDirected2:doIntOptionalChanged(42)
	assert(result == 84, "MyDirectedObject.doIntOptionalChanged(42) should return 84, got " .. tostring(result))

	result = myDirected2:doIntOptionalChanged(-100)
	assert(result == -200, "MyDirectedObject.doIntOptionalChanged(-100) should return -200, got " .. tostring(result))

	result = myDirected2:doIntOptionalChanged(nil)
	assert(result == nil, "MyDirectedObject.doIntOptionalChanged(nil) should return nil")

	-- Override onRectOptionalChanged (returns a new Rect with doubled dimensions)
	local myDirected3 = mod.TestObjectDirected()
	swig_override(myDirected3, "onRectOptionalChanged", function(self, value)
		if value == nil then
			return nil
		else
			return mod.Rect(value.width * 2, value.height * 2)
		end
	end)

	-- Test Rect optional director
	result = myDirected3:doRectOptionalChanged(mod.Rect(10.0, 20.0))
	assert(result ~= nil, "MyDirectedObject.doRectOptionalChanged(Rect(10,20)) should not return nil")
	assert(math.abs(result.width - 20.0) < 0.01, "MyDirectedObject.doRectOptionalChanged result width should be 20.0")
	assert(math.abs(result.height - 40.0) < 0.01, "MyDirectedObject.doRectOptionalChanged result height should be 40.0")

	result = myDirected3:doRectOptionalChanged(nil)
	assert(result == nil, "MyDirectedObject.doRectOptionalChanged(nil) should return nil")

	-- Override onStringOptionalChanged (returns uppercased string)
	local myDirected4 = mod.TestObjectDirected()
	swig_override(myDirected4, "onStringOptionalChanged", function(self, value)
		if value == nil then
			return nil
		else
			return string.upper(value)
		end
	end)

	-- Test string optional director
	result = myDirected4:doStringOptionalChanged("hello")
	assert(result == "HELLO",
		"MyDirectedObject.doStringOptionalChanged('hello') should return 'HELLO', got " .. tostring(result))

	result = myDirected4:doStringOptionalChanged(nil)
	assert(result == nil, "MyDirectedObject.doStringOptionalChanged(nil) should return nil")

	-- Override onSmallEnumOptionalChanged (returns next enum value)
	local myDirected5 = mod.TestObjectDirected()
	swig_override(myDirected5, "onSmallEnumOptionalChanged", function(self, value)
		if value == nil then
			return nil
		elseif value == mod.SmallEnum_Value1 then
			return mod.SmallEnum_Value2
		elseif value == mod.SmallEnum_Value2 then
			return mod.SmallEnum_Value3
		else
			return mod.SmallEnum_Value1
		end
	end)

	-- Test SmallEnum optional director
	result = myDirected5:doSmallEnumOptionalChanged(mod.SmallEnum_Value1)
	assert(result == mod.SmallEnum_Value2, "MyDirectedObject.doSmallEnumOptionalChanged(Value1) should return Value2")

	result = myDirected5:doSmallEnumOptionalChanged(mod.SmallEnum_Value2)
	assert(result == mod.SmallEnum_Value3, "MyDirectedObject.doSmallEnumOptionalChanged(Value2) should return Value3")

	result = myDirected5:doSmallEnumOptionalChanged(mod.SmallEnum_Value3)
	assert(result == mod.SmallEnum_Value1, "MyDirectedObject.doSmallEnumOptionalChanged(Value3) should return Value1")

	result = myDirected5:doSmallEnumOptionalChanged(nil)
	assert(result == nil, "MyDirectedObject.doSmallEnumOptionalChanged(nil) should return nil")

	-- Override onBigEnumOptionalChanged (echo back)
	local myDirected6 = mod.TestObjectDirected()
	swig_override(myDirected6, "onBigEnumOptionalChanged", function(self, value)
		return value -- Just echo back to test round-trip
	end)

	-- Test BigEnum optional director
	result = myDirected6:doBigEnumOptionalChanged(mod.BigEnum_Large)
	assert(result == mod.BigEnum_Large, "MyDirectedObject.doBigEnumOptionalChanged(Large) should return Large")

	result = myDirected6:doBigEnumOptionalChanged(mod.BigEnum_Small)
	assert(result == mod.BigEnum_Small, "MyDirectedObject.doBigEnumOptionalChanged(Small) should return Small")

	result = myDirected6:doBigEnumOptionalChanged(mod.BigEnum_Zero)
	assert(result == mod.BigEnum_Zero, "MyDirectedObject.doBigEnumOptionalChanged(Zero) should return Zero")

	result = myDirected6:doBigEnumOptionalChanged(nil)
	assert(result == nil, "MyDirectedObject.doBigEnumOptionalChanged(nil) should return nil")
end
