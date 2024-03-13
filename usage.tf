locals {
  metric_map = {
    "hosts"         = "hosts"
    "logs_indexed"  = "logs.ingested_events"
    "logs_ingested" = "logs.ingested_bytes"
  }

  merged_usage_config = {
    for k, v in var.estimated_usage_detection_default_config : k => (
      contains(keys(var.estimated_usage_detection_config), k) ? merge(v, var.estimated_usage_detection_config[k]) : v
    )
  }

  anomaly_usage_monitors  = var.enable_estimated_usage_detection ? { for k, v in local.merged_usage_config : k => v if v.anomaly_enabled } : {}
  forecast_usage_monitors = var.enable_estimated_usage_detection ? { for k, v in local.merged_usage_config : k => v if v.forecast_enabled } : {}
}

resource "datadog_monitor" "anomaly_usage" {
  for_each = local.anomaly_usage_monitors

  name    = "Anomalous Datadog Usage Detected - ${local.metric_map[each.key]}"
  message = var.estimated_usage_anomaly_message
  type    = "query alert"

  query = "avg(${each.value.anomaly_span}):anomalies(avg:datadog.estimated_usage.${local.metric_map[each.key]}{*}, 'agile', ${each.value.anomaly_deviations}, direction='above', interval=${each.value.anomaly_rollup}, alert_window='${each.value.anomaly_window}', count_default_zero='true', seasonality='${each.value.anomaly_seasonality}') >= ${each.value.anomaly_threshold}"

  monitor_thresholds {
    critical = each.value.anomaly_threshold
  }

}

resource "datadog_monitor" "forecast_usage" {
  for_each = local.forecast_usage_monitors

  name    = "Forecasted Datadog Usage Above Threshold - ${local.metric_map[each.key]}"
  message = var.estimated_usage_anomaly_message
  type    = "query alert"

  query = "max(next_1mo):forecast(sum:datadog.estimated_usage.${local.metric_map[each.key]}{*}.as_count().rollup(${each.value.forecast_rollup_type}, ${each.value.forecast_rollup_value}), 'seasonal', ${each.value.forecast_deviations}, interval='120m', seasonality='weekly') >= ${each.value.forecast_threshold}"

  monitor_thresholds {
    critical = each.value.forecast_threshold
  }

}
