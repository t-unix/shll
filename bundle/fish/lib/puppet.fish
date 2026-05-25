set -gx PUPPET_CLUSTER_CONFIG ~/.kube/config-compute
set -gx PUPPET_CLUSTER_NS puppet

set -gx PUPPET_KUBECTL_CMD kubectl --kubeconfig $PUPPET_CLUSTER_CONFIG -n $PUPPET_CLUSTER_NS

function puppet_get_a_master_pod
  echo ($PUPPET_KUBECTL_CMD get po | grep chart-puppetserver | cut -f 1 -d " " | head -1)
end

function puppet_master_command
  $PUPPET_KUBECTL_CMD exec -it (puppet_get_a_master_pod) -- puppet $argv
end

function puppet_masterserver_command
  $PUPPET_KUBECTL_CMD exec -it (puppet_get_a_master_pod) -- puppetserver $argv
end

function puppet_master_shell
  $PUPPET_KUBECTL_CMD exec -it (puppet_get_a_master_pod) -- bash
end

alias pm=puppet_master_command
alias pmserver=puppet_masterserver_command
alias pmshell=puppet_master_shell

