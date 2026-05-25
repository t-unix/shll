function mish
  set model "codellama:7b-instruct"
  set prime "Reply to my questions as briefly as possible. If possible even only with a command or some code that can be executed as is...Prompt:"
  set prompt (string join " " $prime $argv)
  #set command (curl -s http://localhost:11434/api/generate -d '{"model": "'$model'", "stream": false, "prompt": "'$prompt'"}' | jq -r .response | awk '/```/{flag=!flag; next} flag' | fzf)
  set command (curl -s http://localhost:11434/api/generate -d '{"model": "'$model'", "stream": false, "prompt": "'$prompt'"}' | jq -r .response | fzf)
  tmux send-keys "$command"
end
