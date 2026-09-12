FROM kong:3.9.3

USER root

COPY handler.lua \
  /usr/local/share/lua/5.1/kong/plugins/request-header-validator/handler.lua

COPY schema.lua \
  /usr/local/share/lua/5.1/kong/plugins/request-header-validator/schema.lua

RUN chown -R kong:kong \
  /usr/local/share/lua/5.1/kong/plugins/request-header-validator

ENV KONG_PLUGINS=bundled,request-header-validator

USER kong
