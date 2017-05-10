ActionController::ForceSSL::ClassMethods.module_eval do
  def force_ssl(options = {})
    config = Rails.application.config
    return unless config.use_ssl

    host = options.delete(:host)
    port = config.ssl_port if config.respond_to?(:ssl_port) && config.ssl_port.present?

    before_filter(options) do
      unless request.ssl?
        redirect_options = {:protocol => 'https://', :status => :moved_permanently}
        redirect_options.merge!(:host => host) if host
        redirect_options.merge!(:port => port) if port
        redirect_options.merge!(:params => request.query_parameters)
        redirect_to redirect_options
      end
    end
  end
end
