load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

@test "home page is available" {
  run /bin/bash -c "curl -i -L localhost:8088"
  assert_output --partial "200 OK"
  assert_output --partial "<title>KuduLab</title>"
  assert_output --partial "Home"
  assert_output --partial "Projects"
  assert_output --partial "About"
  assert_equal "$status" 0
}
