resource "shoreline_notebook" "excessive_load_on_cassandra" {
  name       = "excessive_load_on_cassandra"
  data       = file("${path.module}/data/excessive_load_on_cassandra.json")
  depends_on = [shoreline_action.invoke_cassandra_diagnostic,shoreline_action.invoke_add_node_to_cassandra_cluster]
}

resource "shoreline_file" "cassandra_diagnostic" {
  name             = "cassandra_diagnostic"
  input_file       = "${path.module}/data/cassandra_diagnostic.sh"
  md5              = filemd5("${path.module}/data/cassandra_diagnostic.sh")
  description      = "Increased traffic on the application leading to a higher number of requests to the Cassandra database."
  destination_path = "/agent/scripts/cassandra_diagnostic.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "add_node_to_cassandra_cluster" {
  name             = "add_node_to_cassandra_cluster"
  input_file       = "${path.module}/data/add_node_to_cassandra_cluster.sh"
  md5              = filemd5("${path.module}/data/add_node_to_cassandra_cluster.sh")
  description      = "Scale up the Cassandra cluster by adding more nodes to handle the increased load."
  destination_path = "/agent/scripts/add_node_to_cassandra_cluster.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cassandra_diagnostic" {
  name        = "invoke_cassandra_diagnostic"
  description = "Increased traffic on the application leading to a higher number of requests to the Cassandra database."
  command     = "`chmod +x /agent/scripts/cassandra_diagnostic.sh && /agent/scripts/cassandra_diagnostic.sh`"
  params      = ["TABLE_NAME","KEYSPACE","KEYSPACE_NAME"]
  file_deps   = ["cassandra_diagnostic"]
  enabled     = true
  depends_on  = [shoreline_file.cassandra_diagnostic]
}

resource "shoreline_action" "invoke_add_node_to_cassandra_cluster" {
  name        = "invoke_add_node_to_cassandra_cluster"
  description = "Scale up the Cassandra cluster by adding more nodes to handle the increased load."
  command     = "`chmod +x /agent/scripts/add_node_to_cassandra_cluster.sh && /agent/scripts/add_node_to_cassandra_cluster.sh`"
  params      = ["CASSANDRA_NODE_IP","NEW_NODE_IP","DATACENTER_NAME","NEW_NODE_NAME"]
  file_deps   = ["add_node_to_cassandra_cluster"]
  enabled     = true
  depends_on  = [shoreline_file.add_node_to_cassandra_cluster]
}

