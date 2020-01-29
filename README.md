# Примерный список вопросов на собеседовании по Ruby

## Syntax and idioms

### == (equality) vs === (triple equals / case comparison) vs eql? vs equals? (identity comparison)
```
== - для Object проверяет указывают ли переменные на один объект
   - для подклассов меняет поведение и как правило проверяет равенство значений.
     Но надо смотреть как это реализовано для каждого конкретного класса
=== - умеет работать с Regexp, хотя это и можно заменить на =~
      /^[A-Z]*$/ === 'HELLO' #=> true
      /^[A-Z]*$/ === 'Hello' #=> false
      /^[A-Z]*$/ =~ 'HELLO'  #=> 0
      /^[A-Z]*$/ =~ 'Hello'  #=> nil

equal? - проверяет указывают ли переменные на один объект
eql?   - для Object работает как equal?
       - для всех остальных проверяет что объекты имеют одинаковое значение и принадлежат одному классу
```

### user_ids = users.map(&:id) – что делает амперсанд перед именем метода?
Это короткая запись, используемая вместо конструкции с блоком. Аналогично работает:
```user_ids = users.map { |u| u.id }```
"Под капотом" мы имеем дело с `Symbol#to_proc`. Например вместо `(1..3).map(&:to_s)` можно написать:
```
proc = :to_s.to_proc
(1..3).map{|i| proc.call i}
```

### user&.id # safe navigation operator
Возвращает nil вместо exception
```
# одно и тоже
account && account.owner && account.owner.address
account.try(:owner).try(:address)
account&.owner&.address
```

### var ||= default_value
Если var не присвоено значение (равна nil или false), то присвоить ей значение default_value

### fruits_array |= %w(apple tomato)
Добавление в массив fruits_array новых значений из массива ["apple", "tomato"]
```
fruits_array = %w(carrot lemon apple) # => ["carrot", "lemon", "apple"]
fruits_array |= %w(apple tomato)      # => ["carrot", "lemon", "apple", "tomato"]
```

### splat & double_splat operator
```
# Записывает в массив все поданные методу переменные
def splat(*arr)
  arr.inspect
end
splat 1, 2, "3", 5
# => "[1, 2, \"3\", 5]"

# принимает на вход хеш
def double_splat(**args)
  args.inspect
end
double_splat a: 1, b: 2
# => "{:a=>1, :b=>2}"
```


### class << self
Открываем на изменения синглтон-класс для объекта (self)
Объекты в Ruby не хранят свои собственные методы. Вместо этого они создают синглтон-класс, чтобы он хранил их методы.

```
class String
  class << self
    def value_of obj
      obj.to_s
    end
  end
end

String.value_of 42   # => "42"
```
или короче
```
class String
  def self.value_of obj
    obj.to_s
  end
end
# or
def String.value_of obj
  obj.to_s
end
```

### ClassName, method_name, CONSTANT
Use CamelCase for classes and modules
Use snake_case for symbols, methods and variables.
Use SCREAMING_SNAKE_CASE for other constants (those that don’t refer to classes and modules).
https://rubystyle.guide/#naming-conventions
https://github.com/rubocop-hq/ruby-style-guide

## Object, Class, Module
### В чем разница между class Dog; end и Dog = Class.new
Оба выражения создают класс Dog. С точки зрения результата разницы нет.  

### “singleton methods”
Это те методы, которые мы добавили только одному инстансу. Этих методов нет у других инстансов того-же класса.
```
class SingletonTest
 def size
   "38 parrots"
 end
end
test1 = SingletonTest.new
test2 = SingletonTest.new

def test1.how_are_u?
  "I'm ok!"
end

# синглтон метод это how_are_u?
test1.how_are_u?
"I'm ok!"

test2.how_are_u?
NoMethodError (undefined method `how_are_u?' for #<SingletonTest:0x00007fa59f833c08>)
```
Применяется: ruby-doc.org уверяет, что то часто применяется для элементов GUI, но я такого не встречал.

### instance_of? vs kind_of? vs is_a?
kind_of? и is_a? - синонимы и проверяют что объект принадлежит указанному классу или суперклассу или модулю
instance_of? - проверяет что объект инстанцирован именно от указанного класса
```
module M1; end
module M2; end
class A
  include M1
end
class B < A
  include M2
end
class C < B; end

b = B.new
b.is_a? B # => true
b.is_a? A # => true
b.is_a? C # => false
b.is_a? M1 # => true
b.is_a? M2 # => true

b.instance_of? B  # => true
b.instance_of? A  # => false
b.instance_of? M1 # => false
b.instance_of? M2 # => false
```


### Чем класс отличается от модуля (instantiation, usage, methods, inheritance, inclusion, extension)
Module - это объединение для констант и методов.
Модуль нельзя инстанцировать.
Модуль можно подмешать(mixed in) к классу или другому модулю.
Модуль не может наследовать ни от чего `module M3 < M1; end => SyntaxError ((irb):23: syntax error, unexpected '<')`

Class - это объединение для констант, методов, переменных класса и инстанса
Класс хранит уникальное состояния ля каждого инстанса в его инстанс переменных
Класс нельзя подмешать никуда
Класс может наследоваться от другого класса, но не от модуля.

### include vs extend; prepend
include - Добавляет инстансу методы модуля. Иерархия поиска: инстанс - модуль - родитель
extend - Добавляет методы модуля в качестве методов класса.
Если хочется добавить и туда и туда, то есть колбек included

prepend - Добавляет инстансу методы модуля как include, но меняет иерархию поиска методов: модуль - инстанс - родитель
