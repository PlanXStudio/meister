## Basic
- python
```python
def outer():
  def inner():
    print("call inner")
  
  print("call outer") 
  return inner

def main():
  f = outer()
  f()

if __name__ == "__main__":
    main()
```
- GNU c
```c
typedef void (*FUNC_P)();

FUNC_P outer()
{
  void inner()
  {
    printf("call inner\n");
  }
  
  printf("call outer\n"); 
  return inner;
}

int main() {
  FUNC_P f = outer();
  f();
  return 0;
}
```

## Parameter
- python
```python
def outer(m):
  def inner(n):
    return m + n
  
  return inner

def main():
  f = outer(10)
  ret = f(20)
  
  print(ret)

if __name__ == "__main__":
    main()
```
- c (Test gcc-arm-none-eabi)
```c
typedef int (*FUNC_P)(int);

FUNC_P outer(int m)
{
  int inner(int n)
  {
    return m + n;
  }
  
  return inner;
}

int main() {
  FUNC_P f;
  int ret;
  
  f = outer(10);
  ret = f(20);
  
  printf("%d\n", ret);
  
  return 0;
}
```

## Closure
- python
//--------------------------------
def outer(m):
  def inner(n):
    return m + n
  
  return inner

def main():
  f1 = outer(10)
  f2 = outer(100)  
  
  ret1 = f1(20)
  ret2 = f2(200)
  
  print(ret1, ret2)

if __name__ == "__main__":
    main()

-c (Version 1)
```c
#include <stdlib.h>

typedef struct nested_t nested_t;
struct nested_t
{
  int (*f)(nested_t*, int);
  int m
};

nested_t* outer(int m)
{
  nested_t *o = (nested_t *)malloc(sizeof(nested_t));
  
  int inner(nested_t* o, int n)
  {
    return o->m + n;
  }
  
  o->f = inner;
  o->m = m;
  
  return o;
}

int main() {
  int ret;
  nested_t* o;
  
  o = outer(10);
  ret = o->f(o, 20);
  
  printf("%d\n", ret);
  
  return 0;
}
```
-c (Version 2)
```
#include <stdlib.h>

typedef struct nested_t nested_t;
struct nested_t
{
  int (*f)(nested_t*, int);
  int m
};

nested_t* outer(int m)
{
  nested_t *o = (nested_t *)malloc(sizeof(nested_t));
  
  int inner(nested_t* o, int n)
  {
    return o->m + n;
  }
  
  o->f = inner;
  o->m = m;
  
  return o;
}

#define INNER(o, m) (o->f(o, m))
#define DESTROY(o) free(o)

int main() {
  int ret1, ret2;
  nested_t *o1, *o2;
  
  o1 = outer(10);
  o2 = outer(100);
  
  ret1 = INNER(o1, 20);
  ret2 = INNER(o2, 200);  
  
  printf("%d, %d\n", ret1, ret2);
  
  DESTROY(o1);
  DESTROY(o2);  
  
  return 0;
}
```
