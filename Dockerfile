FROM apache/airflow:2.3.3-python3.8

ARG WANT_NUMPY_VERSION=1.21.0
ARG WANT_SCIPY_VERSION=1.7.3

USER root

RUN apt-get update -y
RUN apt-get install \
    git \
    build-essential \
    gfortran \
    -y

USER airflow

RUN pip install --upgrade pip
RUN pip install mkl-devel
RUN pip uninstall numpy scipy -y

# Fix simplink to mkl_rt to let
RUN cd /home/airflow/.local/lib && \
    ln libmkl_rt.so.2 libmkl_rt.so

# Install NumPy
RUN curl -L https://github.com/numpy/numpy/releases/download/v${WANT_NUMPY_VERSION}/numpy-${WANT_NUMPY_VERSION}.tar.gz > numpy-${WANT_NUMPY_VERSION}.tar.gz && \
    tar xvf numpy-${WANT_NUMPY_VERSION}.tar.gz
COPY site.cfg ./numpy-${WANT_NUMPY_VERSION}
RUN export NPY_NUM_BUILD_JOBS=16 && \
    export NPY_BLAS_ORDER=MKL,ATLAS,blis,openblas && \
    export NPY_LAPACK_ORDER=MKL,ATLAS,openblas && \
    cd ./numpy-${WANT_NUMPY_VERSION} && pip install --verbose .

# Install SciPy
RUN curl -L https://github.com/scipy/scipy/releases/download/v${WANT_SCIPY_VERSION}/scipy-${WANT_SCIPY_VERSION}.tar.gz > scipy-${WANT_SCIPY_VERSION}.tar.gz && \
    tar xvf scipy-${WANT_SCIPY_VERSION}.tar.gz
COPY site.cfg ./scipy-${WANT_SCIPY_VERSION}
RUN export NPY_NUM_BUILD_JOBS=16 && \
    export NPY_BLAS_ORDER=MKL,ATLAS,blis,openblas && \
    export NPY_LAPACK_ORDER=MKL,ATLAS,openblas && \
    cd ./scipy-${WANT_SCIPY_VERSION} && pip install --verbose .

ENV LD_LIBRARY_PATH=/home/airflow/.local/lib:$LD_LIBRARY_PATH
RUN rm -rf ./numpy-${WANT_NUMPY_VERSION} numpy-${WANT_NUMPY_VERSION}.tar.gz
RUN rm -rf ./scipy-${WANT_SCIPY_VERSION} scipy-${WANT_SCIPY_VERSION}.tar.gz
