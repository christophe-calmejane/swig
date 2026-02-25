/* -----------------------------------------------------------------------------
 * std_optional.i
 *
 * SWIG typemaps for std::optional<T>
 * Lua implementation
 *
 * This file provides support for wrapping std::optional<T> types in Lua.
 * An optional value is represented as either the value itself or nil in Lua.
 *
 * ============================================================================
 * USAGE
 * ============================================================================
 *
 * 1. %optional(TYPE):
 *    This macro is used to wrap std::optional<TYPE> for class/struct types.
 *    The value is represented as either the object or nil in Lua.
 *    Example:
 *      %optional(MyClass)
 *
 * 2. %optional_primitive(TYPE):
 *    This macro is used for primitive/arithmetic types (int, float, double, etc.).
 *    Example:
 *      %optional_primitive(double)
 *    This will generate code to handle std::optional<double>.
 *
 * 3. %optional_enum_xxx(TYPE):
 *    These macros are used for C++ enum types. In Lua, enums are treated as numbers,
 *    so these are aliases for %optional_primitive. Use the appropriate macro based on
 *    the enum's underlying type for API compatibility with C#:
 *      %optional_enum_int8(TYPE)   - for enums with std::int8_t underlying type
 *      %optional_enum_uint8(TYPE)  - for enums with std::uint8_t underlying type
 *      %optional_enum_int16(TYPE)  - for enums with std::int16_t underlying type
 *      %optional_enum_uint16(TYPE) - for enums with std::uint16_t underlying type
 *      %optional_enum_int32(TYPE)  - for enums with std::int32_t underlying type (default)
 *      %optional_enum_uint32(TYPE) - for enums with std::uint32_t underlying type
 *      %optional_enum_int64(TYPE)  - for enums with std::int64_t underlying type
 *      %optional_enum_uint64(TYPE) - for enums with std::uint64_t underlying type
 *    Example:
 *      %optional_enum_uint8(MyByteEnum)
 *      %optional_enum_int32(MyIntEnum)
 *
 * 4. %optional_string():
 *    This macro is specifically for std::optional<std::string>.
 *    Example:
 *      %optional_string()
 *    This will generate code to handle std::optional<std::string>.
 *
 * ============================================================================
 * CONFIGURATION MACROS
 * ============================================================================
 *
 * SWIG_STD_OPTIONAL_DEFAULT_TYPES:
 *    When defined, automatically sets up typemaps for common types:
 *    - bool, int8_t, int16_t, int32_t, int64_t and unsigned variants
 *    - float, double
 *    - Native C/C++ types (int, short, long, etc.)
 *    - std::string
 *
 * Director support:
 * Director typemaps (directorin, directorout) are provided for all optional
 * types, allowing C++ virtual methods with std::optional parameters to be
 * overridden in Lua.
 *
 * ----------------------------------------------------------------------------- */

%{
#include <optional>
#include <type_traits>
%}

%include <std_common.i>

// ============================================================================
// Helper functions for pushing/getting primitive values to/from Lua
// Uses if constexpr to choose between lua_pushinteger and lua_pushnumber
// ============================================================================
%fragment("SWIG_Lua_OptionalPrimitiveHelpers", "header") %{
namespace swig {
namespace lua {

// Push a primitive value to Lua stack
// Uses lua_pushinteger for integral types, lua_pushnumber for floating point
template<typename T>
inline void pushOptionalValue(lua_State* L, const T& value) {
    if constexpr (std::is_same_v<T, bool>) {
        lua_pushboolean(L, value ? 1 : 0);
    } else if constexpr (std::is_integral_v<T>) {
        lua_pushinteger(L, static_cast<lua_Integer>(value));
    } else {
        lua_pushnumber(L, static_cast<lua_Number>(value));
    }
}

// Get a primitive value from Lua stack
// Uses lua_tointeger for integral types, lua_tonumber for floating point
template<typename T>
inline T getOptionalValue(lua_State* L, int idx) {
    if constexpr (std::is_same_v<T, bool>) {
        return lua_toboolean(L, idx) != 0;
    } else if constexpr (std::is_integral_v<T>) {
        return static_cast<T>(lua_tointeger(L, idx));
    } else {
        return static_cast<T>(lua_tonumber(L, idx));
    }
}

// Check if a Lua value can be converted to the target type
template<typename T>
inline bool checkOptionalValue(lua_State* L, int idx) {
    if constexpr (std::is_same_v<T, bool>) {
        return lua_isboolean(L, idx) || lua_isnumber(L, idx);
    } else {
        return lua_isnumber(L, idx) || lua_isboolean(L, idx);
    }
}

} // namespace lua
} // namespace swig
%}

