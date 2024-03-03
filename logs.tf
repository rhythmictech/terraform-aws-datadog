data "datadog_logs_indexes" "indexes" {}


resource "datadog_logs_index" "main" {
  name           = "main"
  retention_days = 15

  filter {
    query = "*"
  }
}

resource "datadog_monitor" "daily_log_volume" {
  count = var.daily_log_volume_enabled ? length(data.datadog_logs_indexes.indexes.logs_indexes) : 0

  name    = "Rolling 24h Log Usage Approaching Quota - ${data.datadog_logs_indexes.indexes.logs_indexes[count.index].name}"
  message = var.daily_log_volume_message
  type    = "log alert"

  query = "logs(\"*\").index(\"main\").rollup(\"count\").last(\"1d\") > ${data.datadog_logs_indexes.indexes.logs_indexes[count.index].daily_limit * var.daily_log_volume_alert_threshold}"

  monitor_thresholds {
    warning  = data.datadog_logs_indexes.indexes.logs_indexes[count.index].daily_limit * var.daily_log_volume_warn_threshold
    critical = data.datadog_logs_indexes.indexes.logs_indexes[count.index].daily_limit * var.daily_log_volume_alert_threshold
  }
}

resource "datadog_monitor" "anomalous_log_volume" {
  count = var.anomalous_log_volume_enabled ? 1 : 0

  name    = "Log Usage vs 7 Day Avg - ${data.datadog_logs_indexes.indexes.logs_indexes[count.index].name}"
  message = var.anomalous_log_volume_message
  type    = "query alert"

  query = "avg(last_2d):anomalies(sum:datadog.estimated_usage.logs.ingested_events{datadog_is_excluded:false} by {var.anomalous_log_volume_grouped_sources}.as_count(), 'agile', 2, direction='both', interval=600, alert_window='${var.anomalous_log_volume_alert_window}', count_default_zero='true', seasonality='daily') >= 1"

  monitor_thresholds {
    critical = 1
  }
}
