import sub from require 'string'

--
-- escape given string for passing safely via EventSource transport
--
escape_for_eventsource1 = (str) ->
  s = ''
  for i = 1, #str
    c = sub str, i, i
    print('C', c, c == '\r')
    if c == '%'
      c = '%25'
    if c == '\0'
      c = '%00'
    if c == '\r'
      c = '%0A'
    if c == '\n'
      c = '%0D'
    s = s .. c
  print(str, '->', s)
  s

--
-- eventsource request handler
--
handler = (options, sid) =>
  @handle_balancer_cookie()
  -- N.B. Opera needs one more new line at the start
  @send 200, '\r\n', {
    ['Content-Type']: 'text/event-stream; charset=UTF-8'
    ['Cache-Control']: 'no-store, no-cache, must-revalidate, max-age=0'
  }, false
  -- upgrade response to session handler
  @protocol = 'eventsource'
  @curr_size, @max_size = 0, options.response_limit
  @send_frame = (payload, continue) =>
    @write_frame('data: ' .. payload .. '\r\n\r\n', continue)
  -- register session
  @create_session @req, self, sid, options
  return

return {

  GET: handler
}
