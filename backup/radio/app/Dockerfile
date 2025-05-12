FROM savonet/liquidsoap-alpine:97c7c56

WORKDIR /app

COPY --chown=liquidsoap:liquidsoap cert.pem .
COPY --chown=liquidsoap:liquidsoap cert_key.pem .
COPY --chown=liquidsoap:liquidsoap font/ ./font/
COPY --chown=liquidsoap:liquidsoap image/ ./image/
COPY --chown=liquidsoap:liquidsoap src/ ./src/

RUN chmod 600 cert.pem cert_key.pem

USER liquidsoap

CMD ["liquidsoap", "/app/src/main.liq"]