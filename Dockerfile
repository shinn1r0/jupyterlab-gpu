ARG cuda_version="10.0"
FROM nvidia/cuda:${cuda_version}-base
LABEL maintainer="shinn1r0 <github@shinichironaito.com>"

ARG anaconda_version="miniconda3-latest"
ARG python_version="3.7.3"
ARG nodejs_version="12"
ARG cica_version="v4.1.2"

EXPOSE 8888
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
ENV PATH $PYENV_ROOT/shims:$PATH

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y

RUN apt-get install -y git
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc && eval "$(pyenv init -)"

RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

RUN pyenv install ${anaconda_version} && pyenv global ${anaconda_version}
RUN conda install -y python=${python_version}
RUN conda config --append channels conda-forge
RUN conda config --add channels pytorch

RUN conda install -y numpy scipy numba pandas dask matplotlib
RUN conda install -y scikit-learn scikit-image bokeh pillow pyspark xlrd sympy
RUN conda install -y ipython ipyparallel ipywidgets ipympl
RUN conda install -y jupyter jupyterlab nbdime nbconvert nbformat
RUN conda install -y beautifulsoup4 lxml jinja2 sphinx
RUN conda install -y isort pep8 autopep8 flake8 pyflakes pylint jedi tqdm
RUN conda install -y pytorch torchvision cudatoolkit=${cuda_version}
RUN conda update --all -y
RUN pip install -U pip setuptools pipenv
RUN pip install -U kaggle tensorflow-gpu==2.0.0-beta0 tb-nightly
RUN pip install -U jupyterlab_code_formatter jupyterlab-git jupyterlab_templates jupyterlab_latex jupyter-tensorboard

RUN curl -sL https://deb.nodesource.com/setup_${nodejs_version}.x | bash -
RUN apt-get install -y nodejs

RUN apt-get install curl unzip -y
RUN mkdir -p /usr/share/fonts/opentype/noto
RUN curl -O https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
RUN unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/opentype/noto
RUN rm NotoSansCJKjp-hinted.zip
RUN mkdir -p /usr/share/fonts/opentype/cica
RUN curl -LO https://github.com/miiton/Cica/releases/download/${cica_version}/Cica_${cica_version}.zip
RUN unzip Cica_${cica_version}.zip -d /usr/share/fonts/opentype/cica
RUN rm Cica_${cica_version}.zip
RUN apt-get install fontconfig
RUN fc-cache -f

RUN echo "\nfont.family: Noto Sans CJK JP" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \
  && rm -f ~/.cache/matplotlib/font*
RUN ipython profile create

COPY .jupyter ${HOME}/.jupyter
RUN cat ${HOME}/.ipython/profile_default/ipython_config.py | sed -e "s/#c.InteractiveShellApp.exec_lines = \[\]/c.InteractiveShellApp.exec_lines = \['%matplotlib widget'\]/g" | tee ${HOME}/.ipython/profile_default/ipython_config.py

RUN jupyter labextension install jupyterlab_vim
RUN jupyter labextension install @jupyterlab/git
RUN jupyter labextension install @lckr/jupyterlab_variableinspector
RUN jupyter labextension install @krassowski/jupyterlab_go_to_definition
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install jupyter-matplotlib
RUN jupyter labextension install jupyterlab_voyager
RUN jupyter labextension install jupyterlab-flake8
RUN jupyter labextension install @jupyterlab/toc
RUN jupyter labextension install @ryantam626/jupyterlab_code_formatter
RUN jupyter labextension install jupyterlab_tensorboard
RUN jupyter labextension install jupyterlab_templates
RUN jupyter labextension install @jupyterlab/latex
RUN jupyter labextension install @jupyterlab/katex-extension
RUN jupyter labextension install jupyterlab-drawio

RUN jupyter serverextension enable --py jupyterlab_git
RUN jupyter serverextension enable --py jupyterlab_code_formatter
RUN jupyter serverextension enable --py jupyterlab_templates
RUN nbdime extensions --enable
