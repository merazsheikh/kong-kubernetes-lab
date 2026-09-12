local typedefs = require "kong.db.schema.typedefs"

return {
  name = "request-header-validator",

  fields = {
    {
      consumer = typedefs.no_consumer
    },

    {
      protocols = typedefs.protocols_http
    },

    {
      config = {
        type = "record",

        fields = {
          {
            header_name = {
              type = "string",
              required = true,
              default = "X-Client-ID",
            }
          },

          {
            status_code = {
              type = "integer",
              required = true,
              default = 400,
              between = { 400, 499 },
            }
          }
        }
      }
    }
  }
}
