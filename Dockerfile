FROM rocker/verse:4.1.0

ENV WORKON_HOME /opt/virtualenvs
ENV PYTHON_VENV_PATH $WORKON_HOME/mi_env

RUN apt-get update && apt-get install -y pngquant

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-dev \
        python3-venv \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

## Prepara environment de python
RUN python3 -m venv ${PYTHON_VENV_PATH}
RUN chown -R rstudio:rstudio ${WORKON_HOME}
ENV PATH ${PYTHON_VENV_PATH}/bin:${PATH}
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron && \
    echo "WORKON_HOME=${WORKON_HOME}" >> /usr/local/lib/R/etc/Renviron && \
    echo "RETICULATE_PYTHON_ENV=${PYTHON_VENV_PATH}" >> /usr/local/lib/R/etc/Renviron

## Because reticulate hardwires these PATHs
RUN ln -s ${PYTHON_VENV_PATH}/bin/pip /usr/local/bin/pip && \
    ln -s ${PYTHON_VENV_PATH}/bin/virtualenv /usr/local/bin/virtualenv
RUN chmod -R a+x ${PYTHON_VENV_PATH}

RUN .${PYTHON_VENV_PATH}/bin/activate && \
    pip install pyyaml Pillow requests numpy==1.19.2 \
    tensorflow==2.4.0 keras==2.4.0
  
RUN install2.r --error Rcpp
RUN install2.r --error tidymodels iml pdp
RUN install2.r --error \
    abind splines2 kableExtra gt\
    glmnet \
    ranger baguette rpart.plot\
    doParallel doFuture \
    kernlab \
    tsne irlba\
    kknn \
    ggrepel gganimate patchwork \
    imager

RUN install2.r reticulate tensorflow keras \
    xgboost quantreg

