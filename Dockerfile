FROM registry.baidubce.com/paddlepaddle/paddle:2.2.2-gpu-cuda10.2-cudnn7

ARG NB_USER="sagemaker-user"
ARG NB_UID="0"
ARG NB_GID="0"

# Setup the "sagemaker-user" user with root privileges.
RUN \
    apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    echo "${NB_USER}    ALL=(ALL)    NOPASSWD:    ALL" >> /etc/sudoers && \
    # Prevent apt-get cache from being persisted to this layer.
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID 

ENV LANG=en_US.utf8
ENV LANG=C.UTF-8

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"

RUN pip3 install --upgrade pip

## install paddlepaddle framework
RUN pip3 install paddlepaddle-gpu -i https://mirror.baidu.com/pypi/simple
RUN pip3 install paddleocr==2.0.1

## clone PaddleOCR source code 
RUN git clone -b release/2.1 https://github.com/PaddlePaddle/PaddleOCR.git /opt/program/


#download pretrained model for finetunine
RUN mkdir /opt/program/pretrain/
RUN cd /opt/program/pretrain/
RUN wget -P /opt/program/pretrain/ https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/ch_ppocr_mobile_v2.0_rec_train.tar && tar -xf /opt/program/pretrain/ch_ppocr_mobile_v2.0_rec_train.tar -C /opt/program/pretrain/ && rm -rf /opt/program/pretrain/ch_ppocr_mobile_v2.0_rec_train.tar

# Set up the program in the image
COPY paddle-training-code/* /opt/program/
WORKDIR /opt/program

ENTRYPOINT ["python3", "train.py"]



