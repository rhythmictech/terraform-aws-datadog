resource "datadog_logs_index" "main" {
  count = var.logs_manage_main_index ? 1 : 0

  name                                     = "main"
  retention_days                           = var.logs_main_index_retention_days
  daily_limit                              = var.logs_main_index_daily_limit
  daily_limit_warning_threshold_percentage = var.logs_main_index_daily_limit_warn_threshold
  disable_daily_limit                      = var.logs_main_index_daily_limit == null ? true : false

  daily_limit_reset {
    reset_time       = var.logs_main_index_daily_limit_reset_time
    reset_utc_offset = var.logs_main_index_daily_limit_reset_offset
  }

  filter {
    query = "*"
  }

  dynamic "exclusion_filter" {
    for_each = var.logs_main_index_exclusion_filters
    content {
      name       = exclusion_filter.value.name
      is_enabled = exclusion_filter.value.is_enabled
      filter {
        query       = exclusion_filter.value.filter.query
        sample_rate = exclusion_filter.value.filter.sample_rate
      }
    }
  }
}
