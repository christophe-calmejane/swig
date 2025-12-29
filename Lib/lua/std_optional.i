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
%}

%include <std_common.i>

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

%enddef


// ============================================================================
// Internal macro for primitive types (int, float, double, etc.)
// ============================================================================
%define %optional_primitive_internal(TYPE)

%naturalvar std::optional< TYPE >;

// Input typemap for std::optional<TYPE> by value
%typemap(in) std::optional< TYPE > {
  if (lua_isnil(L, $input)) {
    $1 = std::nullopt;
  } else if (lua_isnumber(L, $input)) {
    $1 = (TYPE)lua_tonumber(L, $input);
  } else if (lua_isboolean(L, $input)) {
    $1 = (TYPE)lua_toboolean(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected number, boolean or nil for optional primitive type");
    SWIG_fail;
  }
}

// Input typemap for std::optional<TYPE> by const reference
%typemap(in) std::optional< TYPE > const & (std::optional< TYPE > temp) {
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isnumber(L, $input)) {
    temp = (TYPE)lua_tonumber(L, $input);
  } else if (lua_isboolean(L, $input)) {
    temp = (TYPE)lua_toboolean(L, $input);
  } else {
    SWIG_Lua_pusherrstring(L, "Expected number, boolean or nil for optional primitive type");
    SWIG_fail;
  }
  $1 = &temp;
}

// Output typemap for std::optional<TYPE> by value
%typemap(out) std::optional< TYPE > {
  if ($1.has_value()) {
    lua_pushnumber(L, (lua_Number)$1.value());
  } else {
    lua_pushnil(L);
  }
  SWIG_arg++;
}

// Output typemap for std::optional<TYPE> by const reference
%typemap(out) std::optional< TYPE > const & {
  if ($1->has_value()) {
    lua_pushnumber(L, (lua_Number)$1->value());
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
%typemap(directorin) std::optional< TYPE >
%{
  if ($1.has_value()) {
    lua_pushnumber(L, (lua_Number)$1.value());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorin) std::optional< TYPE > const &
%{
  if ($1.has_value()) {
    lua_pushnumber(L, (lua_Number)$1.value());
  } else {
    lua_pushnil(L);
  }
%}

%typemap(directorout) std::optional< TYPE >
%{
  if (lua_isnil(L, $input)) {
    $result = std::nullopt;
  } else if (lua_isnumber(L, $input)) {
    $result = (TYPE)lua_tonumber(L, $input);
  } else if (lua_isboolean(L, $input)) {
    $result = (TYPE)lua_toboolean(L, $input);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional primitive type");
  }
%}

%typemap(directorout) std::optional< TYPE > const & (std::optional< TYPE > temp)
%{
  if (lua_isnil(L, $input)) {
    temp = std::nullopt;
  } else if (lua_isnumber(L, $input)) {
    temp = (TYPE)lua_tonumber(L, $input);
  } else if (lua_isboolean(L, $input)) {
    temp = (TYPE)lua_toboolean(L, $input);
  } else {
    Swig::DirectorTypeMismatchException::raise(L, "Failed to convert return value to optional primitive type");
  }
  $result = &temp;
%}

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
