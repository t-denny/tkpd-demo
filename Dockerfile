# use onbuild go image from Dockerfile.onbuild
FROM dimaskiddo/tokpedia-workshop:onbuild as builder

# set base path
WORKDIR $GOPATH/src/github.com/tobapramudia/tkpd-demo

# copy project to workspace
COPY . ./

# get dependencies library & build the app
RUN go get -v \
    && go build -o tkpd-demo .

# use prebuild go image with indonesia timezone
FROM dimaskiddo/alpine:base

# set base path
WORKDIR /app

# copy assets from builder
COPY --from=builder /usr/src/app/github.com/tobapramudia/tkpd-demo/tkpd-demo ./
COPY --from=builder /usr/src/app/github.com/tobapramudia/tkpd-demo/docker-entrypoint.sh ./

# healthcheck
HEALTHCHECK --interval=5s --timeout=1s \
  CMD curl -H 'User-Agent: local_health_check' -f http://127.0.0.1:1323/ping || exit 1

## running as user (disable root on service)
USER user

## port listen
EXPOSE 1323

## add entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# exec service
CMD [ "/app/tkpd-demo" ]