// Template declaration for std::optional
namespace std {
  template<typename T> class optional {
    public:
        typedef T value_type;

        optional();
        optional(T value);
        optional(const optional& other);

        bool has_value() const noexcept;
        const T& value() const;
  };
}

// ============================================================================
// %optional(TYPE) - For classes and structs
// ============================================================================
%define %optional(TYPE)

%naturalvar std::optional< TYPE >;

// Input typemap for std::optional<TYPE> by value
%typemap(in, checkfn="SWIG_isptrtype") std::optional< TYPE > (void *argp = 0, int res = 0) {
  if (lua_isnil(L, $input)) {
    $1 = std::nullopt;
  } else {
    res = SWIG_ConvertPtr(L, $input, &argp, $descriptor(TYPE *), 0);
    if (!SWIG_IsOK(res)) {
      SWIG_fail_ptr("$symname", $argnum, $descriptor(TYPE *));
    }
    $1 = *reinterpret_cast<TYPE *>(argp);
  }
}

// Input typemap for std::optional<TYPE> by const reference
%typemap(in, checkfn="SWIG_isptrtype") std::optional< TYPE > const & (std::optional< TYPE > temp, void *argp = 0, int res = 0) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else {
    res = SWIG_ConvertPtr(L, $input, &argp, $descriptor(TYPE *), 0);
    if (!SWIG_IsOK(res)) {
      SWIG_fail_ptr("$symname", $argnum, $descriptor(TYPE *));
    }
    temp = *reinterpret_cast<TYPE *>(argp);
  }
  $1 = &temp;
}

