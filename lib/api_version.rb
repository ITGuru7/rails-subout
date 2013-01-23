class ApiVersion
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, response = @app.call(env)
    if headers["Content-Type"] =~ /application\/json/
      response.body = "{ \"payload\":#{response.body}, \"version\":#{SUBOUT_APP_VERSION}, \"deploy\":#{SUBOUT_DEPLOY_VERSION}}"
    end
    [status, headers, response]
  end
end
