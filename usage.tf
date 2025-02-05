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

  anomaly_usage_monitors   = var.enable_estimated_usage_detection ? { for k, v in local.merged_usage_config : k => v if v.anomaly_enabled } : {}
  estimated_usage_monitors = var.enable_estimated_usage_detection ? { for k, v in local.merged_usage_config : k => v if v.estimated_usage_enabled } : {}
}

resource "datadog_monitor" "anomaly_usage" {
  for_each = local.anomaly_usage_monitors

  name    = "Anomalous Datadog Usage Detected - ${local.metric_map[each.key]}"
  message = var.estimated_usage_anomaly_message
  type    = "query alert"

  query = "avg(${each.value.anomaly_span}):anomalies(avg:datadog.estimated_usage.${local.metric_map[each.key]}{${each.key == "logs_indexed" ? "datadog_is_excluded:false" : "*"}}, 'agile', ${each.value.anomaly_deviations}, direction='above', interval=${each.value.anomaly_rollup}, alert_window='${each.value.anomaly_window}', count_default_zero='true', seasonality='${each.value.anomaly_seasonality}') >= ${each.value.anomaly_threshold}"

  monitor_thresholds {
    critical = each.value.anomaly_threshold
  }

  renotify_interval = var.renotify_interval
  renotify_statuses = var.renotify_interval == null ? null : var.renotify_statuses
}

# the code for this is toxic. county things like hosts should probably be split from
# summy things like logs.
resource "datadog_monitor" "estimated_usage" {
  for_each = local.estimated_usage_monitors

  name    = "Estimated Datadog Usage Above Threshold - ${local.metric_map[each.key]}"
  message = var.estimated_usage_threshold_message
  type    = "query alert"

  query = <<END
    ${each.key == "hosts" ? "max" : "sum"}(${each.key == "hosts" ? each.value.estimated_usage_span : "current_1mo"}):datadog.estimated_usage.${local.metric_map[each.key]}{${each.key == "logs_indexed" ? "datadog_is_excluded:false" : "*"}} > ${each.value.estimated_usage_threshold}
  END

  scheduling_options {
    evaluation_window {
      hour_starts  = (each.value.estimated_usage_span == "current_1h") ? 0 : null
      day_starts   = (each.value.estimated_usage_span == "current_1mo" || each.value.estimated_usage_span == "current_1d") ? "00:00" : null
      month_starts = (each.value.estimated_usage_span == "current_1mo") ? 1 : null
    }
  }

  monitor_thresholds {
    critical = each.value.estimated_usage_threshold
  }

  renotify_interval = var.renotify_interval
  renotify_statuses = var.renotify_interval == null ? null : var.renotify_statuses
}

resource "datadog_monitor" "limit_exceeded" {
  count = var.log_limit_exceeded_message != null ? 1 : 0

  name         = "Daily Log Quota Warning Threshold Exceeded"
  include_tags = true
  message      = var.log_limit_exceeded_message
  query        = "events(\"source:datadog \"daily quota reached\"\").rollup(\"count\").last(\"15m\") >= 1"

  type = "event-v2 alert"

  monitor_thresholds {
    critical = 1
  }

  renotify_interval = var.renotify_interval
  renotify_statuses = var.renotify_interval == null ? null : var.renotify_statuses
}
