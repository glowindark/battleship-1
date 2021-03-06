module Exceptions
  class ClientError < StandardError; end
  class ServerError < StandardError; end

  # See status symbols at http://guides.rubyonrails.org/layouts_and_rendering.html#using-render

  class BadRequest < ClientError
    def status_symbol; :bad_request; end
  end

  class Forbidden < ClientError
    def status_symbol; :forbidden; end
  end

  class NotFound < ClientError
    def status_symbol; :not_found; end
  end

  class InternalServerError < ServerError
    def status_symbol; :internal_server_error; end
  end
end
