local RequestHeaderValidator = {
  PRIORITY = 900,
  VERSION = "1.0.0",
}

function RequestHeaderValidator:access(conf)

  local header_value =
    kong.request.get_header(conf.header_name)

  if not header_value then
    return kong.response.exit(
      conf.status_code,
      {
        message = "Required request header is missing",
        header = conf.header_name
      }
    )
  end

  kong.service.request.set_header(
    "X-Header-Validated",
    "true"
  )
end

return RequestHeaderValidator
