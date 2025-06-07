terraform {
  cloud {
    organization = "mcafee-demo"

    workspaces {
      name = "mcafee"
    }
  }

  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.2.0"
    }
  }
}

locals {
  cloud  = "GCP"
  region = "us-east1"
  confluent_env = "Demo"
  cluster_name = "McAfee_SampleDemos"
  confluent_service_account = "mcafee-sa"
  sa_id = "sa-xqqmdwq"
  env_id="env-qrnj7m"
  cluster_id="lkc-dxokqo"
  compute_pool_id = "lfcp-rxrr89"
  organization_id="60ee8630-9a17-4256-9722-d3f3e3749f9f"
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# Deploy a Flink SQL statement to Confluent Cloud.
resource "confluent_flink_statement" "my_flink_statement" {
  organization {
    id = locals.organization_id
  }

  environment {
    id = locals.env_id
  }

  compute_pool {
    id = locals.compute_pool_id
  }

  principal {
    id = locals.sa_id
  }

  statement = <<EOT
    INSERT INTO
    `events_windowed`
SELECT
    CAST(UUID () AS BYTES) AS key,
    aff_id,
    FIRST_VALUE (metric_value) AS initial_value,
    LAST_VALUE (metric_value) AS lastest_value,
    window_start,
    window_end
FROM
    (
        SELECT
            *
        FROM
            TABLE (
                TUMBLE (
                    TABLE `Demo`.`McAfee_SampleDemos`.`events`,
                    DESCRIPTOR (ts_ltz),
                    INTERVAL '1' HOURS
                )
            )
        ORDER BY
            ts_ltz ASC
    )
GROUP BY
    aff_id,
    window_start,
    window_end;
    EOT

  properties = {
    "sql.current-catalog"  = locals.confluent_env
    "sql.current-database" = locals.cluster_name
  }

  rest_endpoint = flink.us-east1.gcp.confluent.cloud
  credentials {
    key    = var.flink_api_key
    secret = var.flink_api_secret
  }

}