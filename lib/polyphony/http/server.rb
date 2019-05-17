# frozen_string_literal: true

export :serve, :listener

Net   = import('../net')
HTTP1 = import('./http1')
HTTP2 = import('./http2')

ALPN_PROTOCOLS = %w[h2 http/1.1].freeze
H2_PROTOCOL = 'h2'

async def serve(host, port, opts = {}, &handler)
  opts[:alpn_protocols] = ALPN_PROTOCOLS
  server = Net.tcp_listen(host, port, opts)

  accept_loop(server, opts, handler)
end

def listener(host, port, opts = {}, &handler)
  opts[:alpn_protocols] = ALPN_PROTOCOLS
  server = Net.tcp_listen(host, port, opts)
  proc { accept_loop(server, opts, handler) }
end

def accept_loop(server, opts, handler)
  while true
    client = server.accept
    spawn client_task(client, opts, handler)
  end
rescue OpenSSL::SSL::SSLError
  retry # disregard
end

async def client_task(client, opts, handler)
  client.no_delay
  protocol_module(client).run(client, opts, handler)
end

def protocol_module(socket)
  use_http2 = socket.respond_to?(:alpn_protocol) &&
              socket.alpn_protocol == H2_PROTOCOL
  use_http2 ? HTTP2 : HTTP1
end
