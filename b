#!/bin/env python3

import logging
import sys
import uuid
from pathlib import Path

import hydra
from mtspark import kinit, get_spark
import mtspark
from omegaconf import DictConfig, OmegaConf
from onetl.connection import Postgres, Greenplum
from onetl.log import setup_logging

@hydra.main(config_path="../../conf", config_name="config")
def main(conf: DictConfig) -> None:
    setup_logging()
    
    config = {
        "appName": "my-app-for-etl-process",
        "spark.driver.memory": "32g",
        "spark.executor.memory": "32g",
        "spark.executor.instances": "40",
        "spark.executor.cores": "8",
        "spark.sql.shuffle.partitions": "200",
        "spark.sql.hive.metastorePartitionPruning": False,
        
        # Новые параметры для оптимизации
        "spark.driver.maxResultSize": "10g",
        "spark.network.timeout": "86400s",
        "spark.rpc.io.connectionTimeout": "86400s",
        "spark.rpc.askTimeout": "86400s",
        "spark.sql.broadcastTimeout": "86400s",
        "spark.sql.adaptive.enabled": "true",
        "spark.sql.adaptive.coalescePartitions.enabled": "true",
        "spark.sql.adaptive.skewJoin.enabled": "true"
    }
    
    spark = get_spark(
        config,
        cluster="my_hadoop_cluster",
        spark_version="3.5.0",
    )
    
    # Оптимизированный запрос с CTE
    main_query = """
    WITH base_data AS (
        SELECT 
            concat('7', Detect) as Detect,
            Expressionism, Statue, Unbeknownst, 
            Generosity, Overbooking, Prediction, 
            Realize, Erudite, Rotation
        FROM db1.table1
    ),
    matched_data AS (
        SELECT 
            b.*,
            m.Touchy as match_touchy
        FROM base_data b
        LEFT OUTER JOIN db2.table2 m ON b.Detect = m.Detect
    ),
    additional_data AS (
        SELECT 
            Touchy,
            FIRST_VALUE(Materialism) OVER (
                PARTITION BY Touchy 
                ORDER BY CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
            ) as Materialism,
            FIRST_VALUE(Winged) OVER (
                PARTITION BY Touchy 
                ORDER BY CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
            ) as Winged
        FROM db3.table3
        WHERE Materialism IN (1, 2, 3)
    )
    SELECT m.*, a.Materialism, a.Winged
    FROM matched_data m
    LEFT OUTER JOIN additional_data a 
    ON a.Touchy = m.match_touchy
    """
    
    def process_large_query(spark, output_path):
        try:
            logging.info("Starting query execution")
            result_df = spark.sql(main_query)
            
            count = result_df.count()
            logging.info(f"Query returned {count} rows")
            
            result_df.write \
                .option("header", "true") \
                .option("compression", "gzip") \
                .mode("overwrite") \
                .partitionBy("Rotation") \
                .csv(output_path)
            
            logging.info("Data export completed successfully")
        except Exception as e:
            logging.error(f"Error processing query: {e}")
            raise
    
    # Путь для сохранения результата
    output_path = "/catalog/.ivy2/output_data"
    process_large_query(spark, output_path)

if __name__ == "__main__":
    main()
