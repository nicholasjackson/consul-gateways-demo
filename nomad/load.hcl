job "load-system" {
    datacenters = ["google"]

    type = "system"

    update {
        max_parallel = 1
        min_healthy_time = "10s"
        healthy_deadline = "3m"
    }

    group "load" {
        count = 1

        constraint {
        operator  = "distinct_hosts"
        value     = "true"
        }

        task "httpperf" {
            driver = "docker"

            config {
                image = "quay.io/alaska/httperf"
                command = "httperf"
                args = [
                    "--server", "${attr.unique.network.ip-address}",
                    "--port", "9000",
                    "--timeout", "1",
                    "--num-conns", "100000",
                    "--rate", "100",
                ]
            }

            resources {
                cpu = 500
                memory = 256

                network {
                    mbits = 10
                }
            }
        }
    }
}