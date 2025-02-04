Анализируя ваши настройки, вижу несколько моментов, которые можно улучшить:

1. Отключенный metastorePartitionPruning (False) может быть критичным при работе со 150 млн записей:
```scala
"spark.sql.hive.metastorePartitionPruning": "true"
```
Это позволит Spark отфильтровывать ненужные партиции на уровне метаstore, что существенно уменьшит объем загружаемых данных.

2. Количество партиций (200) может быть недостаточным для такого объема данных:
```scala
"spark.sql.shuffle.partitions": "800"
```
Рекомендуемая формула: количество партиций = количество_ядер * количество_executor'ов * (2-3)
В вашем случае: 8 * 40 * 2.5 ≈ 800 партиций

3. Добавьте настройки для управления памятью:
```scala
"spark.memory.fraction": "0.8",
"spark.memory.storageFraction": "0.3",
"spark.executor.memoryOverhead": "8g"
```

4. Для больших данных рекомендуется настроить broadcast threshold:
```scala
"spark.sql.autoBroadcastJoinThreshold": "512m"
```

5. Добавьте настройки для оптимизации shuffle:
```scala
"spark.shuffle.file.buffer": "1m",
"spark.shuffle.unsafe.file.output.buffer": "1m",
"spark.shuffle.service.enabled": "true"
```

6. Для работы с большими таблицами полезно включить:
```scala
"spark.sql.inMemoryColumnarStorage.compressed": "true",
"spark.sql.inMemoryColumnarStorage.batchSize": "20000"
```

Также рекомендую:
1. Проверить план выполнения запроса через `explain(true)`, чтобы увидеть узкие места
2. Посмотреть Spark UI во время выполнения задачи - там можно увидеть проблемы с data skew или неэффективным shuffle
3. Проверить, как распределены данные по партициям в исходной таблице
4. Убедиться, что данные хранятся в оптимальном формате (например, Parquet с правильной схемой партиционирования)

Можете показать сам SQL-запрос или код? Это поможет дать более точные рекомендации по оптимизации.
