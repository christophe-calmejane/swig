%module cpp11_unique_ptr_move

%include <std_unique_ptr.i>

%unique_ptr(Bar);

%inline %{

#include <memory>

class Bar
{
public:
	Bar() = default;
};

class Foo
{
public:
  using UniquePtr = std::unique_ptr<Bar>;

  Foo() = default;

  void set_ptr(UniquePtr&& ptr) { _ptr = std::move(ptr); }

private:
  UniquePtr _ptr{ nullptr };
};

%}
