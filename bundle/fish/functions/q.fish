function api
  set request $argv[1]
  curl -s https://api.openai.com/v1/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{
    \"model\": \"text-davinci-003\",
    \"prompt\": \"$request\",
    \"temperature\": 0.9,
    \"max_tokens\": 2000,
    \"top_p\": 0.3,
    \"frequency_penalty\": 0.0,
    \"presence_penalty\": 0.6,
    \"stop\": [\" Human:\", \" AI:\"]
    }" 
end


function q
  set baseDir $HOME/.q
  set conversations $baseDir/conversations
  set editor nvim

  mkdir -p $conversations

  test -z "$OPENAI_API_KEY" && echo "No API key found in variable OPENAI_API_KEY" 1>&2 && return 1
  test -z "$argv" && echo "q <TEXT>|new|conversation" 1>&2 && return 1
  test "$argv[1]" = "new" && set -e q_conversationID && return 1

  test -z "$q_conversationID" && set -g q_conversationID (uuidgen)

  set q_conversationFile $conversations/$q_conversationID

  if test "$argv[1]" = "conversation"
    test -f "$q_conversationFile" && sed -r '/^$/d' $q_conversationFile
    return 1
  end

  # $editor -c 'normal G' -c "put='Human:  '" -c 'normal $' -c 'startinsert' $q_conversationFile
  printf "\nHuman: %s" (string join " " $argv) >> $q_conversationFile

  sed -i -r '/^$/d' $q_conversationFile
  set request (cat $q_conversationFile | string join '\n')
  set result (api "$request")
  set answer (echo "$result" | jq -r '.choices[].text ' | sed 's/\\n/\n/g')

  if test -n "$answer"
    printf "\n%s" $answer | tee -a "$q_conversationFile" | sed 's/\\n/\n/g'
  else
    echo "$result" 1>&2
    return 1
  end
end
