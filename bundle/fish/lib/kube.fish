alias k 'kubectl'

function kn
  kubectl config set-context --current --namespace=(kubectl get ns -o json | jq -r ".items[].metadata.name" | fzf --prompt 'namespace> ')
end

function ksc 
  set -gx KUBECONFIG $HOME/.kube/config-(find ~/.kube/ -name "config-*" | string replace -r "^.*config-" "" | fzf --prompt 'cluster> ') && kubectl config set-context --current --namespace=""
end

function ks 
  set -gx KUBECONFIG $HOME/.kube/config-(find ~/.kube/ -name "config-*" | string replace -r "^.*config-" "" | fzf --prompt 'cluster> ')
end

function k8sh 
  if test -z $KUBECONFIG
    ks
  end
  if test -z $argv[1]
    set ns (kubectl get ns -o json | jq -r ".items[].metadata.name" | fzf --prompt 'namespace> ')
  else
    set ns $argv[1]
  end
  if test -z $ns
    return
  end
  set po (kubectl get po -n $ns -o json | jq -r '.items[] | select(.status.phase == "Running") | .metadata.name' | fzf --prompt 'pod> ')
  set containers (kubectl -n $ns get po $po -o json | jq -r '.status.containerStatuses[] | select(.started==true) | .name')
  if test (count $containers) -gt 1
    set container (string split " " $containers | fzf)
  else
    set container $containers
  end
  set command (kubectl -n $ns exec -it $po --container $container -- cat /etc/shells | rev | cut -f 1 -d / | rev | sort | uniq | tr -d \r | fzf)
  kubectl -n $ns exec -it $po --container $container -- $command
end

function knondockerhubimages
  if test -z $argv[1]
    echo usage: knondockerhubimages NAMESPACE
    exit
  else
    set ns $argv[1]
  end
  for image in (k -n $ns get po -o yaml | grep " image: " | sed 's/.*image: //' | sort | uniq)
    if string match -qr "\." (echo $image | cut -f 1 -d \/)
      echo $image
    end
  end
end
