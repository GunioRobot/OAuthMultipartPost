require 'rubygems'
require 'hmac/sha1'
require 'base64'
require 'cgi'
require 'net/https'
require 'uri'

####################################################################
# author: johnny-miyake
# created: 2011/10/15
# last update: 2011/10/15
####################################################################

class OAuthMultipartPost

    def initialize (
        consumer_key,       # String
        consumer_secret,    # String
        oauth_token,        # String
        oauth_token_secret, # String
        signature_method    = 'HMAC-SHA1'
    )
    @consumer_key       = consumer_key
    @consumer_secret    = consumer_secret
    @oauth_token        = oauth_token
    @oauth_token_secret = oauth_token_secret
    @signature_method   = signature_method
    end

    def post (
        resource_url,  # String # APIのURL
        q_params       # Hash   # APIに渡す要求値
    )
    if q_params.class != Hash || q_params == {}
        raise "The second argument must be a hash that has one content at least."
    end

    uri       = URI.parse(resource_url)
    protocol = uri.scheme
    host     = uri.host
    time_stamp         = Time.new.to_i.to_s
    nonce              = "#{time_stamp}#{rand(100000000000)}"
    boundary           = "boundary#{nonce}"

    # OAuthに必要な要求値の設定
    # configure parameters for OAuth
    params = {
        'oauth_consumer_key'     => @consumer_key,
        'oauth_nonce'            => nonce,
        'oauth_signature_method' => @signature_method,
        'oauth_timestamp'        => time_stamp,
        'oauth_token'            => @oauth_token
    }

    # 署名のための鍵を作る
    # make a key for a signature
    key = "#{@consumer_secret}&#{@oauth_token_secret}"

        # 署名対象の文字列をつくる
        # make a string that is signed
        params_str = params.
        sort.
        map{|kv| "#{kv[0]}=#{kv[1]}"}.
    join('&')

    message = "POST&#{CGI.escape(resource_url)}&#{CGI.escape(params_str)}"

        # 署名する
        # make a signature
        digest = HMAC::SHA1.digest(key, message)
    digest_base64 = Base64.encode64(digest).chomp
    params['oauth_signature'] = CGI.escape(digest_base64)

    # ヘッダを作成する
    # make a header
    h_params_str = params.
        sort.
        map{|kv| "#{kv[0]}=#{kv[1]}"}.
    join(',')
    header = {
        'Host' => "#{host}",
        'Authorization' => "OAuth #{h_params_str}",
        'Content-Type' => "multipart/form-data; boundary=#{boundary}"
    }

    # 要求本体の記述
    # write request body
    data = ""
    q_params.each {|key, val|
        data << "--#{boundary}\r\n"
        data << "Content-Disposition: post-data; name=\"#{key}\"\r\n"
        data << "\r\n"
        data << "#{val}\r\n"
    }
    data << "--#{boundary}--"

    # APIサーバに要求を送信する
    # send a request to a API server
    case protocol
    when 'http':
        con = Net::HTTP.new("#{host}")
    when 'https':
        con = Net::HTTP.new("#{host}", '443')
        con.use_ssl = true
    else
        raise "Unknown protocol"
    end
    res = con.request_post("#{resource_url}", "#{data}", header)

    # 応答本体を返す
    # return the responce body of the response
    res.body
    end
end
