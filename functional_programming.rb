# Было простое
arr.select { |e| e > 2 && e < 4 }

# Попробуем select с лямбдами
arr = [1, 2, 3, 4]
f1 = ->(e) { e > 2 }
f2 = ->(e) { e < 4 }
arr.select { |e| f1.call(e) && f2.call(e) }
# => [3] - ожидаемое значение

# Теперь будем создавать лямбды методом
def add2chain(key, val)
  ->(e) { e.send(key, val) }
end
arr.select { |e| proc { true }.call && add2chain(:>, 2).call(e) && add2chain(:<, 4).call(e) }
# => [3] - ожидаемое значение

# Проверим что лямбды нормально вкладываются
f3 = ->(e) { proc { true }.call && add2chain(:>, 2).call(e) }
arr.select { |e| f3.call(e) && add2chain(:<, 4).call(e) }
# => [3] - ожидаемое значение

# А теперь создадим все это инжектом
arr = [1, 2, 3, 4]

params = { :> => 2, :< => 4 }
ff = params.each_pair.inject(proc { true }) { |acc, (k, v)| ->(e) { acc.call(e) && add2chain(k, v).call(e) } }
arr.select(&ff)
# => [3] - ожидаемое значение