// Output typemap for std::optional<TYPE> by value
%typemap(out) std::optional< TYPE > {
  if ($1.has_value()) {
    TYPE * resultptr = new TYPE($1.value());
    SWIG_NewPointerObj(L, resultptr, $descriptor(TYPE *), SWIG_POINTER_OWN);
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Output typemap for std::optional<TYPE> by const reference
%typemap(out) std::optional< TYPE > const & {
  if ($1->has_value()) {
    TYPE * resultptr = new TYPE($1->value());
    SWIG_NewPointerObj(L, resultptr, $descriptor(TYPE *), SWIG_POINTER_OWN);
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Typecheck for overloading
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) std::optional< TYPE >, std::optional< TYPE > const & {
  void *ptr = 0;
  if (lua_isnil(L, $input)) {
    $1 = 1;
  } else {
    $1 = SWIG_IsOK(SWIG_ConvertPtr(L, $input, &ptr, $descriptor(TYPE *), 0));
  }
}

// Director typemaps for std::optional<TYPE>
%typemap(directorin) std::optional< TYPE >
%{
  if ($1.has_value()) {
    TYPE * resultptr = new TYPE($1.value());
    SWIG_NewPointerObj(L, resultptr, $descriptor(TYPE *), SWIG_POINTER_OWN);
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorin) std::optional< TYPE > const &
%{
  if ($1.has_value()) {
    TYPE * resultptr = new TYPE($1.value());
    SWIG_NewPointerObj(L, resultptr, $descriptor(TYPE *), SWIG_POINTER_OWN);
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorout) std::optional< TYPE > (void *argp = 0, int res = 0)
%{
  if (lua_isnil(L, $input)) {
    $result = std::nullopt;
  } else {
    res = SWIG_ConvertPtr(L, $input, &argp, $descriptor(TYPE *), 0);
    if (!SWIG_IsOK(res)) {
      Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to " "$type");
    }
    $result = *reinterpret_cast<TYPE *>(argp);
  }
%}

%typemap(directorout) std::optional< TYPE > const & (std::optional< TYPE > temp, void *argp = 0, int res = 0)
%{
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else {
    res = SWIG_ConvertPtr(L, $input, &argp, $descriptor(TYPE *), 0);
    if (!SWIG_IsOK(res)) {
      Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to " "$type");
    }
    temp = *reinterpret_cast<TYPE *>(argp);
  }
  $result = &temp;
%}

// Pointer typemaps (for struct members)
// Input typemap for members (pointers to optional)
%typemap(memberin) std::optional< TYPE > *, std::optional< TYPE > const * {
  if ($input) {
    $1 = *$input;
  } else {
    $1 = std::nullopt;
  }
}

// Varget typemap for member variables
%typemap(varget) std::optional< TYPE > *, std::optional< TYPE > const * {
  if ($1.has_value()) {
    TYPE * resultptr = new TYPE($1.value());
    SWIG_NewPointerObj(L, resultptr, $descriptor(TYPE *), SWIG_POINTER_OWN);
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Varset typemap for member variables
%typemap(varset) std::optional< TYPE > *, std::optional< TYPE > const * (void *argp = 0, int res = 0) {
  if (lua_isnil(L, -1)) {
    $1 = std::nullopt;
  } else {
    res = SWIG_ConvertPtr(L, -1, &argp, $descriptor(TYPE *), 0);
    if (!SWIG_IsOK(res)) {
      SWIG_fail_ptr("$symname", 1, $descriptor(TYPE *));
    }
    $1 = *reinterpret_cast<TYPE *>(argp);
  }
}

// Input typemap for pointer to optional (used during member access)
%typemap(in) std::optional< TYPE > * (std::optional< TYPE > temp, void *argp = 0, int res = 0) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else {
    res = SWIG_ConvertPtr(L, $input, &argp, $descriptor(TYPE *), 0);
    if (!SWIG_IsOK(res)) {
      SWIG_fail_ptr("$symname", $argnum, $descriptor(TYPE *));
    }
    temp = *reinterpret_cast<TYPE *>(argp);
  }
  $1 = &temp;
}

%typemap(in) std::optional< TYPE > const * (std::optional< TYPE > temp, void *argp = 0, int res = 0) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else {
    res = SWIG_ConvertPtr(L, $input, &argp, $descriptor(TYPE *), 0);
    if (!SWIG_IsOK(res)) {
      SWIG_fail_ptr("$symname", $argnum, $descriptor(TYPE *));
    }
    temp = *reinterpret_cast<TYPE *>(argp);
  }
  $1 = &temp;
}

// Output typemap for pointer to optional
%typemap(out) std::optional< TYPE > * {
  if ($1 && $1->has_value()) {
    TYPE * resultptr = new TYPE($1->value());
    SWIG_NewPointerObj(L, resultptr, $descriptor(TYPE *), SWIG_POINTER_OWN);
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

%typemap(out) std::optional< TYPE > const * {
  if ($1 && $1->has_value()) {
    TYPE * resultptr = new TYPE($1->value());
    SWIG_NewPointerObj(L, resultptr, $descriptor(TYPE *), SWIG_POINTER_OWN);
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Instantiate the template with empty name to prevent SWIGTYPE generation
%template() std::optional< TYPE >;

%enddef


// ============================================================================
// Internal macro for primitive types (int, float, double, etc.)
// Uses helper functions to automatically choose between lua_pushinteger/lua_pushnumber
// ============================================================================
%define %optional_primitive_internal(TYPE)

%naturalvar std::optional< TYPE >;

// Input typemap for std::optional<TYPE> by value
%typemap(in, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > {
  if (lua_isnil(L, $input)) {
    $1 = std::nullopt;
  } else if (swig::lua::checkOptionalValue<TYPE>(L, $input)) {
    $1 = swig::lua::getOptionalValue<TYPE>(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected number, boolean or nil for optional primitive type");
    SWIG_fail;
  }
}

// Input typemap for std::optional<TYPE> by const reference
%typemap(in, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > const & (std::optional< TYPE > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (swig::lua::checkOptionalValue<TYPE>(L, $input)) {
    temp = swig::lua::getOptionalValue<TYPE>(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected number, boolean or nil for optional primitive type");
    SWIG_fail;
  }
  $1 = &temp;
}

// Output typemap for std::optional<TYPE> by value
%typemap(out, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > {
  if ($1.has_value()) {
    swig::lua::pushOptionalValue<TYPE>(L, $1.value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Output typemap for std::optional<TYPE> by const reference
%typemap(out, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > const & {
  if ($1->has_value()) {
    swig::lua::pushOptionalValue<TYPE>(L, $1->value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Typecheck for overloading
%typemap(typecheck, precedence=SWIG_TYPECHECK_DOUBLE) std::optional< TYPE >, std::optional< TYPE > const & {
  $1 = lua_isnil(L, $input) || lua_isnumber(L, $input) || lua_isboolean(L, $input);
}

// Director typemaps for primitive std::optional<TYPE>
%typemap(directorin, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE >
%{
  if ($1.has_value()) {
    swig::lua::pushOptionalValue<TYPE>(L, $1.value());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorin, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > const &
%{
  if ($1.has_value()) {
    swig::lua::pushOptionalValue<TYPE>(L, $1.value());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorout, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE >
%{
  if (lua_isnil(L, $input)) {
    $result = std::nullopt;
  } else if (swig::lua::checkOptionalValue<TYPE>(L, $input)) {
    $result = swig::lua::getOptionalValue<TYPE>(L, $input);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional primitive type");
  }
%}

%typemap(directorout, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > const & (std::optional< TYPE > temp)
%{
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (swig::lua::checkOptionalValue<TYPE>(L, $input)) {
    temp = swig::lua::getOptionalValue<TYPE>(L, $input);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional primitive type");
  }
  $result = &temp;
%}

// Pointer typemaps (for struct members) - primitives
// Memberin typemap for pointer to optional primitive
%typemap(memberin) std::optional< TYPE > *, std::optional< TYPE > const * {
  if ($input) {
    $1 = *$input;
  } else {
    $1 = std::nullopt;
  }
}

// Varget typemap for member variables (primitives)
%typemap(varget, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > *, std::optional< TYPE > const * {
  if ($1.has_value()) {
    swig::lua::pushOptionalValue<TYPE>(L, $1.value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Varset typemap for member variables (primitives)
%typemap(varset, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > *, std::optional< TYPE > const * {
  if (lua_isnil(L, -1)) {
    $1 = std::nullopt;
  } else if (swig::lua::checkOptionalValue<TYPE>(L, -1)) {
    $1 = swig::lua::getOptionalValue<TYPE>(L, -1);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected number, boolean or nil for optional primitive type");
    SWIG_fail;
  }
}

// Input typemap for pointer to optional primitive
%typemap(in, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > * (std::optional< TYPE > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (swig::lua::checkOptionalValue<TYPE>(L, $input)) {
    temp = swig::lua::getOptionalValue<TYPE>(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected number, boolean or nil for optional primitive type");
    SWIG_fail;
  }
  $1 = &temp;
}

%typemap(in, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > const * (std::optional< TYPE > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (swig::lua::checkOptionalValue<TYPE>(L, $input)) {
    temp = swig::lua::getOptionalValue<TYPE>(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected number, boolean or nil for optional primitive type");
    SWIG_fail;
  }
  $1 = &temp;
}

// Output typemap for pointer to optional primitive
%typemap(out, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > * {
  if ($1 && $1->has_value()) {
    swig::lua::pushOptionalValue<TYPE>(L, $1->value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

%typemap(out, fragment="SWIG_Lua_OptionalPrimitiveHelpers") std::optional< TYPE > const * {
  if ($1 && $1->has_value()) {
    swig::lua::pushOptionalValue<TYPE>(L, $1->value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Instantiate the template with empty name to prevent SWIGTYPE generation
%template() std::optional< TYPE >;

%enddef


// ============================================================================
// %optional_primitive(TYPE) - For primitive types (public API)
// ============================================================================
%define %optional_primitive(TYPE)
%optional_primitive_internal(TYPE)
%enddef


// ============================================================================
// %optional_enum_xxx(TYPE) - For enum types
// In Lua, enums are treated as numbers, so these are aliases for the primitive macro.
// These macros exist for API compatibility with C#.
// ============================================================================
%define %optional_enum_int8(TYPE)
%optional_primitive_internal(TYPE)
%enddef

%define %optional_enum_uint8(TYPE)
%optional_primitive_internal(TYPE)
%enddef

%define %optional_enum_int16(TYPE)
%optional_primitive_internal(TYPE)
%enddef

%define %optional_enum_uint16(TYPE)
%optional_primitive_internal(TYPE)
%enddef

%define %optional_enum_int32(TYPE)
%optional_primitive_internal(TYPE)
%enddef

%define %optional_enum_uint32(TYPE)
%optional_primitive_internal(TYPE)
%enddef

%define %optional_enum_int64(TYPE)
%optional_primitive_internal(TYPE)
%enddef

%define %optional_enum_uint64(TYPE)
%optional_primitive_internal(TYPE)
%enddef


// ============================================================================
// Special macro for bool (uses lua_pushboolean for output)
// ============================================================================
%define %optional_bool_internal()

%naturalvar std::optional< bool >;

// Input typemap for std::optional<bool> by value
%typemap(in) std::optional< bool > {
  if (lua_isnil(L, $input)) {
    $1 = std::nullopt;
  } else if (lua_isboolean(L, $input)) {
    $1 = (bool)lua_toboolean(L, $input);
  } else if (lua_isnumber(L, $input)) {
    $1 = (bool)lua_tonumber(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected boolean, number or nil for optional bool type");
    SWIG_fail;
  }
}

// Input typemap for std::optional<bool> by const reference
%typemap(in) std::optional< bool > const & (std::optional< bool > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isboolean(L, $input)) {
    temp = (bool)lua_toboolean(L, $input);
  } else if (lua_isnumber(L, $input)) {
    temp = (bool)lua_tonumber(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected boolean, number or nil for optional bool type");
    SWIG_fail;
  }
  $1 = &temp;
}

// Output typemap for std::optional<bool> by value
%typemap(out) std::optional< bool > {
  if ($1.has_value()) {
    lua_pushboolean(L, (int)$1.value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Output typemap for std::optional<bool> by const reference
%typemap(out) std::optional< bool > const & {
  if ($1->has_value()) {
    lua_pushboolean(L, (int)$1->value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Typecheck for overloading
%typemap(typecheck, precedence=SWIG_TYPECHECK_BOOL) std::optional< bool >, std::optional< bool > const & {
  $1 = lua_isnil(L, $input) || lua_isboolean(L, $input) || lua_isnumber(L, $input);
}

// Director typemaps for std::optional<bool>
%typemap(directorin) std::optional< bool >
%{
  if ($1.has_value()) {
    lua_pushboolean(L, (int)$1.value());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorin) std::optional< bool > const &
%{
  if ($1.has_value()) {
    lua_pushboolean(L, (int)$1.value());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorout) std::optional< bool >
%{
  if (lua_isnil(L, $input)) {
    $result = std::nullopt;
  } else if (lua_isboolean(L, $input)) {
    $result = (bool)lua_toboolean(L, $input);
  } else if (lua_isnumber(L, $input)) {
    $result = (bool)lua_tonumber(L, $input);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional bool");
  }
%}

%typemap(directorout) std::optional< bool > const & (std::optional< bool > temp)
%{
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isboolean(L, $input)) {
    temp = (bool)lua_toboolean(L, $input);
  } else if (lua_isnumber(L, $input)) {
    temp = (bool)lua_tonumber(L, $input);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional bool");
  }
  $result = &temp;
%}

%enddef


// ============================================================================
// %optional_string() - For std::optional<std::string>
// ============================================================================
%define %optional_string()

%naturalvar std::optional< std::string >;

// Input typemap for std::optional<std::string> by value
%typemap(in) std::optional< std::string > {
  if (lua_isnil(L, $input)) {
    $1 = std::nullopt;
  } else if (lua_isstring(L, $input)) {
    size_t len;
    const char *ptr = lua_tolstring(L, $input, &len);
    $1 = std::string(ptr, len);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected string or nil for optional string type");
    SWIG_fail;
  }
}

// Input typemap for std::optional<std::string> by const reference
%typemap(in) std::optional< std::string > const & (std::optional< std::string > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isstring(L, $input)) {
    size_t len;
    const char *ptr = lua_tolstring(L, $input, &len);
    temp = std::string(ptr, len);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected string or nil for optional string type");
    SWIG_fail;
  }
  $1 = &temp;
}

// Output typemap for std::optional<std::string> by value
%typemap(out) std::optional< std::string > {
  if ($1.has_value()) {
    lua_pushlstring(L, $1.value().data(), $1.value().size());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Output typemap for std::optional<std::string> by const reference
%typemap(out) std::optional< std::string > const & {
  if ($1->has_value()) {
    lua_pushlstring(L, $1->value().data(), $1->value().size());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Typecheck for overloading
%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) std::optional< std::string >, std::optional< std::string > const & {
  $1 = lua_isnil(L, $input) || lua_isstring(L, $input);
}

// Director typemaps for std::optional<std::string>
%typemap(directorin) std::optional< std::string >
%{
  if ($1.has_value()) {
    lua_pushlstring(L, $1.value().data(), $1.value().size());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorin) std::optional< std::string > const &
%{
  if ($1.has_value()) {
    lua_pushlstring(L, $1.value().data(), $1.value().size());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorout) std::optional< std::string >
%{
  if (lua_isnil(L, $input)) {
    $result = std::nullopt;
  } else if (lua_isstring(L, $input)) {
    size_t len;
    const char *ptr = lua_tolstring(L, $input, &len);
    $result = std::string(ptr, len);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional std::string");
  }
%}

%typemap(directorout) std::optional< std::string > const & (std::optional< std::string > temp)
%{
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isstring(L, $input)) {
    size_t len;
    const char *ptr = lua_tolstring(L, $input, &len);
    temp = std::string(ptr, len);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional std::string");
  }
  $result = &temp;
%}

// Pointer typemaps (for struct members) - std::string
// Memberin typemap for pointer to optional string
%typemap(memberin) std::optional< std::string > *, std::optional< std::string > const * {
  if ($input) {
    $1 = *$input;
  } else {
    $1 = std::nullopt;
  }
}

// Varget typemap for member variables (string)
%typemap(varget) std::optional< std::string > *, std::optional< std::string > const * {
  if ($1.has_value()) {
    lua_pushlstring(L, $1.value().data(), $1.value().size());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Varset typemap for member variables (string)
%typemap(varset) std::optional< std::string > *, std::optional< std::string > const * {
  if (lua_isnil(L, -1)) {
    $1 = std::nullopt;
  } else if (lua_isstring(L, -1)) {
    size_t len;
    const char *ptr = lua_tolstring(L, -1, &len);
    $1 = std::string(ptr, len);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected string or nil for optional string type");
    SWIG_fail;
  }
}

// Input typemap for pointer to optional string
%typemap(in) std::optional< std::string > * (std::optional< std::string > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isstring(L, $input)) {
    size_t len;
    const char *ptr = lua_tolstring(L, $input, &len);
    temp = std::string(ptr, len);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected string or nil for optional string type");
    SWIG_fail;
  }
  $1 = &temp;
}

%typemap(in) std::optional< std::string > const * (std::optional< std::string > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isstring(L, $input)) {
    size_t len;
    const char *ptr = lua_tolstring(L, $input, &len);
    temp = std::string(ptr, len);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected string or nil for optional string type");
    SWIG_fail;
  }
  $1 = &temp;
}

// Output typemap for pointer to optional string
%typemap(out) std::optional< std::string > * {
  if ($1 && $1->has_value()) {
    lua_pushlstring(L, $1->value().data(), $1->value().size());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

%typemap(out) std::optional< std::string > const * {
  if ($1 && $1->has_value()) {
    lua_pushlstring(L, $1->value().data(), $1->value().size());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Instantiate the template with empty name to prevent SWIGTYPE generation
%template() std::optional< std::string >;

%enddef


// ============================================================================
// Default types (when SWIG_STD_OPTIONAL_DEFAULT_TYPES is defined)
// ============================================================================
#if defined(SWIG_STD_OPTIONAL_DEFAULT_TYPES)

  // Use %optional_primitive for all primitive types
  %optional_bool_internal()
  %optional_primitive_internal(std::int8_t)
  %optional_primitive_internal(std::int16_t)
  %optional_primitive_internal(std::int32_t)
  %optional_primitive_internal(std::uint8_t)
  %optional_primitive_internal(std::uint16_t)
  %optional_primitive_internal(std::uint32_t)
  %optional_primitive_internal(std::int64_t)
  %optional_primitive_internal(std::uint64_t)
  %optional_primitive_internal(float)
  %optional_primitive_internal(double)

  // Also add native C/C++ types (int, short, long, etc.) that may differ from stdint types
  %optional_primitive_internal(signed char)
  %optional_primitive_internal(unsigned char)
  %optional_primitive_internal(short)
  %optional_primitive_internal(unsigned short)
  %optional_primitive_internal(int)
  %optional_primitive_internal(unsigned int)
  %optional_primitive_internal(long)
  %optional_primitive_internal(unsigned long)
  %optional_primitive_internal(long long)
  %optional_primitive_internal(unsigned long long)

  %optional_string()

#endif // SWIG_STD_OPTIONAL_DEFAULT_TYPES
