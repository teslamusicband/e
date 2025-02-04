import os
from pyspark.sql.functions import coalesce

@hydra.main(config_path="../../conf", config_name="config")
def main(conf: DictConfig) -> None:
    setup_logging()
    
    config = {
        # ... ваши текущие настройки ...
        # Добавим настройки для локального вывода
        "spark.driver.host": "localhost",
        "spark.sql.warehouse.dir": "file:///tmp/spark-warehouse",
        "spark.local.dir": "/tmp/spark-temp"
    }
    
    spark = get_spark(
        config,
        cluster="my_hadoop_cluster",
        spark_version="3.5.0",
    )

    # Получаем данные и объединяем в один partition для записи в один файл
    df = spark.sql("select * from table1")
    
    # Путь для сохранения на локальной файловой системе
    local_path = "file:///path/to/your/local/directory/data.csv"
    
    # Вариант 1: Сохранение в один файл
    df.coalesce(1).write \
        .mode("overwrite") \
        .option("header", "true") \
        .option("compression", "gzip") \
        .csv(local_path)

    # ИЛИ Вариант 2: Сохранение частями
    BATCH_SIZE = 1000000
    
    # Получаем общее количество записей
    total_rows = df.count()
    
    # Создаем директорию если её нет
    os.makedirs("/path/to/your/local/directory", exist_ok=True)
    
    # Обрабатываем данные батчами
    for i in range(0, total_rows, BATCH_SIZE):
        df.limit(BATCH_SIZE).offset(i) \
          .toPandas() \
          .to_csv(f"/path/to/your/local/directory/data_part_{i}.csv.gz", 
                 compression='gzip',
                 index=False)
        print(f"Processed {min(i + BATCH_SIZE, total_rows)} of {total_rows} rows")

if __name__ == "__main__":
    main()
