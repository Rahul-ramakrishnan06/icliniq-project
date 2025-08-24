# variable "email_alert" {
#   description = "Email address for critical alerts"
#   type        = string
# }

# variable "chat_webhook_url" {
#   description = "Chat webhook URL for warning alerts"
#   type        = string
# }


# # MONITORING NOTIFICATION CHANNELS
# resource "google_monitoring_notification_channel" "email" {
#   display_name = "Email Alerts"
#   type         = "email"

#   labels = {
#     email_address = var.email_alert
#   }
# }

# resource "google_monitoring_notification_channel" "chat" {
#   display_name = "Chat Webhook"
#   type         = "webhook"

#   labels = {
#     url = var.chat_webhook_url
#   }
# }

# # LOG-BASED METRIC (Count Errors)
# resource "google_logging_metric" "app_error_metric" {
#   name   = "app_error_count"
#   filter = <<EOT
#     resource.type="cloud_run_revision"
#     severity>=ERROR
#     resource.labels.service_name="${local.service_name}"
# EOT

#   metric_descriptor {
#     metric_kind = "DELTA"
#     value_type  = "INT64"
#   }
# }

# # ALERT POLICY - CPU > 70% (Warning)
# resource "google_monitoring_alert_policy" "cpu_warn" {
#   display_name          = "Cloud Run CPU > 70% (Warning)"
#   combiner             = "OR"
#   notification_channels = [google_monitoring_notification_channel.chat.id]

#   conditions {
#     display_name = "CPU > 70%"

#     condition_threshold {
#       filter = <<EOT
#             metric.type="run.googleapis.com/container/cpu/utilizations"
#             resource.type="cloud_run_revision"
#             resource.labels.service_name="${local.service_name}"
#             EOT
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0.70
#       duration        = "60s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_MEAN"
#       }
#     }
#   }
# }


# # ALERT POLICY - CPU > 80% (Critical)

# resource "google_monitoring_alert_policy" "cpu_crit" {
#   display_name          = "Cloud Run CPU > 80% (Critical)"
#   combiner             = "OR"
#   notification_channels = [google_monitoring_notification_channel.email.id]

#   conditions {
#     display_name = "CPU > 80%"

#     condition_threshold {
#       filter = <<EOT
#         metric.type="run.googleapis.com/container/cpu/utilizations"
#         resource.type="cloud_run_revision"
#         resource.labels.service_name="${local.service_name}"
#         EOT
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0.80
#       duration        = "120s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_MEAN"
#       }
#     }
#   }
# }
