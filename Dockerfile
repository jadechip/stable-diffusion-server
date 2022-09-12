FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /sd

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y libglib2.0-0 wget git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget -O ~/miniconda.sh -q --show-progress --progress=bar:force https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Install font for prompt matrix
COPY /data/DejaVuSans.ttf /usr/share/fonts/truetype/

EXPOSE 7860

COPY . /sd/

ENV ENV_NAME="ldm"
ENV ENV_FILE="/sd/environment.yaml"
ENV ENV_UPDATED=0
RUN export ENV_MODIFIED=$(date -r $ENV_FILE "+%s")

RUN if ! conda env list | grep ".*${ENV_NAME}.*" >/dev/null 2>&1; then \
        echo "Could not find conda env: ${ENV_NAME} ... creating ..."; \
        conda env create -f $ENV_FILE; \
        echo "source activate ${ENV_NAME}" > /root/.bashrc; \
        export ENV_UPDATED=1; \
    # elif [[ ! -z $CONDA_FORCE_UPDATE && $CONDA_FORCE_UPDATE == "true" ]] || (( $ENV_MODIFIED > $ENV_MODIFIED_CACHED )); then \
    #     echo "Updating conda env: ${ENV_NAME} ..."; \
    #     conda env update --file $ENV_FILE --prune; \
    #     export ENV_UPDATED=1; \
    fi;

SHELL ["conda", "run", "-n", "ldm", "/bin/bash", "-c"]

# Clear artifacts from conda after create/update
# @see https://docs.conda.io/projects/conda/en/latest/commands/clean.html
# RUN if (( $ENV_UPDATED > 0 )); then \
#         conda clean --all; \
#     fi;

RUN /sd/download-models.sh
# ENTRYPOINT /sd/start-server.sh

CMD [ "conda", "run", "-n", "ldm", "python", "-u", "server.py" ]
