require 'oauth_multipart_post'

CONSUMER_KEY       = 'YOUR_CONSUMER_KEY'
CONSUMER_SECRET    = 'YOUR_CONSUMER_SECRET'
OAUTH_TOKEN        = 'YOUR_OAUTH_TOKEN'
OAUTH_TOKEN_SECRET = 'YOUR_OAUTH_TOKEN_SECRET'

oamp = OAuthMultipartPost.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    OAUTH_TOKEN,
    OAUTH_TOKEN_SECRET
)

# tweet only
status = "test tweet #{rand(1000)}"
url    = 'http://api.twitter.com/1/statuses/update.json'
responce_body = oamp.post(url, {'status' => "#{status}"})

# tweet with a photo
image  = File.read('pie.jpg')
status = "test tweet with photo #{rand(1000)}"
url    = 'https://upload.twitter.com/1/statuses/update_with_media.json'
responce_body = oamp.post(url, {'status' => "#{status}", 'media[]' => image})
