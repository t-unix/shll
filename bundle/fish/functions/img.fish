function img
  set -x query (string join " " $argv)
  curl https://api.openai.com/v1/images/generations -H 'Content-Type: application/json' -H "Authorization: Bearer $OPENAI_API_KEY" -d '{"prompt": "'$query'", "n": 1, "size": "1024x1024"}'
end
