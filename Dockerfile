FROM golang:1.15 as build

WORKDIR /go/src/github.com/arnaudlemaignen/alertmanager2es-1

# Get deps (cached)
COPY ./go.mod /go/src/github.com/arnaudlemaignen/alertmanager2es-1
COPY ./go.sum /go/src/github.com/arnaudlemaignen/alertmanager2es-1
COPY ./Makefile /go/src/github.com/arnaudlemaignen/alertmanager2es-1
RUN make dependencies

# Compile
COPY ./ /go/src/github.com/arnaudlemaignen/alertmanager2es-1
RUN make test
RUN make lint
RUN make build
RUN ./alertmanager2es --help

#############################################
# FINAL IMAGE
#############################################
FROM quay.io/prometheus/busybox:latest
ENV LOG_JSON=1
COPY --from=build /go/src/github.com/arnaudlemaignen/alertmanager2es-1/alertmanager2es /
USER 1000
ENTRYPOINT ["/alertmanager2es"]
