
FROM quay.io/jupyter/scipy-notebook:latest

LABEL maintainer="CSCI461 Team" \
      description="SMS Spam Collection: data cleaning, text analysis, TF-IDF classification and K-Means"


COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt


RUN mkdir -p /home/jovyan/bd-a1/data \
             /home/jovyan/bd-a1/notebook \
             /home/jovyan/bd-a1/output/figures


WORKDIR /home/jovyan/bd-a1


COPY --chown=${NB_UID}:${NB_GID} data/dataset.csv            data/dataset.csv
COPY --chown=${NB_UID}:${NB_GID} notebook/analysis.ipynb     notebook/analysis.ipynb

EXPOSE 8888
