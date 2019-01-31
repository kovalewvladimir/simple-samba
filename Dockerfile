FROM alpine

RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add samba && \
    touch /var/lib/samba/registry.tdb
COPY entrypoint.sh entrypoint.sh

EXPOSE 139 445

ENV ACCOUNT_NAME=user         \
    ACCOUNT_PASSWORD=pwd123   \
    SHARE_NAME=Share                        

ENTRYPOINT ["sh", "entrypoint.sh"]

CMD ["smbd -FS -d 2 --no-process-group"]
# Или 
# smbd -FS --no-process-group