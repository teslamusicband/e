import org.apache.kafka.clients.producer.{KafkaProducer, ProducerConfig, ProducerRecord}
import org.apache.kafka.common.serialization.StringSerializer
import com.typesafe.config.ConfigFactory

import java.util.Properties
import scala.io.Source
import scala.util.{Failure, Success, Try, Using}

object KafkaSSLProducer extends App {
  // Загрузка конфигурации
  val config = ConfigFactory.load()
  
  def createProducerProperties(): Properties = {
    val props = new Properties()
    
    // Основные настройки Kafka
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "your-kafka-broker:9093")
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, classOf[StringSerializer].getName)
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, classOf[StringSerializer].getName)
    
    // Настройки безопасности
    props.put("security.protocol", "SASL_SSL")
    props.put("sasl.mechanism", "SCRAM-SHA-256")
    
    // Путь к truststore (сертификат CA)
    props.put("ssl.truststore.location", "/path/to/kafka.truststore.jks")
    props.put("ssl.truststore.password", "truststore-password")
    
    // Настройка SASL для SCRAM
    val jaasTemplate = """
      |org.apache.kafka.common.security.scram.ScramLoginModule required
      |username="%s"
      |password="%s";
      |""".stripMargin
    val jaasConfig = String.format(jaasTemplate, "kafka-user", "kafka-password")
    props.put("sasl.jaas.config", jaasConfig)
    
    props
  }
  
  def sendToCsv(topic: String, csvPath: String): Unit = {
    val producer = new KafkaProducer[String, String](createProducerProperties())
    
    try {
      Using(Source.fromFile(csvPath)) { source =>
        source.getLines().drop(1) // Пропускаем заголовок
          .foreach { line =>
            val record = new ProducerRecord[String, String](topic, line)
            
            producer.send(record, (metadata, exception) => {
              Option(exception) match {
                case Some(e) => println(s"Error sending record: ${e.getMessage}")
                case None => println(s"Record sent to partition ${metadata.partition()} " +
                  s"with offset ${metadata.offset()}")
              }
            })
          }
      } match {
        case Success(_) => println("CSV processing completed successfully")
        case Failure(e) => println(s"Error processing CSV: ${e.getMessage}")
      }
    } finally {
      producer.flush()
      producer.close()
    }
  }
  
  // Пример использования
  val topic = "your-topic"
  val csvPath = "path/to/your/file.csv"
  sendToCsv(topic, csvPath)
}

// build.sbt
/*
name := "kafka-ssl-producer"
version := "1.0"
scalaVersion := "2.13.10"

libraryDependencies ++= Seq(
  "org.apache.kafka" % "kafka-clients" % "3.7.0",
  "com.typesafe" % "config" % "1.4.2",
  "ch.qos.logback" % "logback-classic" % "1.4.7"
)
*/
