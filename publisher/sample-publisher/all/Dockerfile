ARG EMPIRIC_PUBLISHER_BASE_IMAGE_TAG=0.8.1
FROM 42labs/empiric-publisher:$EMPIRIC_PUBLISHER_BASE_IMAGE_TAG

COPY fetch-and-publish.py ./fetch-and-publish.py
CMD python fetch-and-publish.py
