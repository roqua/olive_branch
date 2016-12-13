module OliveBranch
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      inflection = env["HTTP_X_KEY_INFLECTION"]

      if inflection && env["CONTENT_TYPE"] =~ /application\/json/
        underscore_params(env)
      end

      @app.call(env).tap do |_status, headers, response|
        if inflection && headers["Content-Type"] =~ /application\/json/
          response.each do |body|
            begin
              new_response = JSON.parse(body)
            rescue JSON::ParserError
              next
            end

            if inflection == "camel"
              new_response.deep_transform_keys! { |k| k.camelize(:lower) }
            elsif inflection == "dash"
              new_response.deep_transform_keys!(&:dasherize)
            end

            body.replace(new_response.to_json)
          end
        end
      end
    end

    def underscore_params(env)
      if Rails::VERSION::MAJOR < 5
        (env["action_dispatch.request.request_parameters"] || {}).deep_transform_keys!(&:underscore)
      else
        request_body = JSON.parse(env['rack.input'].read)
        request_body.deep_transform_keys!(&:underscore)
        req = StringIO.new(request_body.to_json)

        env['rack.input']     = req
        env['CONTENT_LENGTH'] = req.length
      end
    end
  end
end
