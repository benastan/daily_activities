require 'uri'

class Db < Thor  
  desc 'migrate ENV', 'migrate the database'
  def migrate(env = nil)
    env_key = [(env.upcase if env), 'DATABASE', 'URL'].compact.join('_')
    database_url = ENV[env_key]
    raise 'missing database url: %s' % env_key unless database_url
    uri = URI(database_url)
    db = uri.path[1..-1]
    uri.path = ''
    url = uri.to_s
    `psql #{url} -c "CREATE DATABASE #{db}"`
    `sequel -m ./migrate #{database_url}`
  end
end