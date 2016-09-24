require "devless_ruby/version"
require "http"

module DevlessRuby

  @token = nil
  @url = nil

  def self.token=(token); @token = token; end
  def self.url=(url); @url = url; end

  @origin = HTTP.headers('content-Type' => "application/json", "devless-token" => "6ffca01bd06aaeaa2af9d15a42fc1508")

  def self.query(service, table, params={})
    parameters = nil

    if params.size != 0
      params.each do |key, value|
        parameters = "&#{key}=#{value}#{parameters}"
      end
      base_url = "#{@url}/api/v1/service/#{service}/db?table=#{table}#{parameters}"
    else
      base_url = "#{@url}/api/v1/service/#{service}/db?table=#{table}"
    end

    res = @origin.get(base_url)

    return res.to_json
  end

  def self.create(service, table, data)
    res = nil
    base_url = "#{@url}/api/v1/service/#{service}/db"
    data.each do |object|
      payload = {:resource => [{:name => table, :field => [object]}]}

      res = @origin.post(base_url, :json => payload)
    end

    return res.to_json
  end

  def self.update(service, table, key, value, data)
    base_url = "#{@url}/api/v1/service/#{service}/db"
    payload = {:resource => [{:name => table, :params => [{:where => "#{key},#{value}", :data => [data]}]}]}
    res = @origin.patch(base_url, :json => payload)

    return res.to_json
  end

  def self.destroy(service, table, key, value)
    base_url = "#{@url}/api/v1/service/#{service}/db"
    payload = {:resource => [{:name => table, :params => [{:delete => true, :where => "#{key},#{value}"}]}]}
    res  = @origin.delete(base_url, :json => payload)

    return res.to_json
  end

  def self.method_call(service, method, params)
    base_url = "#{@url}/api/v1/service/#{service}/rpc?action=#{method}"
    get_id = rand(2000*1233)
    payload = {:jsonrpc => "2.0", :method => service, :id => get_id, :params => params}
    res = @origin.post(base_url, :json => payload)

    return res
  end

end
