
variable "slack_token" {
  description = "Slack Bot OAuth Token (xoxb-...)"
  type        = string
  sensitive   = true
}


resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Alerts"
  type         = "email"

  labels = {
    email_address = local.email_alert
  }
}


resource "google_monitoring_notification_channel" "slack" {
  display_name = "Slack Alerts"
  type         = "slack"

  labels = {
    channel_name = local.slack_channel_name
  }

  sensitive_labels {
    auth_token = var.slack_token
  }
}



resource "google_logging_metric" "app_error_metric" {
  name   = "app_error_count"
  filter = <<EOT
    resource.type="cloud_run_revision"
    severity>=ERROR
    resource.labels.service_name="${local.service_name}"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}


resource "google_monitoring_alert_policy" "cpu_warn" {
  display_name          = "Cloud Run CPU higher than 70% (Warning)"
  combiner             = "OR"
  notification_channels = [google_monitoring_notification_channel.slack.id]

  conditions {
    display_name = "CPU > 70%"

    condition_threshold {
      filter = <<EOT
        metric.type="run.googleapis.com/container/cpu/utilizations"
        resource.type="cloud_run_revision"
        resource.labels.service_name="${local.service_name}"
        EOT
      comparison      = "COMPARISON_GT"
      threshold_value = 0.70
      duration        = "60s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN" 
      }
    }
  }
}



resource "google_monitoring_alert_policy" "cpu_crit" {
  display_name          = "Cloud Run CPU is higher than 80% (Critical)"
  combiner             = "OR"
  notification_channels = [google_monitoring_notification_channel.email.id]

  conditions {
    display_name = "CPU > 80%"

    condition_threshold {
      filter = <<EOT
        metric.type="run.googleapis.com/container/cpu/utilizations"
        resource.type="cloud_run_revision"
        resource.labels.service_name="${local.service_name}"
        EOT
      comparison      = "COMPARISON_GT"
      threshold_value = 0.80
      duration        = "60s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }
}

#test alert
resource "google_monitoring_alert_policy" "cpu_test" {
  display_name          = "Cloud Run CPU is higher than 80% (test)"
  combiner             = "OR"
  notification_channels = [google_monitoring_notification_channel.email.id,google_monitoring_notification_channel.slack.id]

  conditions {
    display_name = "CPU > 80%"

    condition_threshold {
      filter = <<EOT
        metric.type="run.googleapis.com/container/cpu/utilizations"
        resource.type="cloud_run_revision"
        resource.labels.service_name="${local.service_name}"
        EOT
      comparison      = "COMPARISON_GT"
      threshold_value = 0.080
      duration        = "60s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }
}